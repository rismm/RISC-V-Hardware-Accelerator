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
    (
        input CLK,
        input RESETN,
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
        output [1:0] S_AXI_BRESP,
        input S_AXI_ARVALID,
        output S_AXI_ARREADY,
        input [31:0] S_AXI_ARADDR,
        output S_AXI_RVALID,
        input S_AXI_RREADY,
        output [31:0] S_AXI_RDATA,
        output [1:0] S_AXI_RRESP
    );
endmodule
