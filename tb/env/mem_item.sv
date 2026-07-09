class mem_item extends uvm_sequence_item;

    rand mem_op_t op;
    rand logic [15:0] addr;
    rand logic [7:0]  data;

    logic [7:0]  read_data;
    logic [23:0] man_id;
    logic [7:0]  cfg_status_hi;
    logic [7:0]  cfg_status_lo;

    `uvm_object_utils_begin(mem_item)
        `uvm_field_enum(mem_op_t, op, UVM_DEFAULT)
        `uvm_field_int(addr,          UVM_DEFAULT)
        `uvm_field_int(data,          UVM_DEFAULT)
        `uvm_field_int(read_data,     UVM_DEFAULT)
        `uvm_field_int(man_id,        UVM_DEFAULT)
        `uvm_field_int(cfg_status_hi, UVM_DEFAULT)
        `uvm_field_int(cfg_status_lo, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "mem_item");
        super.new(name);
    endfunction

endclass