`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2025 07:13:35 PM
// Design Name: 
// Module Name: tb_pcipi_mul_core_mem_readwrite
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


module tb_pcipi_mul_core_mem_readwrite();
    // parameters must match DUT or be overridden at instantiation
    localparam READ_BASE  = 32'h0000_2000;
    localparam WRITE_BASE = 32'h0000_3000;
    localparam COUNT      = 4;

    // clock / reset
    reg clk = 0;
    reg rst = 1;

    always #5 clk = ~clk; // 100 MHz

    // DUT AXI interface (driven by TB as slave)
    wire       M_AXI_ARVALID;
    reg        M_AXI_ARREADY = 0;
    wire [31:0] M_AXI_ARADDR;
    wire [2:0] M_AXI_ARPROT;
    reg        M_AXI_RVALID = 0;
    wire       M_AXI_RREADY;
    reg [31:0] M_AXI_RDATA = 0;

    wire       M_AXI_AWVALID;
    reg        M_AXI_AWREADY = 0;
    wire [31:0] M_AXI_AWADDR;
    wire [2:0] M_AXI_AWPROT;
    wire       M_AXI_WVALID;
    reg        M_AXI_WREADY = 0;
    wire [31:0] M_AXI_WDATA;
    wire [3:0]  M_AXI_WSTRB;
    reg        M_AXI_BVALID = 0;
    reg [0:0]  M_AXI_BRESP  = 0;
    wire       M_AXI_BREADY;
    

    // Instantiate DUT
    pcpi_mul_core #(
        .READ_BASE(READ_BASE),
        .WRITE_BASE(WRITE_BASE),
        .COUNT(COUNT)
    ) dut (
        .clk(clk),
        .rst(rst),

        // AR
        .M_AXI_ARVALID(M_AXI_ARVALID),
        .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_ARADDR(M_AXI_ARADDR),
        .M_AXI_ARPROT(M_AXI_ARPROT),
        // R
        .M_AXI_RVALID(M_AXI_RVALID),
        .M_AXI_RREADY(M_AXI_RREADY),
        .M_AXI_RDATA(M_AXI_RDATA),

        // AW
        .M_AXI_AWVALID(M_AXI_AWVALID),
        .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_AWADDR(M_AXI_AWADDR),
        .M_AXI_AWPROT(M_AXI_AWPROT),
        // W
        .M_AXI_WVALID(M_AXI_WVALID),
        .M_AXI_WREADY(M_AXI_WREADY),
        .M_AXI_WDATA(M_AXI_WDATA),
        .M_AXI_WSTRB(M_AXI_WSTRB),
        // B
        .M_AXI_BVALID(M_AXI_BVALID),
        .M_AXI_BRESP(M_AXI_BRESP),
        .M_AXI_BREADY(M_AXI_BREADY),
        
    );

    // test data
    reg [31:0] test_data [0:COUNT-1];
    integer i;

    initial begin
        // simple vector
        test_data[0] = 32'h0000_0001;
        test_data[1] = 32'h0000_0002;
        test_data[2] = 32'h0000_0003;
        test_data[3] = 32'h0000_0004;

        // reset
        rst = 1;
        M_AXI_ARREADY = 0;
        M_AXI_RVALID  = 0;
        M_AXI_AWREADY = 0;
        M_AXI_WREADY  = 0;
        M_AXI_BVALID  = 0;
        #25;
        rst = 0;
        #20;

        $display("[%0t] TB: start sequence", $time);

        // perform COUNT sequential read cycles by pulsing internal start_read and setting internal address
        for (i = 0; i < COUNT; i = i + 1) begin
            // set internal read address inside DUT (hierarchical access)
            // NOTE: hierarchical access is simulator-only
            dut.axi_araddr = READ_BASE + i*4;
            // pulse internal start_read
            dut.start_read = 1'b1;
            #10;
            dut.start_read = 1'b0;

            // wait until DUT asserts ARVALID
            wait (M_AXI_ARVALID == 1);
            $display("[%0t] TB: ARVALID observed for read %0d, ARADDR=0x%08h", $time, i, M_AXI_ARADDR);

            // respond with ARREADY next cycle
            #10;
            M_AXI_ARREADY = 1'b1;
            #10;
            M_AXI_ARREADY = 1'b0;

            // present read data (RVALID) one cycle later
            M_AXI_RDATA = test_data[i];
            M_AXI_RVALID = 1'b1;
            @(posedge clk);
            // DUT should assert RREADY; sample handshake
            if (M_AXI_RREADY) begin
                $display("[%0t] TB: RREADY seen, RDATA=0x%08h accepted", $time, M_AXI_RDATA);
            end else begin
                $display("[%0t] TB: WARNING RREADY not asserted by DUT", $time);
            end
            // deassert RVALID
            M_AXI_RVALID = 1'b0;
            @(posedge clk);
        end

        // Now perform the write (result write)
        // Give DUT the address and data to write via internal regs (hierarchical)
        dut.axi_awaddr = WRITE_BASE;
        dut.axi_wdata  = 32'hDEAD_BEEF;
        // pulse start_write for a cycle
        dut.start_write = 1'b1;
        #10;
        dut.start_write = 1'b0;

        // wait for AWVALID and WVALID
        wait (M_AXI_AWVALID == 1 && M_AXI_WVALID == 1);
        $display("[%0t] TB: AWVALID and WVALID observed, AWADDR=0x%08h WDATA=0x%08h", $time, M_AXI_AWADDR, M_AXI_WDATA);

        // accept AW and W next cycle
        #10;
        M_AXI_AWREADY = 1'b1;
        M_AXI_WREADY  = 1'b1;
        #10;
        M_AXI_AWREADY = 1'b0;
        M_AXI_WREADY  = 1'b0;

        // provide write response BVALID next cycle
        #10;
        M_AXI_BRESP  = 1'b0; // OKAY
        M_AXI_BVALID = 1'b1;
        #10;
        if (M_AXI_BREADY) $display("[%0t] TB: BREADY seen from DUT, write response accepted", $time);
        #10;
        M_AXI_BVALID = 1'b0;

        $display("[%0t] TB: sequence complete - finishing", $time);
        #20;
        $finish;
    end

    // monitor signals for visibility
    always @(posedge clk) begin
        if (M_AXI_ARVALID) $display("[%0t] TB MON: DUT asserted ARVALID addr=0x%08h", $time, M_AXI_ARADDR);
        if (M_AXI_RVALID)  $display("[%0t] TB MON: (slave) RVALID set data=0x%08h", $time, M_AXI_RDATA);
        if (M_AXI_AWVALID) $display("[%0t] TB MON: DUT asserted AWVALID addr=0x%08h", $time, M_AXI_AWADDR);
        if (M_AXI_WVALID)  $display("[%0t] TB MON: DUT asserted WVALID data=0x%08h", $time, M_AXI_WDATA);
        if (M_AXI_BVALID)  $display("[%0t] TB MON: (slave) BVALID set resp=%0d", $time, M_AXI_BRESP);
    end

endmodule