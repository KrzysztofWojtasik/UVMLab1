class mem_coverage extends uvm_component;

    `uvm_component_utils(mem_coverage)

    uvm_analysis_imp #(mem_item, mem_coverage) analysis_imp;

    function new(string name = "mem_coverage", uvm_component parent = null);
        super.new(name, parent);
        analysis_imp = new("analysis_imp", this);
    endfunction

    function void write(mem_item item);
        `uvm_info(get_full_name(),
            $sformatf("Coverage received item: op=%s addr=0x%04h data=0x%02h",
                      item.op.name(), item.addr, item.data),
            UVM_MEDIUM)
    endfunction

endclass