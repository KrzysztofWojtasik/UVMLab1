`include "uvm_macros.svh"

package mem_pkg;

    import uvm_pkg::*;

    `include "mem_defines.svh"

    `include "env/mem_item.sv"
    `include "seq/mem_basic_seq.sv"
    `include "env/mem_sequencer.sv"
    `include "env/mem_driver.sv"
    `include "env/mem_env.sv"
    `include "tests/mem_base_test.sv"

endpackage