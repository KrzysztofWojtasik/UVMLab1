class mem_basic_seq extends uvm_sequence #(mem_item);

    `uvm_object_utils(mem_basic_seq)

    logic [15:0] saved_addr;
    logic [7:0]  saved_data;

    function new(string name = "mem_basic_seq");
        super.new(name);
    endfunction

    task body();

        repeat (20) begin
            req = mem_item::type_id::create("write_req");

            start_item(req);

            if (!req.randomize() with {
                op == MEM_WRITE;
            }) begin
                `uvm_fatal(get_full_name(), "Failed to randomize write item")
            end

            saved_addr = req.addr;
            saved_data = req.data;

            finish_item(req);

            req = mem_item::type_id::create("read_req");

            start_item(req);

            if (!req.randomize() with {
                op   == MEM_READ;
                addr == local::saved_addr;
                data == local::saved_data;
            }) begin
                `uvm_fatal(get_full_name(), "Failed to randomize read item")
            end

            finish_item(req);
        end

    endtask

endclass