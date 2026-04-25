module tb_top (
    output logic        clk,
    output logic        nrst,

    output logic        start,
    output logic        read_man_id,
    output logic        read_cfg_status,
    output logic        read_eeprom,
    output logic        write_eeprom,
    output logic [15:0] mem_addr,
    output logic [7:0]  write_data,

    input  logic [7:0]  read_data,
    input  logic [23:0] man_id,
    input  logic [7:0]  cfg_status_hi,
    input  logic [7:0]  cfg_status_lo,
    input  logic        busy,
    input  logic        done
);

    initial begin
        clk = 1'b0;
        forever #300ns clk = ~clk;
    end

    task automatic do_eeprom_write(
    input logic [15:0] addr,
    input logic [7:0]  data
    );
    begin
        mem_addr        = addr;
        write_data      = data;

        read_man_id     = 1'b0;
        read_cfg_status = 1'b0;
        read_eeprom     = 1'b0;
        write_eeprom    = 1'b1;

        #1000ns;
        start = 1'b1;
        #10000ns;
        start = 1'b0;

        wait(done == 1'b1);
        #10000ns;

        $display("========================================");
        $display("EEPROM WRITE ADDR = 0x%04h", mem_addr);
        $display("EEPROM WRITE DATA = 0x%02h", write_data);
        $display("busy              = %0b", busy);
        $display("time              = %0t", $time);
        $display("========================================");

        write_eeprom = 1'b0;

        // tWC modelu EEPROM
        #10000000ns;
    end
    endtask

    task automatic do_eeprom_read(
    input  logic [15:0] addr,
    input  logic [7:0]  expected
    );
    begin
        mem_addr        = addr;

        read_man_id     = 1'b0;
        read_cfg_status = 1'b0;
        read_eeprom     = 1'b1;
        write_eeprom    = 1'b0;

        #1000ns;
        start = 1'b1;
        #10000ns;
        start = 1'b0;

        wait(done == 1'b1);
        #10000ns;

        $display("========================================");
        $display("EEPROM READ ADDR  = 0x%04h", mem_addr);
        $display("EEPROM READ DATA  = 0x%02h", read_data);
        $display("EXPECTED DATA     = 0x%02h", expected);
        $display("busy              = %0b", busy);
        $display("time              = %0t", $time);

        if (read_data !== expected) begin
            $display("[ERROR] EEPROM data mismatch!");
            $display("        addr     = 0x%04h", mem_addr);
            $display("        expected = 0x%02h", expected);
            $display("        got      = 0x%02h", read_data);
            $fatal;
        end else begin
            $display("[OK] EEPROM data correct");
        end

        $display("========================================");

        read_eeprom = 1'b0;

        #10000ns;
    end
    endtask


    initial begin

        int i;
        logic [16:0] rand_addr;
        logic [7:0]  rand_data;
        logic [7:0]  expected_data;
        localparam int NUM_RANDOM_TESTS = 20;

        nrst            = 1'b0;
        start           = 1'b0;
        read_man_id     = 1'b0;
        read_cfg_status = 1'b0;
        read_eeprom     = 1'b0;
        write_eeprom    = 1'b0;
        mem_addr        = 16'h0000;
        write_data      = 8'h00;

        #10000ns;
        nrst = 1'b1;
        #10000ns;

        // 1. Manufacturer ID
        read_man_id     = 1'b1;
        read_cfg_status = 1'b0;
        read_eeprom     = 1'b0;
        write_eeprom    = 1'b0;
        start           = 1'b1;
        #10000ns;
        start           = 1'b0;

        wait(done == 1'b1);
        #10000ns;

        $display("========================================");
        $display("Manufacturer ID = 0x%06h", man_id);
        $display("Last read_data  = 0x%02h", read_data);
        $display("busy            = %0b", busy);
        $display("time            = %0t", $time);
        $display("========================================");

        #10000ns;

        // 2. Config / Status
        read_man_id     = 1'b0;
        read_cfg_status = 1'b1;
        read_eeprom     = 1'b0;
        write_eeprom    = 1'b0;
        start           = 1'b1;
        #10000ns;
        start           = 1'b0;

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

        for (i = 0; i < NUM_RANDOM_TESTS; i = i + 1) begin
            rand_addr = $urandom_range(16'hFFFF, 16'h0000);
            rand_data = $urandom_range(8'hFF, 8'h00);

            $display("========================================");
            $display("RANDOM EEPROM TEST %0d / %0d", i + 1, NUM_RANDOM_TESTS);
            $display("ADDR = 0x%04h, DATA = 0x%02h", rand_addr, rand_data);
            $display("========================================");

            do_eeprom_write(rand_addr, rand_data);
            do_eeprom_read(rand_addr, rand_data);
        end

        #10000ns;
        $finish;
    end

endmodule