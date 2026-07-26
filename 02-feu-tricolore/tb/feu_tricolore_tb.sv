`timescale 1ns/1ps

module feu_tricolore_tb;

// Déclaration des signaux
    logic clk;
    logic rst;
    logic en;
    logic red;
    logic green;
    logic orange;

    feu_tricolore dut(
        .clk (clk),
        .rst (rst),
        .en (en),
        .red (red),
        .green (green),
        .orange (orange)
    );

    
    // Génération de l'horloge
    initial clk = 0;
    always #5 clk = ~clk;  // période de 10ns — 100MHz

    

   initial begin

    $dumpfile("feu_tricolore_tb.vcd");
    $dumpvars(0,feu_tricolore_tb);
    
    // 1. Initialisation
    rst = 1;
    en  = 0;

    // 2. Attendre 2 cycles puis relâcher le reset
    @(posedge clk);
    @(posedge clk);
    rst = 0;

    // 3. Activer le feu
    en = 1;

    // 4. Laisser tourner 
    // VERT=30 + ORANGE=5 + ROUGE=30 = 65 cycles minimum
    // Pour voir 2 cycles complets : 130 cycles
    repeat(150) @(posedge clk);

    $finish;
end

endmodule