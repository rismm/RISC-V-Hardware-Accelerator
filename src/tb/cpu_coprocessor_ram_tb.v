`timescale 1ns / 1ps
// Simple testbench for the cpu_coprocessor_ram block design
module cpu_coprocessor_ram_tb;

  // ---------------- Signals ----------------
  reg clk = 0;
  reg resetn = 0;

  // ---------------- Clock generation ----------------
  // 100 MHz clock (period = 10 ns)
  always #5 clk = ~clk;

  // ---------------- DUT instantiation ----------------
  cpu_coprocessor_ram uut (
    .clk    (clk),
    .resetn (resetn)
  );

  // ---------------- Stimulus ----------------
  initial begin
    $display("[%0t] Starting simulation...", $time);

    // Hold reset low for 100 ns
    resetn = 0;
    #100;
    resetn = 1;
    $display("[%0t] Reset released", $time);

    // Let it run for some time
    #5000;
    $display("[%0t] Simulation complete.", $time);
    $finish;
  end

endmodule
