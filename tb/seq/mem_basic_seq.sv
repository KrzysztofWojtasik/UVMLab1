class mem_basic_seq extends uvm_sequence #(mem_item);

    `uvm_object_utils(mem_basic_seq)

    function new(string name = "mem_basic_seq");
        super.new(name);
    endfunction

    task body();
        mem_item req;
        logic [15:0] rand_addr;
        logic [7:0]  rand_data;

        repeat (20) begin
            rand_addr = $urandom_range(16'hFFFF, 16'h0000);
            rand_data = $urandom_range(8'hFF, 8'h00);

            req = mem_item::type_id::create("write_req");
            start_item(req);
            req.op   = MEM_WRITE;
            req.addr = rand_addr;
            req.data = rand_data;
            finish_item(req);

            req = mem_item::type_id::create("read_req");
            start_item(req);
            req.op   = MEM_READ;
            req.addr = rand_addr;
            req.data = rand_data;
            finish_item(req);
        end
    endtask

endclass