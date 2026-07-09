import uvm_pkg::*;
`include "uvm_macros.svh"
import mem_ops_pkg::*;

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

        `uvm_info("EEPROM_WRITE", $sformatf("EEPROM WRITE ADDR = 0x%04h, DATA = 0x%02h, busy = %0b, time = %0t",
                mem_addr, write_data, busy, $time),UVM_LOW)

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

        `uvm_info("EEPROM_READ", $sformatf("EEPROM READ ADDR = 0x%04h, DATA = 0x%02h, EXPECTED = 0x%02h, busy = %0b, time = %0t",
              mem_addr, read_data, expected, busy, $time),UVM_LOW)

        if (read_data !== expected) begin
            `uvm_fatal("EEPROM_MISMATCH",$sformatf("EEPROM data mismatch: addr = 0x%04h, expected = 0x%02h, got = 0x%02h",
              mem_addr, expected, read_data))
        end else begin
            `uvm_info("EEPROM_CHECK",  $sformatf("EEPROM data correct: addr = 0x%04h, data = 0x%02h",
              mem_addr, read_data),UVM_LOW)
        end

        read_eeprom = 1'b0;

        #10000ns;
    end
    endtask


    initial begin

        int i;
        logic [15:0] rand_addr;
        logic [7:0]  rand_data;
        logic [7:0]  expected_data;
        localparam int NUM_RANDOM_TESTS = 20;
        mem_op_t current_op;

        `uvm_info("HELLO", "Hello World from UVM", UVM_MEDIUM)

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

        current_op = OP_READ_ID;
        `uvm_info("TEST_OP", $sformatf("Starting operation: %s", current_op.name()), UVM_MEDIUM)

        `uvm_info("MAN_ID", $sformatf("Manufacturer ID = 0x%06h, last read_data = 0x%02h, busy = %0b, time = %0t",
              man_id, read_data, busy, $time),UVM_LOW)
        #10000ns;

        if (man_id !== 24'h00d0d0) begin
            `uvm_error("MAN_ID_CHECK", $sformatf("Unexpected Manufacturer ID: expected = 0x00d0d0, got = 0x%06h", man_id)) 
        end else begin
            `uvm_info("MAN_ID_CHECK", $sformatf("Manufacturer ID correct: 0x%06h", man_id), UVM_LOW)
        end

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

        current_op = OP_READ_STATUS;
        `uvm_info("TEST_OP", $sformatf("Starting operation: %s", current_op.name()), UVM_MEDIUM)

        `uvm_info("CFG_STATUS",
        $sformatf("CFG_STATUS_HI = 0x%02h, CFG_STATUS_LO = 0x%02h, ECS = %0b, EWPM = %0b, LOCK = %0b, SWP = 0x%02h, Last read_data = 0x%02h, busy = %0b, time = %0t",
              cfg_status_hi,
              cfg_status_lo,
              cfg_status_hi[7],
              cfg_status_hi[1],
              cfg_status_hi[0],
              cfg_status_lo,
              read_data,
              busy,
              $time),
        UVM_LOW)

        if (cfg_status_hi !== 8'h00 || cfg_status_lo !== 8'h00) begin
            `uvm_error("CFG_STATUS_CHECK",$sformatf("Unexpected CFG status: expected HI = 0x00, LO = 0x00, got HI = 0x%02h, LO = 0x%02h",
              cfg_status_hi,
              cfg_status_lo))
        end else begin
            `uvm_info("CFG_STATUS_CHECK","CFG status correct: HI = 0x00, LO = 0x00",UVM_LOW)
        end

        #10000ns;

        for (i = 0; i < NUM_RANDOM_TESTS; i = i + 1) begin
            rand_addr = $urandom_range(16'hFFFF, 16'h0000);
            rand_data = $urandom_range(8'hFF, 8'h00);

            `uvm_info("RANDOM_TEST", $sformatf("RANDOM EEPROM TEST %0d / %0d, ADDR = 0x%04h, DATA = 0x%02h",
              i + 1, NUM_RANDOM_TESTS, rand_addr, rand_data),UVM_MEDIUM)

            current_op = OP_WRITE_EEPROM;
            `uvm_info("TEST_OP", $sformatf("Starting operation: %s", current_op.name()), UVM_MEDIUM)
            do_eeprom_write(rand_addr, rand_data);

            current_op = OP_READ_EEPROM;
            `uvm_info("TEST_OP", $sformatf("Starting operation: %s", current_op.name()), UVM_MEDIUM)
            do_eeprom_read(rand_addr, rand_data);
        end

        #10000ns;
        $finish;
    end

endmodule