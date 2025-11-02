`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2025 03:08:07 AM
// Design Name: 
// Module Name: pcpi_mul_core
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


module pcpi_mul_core
    #(
    parameter READ_BASE = 32'h0000_2000,
    parameter WRITE_BASE = 32'h0000_3000,
    parameter COUNT = 4 // number of 32-bit words to read
    )   
    (
    input wire clk,
    input wire rst,


    // AXI4-lite master memory interface
    // Address read
	output      M_AXI_ARVALID,
	input       M_AXI_ARREADY,
	output      [31:0] M_AXI_ARADDR,
	output wire [2:0] M_AXI_ARPROT,
    // Read data
	input       M_AXI_RVALID,
	output      M_AXI_RREADY,
	input       [31:0] M_AXI_RDATA,
    // input       [1:0] M_AXI_RRESP,

    // Address write
	output      M_AXI_AWVALID,
	input       M_AXI_AWREADY,
	output      [31:0] M_AXI_AWADDR,
	output wire [2:0] M_AXI_AWPROT,
    // Write data
	output      M_AXI_WVALID,
	input       M_AXI_WREADY,
	output      [31:0] M_AXI_WDATA,
	output wire [3:0] M_AXI_WSTRB,
    // Write response
	input       M_AXI_BVALID,
    input       M_AXI_BRESP,
	output      M_AXI_BREADY
    );

    // CAPITALS resevered for external signals, internal signals are in lower case
    // Link external outputs to internal registers
    // Address read
    reg axi_arvalid;
    reg [31:0] axi_araddr;
    assign M_AXI_ARVALID = axi_arvalid;
    assign M_AXI_ARADDR = axi_araddr;
    assign M_AXI_ARPROT = 3'b000;
    // Read data
    reg axi_rready;
    assign M_AXI_RREADY = axi_rready;

    // Address write
    reg axi_awvalid;
    reg [31:0] axi_awaddr;
    assign M_AXI_AWVALID = axi_awvalid;
    assign M_AXI_AWADDR = axi_awaddr;
    assign M_AXI_AWPROT = 3'b000;
    // Write data
    reg axi_wvalid;
    reg [31:0] axi_wdata;
    reg [3:0] axi_wstrb;
    assign M_AXI_WVALID = axi_wvalid;
    assign M_AXI_WDATA = axi_wdata;
    assign M_AXI_WSTRB = axi_wstrb;
    // Write response
    reg axi_bready;
    assign M_AXI_BREADY = axi_bready;

    // Wires for AXI Read/Write state
    wire write_done = axi_bready & M_AXI_BVALID;
    wire read_done = axi_rready & M_AXI_RVALID;

    // Control Registers (set in state machine)
    reg start_read = 1'b0;
    reg start_write = 1'b0;

    // Interfaces for each AXI Channel
    // Address read
    always @(posedge clk) begin
        if (rst) begin
            axi_arvalid <= 1'b0;
        end
        else begin
            if (start_read) begin
                axi_arvalid <= 1'b1;
            end
            else if (M_AXI_ARREADY & axi_arvalid) begin
                axi_arvalid <= 1'b0;
            end 
        end
    end
    // Read data
    always @(posedge clk) begin
        if (rst) begin
            axi_rready <= 1'b0;
        end
        else begin
            axi_rready <= 1'b1; // always ready to accept data
        end
    end

    // Address write
    always @(posedge clk) begin
        if (rst) begin
            axi_awvalid <= 1'b0;
        end
        else begin
            if (start_write) begin
                axi_awvalid <= 1'b1;
            end
            else if (M_AXI_AWREADY & axi_awvalid) begin
                axi_awvalid <= 1'b0;
            end 
        end
    end
    // Write data
    always @(posedge clk) begin
        if (rst) begin
            axi_wvalid <= 1'b0;
            axi_wstrb <= 4'b0000;
        end
        else begin
            if (start_write) begin
                axi_wvalid <= 1'b1;
                axi_wstrb <= 4'b1111; // all bytes valid
            end
            // hold high until ready is asserted
            else if (M_AXI_WREADY & axi_wvalid) begin
                axi_wvalid <= 1'b0;
                axi_wstrb <= 4'b0000;
            end 
        end
    end
    // Write response
    always @(posedge clk) begin
        if (rst) begin
            axi_bready <= 1'b0;
        end
        else begin
            axi_bready <= 1'b1; // always ready to accept write response
        end
    end

endmodule
