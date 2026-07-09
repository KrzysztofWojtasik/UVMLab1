import uvm_pkg::*;
import mem_pkg::*;

module top;

    logic clk;

    mem_if vif(.clk(clk));

    initial begin
        clk = 1'b0;
        forever #300ns clk = ~clk;
    end

    dut u_dut (
        .clk             (vif.clk),
        .nrst            (vif.nrst),
        .start           (vif.start),
        .read_man_id     (vif.read_man_id),
        .read_cfg_status (vif.read_cfg_status),
        .read_eeprom     (vif.read_eeprom),
        .write_eeprom    (vif.write_eeprom),
        .mem_addr        (vif.mem_addr),
        .write_data      (vif.write_data),
        .read_data       (vif.read_data),
        .man_id          (vif.man_id),
        .cfg_status_hi   (vif.cfg_status_hi),
        .cfg_status_lo   (vif.cfg_status_lo),
        .busy            (vif.busy),
        .done            (vif.done)
    );

    initial begin
        uvm_config_db#(virtual mem_if)::set(null, "*", "vif", vif);
        run_test();
    end

endmodule