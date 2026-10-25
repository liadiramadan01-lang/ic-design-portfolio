`timescale 1ns/1ps

module i2c_tb;

    // Signaux du testbench
    logic clk, rst, start, rw;
    logic busy, ack_error;

    logic [7:0] data_in, data_out;
    logic [7:0] s_data_in, s_data_out;
    logic [6:0] addr;

    // Connexions entre le maitre et l'esclave
    wire scl_wire;
    tri1 sda_wire;

    // Instanciation du maitre
    i2c_master master(
        .clk(clk),
        .rst(rst),
        .start(start),
        .rw(rw),
        .addr(addr),
        .data_in(data_in),
        .busy(busy),
        .scl(scl_wire),
        .ack_error(ack_error),
        .sda(sda_wire),
        .data_out(data_out)
    );

    // Instanciation de l'esclave
    i2c_slave slave(
        .scl(scl_wire),
        .rst(rst),
        .rw(rw),
        .sda(sda_wire),
        .s_data_in(s_data_in),
        .s_data_out(s_data_out)
    );

    // Horloge du maitre
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Verification des donnees recues
    task check;
        begin

            if (rw == 1'b1) begin

                if ((data_out === s_data_in) &&
                    (ack_error === 1'b0))
                    $display("OK | Maitre recu : %0h (attendu : %0h)",
                             data_out, s_data_in);
                else
                    $display("ERR | Maitre recu : %0h (attendu : %0h), ack_error=%b",
                             data_out, s_data_in, ack_error);

            end
            else begin

                if ((s_data_out === data_in) &&
                    (ack_error === 1'b0))
                    $display("OK | Esclave recu : %0h (attendu : %0h)",
                             s_data_out, data_in);
                else
                    $display("ERR | Esclave recu : %0h (attendu : %0h), ack_error=%b",
                             s_data_out, data_in, ack_error);

            end

        end
    endtask

    // Lancement d'une transaction et verification
    task lancer_transfert(input logic mode);
        begin
            @(negedge clk);
            rw = mode;
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;

            // Attendre que le maitre termine
            wait (busy === 1'b1);
            wait (busy === 1'b0);

            #1;
            check();
        end
    endtask

    initial begin

        $dumpfile("i2c_tb.vcd");
        $dumpvars(0, i2c_tb);

        $display("DEBUT DE LA SIMULATION");

        // Initialisation
        rst = 1;
        start = 0;
        rw = 0;

        addr = 7'h01;
        data_in = 8'h00;
        s_data_in = 8'h00;

        repeat (3) @(negedge clk);
        rst = 0;

        // Donnees de test
        data_in = 8'hA5;
        s_data_in = 8'hC3;

        // Test 1 : le maitre envoie une donnee
        $display("--------------------------------");
        $display("TEST 1 : ECRITURE");
        lancer_transfert(1'b0);

        // Test 2 : le maitre lit une donnee
        $display("--------------------------------");
        $display("TEST 2 : LECTURE");
        lancer_transfert(1'b1);

        $display("--------------------------------");
        $display("FIN DE LA SIMULATION");

        #20;
        $finish;

    end

endmodule