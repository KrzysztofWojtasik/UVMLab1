class mem_monitor extends uvm_monitor;

    `uvm_component_utils(mem_monitor)

    virtual mem_if vif;

    uvm_analysis_port #(mem_item) analysis_port;

    function new(string name = "mem_monitor", uvm_component parent = null);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual mem_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_full_name(), "Could not get virtual interface from uvm_config_db")
        end
    endfunction

endclass