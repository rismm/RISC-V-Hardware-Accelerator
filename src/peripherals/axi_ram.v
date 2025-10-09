`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Design Name: 
// Module Name: axi_ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: RAM unit with AXI4-lite slave interface, written specifically for the
//               purpose of this project
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_ram
    #(
        parameter WIDTH = 32,
        parameter IROM_DEPTH = 9,
        parameter DMEM_DEPTH = 9,
        parameter IROM_BASE = 32'h0000_0000,
        parameter DMEM_BASE = 32'h0000_2000,
        parameter MMIO_BASE = 32'h0000_7F00
    )
    (
        input CLK,
        output [31:0] debug_reg,
        
        // AXI4-Lite slave interface
        input S_AXI_AWVALID,
        output S_AXI_AWREADY,
        input [31:0] S_AXI_AWADDR,
        
        input S_AXI_WVALID,
        output S_AXI_WREADY,
        input [31:0] S_AXI_WDATA,
        input [3:0] S_AXI_WSTRB,
        
        output S_AXI_BVALID,
        input S_AXI_BREADY,

        input S_AXI_ARVALID,
        output S_AXI_ARREADY,
        input [31:0] S_AXI_ARADDR,
        
        output S_AXI_RVALID,
        input S_AXI_RREADY,
        output [31:0] S_AXI_RDATA
    );
    
    
    reg [WIDTH-1:0] IROM [0:2**(IROM_DEPTH-2) - 1];
    reg [WIDTH-1:0] DMEM [0:2**(DMEM_DEPTH-2) - 1];
    reg [WIDTH-1:0] MMIO_interface [0:31];
    reg [WIDTH-1:0] dump;
    
    assign debug_reg = MMIO_interface[0];
    
    wire [1:0] w_mem_ctrl;
    wire [1:0] r_mem_ctrl;

    assign w_mem_ctrl = (S_AXI_AWADDR[31:IROM_DEPTH] == IROM_BASE[31:IROM_DEPTH]) ? 2'b00 :
                        (S_AXI_AWADDR[31:DMEM_DEPTH] == DMEM_BASE[31:DMEM_DEPTH]) ? 2'b01 :
                        (S_AXI_AWADDR[31:5] == MMIO_BASE[31:5]) ? 2'b10 : 2'b11;
                        
    assign r_mem_ctrl = (S_AXI_ARADDR[31:IROM_DEPTH] == IROM_BASE[31:IROM_DEPTH]) ? 2'b00 :
                        (S_AXI_ARADDR[31:DMEM_DEPTH] == DMEM_BASE[31:DMEM_DEPTH]) ? 2'b01 :
                        (S_AXI_ARADDR[31:5] == MMIO_BASE[31:5]) ? 2'b10 : 2'b11;
    
//    assign mem_ctrl = ((wbm_adr[31:IROM_DEPTH] == IROM_BASE[31:IROM_DEPTH]) && mem_instr) ? 2'b00 :
//                      (wbm_adr[31:DMEM_DEPTH] == DMEM_BASE[31:DMEM_DEPTH]) ? 2'b01 : 2'b10;

    reg axi_awready;
//    reg [31:0] latch_waddr;
//    reg [31:0] latch_wdata;
//    reg [3:0] latch_wstrb;
    reg [31:0] rdata;
    
    reg axi_wready;
    
    reg axi_arready;
    
    reg axi_bvalid;
    reg axi_rvalid;

    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY = axi_wready;
    assign S_AXI_ARREADY = axi_arready;
    
    assign S_AXI_RVALID = axi_rvalid;
    assign S_AXI_BVALID = axi_bvalid;
    
    assign S_AXI_RDATA = rdata;
    
//    reg w_done;

    integer i;
    initial begin
        $readmemh("basic_tb_irom_compact.mem", IROM);
        $readmemh("basic_tb_dmem_compact.mem", DMEM);
        axi_rvalid = 0;
        axi_bvalid = 0;
        
        for (i = 0; i < 32; i = i + 1) begin
            MMIO_interface[i] = 0;
        end
        dump = 0;
    end

    always @ (posedge CLK) begin
        
        axi_awready <= 0;
        axi_wready <= 0;
        axi_arready <= 0;
        
        if (axi_rvalid && S_AXI_RREADY) axi_rvalid <= 0;
        if (axi_bvalid && S_AXI_BREADY) axi_bvalid <= 0;
        
        if (S_AXI_AWVALID && S_AXI_WVALID && !axi_bvalid) begin
            axi_awready <= 1;
            axi_wready <= 1;
            
            case (w_mem_ctrl)
            2'b00: begin
                $display("Write to IROM");
            end
            2'b01: begin
                if (S_AXI_WSTRB[0]) DMEM[S_AXI_AWADDR[DMEM_DEPTH-1:2]][7:0] <= S_AXI_WDATA[7:0];
                if (S_AXI_WSTRB[1]) DMEM[S_AXI_AWADDR[DMEM_DEPTH-1:2]][15:8] <= S_AXI_WDATA[15:8];
                if (S_AXI_WSTRB[2]) DMEM[S_AXI_AWADDR[DMEM_DEPTH-1:2]][23:16] <= S_AXI_WDATA[23:16];
                if (S_AXI_WSTRB[3]) DMEM[S_AXI_AWADDR[DMEM_DEPTH-1:2]][31:24] <= S_AXI_WDATA[31:24];
            end
            2'b10: begin
                if (S_AXI_WSTRB[0]) MMIO_interface[S_AXI_AWADDR[4:2]][7:0] <= S_AXI_WDATA[7:0];
                if (S_AXI_WSTRB[1]) MMIO_interface[S_AXI_AWADDR[4:2]][15:8] <= S_AXI_WDATA[15:8];
                if (S_AXI_WSTRB[2]) MMIO_interface[S_AXI_AWADDR[4:2]][23:16] <= S_AXI_WDATA[23:16];
                if (S_AXI_WSTRB[3]) MMIO_interface[S_AXI_AWADDR[4:2]][31:24] <= S_AXI_WDATA[31:24];
            end
            2'b11: dump <= S_AXI_WDATA;
            endcase
            
            axi_bvalid <= 1;
        end
        if (S_AXI_ARVALID && !axi_rvalid) begin
            axi_arready <= 1;
            
            case (r_mem_ctrl)
            2'b00: rdata <= IROM[S_AXI_ARADDR[IROM_DEPTH-1:2]];
            2'b01: rdata <= DMEM[S_AXI_ARADDR[DMEM_DEPTH-1:2]];
            2'b10: rdata <= MMIO_interface[S_AXI_ARADDR[4:2]];
            2'b11: rdata <= dump;
            endcase
            
            axi_rvalid <= 1;
        end
    end
    
endmodule
