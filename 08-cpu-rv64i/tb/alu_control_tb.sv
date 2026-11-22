`timescale 1ns/1ps

module alu_control_tb import cpu_pkg::*;;

    class_t alu_class;
    logic[2:0] funct3;
    logic funct7_5;
    alu_op_t alu_op;

    alu_control dut(
        .alu_class(alu_class),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .alu_op(alu_op)
    );

    int N_err=0;
    task alu_control_check(
        input class_t alu_class_in,
        input logic[2:0] funct3_in,
        input logic funct7_5_in,
        input alu_op_t alu_op_exp,
        input string name_op
    );
        alu_class=alu_class_in;
        funct3=funct3_in;
        funct7_5=funct7_5_in;
        #20;
        if (alu_op===alu_op_exp) begin
            $display("OK | %s | alu_class=%0d | alu_op=%0d",name_op , alu_class , alu_op);
        end 
        else begin
            N_err=N_err+1;
            $display("ERR | %s | alu_class=%0d | alu_op=%0d (alu_op_exp %0d) | N erreurs=%0d ",name_op , alu_class , alu_op, alu_op_exp, N_err);
        end
        
    endtask
    
    initial begin 
         $dumpfile("build/alu_control_tb.vcd");
    $dumpvars(0,alu_control_tb);

        // ADD_direct et PASS : funct3/funct7_5 sans effet
alu_control_check(cls_ADD_direct, 3'b000, 1'b0, ADD, "ADD_direct f3=000");
alu_control_check(cls_ADD_direct, 3'b111, 1'b1, ADD, "ADD_direct f3=111 f7=1");
alu_control_check(cls_PASS, 3'b000, 1'b0, PASS_B, "PASS f3=000");
alu_control_check(cls_PASS, 3'b101, 1'b1, PASS_B, "PASS f3=101 f7=1");

// BRANCH
alu_control_check(cls_BRANCH, 3'b000, 1'b0, SUB, "BEQ");
alu_control_check(cls_BRANCH, 3'b001, 1'b0, SUB, "BNE");
alu_control_check(cls_BRANCH, 3'b100, 1'b0, SLT, "BLT");
alu_control_check(cls_BRANCH, 3'b101, 1'b0, SLT, "BGE");
alu_control_check(cls_BRANCH, 3'b110, 1'b0, SLTU, "BLTU");
alu_control_check(cls_BRANCH, 3'b111, 1'b0, SLTU, "BGEU");
alu_control_check(cls_BRANCH, 3'b010, 1'b0, ADD, "BRANCH f3=010 invalide");
alu_control_check(cls_BRANCH, 3'b011, 1'b0, ADD, "BRANCH f3=011 invalide");
alu_control_check(cls_BRANCH, 3'b000, 1'b1, SUB, "BEQ f7=1 ignore");

// R-type
alu_control_check(cls_R, 3'b000, 1'b0, ADD, "ADD");
alu_control_check(cls_R, 3'b000, 1'b1, SUB, "SUB");
alu_control_check(cls_R, 3'b001, 1'b0, SLL, "SLL");
alu_control_check(cls_R, 3'b010, 1'b0, SLT, "SLT");
alu_control_check(cls_R, 3'b011, 1'b0, SLTU, "SLTU");
alu_control_check(cls_R, 3'b100, 1'b0, XOR, "XOR");
alu_control_check(cls_R, 3'b101, 1'b0, SRL, "SRL");
alu_control_check(cls_R, 3'b101, 1'b1, SRA, "SRA");
alu_control_check(cls_R, 3'b110, 1'b0, OR, "OR");
alu_control_check(cls_R, 3'b111, 1'b0, AND, "AND");

// I-type
alu_control_check(cls_I, 3'b000, 1'b0, ADD, "ADDI");
alu_control_check(cls_I, 3'b000, 1'b1, ADD, "ADDI imm negatif (f7=1 ignore)");
alu_control_check(cls_I, 3'b001, 1'b0, SLL, "SLLI");
alu_control_check(cls_I, 3'b010, 1'b0, SLT, "SLTI");
alu_control_check(cls_I, 3'b010, 1'b1, SLT, "SLTI imm negatif");
alu_control_check(cls_I, 3'b011, 1'b0, SLTU, "SLTIU");
alu_control_check(cls_I, 3'b100, 1'b0, XOR, "XORI");
alu_control_check(cls_I, 3'b100, 1'b1, XOR, "XORI imm negatif");
alu_control_check(cls_I, 3'b101, 1'b0, SRL, "SRLI");
alu_control_check(cls_I, 3'b101, 1'b1, SRA, "SRAI");
alu_control_check(cls_I, 3'b110, 1'b0, OR, "ORI");
alu_control_check(cls_I, 3'b110, 1'b1, OR, "ORI imm negatif");
alu_control_check(cls_I, 3'b111, 1'b0, AND, "ANDI");
alu_control_check(cls_I, 3'b111, 1'b1, AND, "ANDI imm negatif");

// Classe hors enum -> default ADD
alu_control_check(class_t'(3'b111), 3'b000, 1'b0, ADD, "classe invalide");

    if (N_err == 0) begin 
        $display("TOUS LES TESTS PASSENT"); 
    end
    else begin 
        $display("N erreurs=%0d", N_err); 
    end

    $finish;

    end

endmodule
