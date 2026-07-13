class mem_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(mem_scoreboard)

    uvm_analysis_imp #(mem_item, mem_scoreboard) analysis_imp;

    bit [7:0] expected_mem [bit [15:0]];

    bit [15:0] cfg_status;

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
                `uvm_error(get_full_name(),
                    $sformatf("Unsupported item op in scoreboard: %s", item.op.name()))
            end

        endcase
    endfunction

    function void check_read_id(mem_item item);
        if (item.man_id !== EXPECTED_MAN_ID) begin
            `uvm_error(get_full_name(),
                $sformatf("Manufacturer ID mismatch: expected=0x%06h got=0x%06h",
                        EXPECTED_MAN_ID, item.man_id))
        end else begin
            `uvm_info(get_full_name(),
                $sformatf("Manufacturer ID correct: 0x%06h", item.man_id),
                UVM_LOW)
        end
    endfunction

    function void handle_read_status(mem_item item);
        cfg_status = item.cfg_status;
        `uvm_info(get_full_name(),
            $sformatf("Stored status: cfg_status=0x%04h", cfg_status),
            UVM_LOW)
    endfunction

    function void handle_write(mem_item item);
        bit [15:0] addr_key;

        if ($isunknown(item.addr)) begin
            `uvm_error(get_full_name(),
                $sformatf("Write address contains X/Z: addr=0x%04h", item.addr))
            return;
        end

        addr_key = item.addr;
        expected_mem[addr_key] = item.data;

        `uvm_info(get_full_name(),
            $sformatf("Stored expected memory: addr=0x%04h data=0x%02h",
                    addr_key, item.data),
            UVM_LOW)
    endfunction

    function void check_read(mem_item item);
        bit [15:0] addr_key;
        bit [7:0]  expected_data;

        if ($isunknown(item.addr)) begin
            `uvm_error(get_full_name(),
                $sformatf("Read address contains X/Z: addr=0x%04h", item.addr))
            return;
        end

        addr_key = item.addr;

        if (expected_mem.exists(addr_key)) begin
            expected_data = expected_mem[addr_key];
        end else begin
            expected_data = EEPROM_DEFAULT_DATA;
        end

        if (item.read_data !== expected_data) begin
            `uvm_error(get_full_name(),
                $sformatf("EEPROM read mismatch: addr=0x%04h expected=0x%02h got=0x%02h",
                        addr_key, expected_data, item.read_data))
        end else begin
            `uvm_info(get_full_name(),
                $sformatf("EEPROM read correct: addr=0x%04h data=0x%02h",
                        addr_key, item.read_data),
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