class mem_direct_test extends mem_base_test;

    `uvm_component_utils(mem_direct_test)

    function new(string name = "mem_direct_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task main_phase(uvm_phase phase);
        mem_direct_seq seq;

        phase.raise_objection(this);
        phase.phase_done.set_drain_time(this, 10ms);

        `uvm_info(get_full_name(), "Starting mem_direct_test", UVM_LOW)

        seq = mem_direct_seq::type_id::create("seq");
        seq.start(m_env.m_seqr);

        phase.drop_objection(this);
    endtask

endclass