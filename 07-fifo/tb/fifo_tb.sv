`timescale 1ns/1ps

module fifo_tb;

    // Déclaration des signaux
     logic clk,rst,wr_en,rd_en,full,empty;
     logic [31:0] wr_data,rd_data,received;
    

    // Instanciation du FIFO
    fifo #(
        .DATA_WIDTH(32), 
        .DEPTH(1024) ,
        .PTR_WIDTH(11) 
    ) dut(
        .clk (clk),
        .rst (rst),
        .wr_en (wr_en),
        .rd_en (rd_en),
        .full (full),
        .empty (empty),
        .wr_data (wr_data),
        .rd_data (rd_data)

    );
    // Génèration de  l'horloge
    initial clk=0;
    always #10 clk=~clk;



    task write_data(input logic [31:0] data);
        if (!full) begin 
            wr_en=1; 
            wr_data=data; 
            @(posedge clk);
            wr_en=0;
            $display("Write: %0h", data);
        end
        else 
            $display("ERROR | FIFO full");
        
    endtask

    task read_data(output logic [31:0] data);
        if(!empty) begin 
            rd_en=1;
            @(posedge clk);
            #3 // juste pour etre sur de lire quand ,stable
            data=rd_data;
            rd_en=0;
            $display("Read: %0h", data);
        end
        else 
            $display("ERROR | FIFO empty");
    endtask
    
    initial begin

        $dumpfile("fifo.vcd");
        $dumpvars(0,fifo_tb);

        $display("DEBUT DE LA SIMULATION");

        rst=1;
        wr_data='0;
        rd_en=0;
        wr_en=0;

        @(posedge clk);
        rst=0;

        // test écriture
        write_data(32'hA5A5A5A5);
        write_data(32'hC3C3C3C3);

        // test lecture
        read_data(received);
        read_data(received);

        rst = 1;
        @(posedge clk);
        rst = 0;

        // test full
        repeat(1024) write_data($random);
        if(full) $display("OK | FIFO full");
        else     $display("ERR | FIFO should be full");

        // test empty
        repeat(1024) read_data(received);
        if(empty) $display("OK | FIFO empty");
        else      $display("ERR | FIFO should be empty");
        
        $display("FIN DE LA SIMULATION");

        $finish;
    end

endmodule