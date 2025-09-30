`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2025 18:09:38
// Design Name: 
// Module Name: wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wrapper
    #(
        parameter reset_pc = 32'h0040_0000
    )
    (
        input clk,
        input rst,
        output [31:0] mmio_o
    );
    
    localparam IROM_BASE = reset_pc;
    localparam DMEM_BASE = 32'h1001_0000;
    
    localparam IROM_DEPTH = 9;
    localparam DMEM_DEPTH = 9;
    
    reg [31:0] IROM [0:2**(IROM_DEPTH - 2) - 1];
    reg [31:0] DMEM [0:2**(DMEM_DEPTH - 2) - 1];
    reg [31:0] MMIO_tmp;
    
    assign mmio_o = MMIO_tmp;
    
    initial begin
        $readmemh("IROM.mem", IROM);
        $readmemh("DMEM.mem", DMEM);
    end
    
    wire [31:0] wbm_adr;
    wire [31:0] wbm_dat_write;
    wire [31:0] wbm_dat_read;
    wire wbm_we;
    wire [3:0] wbm_sel;
    wire wbm_stb;
    reg wbm_ack;
    wire wbm_cyc;
    
    wire mem_instr;
    
    wire [1:0] mem_ctrl;

    assign mem_ctrl = ((wbm_adr[31:IROM_DEPTH] == IROM_BASE[31:IROM_DEPTH]) && mem_instr) ? 2'b00 :
                      (wbm_adr[31:DMEM_DEPTH] == DMEM_BASE[31:DMEM_DEPTH]) ? 2'b01 : 2'b10;
    
    reg [31:0] data_read;
    assign wbm_dat_read = data_read;
    
    integer i;
    always @ (posedge clk) begin
        wbm_ack <= 0;
        if (wbm_stb && wbm_cyc) begin
            wbm_ack <= 1;
            case (mem_ctrl)
            2'b00: begin
                data_read <= (wbm_adr[1:0] == 2'b00) ? IROM[wbm_adr[IROM_DEPTH-1:2]] : 32'h0000_0013;
            end
            2'b01: begin
                if (wbm_we) begin
                    for (i = 0; i < 4; i = i + 1) begin
                        if (wbm_sel[i])
                            DMEM[wbm_adr[DMEM_DEPTH-1:2]][i*8 +: 8] <= wbm_dat_write[i*8 +: 8];
                    end
                end
                else begin
                    data_read <= DMEM[wbm_adr[DMEM_DEPTH-1:2]];
                end
            end
            default: begin
                if (wbm_we) begin
                    for (i = 0; i < 4; i = i + 1) begin
                        if (wbm_sel[i])
                            MMIO_tmp[i*8 +: 8] <= wbm_dat_write[i*8 +: 8];
                    end
                end
                else begin
                    data_read <= MMIO_tmp;
                end
            end
            endcase
        end
    end
    
    picorv32_wb #(
        .PROGADDR_RESET(reset_pc)
    ) cpu (
        .wb_rst_i(rst),
        .wb_clk_i(clk),
        .wbm_adr_o(wbm_adr),
        .wbm_dat_o(wbm_dat_write),
        .wbm_dat_i(wbm_dat_read),
        .wbm_we_o(wbm_we),
        .wbm_sel_o(wbm_sel),
        .wbm_stb_o(wbm_stb),
        .wbm_ack_i(wbm_ack),
        .wbm_cyc_o(wbm_cyc),
        .mem_instr(mem_instr)
    );
    
endmodule
