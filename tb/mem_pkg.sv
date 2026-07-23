`include "uvm_macros.svh"

package mem_pkg;

    import uvm_pkg::*;

    `include "mem_defines.svh"

    `include "env/mem_config.sv"
    `include "env/mem_item.sv"
    `include "seq/mem_basic_seq.sv"
    `include "seq/mem_direct_seq.sv"
    `include "env/mem_sequencer.sv"
    `include "env/mem_driver.sv"
    `include "env/mem_monitor.sv"
    `include "env/mem_scoreboard.sv"
    `include "env/mem_coverage.sv"
    `include "env/mem_env.sv"
    `include "tests/mem_base_test.sv"
    `include "tests/mem_direct_test.sv"
    `include "tests/mem_multi_addr_test.sv"

endpackage