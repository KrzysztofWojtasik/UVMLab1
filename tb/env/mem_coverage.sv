class mem_coverage extends uvm_component;

    `uvm_component_utils(mem_coverage)

    uvm_analysis_imp #(mem_item, mem_coverage) analysis_imp;

    mem_op_t cov_op;
    bit      cov_addr_msb;
    bit      cov_data_msb;

    covergroup mem_cg;
        option.per_instance = 1;

        cp_op: coverpoint cov_op {
            bins read_id     = {MEM_READ_ID};
            bins read_status = {MEM_READ_STATUS};
            bins write       = {MEM_WRITE};
            bins read        = {MEM_READ};
        }

        cp_addr_msb: coverpoint cov_addr_msb {
            bins low_half  = {1'b0};
            bins high_half = {1'b1};
        }

        cp_data_msb: coverpoint cov_data_msb {
            bins low_data  = {1'b0};
            bins high_data = {1'b1};
        }

        op_x_addr: cross cp_op, cp_addr_msb;
        op_x_data: cross cp_op, cp_data_msb;
    endgroup

    function new(string name = "mem_coverage", uvm_component parent = null);
        super.new(name, parent);
        analysis_imp = new("analysis_imp", this);
        mem_cg = new();
    endfunction

    function void write(mem_item item);

        cov_op       = item.op;
        cov_addr_msb = item.addr[15];
        cov_data_msb = item.data[7];

        mem_cg.sample();

        `uvm_info(get_full_name(),
            $sformatf("Coverage sampled item: op=%s addr_msb=%0b data_msb=%0b coverage=%0.2f%%",
                      item.op.name(),
                      cov_addr_msb,
                      cov_data_msb,
                      mem_cg.get_inst_coverage()),
            UVM_MEDIUM)

    endfunction

endclass