`timescale 1ns / 1ps

// pcpi_matmul.v - "matmul" custom instruction via PCPI (actually rs1+rs2)
module pcpi_matmul (
    input         clk,
    input         resetn,
    input         pcpi_valid,
    input  [31:0] pcpi_insn,
    input  [31:0] pcpi_rs1,
    input  [31:0] pcpi_rs2,
    output        pcpi_wr,
    output [31:0] pcpi_rd,
    output        pcpi_wait,
    output        pcpi_ready
);
    // Match our chosen encoding:
    // opcode = 0x33 (0110011), funct7 = 0x2A (0101010), funct3 = 000
    wire is_op     = pcpi_insn[6:0]   == 7'b0110011;
    wire is_f3_000 = pcpi_insn[14:12] == 3'b000;
    wire is_f7_2A  = pcpi_insn[31:25] == 7'b0101010;

    wire is_matmul = is_op && is_f3_000 && is_f7_2A;

    // Single-cycle, no stalling needed.
    assign pcpi_wait  = 1'b0;
    assign pcpi_ready = pcpi_valid && is_matmul;
    assign pcpi_wr    = pcpi_valid && is_matmul;
    assign pcpi_rd    = pcpi_rs1 + pcpi_rs2;  // placeholder "matmul"
endmodule

