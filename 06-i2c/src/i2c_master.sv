module i2c_master #(
    parameter integer CLK_PER_HALF_BIT = 250
)(
    input logic clk, rst, start, rw,
    input logic [6:0] addr,
    input logic [7:0] data_in,
    output logic busy, scl, ack_error,
    inout wire sda,
    output logic [7:0] data_out
);

    localparam integer CW =
        (CLK_PER_HALF_BIT <= 1) ? 1 : $clog2(CLK_PER_HALF_BIT);

    // Les differents etats du maitre
    typedef enum logic [3:0] {
        IDLE,
        START,
        ADDR_LOW,
        ADDR_HIGH,
        ACK_ADDR_LOW,
        ACK_ADDR_HIGH,
        DATA_LOW,
        DATA_HIGH,
        ACK_DATA_LOW,
        ACK_DATA_HIGH,
        STOP_LOW,
        STOP_HIGH,
        STOP_END
    } state_t;

    state_t state;

    logic [2:0] t_bits;
    logic [CW-1:0] t_cycles;

    logic [7:0] tx_shift;
    logic [7:0] data_latched;
    logic [6:0] addr_latched;
    logic rw_latched;

    logic sda_en;
    wire sda_in;

    // SDA est en drain ouvert : on force 0 ou on relache le bus
    assign sda = sda_en ? 1'b0 : 1'bz;
    assign sda_in = sda;

    // SCL et SDA sont commandes selon l'etat
    always_comb begin

        scl = 1'b1;
        busy = (state != IDLE);
        sda_en = 1'b0;

        case (state)

            IDLE: begin
                scl = 1'b1;
            end

            START: begin
                scl = 1'b1;
                sda_en = 1'b1;
            end

            ADDR_LOW, ADDR_HIGH: begin

                if (state == ADDR_LOW)
                    scl = 1'b0;
                else
                    scl = 1'b1;

                // Adresse sur 7 bits puis bit R/W
                sda_en = ~tx_shift[t_bits];
            end

            ACK_ADDR_LOW, ACK_DATA_LOW: begin
                scl = 1'b0;
            end

            ACK_ADDR_HIGH, ACK_DATA_HIGH: begin
                scl = 1'b1;
            end

            DATA_LOW, DATA_HIGH: begin

                if (state == DATA_LOW)
                    scl = 1'b0;
                else
                    scl = 1'b1;

                // En lecture, le maitre relache SDA
                if (rw_latched == 1'b0)
                    sda_en = ~tx_shift[t_bits];
            end

            STOP_LOW: begin
                scl = 1'b0;
                sda_en = 1'b1;
            end

            STOP_HIGH: begin
                scl = 1'b1;
                sda_en = 1'b1;
            end

            STOP_END: begin
                scl = 1'b1;
            end

            default: begin
                scl = 1'b1;
                sda_en = 1'b0;
            end

        endcase
    end

    // Gestion de la transmission
    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            state <= IDLE;
            t_bits <= 0;
            t_cycles <= 0;

            tx_shift <= 0;
            data_latched <= 0;
            addr_latched <= 0;
            rw_latched <= 0;

            ack_error <= 0;
            data_out <= 0;
        end

        else if (state == IDLE) begin

            t_cycles <= 0;

            if (start) begin

                addr_latched <= addr;
                rw_latched <= rw;
                data_latched <= data_in;

                // Les 7 bits d'adresse suivis de R/W
                tx_shift <= {addr, rw};
                t_bits <= 7;

                ack_error <= 0;
                data_out <= 0;

                state <= START;
            end

        end

        else if (t_cycles == CLK_PER_HALF_BIT - 1) begin

            t_cycles <= 0;

            case (state)

                START: begin
                    state <= ADDR_LOW;
                end

                ADDR_LOW: begin
                    state <= ADDR_HIGH;
                end

                ADDR_HIGH: begin

                    if (t_bits == 0) begin
                        state <= ACK_ADDR_LOW;
                    end
                    else begin
                        t_bits <= t_bits - 1'b1;
                        state <= ADDR_LOW;
                    end

                end

                ACK_ADDR_LOW: begin
                    state <= ACK_ADDR_HIGH;
                end

                ACK_ADDR_HIGH: begin

                    // Verification de l'ACK de l'esclave
                    if (sda_in !== 1'b0) begin
                        ack_error <= 1'b1;
                        state <= STOP_LOW;
                    end
                    else begin
                        tx_shift <= data_latched;
                        t_bits <= 7;
                        state <= DATA_LOW;
                    end

                end

                DATA_LOW: begin
                    state <= DATA_HIGH;
                end

                DATA_HIGH: begin

                    // En lecture, le maitre recupere les bits
                    if (rw_latched == 1'b1)
                        data_out[t_bits] <= sda_in;

                    if (t_bits == 0) begin
                        state <= ACK_DATA_LOW;
                    end
                    else begin
                        t_bits <= t_bits - 1'b1;
                        state <= DATA_LOW;
                    end

                end

                ACK_DATA_LOW: begin
                    state <= ACK_DATA_HIGH;
                end

                ACK_DATA_HIGH: begin

                    // En ecriture, verification de l'ACK
                    if ((rw_latched == 1'b0) &&
                        (sda_in !== 1'b0))
                        ack_error <= 1'b1;

                    state <= STOP_LOW;
                end

                STOP_LOW: begin
                    state <= STOP_HIGH;
                end

                STOP_HIGH: begin
                    state <= STOP_END;
                end

                STOP_END: begin
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase

        end
        else begin
            t_cycles <= t_cycles + 1'b1;
        end

    end

endmodule