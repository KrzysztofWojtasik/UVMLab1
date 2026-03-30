module ctrl (
    input  logic        clk,
    input  logic        nrst,

    input  logic        read_man_id,

    input  logic        start,
    input  logic        rw,
    input  logic [15:0] mem_addr,
    input  logic [7:0]  write_data,
    output logic [7:0]  read_data,
    output logic        busy,
    output logic        done,

    output logic        scl,
    inout  wire         sda,


    output logic [23:0] man_id

    
);

    typedef enum logic [5:0] {
    IDLE,

    START_1,
    START_2,
    START_HOLD,

    LOAD_TX_F8,
    LOAD_TX_A0,
    LOAD_TX_F9,

    TX_SCL_LOW,
    TX_DATA_SETUP,
    TX_BIT_HIGH,
    TX_NEXT_BIT,

    ACK_LOW,
    ACK_HIGH,
    ACK_CHECK,

    REP_ACK_END,
    REP_RELEASE_SDA,
    REP_SCL_HIGH,
    REP_START_1,
    REP_START_2,
    REP_START_HOLD,

    READ_BIT_LOW,
    READ_BIT_HIGH,
    READ_SAMPLE,
    READ_NEXT_BIT,
    READ_STORE_BYTE,

    MASTER_ACK_SETUP,
    MASTER_ACK_LOW,
    MASTER_ACK_HIGH,
    MASTER_ACK_DONE,

    STOP_1,
    STOP_2,
    STOP_3,
    STOP_4,

    FINISH
} state_t;

    state_t state;
    state_t next_after_ack;

    logic drive_low;              // open-drain sterowanie SDA
    logic [7:0] shift_reg;
    logic [2:0] bit_cnt;
    logic ack_ok;
    logic [1:0] read_byte_idx;    // 0,1,2 dla 3 bajtów ID

    // I2C open-drain:
    // 0 -> ciągnij linię do zera
    // 1 -> puść linię (Z)
    assign sda = drive_low ? 1'b0 : 1'bz;
    wire sda_in = sda;

    

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            state          <= IDLE;
            next_after_ack <= IDLE;

            scl           <= 1'b1;
            drive_low     <= 1'b0;

            shift_reg     <= 8'h00;
            bit_cnt       <= 3'd7;
            ack_ok        <= 1'b0;
            read_byte_idx <= 2'd0;

            read_data     <= 8'h00;
            man_id        <= 24'h000000;

            busy          <= 1'b0;
            done          <= 1'b0;
        end
        else begin
            done <= 1'b0;

            case (state)

                IDLE: begin
                    scl           <= 1'b1;
                    drive_low     <= 1'b0;
                    busy          <= 1'b0;
                    ack_ok        <= 1'b0;
                    read_byte_idx <= 2'd0;

                    if (start && read_man_id) begin
                        busy  <= 1'b1;
                        man_id <= 24'h000000;
                        state <= START_1;
                    end
                end

                START_1: begin
                    scl       <= 1'b1;
                    drive_low <= 1'b0;
                    state     <= START_2;
                end

                START_2: begin
                    scl       <= 1'b1;
                    drive_low <= 1'b1;   // START: SDA 1->0 przy SCL=1
                    state     <= START_HOLD;
                end

                START_HOLD: begin
                    scl       <= 1'b1;
                    drive_low <= 1'b1;   // trzymaj jeszcze START
                    state     <= LOAD_TX_F8;
                end

                LOAD_TX_F8: begin
                    shift_reg      <= 8'hF8;
                    bit_cnt        <= 3'd7;
                    next_after_ack <= LOAD_TX_A0;
                    state          <= TX_SCL_LOW;
                end

                LOAD_TX_A0: begin
                    shift_reg      <= 8'hA0;
                    bit_cnt        <= 3'd7;
                    next_after_ack <= REP_ACK_END;
                    state          <= TX_SCL_LOW;
                end

                LOAD_TX_F9: begin
                    shift_reg      <= 8'hF9;
                    bit_cnt        <= 3'd7;
                    next_after_ack <= READ_BIT_LOW;
                    state          <= TX_SCL_LOW;
                end

                TX_SCL_LOW: begin
                    scl   <= 1'b0;
                    state <= TX_DATA_SETUP;
                end

                TX_DATA_SETUP: begin
                    scl       <= 1'b0;
                    drive_low <= ~shift_reg[bit_cnt]; // 0 -> ciągnij low, 1 -> puść linię
                    state     <= TX_BIT_HIGH;
                end

                TX_BIT_HIGH: begin
                    scl   <= 1'b1;
                    state <= TX_NEXT_BIT;
                end

                TX_NEXT_BIT: begin
                    if (bit_cnt == 0) begin
                        state <= ACK_LOW;
                    end
                    else begin
                        bit_cnt <= bit_cnt - 3'd1;
                        state   <= TX_SCL_LOW;
                    end
                end

                // Odbiór ACK od slave
                ACK_LOW: begin
                    scl       <= 1'b0;
                    drive_low <= 1'b0;   // puść SDA
                    state     <= ACK_HIGH;
                end

                ACK_HIGH: begin
                    scl    <= 1'b1;
                    ack_ok <= (sda_in == 1'b0);
                    state  <= ACK_CHECK;
                end

                ACK_CHECK: begin
                    $display("t=%0t ACK_CHECK ack_ok=%b next=%0d", $time, ack_ok, next_after_ack);
                    if (!ack_ok) begin
                        state <= STOP_1;
                    end
                    else begin
                        if (next_after_ack == READ_BIT_LOW) begin
                            bit_cnt   <= 3'd7;
                            shift_reg <= 8'h00;
                        end
                        state <= next_after_ack;
                    end
                end

                REP_ACK_END: begin
                    scl       <= 1'b0;   // zakończ ACK bit
                    drive_low <= 1'b0;   // puść SDA
                    state     <= REP_RELEASE_SDA;
                end

                REP_RELEASE_SDA: begin
                    scl       <= 1'b0;
                    drive_low <= 1'b0;   // daj czas slave'owi zwolnić SDA
                    state     <= REP_SCL_HIGH;
                end

                REP_SCL_HIGH: begin
                    scl       <= 1'b1;
                    drive_low <= 1'b0;   // bus idle: SDA=1, SCL=1
                    state     <= REP_START_1;
                end

                REP_START_1: begin
                    scl       <= 1'b1;
                    drive_low <= 1'b1;   // repeated START: SDA 1->0 przy SCL=1
                    state     <= REP_START_HOLD;
                end

                REP_START_HOLD: begin
                    scl       <= 1'b1;
                    drive_low <= 1'b1;
                    state     <= LOAD_TX_F9;
                end

               READ_BIT_LOW: begin
                    scl       <= 1'b0;
                    drive_low <= 1'b0;   // puść SDA, slave nadaje
                    if (bit_cnt == 3'd7)
                        shift_reg <= 8'h00;
                    state <= READ_BIT_HIGH;
                end

                READ_BIT_HIGH: begin
                    scl       <= 1'b1;
                    drive_low <= 1'b0;
                    state     <= READ_SAMPLE;
                end

                READ_SAMPLE: begin
                    scl       <= 1'b1;
                    drive_low <= 1'b0;
                    shift_reg[bit_cnt] <= sda_in;
                    state <= READ_NEXT_BIT;
                end

                READ_NEXT_BIT: begin
                    if (bit_cnt == 0) begin
                        state <= READ_STORE_BYTE;
                    end
                    else begin
                        bit_cnt <= bit_cnt - 3'd1;
                        state   <= READ_BIT_LOW;
                    end
                end

                READ_STORE_BYTE: begin
                    $display("t=%0t READ_STORE_BYTE idx=%0d shift_reg=0x%02h", $time, read_byte_idx, shift_reg);
                    case (read_byte_idx)
                        2'd0: man_id[23:16] <= shift_reg;
                        2'd1: man_id[15:8]  <= shift_reg;
                        2'd2: begin
                            man_id[7:0] <= shift_reg;
                            read_data   <= shift_reg;
                        end
                        default: ;
                    endcase
                    state <= MASTER_ACK_SETUP;
                end

                // Po 1 i 2 bajcie ACK, po 3 bajcie NACK
                MASTER_ACK_SETUP: begin
                    scl       <= 1'b0;
                    drive_low <= 1'b0;   // najpierw puść SDA, bez zmiany danych
                    state     <= MASTER_ACK_LOW;
                end

                MASTER_ACK_LOW: begin
                    scl <= 1'b0;
                    if (read_byte_idx < 2)
                        drive_low <= 1'b1; // ACK = 0
                    else
                        drive_low <= 1'b0; // NACK = puść linię
                    state <= MASTER_ACK_HIGH;
                end

                MASTER_ACK_HIGH: begin
                    scl <= 1'b1;
                    state <= MASTER_ACK_DONE;
                end

                MASTER_ACK_DONE: begin
                    scl       <= 1'b0;
                    drive_low <= 1'b0;

                    if (read_byte_idx < 2) begin
                        read_byte_idx <= read_byte_idx + 2'd1;
                        bit_cnt       <= 3'd7;
                        state         <= READ_BIT_LOW;
                    end
                    else begin
                        state <= STOP_1;
                    end
                end

                STOP_1: begin
                    scl       <= 1'b0;
                    drive_low <= 1'b0;
                    state     <= STOP_2;
                end

                STOP_2: begin
                    scl       <= 1'b0;
                    drive_low <= 1'b1;   // ustaw SDA=0 dopiero po tym jak SCL już jest nisko
                    state     <= STOP_3;
                end

                STOP_3: begin
                    scl       <= 1'b1;
                    drive_low <= 1'b1;
                    state     <= STOP_4;
                end

                STOP_4: begin
                    scl       <= 1'b1;
                    drive_low <= 1'b0;   // SDA 0->1 przy SCL=1 => STOP
                    state     <= FINISH;
                end

                FINISH: begin
                     $display("t=%0t FINISH man_id=0x%06h read_data=0x%02h", $time, man_id, read_data);
                    busy  <= 1'b0;
                    done  <= 1'b1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
