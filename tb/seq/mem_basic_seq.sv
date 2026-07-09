class mem_basic_seq extends uvm_sequence #(mem_item);

    `uvm_object_utils(mem_basic_seq)

    function new(string name = "mem_basic_seq");
        super.new(name);
    endfunction

    task body();
        mem_item req;

        repeat (20) begin
            req = mem_item::type_id::create("req");

            start_item(req);

            if (!req.randomize() with {
                op inside {MEM_WRITE, MEM_READ};
            }) begin
                `uvm_fatal(get_name(), "Failed to randomize mem_item")
            end

            finish_item(req);
        end
    endtask

endclass