`timescale 1ns/1ps

module spi_tb; 

    //declaration des signaux
    logic clk,rst,start,mosi,miso,sclk,cs,rx_done,done;
    logic [7:0] tx_data,miso_data,mosi_data,rx_data;
    // signaux d'interconnexion
    logic sclk_wire,miso_wire,mosi_wire,cs_wire;


    // instanciation du spi_master
    spi_master master(
        .clk (clk),
        .rst (rst),
        .start (start),
        .miso (miso_wire),
        .mosi_data (mosi_data),
        .sclk (sclk_wire),
        .cs (cs_wire),
        .mosi (mosi_wire),
        .done (done),
        .miso_data (miso_data)
        

    );
    // instanciation du spi_slave
    spi_slave slave(
        .tx_data (tx_data),
        .cs (cs_wire),
        .sclk (sclk_wire),
        .mosi (mosi_wire),
        .miso (miso_wire),
        .rx_done (rx_done),
        .rx_data (rx_data)

    );
    task check();

        if(miso_data === tx_data)
            $display("OK | Master recu: %0h (attendu: %0h)", miso_data, tx_data);
        else
            $display("ERR | Master recu: %0h (attendu: %0h)", miso_data, tx_data);

        if(rx_data === mosi_data)
            $display("OK | Slave recu: %0h (attendu: %0h)", rx_data, mosi_data);
        else
            $display("ERR | Slave recu: %0h (attendu: %0h)", rx_data, mosi_data);
    endtask

    initial clk =0;
    always #10 clk= ~clk;

    initial begin 

        $dumpfile("spi_tb.vcd");
        $dumpvars(0,spi_tb);
        $display("DEBUT DE LA SIMULATION");

        #10;
        rst      = 1;
        start    = 0;
        mosi_data = 8'h00;
        tx_data   = 8'h00;
        #20;
        rst=0;
        mosi_data=8'hA5;
        tx_data=8'hC3;
        start=1;
        #20;
        start=0;
        #15000;
        check();
        $display("FIN DE LA SIMULATION");

        $finish;


    end


endmodule
