class mem_driver extends uvm_driver #(mem_item);

    `uvm_component_utils(mem_driver)

    virtual mem_if vif;

    function new(string name = "mem_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual mem_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_full_name(), "Could not get virtual interface from uvm_config_db")
        end
    endfunction

    task reset_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info(get_full_name(), "Driving reset", UVM_LOW)

        vif.nrst <= 1'b0;
        repeat (5) @(posedge vif.clk);
        vif.nrst <= 1'b1;
        repeat (5) @(posedge vif.clk);

        phase.drop_objection(this);
    endtask

    task main_phase(uvm_phase phase);
        mem_item req;

        forever begin
            seq_item_port.get_next_item(req);

            `uvm_info(get_full_name(),
                $sformatf("Got item: op=%s addr=0x%04h data=0x%02h",
                          req.op.name(), req.addr, req.data),
                UVM_MEDIUM)

            // Tutaj później przeniesiemy logikę z do_eeprom_write/do_eeprom_read.

            seq_item_port.item_done();
        end
    endtask

endclass