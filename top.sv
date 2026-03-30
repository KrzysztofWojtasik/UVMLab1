
module top;

    logic        clk;
    logic        nrst;

    logic        start;
    logic        rw;
    logic        read_man_id;
    logic [15:0] mem_addr;
    logic [7:0]  write_data;

    logic [7:0]  read_data;
    logic [23:0] man_id;
    logic        busy;
    logic        done;

    tb_top u_tb (
        .clk         (clk),
        .nrst        (nrst),
        .start       (start),
        .rw          (rw),
        .read_man_id (read_man_id),
        .mem_addr    (mem_addr),
        .write_data  (write_data),
        .read_data   (read_data),
        .man_id      (man_id),
        .busy        (busy),
        .done        (done)
    );

    dut u_dut (
        .clk         (clk),
        .nrst        (nrst),
        .start       (start),
        .rw          (rw),
        .read_man_id (read_man_id),
        .mem_addr    (mem_addr),
        .write_data  (write_data),
        .read_data   (read_data),
        .man_id      (man_id),
        .busy        (busy),
        .done        (done)
    );

endmodule
