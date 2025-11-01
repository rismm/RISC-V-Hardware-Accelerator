`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for pcpi_matmul_test IP block
//////////////////////////////////////////////////////////////////////////////////

module pcpi_matmul_test_tb();

    // Clock and reset signals
    reg clk;
    reg rstn;
    
    // Output signals
    wire [31:0] debug_reg;
    wire [31:0] pcpi_rd_snoop;
    wire pcpi_wait_snoop;
    wire pcpi_ready_snoop;
    
    // Instantiate the DUT (Device Under Test)
    pcpi_matmul_test dut (
        .clk(clk),
        .rstn(rstn),
        .debug_reg(debug_reg),
        .pcpi_rd_snoop(pcpi_rd_snoop),
        .pcpi_wait_snoop(pcpi_wait_snoop),
        .pcpi_ready_snoop(pcpi_ready_snoop)
    );
    
    // Clock generation - 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        rstn = 0;
        
        // Apply reset for 20ns
        #20;
        rstn = 1;
        
        // Run for 1000ns total
        #980;
        
        // End simulation
        $display("Simulation completed at time %0t ns", $time);
        $finish;
    end
endmodule