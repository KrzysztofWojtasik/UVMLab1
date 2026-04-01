
module tb_top (
    output logic        clk,
    output logic        nrst,

    output logic        start,
    output logic        rw,
    output logic        read_man_id,
    output logic        read_cfg_status,
    output logic [15:0] mem_addr,
    output logic [7:0]  write_data,

    input  logic [7:0]  read_data,
    input  logic [23:0] man_id,
    input  logic [7:0]  cfg_status_hi,
    input  logic [7:0]  cfg_status_lo,
    input  logic        busy,
    input  logic        done
);

    // generator zegara
    initial begin
        clk = 1'b0;
        forever #300ns clk = ~clk;
    end

    initial begin
        nrst            = 1'b0;
        start           = 1'b0;
        rw              = 1'b0;
        read_man_id     = 1'b0;
        read_cfg_status = 1'b0;
        mem_addr        = 16'h0000;
        write_data      = 8'h00;

        // reset
        #10000ns;
        nrst = 1'b1;

        #10000ns;

        // ========================================
        // 1. Odczyt Manufacturer ID
        // ========================================
        read_man_id     = 1'b1;
        read_cfg_status = 1'b0;
        start           = 1'b1;

        #10000ns;
        start = 1'b0;

        wait(done == 1'b1);
        #10000ns;

        $display("========================================");
        $display("Manufacturer ID = 0x%06h", man_id);
        $display("Last read_data  = 0x%02h", read_data);
        $display("busy            = %0b", busy);
        $display("time            = %0t", $time);
        $display("========================================");

        #10000ns;

        // ========================================
        // 2. Odczyt Configuration / Status
        // ========================================
        read_man_id     = 1'b0;
        read_cfg_status = 1'b1;
        start           = 1'b1;

        #10000ns;
        start = 1'b0;

        wait(done == 1'b1);
        #10000ns;

        $display("========================================");
        $display("CFG_STATUS_HI   = 0x%02h", cfg_status_hi);
        $display("CFG_STATUS_LO   = 0x%02h", cfg_status_lo);
        $display("ECS             = %0b", cfg_status_hi[7]);
        $display("EWPM            = %0b", cfg_status_hi[1]);
        $display("LOCK            = %0b", cfg_status_hi[0]);
        $display("SWP             = 0x%02h", cfg_status_lo);
        $display("Last read_data  = 0x%02h", read_data);
        $display("busy            = %0b", busy);
        $display("time            = %0t", $time);
        $display("========================================");

        #10000ns;
        $finish;
    end

endmodule