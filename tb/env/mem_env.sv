class mem_env extends uvm_env;

    `uvm_component_utils(mem_env)

    mem_config     m_cfg;
    mem_sequencer  m_seqr;
    mem_driver     m_drv;
    mem_monitor    m_mon;
    mem_scoreboard m_scoreboard;
    mem_coverage   m_coverage;

    function new(string name = "mem_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(mem_config)::get(this, "", "cfg", m_cfg)) begin
            `uvm_warning(get_full_name(), "No mem_config found in uvm_config_db, creating default config")
            m_cfg = mem_config::type_id::create("m_cfg");
        end

        m_seqr = mem_sequencer::type_id::create("m_seqr", this);
        m_drv  = mem_driver::type_id::create("m_drv", this);
        m_mon  = mem_monitor::type_id::create("m_mon", this);

        if (m_cfg.scoreboard_enable) begin
            m_scoreboard = mem_scoreboard::type_id::create("m_scoreboard", this);
        end

        if (m_cfg.coverage_enable) begin
            m_coverage = mem_coverage::type_id::create("m_coverage", this);
        end
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        m_drv.seq_item_port.connect(m_seqr.seq_item_export);

        if (m_cfg.scoreboard_enable) begin
            m_mon.analysis_port.connect(m_scoreboard.analysis_imp);
        end

        if (m_cfg.coverage_enable) begin
            m_mon.analysis_port.connect(m_coverage.analysis_imp);
        end
    endfunction

endclass