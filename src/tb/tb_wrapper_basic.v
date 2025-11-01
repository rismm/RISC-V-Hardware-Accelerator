`timescale 1ns / 1ps
/**
 * tb for basic CPU instructions. Just making CPU works as intended
 */

module tb_wrapper_basic #(
        parameter reset_pc = 32'h0000_0000
    )
    (
    );
    
    reg clk = 0;
    reg rst = 0;

    wire [31:0] MMIO_mem;
    reg [31:0] exp_out [0:7];
    
    reg [31:0] prev_mem;
    
    
    // wrapper dut (.clk(clk), .rst(rst), .mmio_o(MMIO_mem));
    design_2_copy dut (.clk(clk), .rstn(rst), .debug_reg(MMIO_mem));
    
    integer test_count = 0;
	integer pass_count = 0;
	integer fail_count = 0;
	
	always #5 clk = ~clk;
	
	integer i = 0;
	always @ (posedge clk) begin
	   prev_mem <= MMIO_mem;
	   if (prev_mem != MMIO_mem) begin
	       test_count <= test_count + 1;
	       if (MMIO_mem == exp_out[test_count]) begin
                pass_count <= pass_count + 1;
                $display("[%0t] PASS: Test #%0d", $time, test_count);
            end
            else begin
                fail_count <= fail_count + 1;
                $display("[%0t] FAIL: Test #%0d, Expected MMIO_mem=0x%08X, Got=0x%08X", 
                    $time, test_count, exp_out[test_count], MMIO_mem);
            end
	   end
	   
	end
	
	initial begin
	    $readmemh("exp_out_basic_tb.mem", exp_out);
//	    rst = 1; #100; rst = 0;
	    rst = 0; #100; rst = 1;
	   
        
        #5000;
        $display("\n[%0t] === FINAL TEST SUMMARY ===", $time);
		$display("Total Tests: %0d", test_count);
		$display("Passed: %0d", pass_count);
		$display("Failed: %0d", fail_count);
		if (test_count > 0) begin
			$display("Pass Rate: %0.1f%%", (pass_count * 100.0) / test_count);
			if (fail_count == 0) begin
				$display("*** ALL TESTS PASSED! ***");
			end else begin
				$display("*** %0d TESTS FAILED ***", fail_count);
			end
		end else begin
			$display("*** NO TESTS EXECUTED ***");
		end
		$display("=============================\n");
		
		$finish;
	
	end
    
endmodule
