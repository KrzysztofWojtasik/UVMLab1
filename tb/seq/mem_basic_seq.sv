class mem_basic_seq extends uvm_sequence #(mem_item);

    `uvm_object_utils(mem_basic_seq)

    function new(string name = "mem_basic_seq");
        super.new(name);
    endfunction

    task body();

        logic [15:0] saved_addr;
        logic [7:0]  saved_data;
        mem_len_t    saved_len;
        int unsigned len_sel;

        repeat (50) begin

            req = mem_item::type_id::create("write_req");

            start_item(req);

            if (!std::randomize(len_sel) with {
                len_sel dist {
                    0 := 1,
                    1 := 70,
                    2 := 20,
                    3 := 8,
                    4 := 1
                };
            }) begin
                `uvm_fatal(get_full_name(), "Failed to randomize length selector")
            end

            case (len_sel)
                0: saved_len = LEN_SINGLE;
                1: saved_len = LEN_SHORT;
                2: saved_len = LEN_MEDIUM;
                3: saved_len = LEN_LONG;
                4: saved_len = LEN_MAX;
                default: begin
                    `uvm_fatal(get_full_name(), $sformatf("Invalid len_sel=%0d", len_sel))
                end
            endcase

            if (!req.randomize() with {
                op       == MEM_WRITE;
                data_len == local::saved_len;
            }) begin
                `uvm_fatal(get_full_name(), "Failed to randomize write item")
            end

            saved_addr = req.addr;
            saved_data = req.data;
            saved_len  = req.data_len;

            `uvm_info(get_full_name(),
                $sformatf("Randomized WRITE: addr=0x%04h data=0x%02h len=%s",
                        saved_addr, saved_data, saved_len.name()),
                UVM_MEDIUM)

            finish_item(req);


            req = mem_item::type_id::create("read_req");

            start_item(req);

            if (!req.randomize() with {
                op       == MEM_READ;
                addr     == local::saved_addr;
                data     == local::saved_data;
                data_len == local::saved_len;
            }) begin
                `uvm_fatal(get_full_name(), "Failed to randomize read item")
            end

            `uvm_info(get_full_name(),
                $sformatf("Randomized READ: addr=0x%04h expected_data=0x%02h len=%s",
                        req.addr, req.data, req.data_len.name()),
                UVM_MEDIUM)

            finish_item(req);
        end

    endtask

endclass