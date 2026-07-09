class mem_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(mem_scoreboard)

    uvm_analysis_imp #(mem_item, mem_scoreboard) analysis_imp;

    bit [7:0] expected_mem [logic [15:0]];

    bit [7:0] cfg_status_hi;
    bit [7:0] cfg_status_lo;

    function new(string name = "mem_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        analysis_imp = new("analysis_imp", this);
    endfunction

    function void write(mem_item item);
        `uvm_info(get_full_name(),
            $sformatf("Scoreboard received item: op=%s addr=0x%04h data=0x%02h read_data=0x%02h",
                      item.op.name(), item.addr, item.data, item.read_data),
            UVM_MEDIUM)

        case (item.op)

            MEM_READ_ID: begin
                check_read_id(item);
            end

            MEM_READ_STATUS: begin
                handle_read_status(item);
            end

            MEM_WRITE: begin
                handle_write(item);
            end

            MEM_READ: begin
                check_read(item);
            end

            default: begin
                `uvm_warning(get_full_name(),
                    $sformatf("Unsupported item op in scoreboard: %s", item.op.name()))
            end

        endcase
    endfunction

    function void check_read_id(mem_item item);
        if (item.man_id !== 24'h00d0d0) begin
            `uvm_error(get_full_name(),
                $sformatf("Manufacturer ID mismatch: expected=0x00d0d0 got=0x%06h",
                          item.man_id))
        end else begin
            `uvm_info(get_full_name(),
                $sformatf("Manufacturer ID correct: 0x%06h", item.man_id),
                UVM_LOW)
        end
    endfunction

    function void handle_read_status(mem_item item);
        cfg_status_hi = item.cfg_status_hi;
        cfg_status_lo = item.cfg_status_lo;

        `uvm_info(get_full_name(),
            $sformatf("Stored status: cfg_status_hi=0x%02h cfg_status_lo=0x%02h",
                      cfg_status_hi, cfg_status_lo),
            UVM_LOW)
    endfunction

    function void handle_write(mem_item item);
        expected_mem[item.addr] = item.data;

        `uvm_info(get_full_name(),
            $sformatf("Stored expected memory: addr=0x%04h data=0x%02h",
                      item.addr, item.data),
            UVM_LOW)
    endfunction

    function void check_read(mem_item item);
        bit [7:0] expected_data;

        if (expected_mem.exists(item.addr)) begin
            expected_data = expected_mem[item.addr];
        end else begin
            expected_data = 8'hFF;
        end

        if (item.read_data !== expected_data) begin
            `uvm_error(get_full_name(),
                $sformatf("EEPROM read mismatch: addr=0x%04h expected=0x%02h got=0x%02h",
                          item.addr, expected_data, item.read_data))
        end else begin
            `uvm_info(get_full_name(),
                $sformatf("EEPROM read correct: addr=0x%04h data=0x%02h",
                          item.addr, item.read_data),
                UVM_LOW)
        end
    endfunction

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);

        `uvm_info(get_full_name(),
            $sformatf("Scoreboard check_phase complete. Stored addresses: %0d",
                      expected_mem.num()),
            UVM_LOW)
    endfunction

endclass