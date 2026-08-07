`timescale 1ns/1ps

module uart_tx_tb;
    //Declaration des signaux

    logic clk,rst,tx_start;
    logic [7:0] tx_data;
    logic tx,tx_busy;

    //instantiations de l'uart

    uart_tx dut(
        .clk (clk),
        .rst (rst),
        .tx_start (tx_start),
        .tx (tx),
        .tx_busy (tx_busy),
        .tx_data (tx_data)
    );

    // Generation de l'horloge
initial clk = 0;
always #10 clk = ~clk;

initial begin
    $dumpfile("uart_tx_tb.vcd");
    $dumpvars(0, uart_tx_tb);
    $display("DEBUT SIMULATION");

    // Reset
    rst      = 1;
    tx_start = 0;
    tx_data  = 8'h00;
    
    #40;  // attendre 2 cycles (40ns)
    rst = 0;

    #20;  // attendre 1 cycle
    tx_data  = 8'h41;
    tx_start = 1;
    
    #20;  // attendre 1 cycle
    tx_start = 0;

    // Attendre la fin — 4340 cycles × 20ns = 86800ns
    #200000;

    $display("FIN SIMULATION");
    $finish;
end


endmodule