class mem_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(mem_scoreboard)

    uvm_analysis_imp #(mem_item, mem_scoreboard) analysis_imp;

    function new(string name = "mem_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        analysis_imp = new("analysis_imp", this);
    endfunction

    function void write(mem_item item);
        `uvm_info(get_full_name(),
            $sformatf("Scoreboard received item: op=%s addr=0x%04h data=0x%02h read_data=0x%02h",
                      item.op.name(), item.addr, item.data, item.read_data),
            UVM_MEDIUM)
    endfunction

endclass