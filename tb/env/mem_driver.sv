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

        vif.nrst       <= 1'b0;
        vif.start      <= 1'b0;
        vif.op         <= MEM_READ_ID;
        vif.mem_addr   <= 16'h0000;
        vif.write_data <= 8'h00;

        #10000ns;
        vif.nrst <= 1'b1;
        #10000ns;

        phase.drop_objection(this);
    endtask

    task automatic wait_done_or_fatal(string op_name);
        fork
            begin
                wait(vif.done == 1'b1);
            end
            begin
                #50000000ns;
                `uvm_fatal(get_full_name(),
                    $sformatf("Timeout while waiting for done during %s", op_name))
            end
        join_any
        disable fork;
    endtask

    task automatic do_eeprom_write(
        input logic [15:0] addr,
        input logic [7:0]  data
    );
        do_eeprom_access(MEM_WRITE, addr, data);
    endtask

    task automatic do_eeprom_read(
        input logic [15:0] addr
    );
        do_eeprom_access(MEM_READ, addr);
    endtask

    task automatic do_eeprom_access(
        input mem_op_t op,
        input logic [15:0] addr,
        input logic [7:0]  data = 8'h00
    );
        vif.op       <= op;
        vif.mem_addr <= addr;

        if (op == MEM_WRITE) begin
            vif.write_data <= data;
        end

        #1000ns;
        vif.start <= 1'b1;
        #10000ns;
        vif.start <= 1'b0;

        wait_done_or_fatal(op.name());
        #10000ns;

        `uvm_info(get_full_name(),
            $sformatf("EEPROM access command finished: op=%s addr=0x%04h data=0x%02h busy=%0b time=%0t",
                    op.name(), addr, data, vif.busy, $time),
            UVM_LOW)

        if (op == MEM_WRITE) begin
            #10000000ns;
        end else begin
            #10000ns;
        end
    endtask

    task automatic do_simple_command(input mem_op_t op);
        vif.op <= op;

        #1000ns;
        vif.start <= 1'b1;
        #10000ns;
        vif.start <= 1'b0;

        wait_done_or_fatal(op.name());
        #10000ns;

        `uvm_info(get_full_name(),
            $sformatf("Simple command finished: op=%s busy=%0b time=%0t",
                    op.name(), vif.busy, $time),
            UVM_LOW)

        #10000ns;
    endtask

    task automatic do_read_man_id();
        do_simple_command(MEM_READ_ID);
    endtask

    task automatic do_read_status();
        do_simple_command(MEM_READ_STATUS);
    endtask

    task main_phase(uvm_phase phase);
        mem_item req;

        do_read_man_id();
        do_read_status();

        forever begin
            seq_item_port.get_next_item(req);

            `uvm_info(get_full_name(),
                $sformatf("Got item: op=%s addr=0x%04h data=0x%02h",
                          req.op.name(), req.addr, req.data),
                UVM_MEDIUM)

            case (req.op)
                MEM_WRITE: begin
                    do_eeprom_write(req.addr, req.data);
                end

                MEM_READ: begin
                    do_eeprom_read(req.addr);
                end

                MEM_READ_ID: begin
                    do_read_man_id();
                end

                MEM_READ_STATUS: begin
                    do_read_status();
                end

                default: begin
                    `uvm_warning(get_full_name(),
                        $sformatf("Unsupported operation: %s", req.op.name()))
                end
            endcase

            seq_item_port.item_done();
        end
    endtask

endclass