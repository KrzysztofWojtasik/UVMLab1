class mem_base_test extends uvm_test;

    `uvm_component_utils(mem_base_test)

    mem_config m_cfg;
    mem_env    m_env;

    function new(string name = "mem_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        m_cfg = mem_config::type_id::create("m_cfg");

        m_cfg.scoreboard_enable = 1'b1;

    `ifdef FCOV
        m_cfg.coverage_enable = 1'b1;
    `else
        m_cfg.coverage_enable = 1'b0;
    `endif

        uvm_config_db#(mem_config)::set(this, "*", "cfg", m_cfg);

        m_env = mem_env::type_id::create("m_env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        uvm_top.set_timeout(2s, 1);
        uvm_top.print_topology();

        `uvm_info(get_full_name(), "Printing mem_config", UVM_LOW)
        m_cfg.print();
    endfunction

    task main_phase(uvm_phase phase);
        mem_basic_seq seq;

        phase.raise_objection(this);

        phase.phase_done.set_drain_time(this, 10ms);

        `uvm_info(get_full_name(), "Starting mem_basic_seq", UVM_LOW)

        seq = mem_basic_seq::type_id::create("seq");
        seq.start(m_env.m_seqr);

        phase.drop_objection(this);
    endtask

endclass