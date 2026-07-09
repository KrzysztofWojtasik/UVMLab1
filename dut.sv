module dut (
    input  logic        clk,
    input  logic        nrst,

    input  logic        start,
    input  logic        read_man_id,
    input  logic        read_cfg_status,
    input  logic        read_eeprom,
    input  logic        write_eeprom,
    input  logic [15:0] mem_addr,
    input  logic [7:0]  write_data,
    output logic [7:0]  read_data,
    output logic [23:0] man_id,
    output logic [7:0]  cfg_status_hi,
    output logic [7:0]  cfg_status_lo,
    output logic        busy,
    output logic        done
);

    logic scl;
    tri1  sda;

    logic a1;
    logic a2;
    logic wp;

    assign a1 = 1'b0;
    assign a2 = 1'b0;
    assign wp = 1'b0;

    ctrl u_ctrl (
        .clk             (clk),
        .nrst            (nrst),
        .start           (start),
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
        .done            (done),
        .scl             (scl),
        .sda             (sda)
    );

    M24CSM01 u_eeprom (
        .A1    (a1),
        .A2    (a2),
        .WP    (wp),
        .SDA   (sda),
        .SCL   (scl),
        .RESET (~nrst)
    );

endmodule