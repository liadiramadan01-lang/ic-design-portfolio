`timescale 1ns/1ps

module pc_tb ;
    

    localparam int XLEN = 64;
    //signaux
    logic clk,rst,pc_write;
    logic [XLEN-1:0] pc_next;
    logic [XLEN-1:0] pc;

    //instantiation du module
    pc #(.XLEN(64)) dut(
        .clk(clk),
        .rst(rst),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc(pc)
    );

    //horloge
    initial clk=0;
    always #10 clk=~clk;

    int N_err=0;
    // task
    task pc_check(
        input logic [63:0] pc_next_in,
        input logic pc_write_in,
        input logic [63:0] pc_exp,
        input string name
     );

     pc_write=pc_write_in;
     pc_next=pc_next_in;
     #20;

     if(pc_exp===pc)begin
        $display("Ok| pc: %0h| pc_write: %0h", pc, pc_write_in);
     end 
     else begin 
        $display("ERR| pc: %0h (PC_attendu %0h)| pc_write: %0h ", pc, pc_exp, pc_write_in);
     end
        
    endtask

    //initialisation du test
    initial begin 
        $dumpfile("build/pc_tb.vcd");
        $dumpvars(0,pc_tb);

        $display("DEBUT DE LA SIMULATION");
        #20;
        rst=1;
        pc_write = 0;
        pc_next='0;
        #20;
        rst=0;
        // Après reset : pc = 0
        pc_check(64'h4,1, 64'h4,"charge 4");
        pc_check(64'h8,1, 64'h8,"charge 8");
        pc_check(64'hC,1, 64'hC,"charge C");
        // Gel : pc_write=0, pc_next ignoré
        pc_check(64'h100, 0, 64'hC,"stall: pc gele");
        pc_check(64'h200, 0, 64'hC, "stall: 2e cycle");
        // Reprise
        pc_check(64'h10, 1, 64'h10, "reprise apres stall");
        // Grandes valeurs, 64 bits complets
        pc_check(64'h8000_0000_0000_0000, 1, 64'h8000_0000_0000_0000, "bit 63");
        pc_check(64'hFFFF_FFFF_FFFF_FFFC, 1, 64'hFFFF_FFFF_FFFF_FFFC, "max aligne");
        // saut vers l'arrière (adresse plus petite)
        pc_check(64'h0,1, 64'h0,"retour a 0");
        

        pc_check(64'h40, 1, 64'h40, "avant reset");
        rst = 1; 
        #5;
        if (pc === 64'h0) 
            $display("OK | reset asynchrone immediat");
        else begin 
            N_err = N_err + 1; 
            $display("ERR | reset asynchrone: pc=%0h | N erreur %0d ", pc, N_err); 
        end
        rst = 0;
        // Reset prioritaire sur pc_write
        pc_write = 1; 
        pc_next = 64'h99;
        rst = 1; 
        @(posedge clk); 
        #1;
        if (pc === 64'h0) 
            $display("OK | reset prioritaire sur pc_write");
        else begin 
            N_err = N_err + 1; 
            $display("ERR | reset non prioritaire |N erreur %0d", N_err); 
        end
        rst = 0;

        $display("FIN DE LA SIMULATION");
        $finish;
    end

endmodule