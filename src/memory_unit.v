/**
 * Custom memory for CPU wrapper
 */

module memory_unit
    #(
    parameter           reset_pc = 32'h0000_0000)
    (
    input CLK,
    input wire [31:0]   i_wb_mem_adr,
    input wire [31:0]   i_wb_mem_data,
    input wire [3:0]    i_wb_mem_sel,
    input wire          i_wb_mem_we,
    input wire          i_wb_mem_stb,
    output wire [31:0]  o_wb_mem_rdt,
    output reg          o_wb_mem_ack
    );

    localparam IROM_BASE = reset_pc;
    localparam DMEM_BASE = 32'h0000_3000;
    
    localparam IROM_DEPTH = 9;
    localparam DMEM_DEPTH = 9;
    
    reg [31:0] IROM [0:2**(IROM_DEPTH - 2) - 1];
    reg [31:0] DMEM [0:2**(DMEM_DEPTH - 2) - 1];

    reg [31:0] data_out;
    
    wire [1:0] mem_ctrl;

    assign o_wb_mem_rdt[31:0] = data_out[31:0];    
    assign mem_ctrl = (i_wb_mem_adr[31:IROM_DEPTH] == IROM_BASE[31:IROM_DEPTH]) ? 2'b0 :
                      ((i_wb_mem_adr[31:DMEM_DEPTH] == DMEM_BASE[31:DMEM_DEPTH]) ? 2'b01 : 2'b10);
    
    initial begin
        $readmemh("IROM.mem", IROM);
        $readmemh("DMEM.mem", DMEM);
    end
    
    integer i;
    always @ (posedge CLK) begin
        o_wb_mem_ack <= 0;
        data_out <= 32'h0;
        if (i_wb_mem_stb) begin
            o_wb_mem_ack <= 1;
            case (mem_ctrl)
            2'b00: begin
                data_out <= (i_wb_mem_adr[1:0] == 2'b00) ? IROM[i_wb_mem_adr[IROM_DEPTH-1:2]] : 32'h0000_0013;
            end
            2'b01: begin
                if (i_wb_mem_we) begin
                    for (i = 0; i < 4; i = i + 1) begin
                        if (i_wb_mem_sel[i])
                            DMEM[i_wb_mem_adr[DMEM_DEPTH-1:2]][i*8 +: 8] <= i_wb_mem_data[i*8 +: 8];
                    end
                end
                else begin
                    for (i = 0; i < 4; i = i + 1) begin
                        if (i_wb_mem_sel[i])
                            data_out[i*8 +: 8] <= DMEM[i_wb_mem_adr[DMEM_DEPTH-1:2]][i*8 +: 8];
                    end 
                end
            end
            default: begin
                data_out <= 32'h0000_0013;
            end
            endcase
        end
        
    end

endmodule
