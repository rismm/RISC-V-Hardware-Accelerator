`timescale 1ns / 1ps
module coprocessor (
    input  wire         clk,
    input  wire         resetn,

    input  wire         pcpi_valid,
    input  wire [31:0]  pcpi_insn,
    input  wire [31:0]  pcpi_rs1,
    input  wire [31:0]  pcpi_rs2,
    output reg          pcpi_wr,
    output reg  [31:0]  pcpi_rd,
    output reg          pcpi_wait,
    output reg          pcpi_ready,

    output wire         M_AXI_AWVALID,
    input  wire         M_AXI_AWREADY,
    output wire [31:0]  M_AXI_AWADDR,
    output wire [2:0]   M_AXI_AWPROT,
    output wire         M_AXI_WVALID,
    input  wire         M_AXI_WREADY,
    output wire [31:0]  M_AXI_WDATA,
    output wire [3:0]   M_AXI_WSTRB,
    input  wire         M_AXI_BVALID,
    output wire         M_AXI_BREADY,
    input  wire [1:0]   M_AXI_BRESP,
    output reg          M_AXI_ARVALID,
    input  wire         M_AXI_ARREADY,
    output reg  [31:0]  M_AXI_ARADDR,
    output wire [2:0]   M_AXI_ARPROT,
    input  wire         M_AXI_RVALID,
    output reg          M_AXI_RREADY,
    input  wire [31:0]  M_AXI_RDATA,
    input  wire [1:0]   M_AXI_RRESP
);

    initial begin
        $display("---------------------------------------------------------------------------------");
        $display("                      Coprocessor Sanity Check (0x0006)                          ");
        $display("---------------------------------------------------------------------------------");
    end

    localparam [6:0] OPC_CUSTOM0 = 7'h33;
    localparam [2:0] FUNCT3_MM   = 3'h0;
    localparam [6:0] FUNCT7_MM   = 7'h2A;

    wire is_matmul = pcpi_valid &&
                     (pcpi_insn[6:0]   == OPC_CUSTOM0) &&
                     (pcpi_insn[14:12] == FUNCT3_MM)   &&
                     (pcpi_insn[31:25] == FUNCT7_MM);

    reg [31:0] mat_A [0:3];
    reg [31:0] mat_B [0:3];
    reg [31:0] mat_C [0:3];
    reg [31:0] base_A, base_B, base_C;

    localparam IDLE=0, READA_ADDR=1, READA_DATA=2,
               READB_ADDR=3, READB_DATA=4, COMPUTE=5,
               WRITE_ADDR=6, WRITE_RESP=7, DONE_PULSE=8;
    reg [3:0] state, next_state;
    reg [1:0] idx, idx_next;

    reg        awvalid_r, wvalid_r;
    reg [31:0] awaddr_r,  wdata_r;
    reg        bready_r;
    reg        aw_done, w_done;

    assign M_AXI_AWVALID = awvalid_r;
    assign M_AXI_AWADDR  = awaddr_r;
    assign M_AXI_AWPROT  = 3'b000;
    assign M_AXI_WVALID  = wvalid_r;
    assign M_AXI_WDATA   = wdata_r;
    assign M_AXI_WSTRB   = 4'b1111;
    assign M_AXI_BREADY  = bready_r;
    assign M_AXI_ARPROT  = 3'b000;

    wire [31:0] c11 = mat_A[0]*mat_B[0] + mat_A[1]*mat_B[2];
    wire [31:0] c12 = mat_A[0]*mat_B[1] + mat_A[1]*mat_B[3];
    wire [31:0] c21 = mat_A[2]*mat_B[0] + mat_A[3]*mat_B[2];
    wire [31:0] c22 = mat_A[2]*mat_B[1] + mat_A[3]*mat_B[3];

    always @* begin
        next_state   = state;
        idx_next     = idx;
        M_AXI_ARVALID= 1'b0;
        M_AXI_ARADDR = 32'h0;
        M_AXI_RREADY = 1'b0;

        case (state)
            IDLE: if (is_matmul) begin next_state = READA_ADDR; idx_next = 0; end

            READA_ADDR: begin
                M_AXI_ARVALID = 1'b1;
                M_AXI_ARADDR  = base_A + { {28{1'b0}}, idx, 2'b00 };
                if (M_AXI_ARVALID && M_AXI_ARREADY) next_state = READA_DATA;
            end
            READA_DATA: if (M_AXI_RVALID) begin
                M_AXI_RREADY = 1'b1;
                next_state = (idx==3) ? READB_ADDR : READA_ADDR;
                idx_next   = (idx==3) ? 0 : idx + 1;
            end

            READB_ADDR: begin
                M_AXI_ARVALID = 1'b1;
                M_AXI_ARADDR  = base_B + { {28{1'b0}}, idx, 2'b00 };
                if (M_AXI_ARVALID && M_AXI_ARREADY) next_state = READB_DATA;
            end
            READB_DATA: if (M_AXI_RVALID) begin
                M_AXI_RREADY = 1'b1;
                next_state = (idx==3) ? COMPUTE : READB_ADDR;
                idx_next   = (idx==3) ? 0 : idx + 1;
            end

            COMPUTE: next_state = WRITE_ADDR;

            WRITE_ADDR: if (aw_done && w_done) next_state = WRITE_RESP;

            WRITE_RESP: if (M_AXI_BVALID) begin
                next_state = (idx == 3) ? DONE_PULSE : WRITE_ADDR;
                idx_next   = (idx == 3) ? 0 : idx + 1;
            end

            DONE_PULSE: next_state = IDLE;
        endcase
    end

    integer i;
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state<=IDLE; idx<=0;
            awvalid_r<=0; wvalid_r<=0; awaddr_r<=0; wdata_r<=0;
            aw_done<=0; w_done<=0; bready_r<=0;
            pcpi_wait<=0; pcpi_ready<=0; pcpi_wr<=0; pcpi_rd<=0;
            for(i=0;i<4;i=i+1) begin mat_A[i]<=0; mat_B[i]<=0; mat_C[i]<=0; end
        end else begin
            // State + index trace
            //$display("[%0t] STATE: %0d ? %0d, idx=%0d", $time, state, next_state, idx);

            state<=next_state; idx<=idx_next;
            pcpi_ready<=0; pcpi_wr<=0; pcpi_rd<=0;
            pcpi_wait <= (state!=IDLE || next_state!=IDLE);
            bready_r  <= (state == WRITE_RESP);

            if (state==IDLE && is_matmul) begin
                base_A  <= pcpi_rs1;
                base_B  <= pcpi_rs2;
                base_C  <= pcpi_rs1 + 32'h20;
                aw_done <= 0; w_done <= 0;
            end

            if (state==READA_DATA && M_AXI_RVALID) mat_A[idx] <= M_AXI_RDATA;
            if (state==READB_DATA && M_AXI_RVALID) mat_B[idx] <= M_AXI_RDATA;

            if (state==COMPUTE) begin
                mat_C[0]<=c11; mat_C[1]<=c12; mat_C[2]<=c21; mat_C[3]<=c22;
                awaddr_r <= base_C;
                wdata_r  <= c11;
                awvalid_r <= 1; wvalid_r <= 1;
                aw_done <= 0; w_done <= 0;

                //$display("[%0t] COMPUTE: mat_C = {%08h, %08h, %08h, %08h}",
                //          $time, c11, c12, c21, c22);
                //$display("[%0t] WRITE ARM (initial): addr=0x%08h data=0x%08h", $time, base_C, c11);
            end

            if (state==WRITE_ADDR) begin
                //$display("[%0t] WRITE_ADDR: awvalid=%b awready=%b wvalid=%b wready=%b",
                //          $time, awvalid_r, M_AXI_AWREADY, wvalid_r, M_AXI_WREADY);

                if (awvalid_r && M_AXI_AWREADY) begin
                    awvalid_r<=0; aw_done<=1;
                    //$display("[%0t] AW Handshake DONE", $time);
                end
                if (wvalid_r && M_AXI_WREADY) begin
                    wvalid_r <=0; w_done <=1;
                    //$display("[%0t] W  Handshake DONE", $time);
                end
            end

            if (state==WRITE_RESP && M_AXI_BVALID) begin
                //$display("[%0t] BVALID received, idx=%0d", $time, idx);
            end

            if (state==WRITE_RESP && next_state==WRITE_ADDR) begin
                awaddr_r  <= base_C + { {28{1'b0}}, (idx + 1), 2'b00 };
                wdata_r   <= mat_C[idx + 1];
                awvalid_r <= 1; wvalid_r <= 1;
                aw_done <= 0; w_done <= 0;

                //$display("[%0t] ARM NEXT BEAT: idx=%0d addr=0x%08h data=0x%08h",
                //          $time, idx+1, base_C + { {28{1'b0}}, (idx + 1), 2'b00 }, mat_C[idx + 1]);
            end

            if (state==DONE_PULSE) begin
                pcpi_ready <= 1;
                pcpi_wr    <= 1;
                pcpi_rd    <= 32'h0;
                //$display("[%0t] DONE_PULSE: Coprocessor completed matmul", $time);
            end
        end
    end
endmodule
