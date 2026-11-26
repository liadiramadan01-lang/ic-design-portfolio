`timescale 1ns/1ps

module instr_mem_tb;
    
    // parameter
    localparam int DEPTH=4096;

    //signaux
    logic clk,en;
    logic [$clog2(DEPTH)-1:0] addr_m;
    logic [31:0] instr,instr_recu,instr_in;

    //instantiation
    instr_mem #(
        .DEPTH(DEPTH)
     ) dut(
        .clk(clk),
        .en(en),
        .addr_m(addr_m),
        .instr(instr)
    );

    //horloge
    initial clk=0;
    always #10 clk=~clk;

    int N_err=0;
    //task
    task check_mem_i(
        input logic [11:0]addr_m_in,
        input logic en_in,
        input logic [31:0] instr_exp,
        input string text
     );
        addr_m=addr_m_in;
        en=en_in;
        @(posedge clk);
        #1;
        if (instr_exp===instr) begin
            $display("OK |instruction: %0h | contexte :%0s",instr ,text);
        end else begin
            N_err=N_err+1;
            $display("ERR |instruction: %0h (ATTENDU: %0h) | N erreur= %0d | contexte: %0s ",instr,instr_exp,N_err,text);
        end
        
    endtask

    //test
    initial begin 
        $dumpfile("build/instr_mem_tb.vcd");
        $dumpvars(0,instr_mem_tb);

        $display("DEBUT DE LA SIMULATION");

        @(posedge clk);
        check_mem_i(12'd0, 1, 32'h00500093, "case 0");
        check_mem_i(12'd1, 1, 32'h00a00113, "case 1");
        check_mem_i(12'd2, 0, 32'h00a00113, "en=0: sortie gelee, adresse 2 ignoree");
        check_mem_i(12'd2, 1, 32'h002081b3, "reprise en=1: case 2");
        check_mem_i(12'd3, 1, 32'h00000013, "case jamais ecrite = NOP");
        if (N_err==0) begin
            $display("TOUT LES TESTS PASSENT");
        end else begin
            $display("N erreurs=%0d", N_err);
        end
        $display("FIN DE LA SIMULATION");
        $finish;


    end
endmodule