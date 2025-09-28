/**
 * Top level module for overall hardware accelerator
 * To be synthesized and implemented on the Nexys 4 FPGA
 */

module Top_wrapper
  #(
    parameter	    width = 1,
    parameter	    reset_pc = 32'h00000000,
    parameter	    rf_width = 2*width,
    parameter [0:0] with_csr = 1'b0,
    parameter	    regs = 32+with_csr*4,
    parameter	    rf_l2d = $clog2(regs*32/rf_width))
   (
    input CLK,
    input RESET,
    input [15:0] DIP,
    output [15:0] LED
    );
    
    // Memory bus wires
    wire [31:0] wb_mem_adr;
    wire [31:0] wb_mem_dat;
    wire [3:0]  wb_mem_sel;
    wire        wb_mem_we;
    wire        wb_mem_stb;
    wire [31:0] wb_mem_rdt;
    wire        wb_mem_ack;
    
    // Extension unit interface wires (data bus)
    wire [31:0] wb_ext_adr;
    wire [31:0] wb_ext_dat;
    wire [3:0]  wb_ext_sel;
    wire        wb_ext_we;
    wire        wb_ext_stb;
    wire [31:0] wb_ext_rdt;
    wire        wb_ext_ack;
    
    // RF memory wires (used as SRAM)
    wire [rf_l2d-1:0]   rf_waddr;
    wire [rf_width-1:0] rf_wdata;
    wire		        rf_wen;
    wire [rf_l2d-1:0]   rf_raddr;
    wire [rf_width-1:0] rf_rdata;
    wire		        rf_ren;
    
    // CPU
    servile #(
        .width          (width),
        .reset_pc       (reset_pc),
        .with_csr       (with_csr))
    cpu_wrapper (
        .i_clk          (CLK),
        .i_rst          (RESET),
        .i_timer_irq    (0),
        .o_wb_mem_adr   (wb_mem_adr),
        .o_wb_mem_dat   (wb_mem_dat),
        .o_wb_mem_sel   (wb_mem_sel),
        .o_wb_mem_we    (wb_mem_we),
        .o_wb_mem_stb   (wb_mem_stb),
        .i_wb_mem_rdt   (wb_mem_rdt),
        .i_wb_mem_ack   (wb_mem_ack),
        .o_wb_ext_adr   (wb_ext_adr),
        .o_wb_ext_dat   (wb_ext_dat),
        .o_wb_ext_sel   (wb_ext_sel),
        .o_wb_ext_we    (wb_ext_we),
        .o_wb_ext_stb   (wb_ext_stb),
        .i_wb_ext_rdt   (wb_ext_rdt),
        .o_wb_ext_ack   (wb_ext_ack),
        .o_rf_waddr     (rf_waddr),
        .o_rf_wdata     (rf_wdata),
        .o_rf_wen       (rf_wen),
        .o_rf_raddr     (rf_raddr),
        .i_rf_rdata     (rf_rdata),
        .o_rf_ren       (rf_ren));
    
    // MEM
    memory_unit #(
        .reset_pc   (reset_pc))
    mem (
        .CLK            (CLK),
        .i_wb_mem_adr   (wb_mem_adr),
        .i_wb_mem_data  (wb_mem_dat),
        .i_wb_mem_sel   (wb_mem_sel),
        .i_wb_mem_we    (wb_mem_we),
        .i_wb_mem_stb   (wb_mem_stb),
        .o_wb_mem_rdt   (wb_mem_rdt),
        .o_wb_mem_ack   (wb_mem_ack));
    
    // RF
    serv_rf_ram #(
        .width      (rf_width),
        .csr_regs   (0))
    RF (
        .i_clk      (CLK),
        .i_waddr    (rf_waddr),
        .i_wdata    (rf_wdata),
        .i_wen      (rf_wen),
        .i_raddr    (rf_raddr),
        .i_ren      (rf_ren),
        .o_rdata    (rf_rdata));
        
    
    
endmodule
