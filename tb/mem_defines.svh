`ifndef MEM_DEFINES_SVH
`define MEM_DEFINES_SVH


localparam logic [23:0] EXPECTED_MAN_ID = 24'h00d0d0;
localparam logic [7:0]  EEPROM_DEFAULT_DATA = 8'hFF;

typedef enum logic [1:0] {
    MEM_READ_ID,
    MEM_READ_STATUS,
    MEM_WRITE,
    MEM_READ
} mem_op_t;

typedef enum logic [2:0] {
    LEN_SINGLE,
    LEN_SHORT,
    LEN_MEDIUM,
    LEN_LONG,
    LEN_MAX
} mem_len_t;

`endif