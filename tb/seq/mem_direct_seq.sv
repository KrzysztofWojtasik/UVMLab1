class mem_direct_seq extends uvm_sequence #(mem_item);

    `uvm_object_utils(mem_direct_seq)

    function new(string name = "mem_direct_seq");
        super.new(name);
    endfunction

    task do_write(input logic [15:0] addr, input logic [7:0] data);
        req = mem_item::type_id::create("direct_write_req");

        start_item(req);

        req.op       = MEM_WRITE;
        req.addr     = addr;
        req.data     = data;
        req.data_len = LEN_SINGLE;

        finish_item(req);

        `uvm_info(get_full_name(),
            $sformatf("Direct WRITE: addr=0x%04h data=0x%02h", addr, data),
            UVM_MEDIUM)
    endtask

    task do_read(input logic [15:0] addr, input logic [7:0] expected_data = 8'h00);
        req = mem_item::type_id::create("direct_read_req");

        start_item(req);

        req.op       = MEM_READ;
        req.addr     = addr;
        req.data     = expected_data;
        req.data_len = LEN_SINGLE;

        finish_item(req);

        `uvm_info(get_full_name(),
            $sformatf("Direct READ: addr=0x%04h expected_data=0x%02h", addr, expected_data),
            UVM_MEDIUM)
    endtask

    task body();
        `uvm_info(get_full_name(), "Starting mem_direct_seq", UVM_LOW)

        do_write(16'h0000, 8'hA5);
        do_read (16'h0000, 8'hA5);

        do_write(16'h1234, 8'h5A);
        do_read (16'h1234, 8'h5A);

        do_write(16'hFFFF, 8'hC3);
        do_read (16'hFFFF, 8'hC3);
    endtask

endclass

class mem_multi_addr_seq extends mem_direct_seq;

    `uvm_object_utils(mem_multi_addr_seq)

    function new(string name = "mem_multi_addr_seq");
        super.new(name);
    endfunction

    task body();

        `uvm_info(get_full_name(), "Starting mem_multi_addr_seq", UVM_LOW)

        do_write(16'h0100, 8'h11);
        do_write(16'h0200, 8'h22);
        do_write(16'h0300, 8'h33);

        do_read(16'h0200, 8'h22);
        do_read(16'h0100, 8'h11);
        do_read(16'h0300, 8'h33);

    endtask

endclass