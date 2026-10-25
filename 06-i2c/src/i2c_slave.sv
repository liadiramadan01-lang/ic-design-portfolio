module i2c_slave(
    input logic scl, rst, rw,
    inout wire sda,
    input logic [7:0] s_data_in,
    output logic [7:0] s_data_out
);

    typedef enum logic [3:0] {
        IDLE,
        ADDR,
        ACK_ADDR,
        NACK_ADDR,
        DATA_RX,
        ACK_DATA,
        DATA_TX,
        WAIT_NACK,
        WAIT_STOP
    } state_t;

    state_t state;

    logic [6:0] s_addr;
    logic [2:0] t_bits;
    logic rw_rx;

    logic sda_en;
    wire sda_in;

    // SDA : l'esclave force 0 ou relache le bus
    assign sda = sda_en ? 1'b0 : 1'bz;
    assign sda_in = sda;

    // Reception de l'adresse et des donnees
    always_ff @(posedge scl or posedge rst) begin

        if (rst) begin
            state <= IDLE;
            s_addr <= 0;
            t_bits <= 0;
            rw_rx <= 0;
            s_data_out <= 0;
        end

        else begin

            case (state)

                IDLE: begin
                    // Reception du premier bit de l'adresse
                    s_addr <= {6'b000000, sda_in};
                    t_bits <= 1;
                    state <= ADDR;
                end

                ADDR: begin

                    if (t_bits < 7) begin

                        s_addr <= {s_addr[5:0], sda_in};
                        t_bits <= t_bits + 1'b1;

                    end
                    else begin

                        // Reception du bit R/W
                        rw_rx <= sda_in;
                        t_bits <= 0;

                        if (s_addr == 7'h01)
                            state <= ACK_ADDR;
                        else
                            state <= NACK_ADDR;

                    end

                end

                ACK_ADDR: begin

                    // Le maitre a termine le neuvieme coup d'horloge
                    t_bits <= 0;

                    if (rw_rx == 1'b0)
                        state <= DATA_RX;
                    else
                        state <= DATA_TX;

                end

                NACK_ADDR: begin
                    state <= WAIT_STOP;
                end

                DATA_RX: begin

                    // Le maitre envoie les donnees a l'esclave
                    s_data_out[7-t_bits] <= sda_in;

                    if (t_bits == 7) begin
                        t_bits <= 0;
                        state <= ACK_DATA;
                    end
                    else begin
                        t_bits <= t_bits + 1'b1;
                    end

                end

                ACK_DATA: begin
                    state <= WAIT_STOP;
                end

                DATA_TX: begin

                    // L'esclave envoie les donnees au maitre
                    if (t_bits == 7) begin
                        t_bits <= 0;
                        state <= WAIT_NACK;
                    end
                    else begin
                        t_bits <= t_bits + 1'b1;
                    end

                end

                WAIT_NACK: begin
                    // Attente du neuvieme bit envoye par le maitre
                    state <= WAIT_STOP;
                end

                WAIT_STOP: begin
                    // Retour a l'etat initial
                    state <= IDLE;
                    t_bits <= 0;
                end

                default: begin
                    state <= IDLE;
                end

            endcase

        end
    end

    // Commande de SDA pendant la phase basse de SCL
    always_ff @(negedge scl or posedge rst) begin

        if (rst) begin
            sda_en <= 0;
        end

        else begin

            case (state)

                ACK_ADDR: begin
                    // ACK de l'adresse
                    sda_en <= 1;
                end

                ACK_DATA: begin
                    // ACK des donnees recues
                    sda_en <= 1;
                end

                DATA_TX: begin
                    // Bit a 0 : SDA est forcee a 0
                    // Bit a 1 : SDA est relachee
                    sda_en <= ~s_data_in[7-t_bits];
                end

                default: begin
                    sda_en <= 0;
                end

            endcase

        end
    end

endmodule