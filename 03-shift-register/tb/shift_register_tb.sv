`timescale 1ns/1ps

module shift_register_tb;

    //Declaration des signaux
    logic clk, rst, sin, load,sout;
    logic [7:0] din,dout;

    //Instaciation du registre

    shift_register dut(
        .clk  (clk),
        .rst (rst),
        .sin (sin),
        .load (load),
        .din (din),
        .dout (dout),
        .sout (sout)
    );

    // generation de l'horloge 
    initial clk=0;
    always #5 clk= ~clk;

    task check(
        input load_in,
        input sin_in,
        input [7:0] din_in,
        input [7:0] expected_dout,
        input expected_sout,
        input string load_type
    );
        load=load_in; sin=sin_in; din=din_in;

        @(posedge clk);
        #1;  // attendre 1ns après le front pour lire la valeur stable
        if(load) begin
            if(dout === expected_dout)
                $display("OK  | %s | sin=%0b din=%0b | dout=%0b", load_type, sin_in, din_in, dout);
            else
                $display("ERR | %s | sin=%0b din=%0b | dout=%0b (expected_dout %0b)", load_type, sin_in, din_in, dout, expected_dout);
        end
        else begin 
            if(sout === expected_sout)
                $display("OK  | %s | sin=%0b din=%0b | sout=%0b", load_type, sin_in, din_in, sout);
            else
                $display("ERR | %s | sin=%0b din=%0b | sout=%0b (expected_sout %0b)", load_type, sin_in, din_in, sout, expected_sout);
            
        end
    endtask


    initial begin 

        $dumpfile("shift_register_tb.vcd");
        $dumpvars(0,shift_register_tb);

        //initialisation
        rst=1;
        @(posedge clk);
        @(posedge clk);
        rst=0;

        //Mode chargement
        check(1'b1, 1'b1, 8'b10101010, 8'b10101010, 1'b1, "Mode chargement" );
        check(1'b1, 1'b0, 8'b01010101, 8'b01010101, 1'b0, "Mode chargement" );

        //Mode décalage
        #1;  // attendre 1ns après le front pour lire la valeur stable
        check(1'b0, 1'b1, 8'b10101010, 8'b00000000, 1'b1, "Mode décalage" );
        #1;  // attendre 1ns après le front pour lire la valeur stable
        check(1'b0, 1'b0, 8'b01010101, 8'b00000000, 1'b0, "Mode décalage" );

        $finish;
    end
endmodule
