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

    task main_phase(uvm_phase phase);
        mem_item item;

        forever begin
            @(posedge vif.done);

            item = mem_item::type_id::create("item", this);

            item.op            = mem_op_t'(vif.op);
            item.addr          = vif.mem_addr;
            item.data          = vif.write_data;
            item.read_data     = vif.read_data;
            item.man_id        = vif.man_id;
            item.cfg_status_hi = vif.cfg_status_hi;
            item.cfg_status_lo = vif.cfg_status_lo;

            `uvm_info(get_full_name(),
                $sformatf("Observed item: raw_op=0x%0h op=%s addr=0x%04h data=0x%02h read_data=0x%02h man_id=0x%06h status_hi=0x%02h status_lo=0x%02h",
                        vif.op,
                        item.op.name(),
                        item.addr,
                        item.data,
                        item.read_data,
                        item.man_id,
                        item.cfg_status_hi,
                        item.cfg_status_lo),
                UVM_MEDIUM)

            analysis_port.write(item);
        end
    endtask

endclass