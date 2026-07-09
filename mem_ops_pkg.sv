package mem_ops_pkg;

    typedef enum logic [2:0] {
        OP_READ_ID,
        OP_READ_STATUS,
        OP_READ_EEPROM,
        OP_WRITE_EEPROM
    } mem_op_t;

endpackage