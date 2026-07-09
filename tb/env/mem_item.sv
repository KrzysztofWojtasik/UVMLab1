class mem_item extends uvm_sequence_item;

    rand mem_op_t op;
    rand logic [15:0] addr;
    rand logic [7:0]  data;

    logic [7:0] read_data;

    `uvm_object_utils_begin(mem_item)
        `uvm_field_enum(mem_op_t, op, UVM_DEFAULT)
        `uvm_field_int(addr, UVM_DEFAULT)
        `uvm_field_int(data, UVM_DEFAULT)
        `uvm_field_int(read_data, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "mem_item");
        super.new(name);
    endfunction

endclass