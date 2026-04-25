module top;

    logic        clk;
    logic        nrst;

    logic        start;
    logic        rw;
    logic        read_man_id;
    logic        read_cfg_status;
    logic        read_eeprom;
    logic        write_eeprom;
    logic [15:0] mem_addr;
    logic [7:0]  write_data;

    logic [7:0]  read_data;
    logic [23:0] man_id;
    logic [7:0]  cfg_status_hi;
    logic [7:0]  cfg_status_lo;
    logic        busy;
    logic        done;

    tb_top u_tb (
        .clk             (clk),
        .nrst            (nrst),
        .start           (start),
        .rw              (rw),
        .read_man_id     (read_man_id),
        .read_cfg_status (read_cfg_status),
        .read_eeprom     (read_eeprom),
        .write_eeprom    (write_eeprom),
        .mem_addr        (mem_addr),
        .write_data      (write_data),
        .read_data       (read_data),
        .man_id          (man_id),
        .cfg_status_hi   (cfg_status_hi),
        .cfg_status_lo   (cfg_status_lo),
        .busy            (busy),
        .done            (done)
    );

    dut u_dut (
        .clk             (clk),
        .nrst            (nrst),
        .start           (start),
        .rw              (rw),
        .read_man_id     (read_man_id),
        .read_cfg_status (read_cfg_status),
        .read_eeprom     (read_eeprom),
        .write_eeprom    (write_eeprom),
        .mem_addr        (mem_addr),
        .write_data      (write_data),
        .read_data       (read_data),
        .man_id          (man_id),
        .cfg_status_hi   (cfg_status_hi),
        .cfg_status_lo   (cfg_status_lo),
        .busy            (busy),
        .done            (done)
    );

endmodule