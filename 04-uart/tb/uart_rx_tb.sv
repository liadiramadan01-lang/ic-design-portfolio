`timescale 1ns/1ps

module uart_rx_tb;
    //Declaration des signaux

    logic clk,rst,rx;
    logic [7:0] rx_data;
    logic rx_done;

    //instantiations de l'uart

    uart_rx dut(
        .clk (clk),
        .rst (rst),
        .rx (rx),
        .rx_done (rx_done),
        .rx_data (rx_data)
    );

    // Generation de l'horloge
initial clk = 0;
always #10 clk = ~clk;

initial begin
    $dumpfile("uart_rx_tb.vcd");
    $dumpvars(0, uart_rx_tb);
    $display("DEBUT SIMULATION");

    // Reset
    rst = 1;
    rx=1;
    
    
    
    #60;  // attendre 3 cycles (60ns)
    rst = 0;

    rx = 1;      // IDLE
   #8680;
    rx = 0;      // START bit
    #8680;
    rx = 1;      // D0 = 1
    #8680;
    rx = 0;      // D1 = 0
    #8680;
    rx = 1;      // D2 = 1
    #8680;
    rx = 0;      // D3 = 0
    #8680;
    rx = 1;      // D4 = 1
    #8680;
    rx = 0;      // D5 = 0
    #8680;
    rx = 1;      // D6 = 1
    #8680;
    rx = 0;      // D7 = 0
    #8680;
    rx = 1;      // STOP bit
    #8680;

    #500000;
    $display("FIN SIMULATION");
    $finish;
end


endmodule