interface mem_if(input logic clk);

    logic        nrst;
    logic        start;

    logic [1:0]  op;

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

    assign read_man_id     = (op == 2'd0);
    assign read_cfg_status = (op == 2'd1);
    assign write_eeprom    = (op == 2'd2);
    assign read_eeprom     = (op == 2'd3);

endinterface