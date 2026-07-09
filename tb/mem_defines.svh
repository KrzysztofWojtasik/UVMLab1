`ifndef MEM_DEFINES_SVH
`define MEM_DEFINES_SVH

typedef enum logic [1:0] {
    MEM_READ_ID,
    MEM_READ_STATUS,
    MEM_WRITE,
    MEM_READ
} mem_op_t;

`endif