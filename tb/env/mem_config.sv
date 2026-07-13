class mem_config extends uvm_object;

    bit scoreboard_enable = 1'b0;
    bit coverage_enable   = 1'b0;

    `uvm_object_utils_begin(mem_config)
        `uvm_field_int(scoreboard_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable,   UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "mem_config");
        super.new(name);
    endfunction

endclass