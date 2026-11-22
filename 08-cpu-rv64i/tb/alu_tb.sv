`timescale 1ns/1ps

module alu_tb import cpu_pkg::*; #(
    parameter int XLEN=64
);
    logic[XLEN-1:0] a,b,result;
    logic zero,is_word;
    alu_op_t alu_op;

    localparam logic [63:0] ONES = 64'hFFFFFFFFFFFFFFFF;
    localparam logic [63:0] MINS = 64'h8000000000000000;
    localparam logic [63:0] MAXS = 64'h7FFFFFFFFFFFFFFF;
    localparam logic [63:0] ALTA = 64'hAAAAAAAAAAAAAAAA;
    localparam logic [63:0] ALT5 = 64'h5555555555555555;


   alu #(.XLEN(64)) dut(
        .a(a),
        .b(b),
        .result(result),
        .zero(zero),
        .is_word(is_word),
        .alu_op(alu_op)
   ); 
    int N_err=6'd0;
    task check_alu(
        input logic [XLEN-1:0] a_in,
        input logic [XLEN-1:0] b_in,
        input logic is_word_in,
        input logic [XLEN-1:0] expected_r,
        input string name_op,
        input alu_op_t op_in,
        input logic zero_exp
     );
     a=a_in;
     b=b_in; 
     alu_op=op_in;
     is_word=is_word_in;
    #20;
     if (result===expected_r &&zero_exp===zero) begin
         $display("OK  | %s | a=%0d b=%0d | result=%0d | zero=%0d", name_op, a_in, b_in, result,zero);
     end 
     else begin
        N_err=N_err+1;
         $display("ERR | %s | a=%0d b=%0d W=%0d| result=%0d (expected %0d) | zero=%0d (zero_exp %0d) | N erreurs=%0d", name_op, a_in, b_in,is_word, result, expected_r,zero,zero_exp,N_err);
     end
    
    endtask

   initial begin 
    $dumpfile("build/alu_tb.vcd");
    $dumpvars(0,alu_tb);

    // ---------- ADD, W=0 ----------
check_alu(64'h0, 64'h0, 1'b0, 64'h0, "ADD 0+0", ADD, 1'b1);
check_alu(64'd5, 64'd7, 1'b0, 64'd12, "ADD 5+7", ADD, 1'b0);
check_alu(ONES, 64'd1, 1'b0, 64'h0, "ADD overflow 64b", ADD, 1'b1);
check_alu(MAXS, 64'd1, 1'b0, MINS, "ADD overflow signe", ADD, 1'b0);
check_alu(64'hFFFFFFFFFFFFFFFB, 64'd10, 1'b0, 64'd5, "ADD -5+10", ADD, 1'b0);
// ---------- ADD, W=1 ----------
check_alu(64'h7FFFFFFF, 64'd1, 1'b1, 64'hFFFFFFFF80000000, "ADDW 7FFFFFFF+1", ADD, 1'b0);
check_alu(64'hFFFFFFFF, 64'd1, 1'b1, 64'h0, "ADDW FFFFFFFF+1", ADD, 1'b1);
check_alu(64'h1234567800000001, 64'd1, 1'b1, 64'd2, "ADDW bits hauts ignores", ADD, 1'b0);
check_alu(64'd5, 64'd7, 1'b1, 64'd12, "ADDW 5+7", ADD, 1'b0);

// ---------- SUB, W=0 ----------
check_alu(64'h123456789ABCDEF0, 64'h123456789ABCDEF0, 1'b0, 64'h0, "SUB a-a", SUB, 1'b1);
check_alu(64'h0, 64'd1, 1'b0, ONES, "SUB 0-1", SUB, 1'b0);
check_alu(64'd10, 64'd3, 1'b0, 64'd7, "SUB 10-3", SUB, 1'b0);
check_alu(64'd3, 64'd10, 1'b0, 64'hFFFFFFFFFFFFFFF9, "SUB 3-10", SUB, 1'b0);
check_alu(MINS, 64'd1, 1'b0, MAXS, "SUB overflow signe", SUB, 1'b0);
// ---------- SUB, W=1 ----------
check_alu(64'h0, 64'd1, 1'b1, ONES, "SUBW 0-1", SUB, 1'b0);
check_alu(64'h80000000, 64'd1, 1'b1, 64'h000000007FFFFFFF, "SUBW 80000000-1", SUB, 1'b0);

// ---------- AND ----------
check_alu(64'h0, ONES, 1'b0, 64'h0, "AND 0&F", AND, 1'b1);
check_alu(ONES, ONES, 1'b0, ONES, "AND F&F", AND, 1'b0);
check_alu(ALTA, ALT5, 1'b0, 64'h0, "AND A&5", AND, 1'b1);
check_alu(64'h123456789ABCDEF0, 64'h123456789ABCDEF0, 1'b0, 64'h123456789ABCDEF0, "AND a&a", AND, 1'b0);
check_alu(64'hFFFFFFFF00000000, ONES, 1'b1, 64'hFFFFFFFF00000000, "AND W ignore", AND, 1'b0);
// ---------- OR ----------
check_alu(64'h0, ONES, 1'b0, ONES, "OR 0|F", OR, 1'b0);
check_alu(ONES, ONES, 1'b0, ONES, "OR F|F", OR, 1'b0);
check_alu(ALTA, ALT5, 1'b0, ONES, "OR A|5", OR, 1'b0);
check_alu(64'h123456789ABCDEF0, 64'h123456789ABCDEF0, 1'b0, 64'h123456789ABCDEF0, "OR a|a", OR, 1'b0);
check_alu(64'hFFFFFFFF00000000, 64'h1, 1'b1, 64'hFFFFFFFF00000001, "OR W ignore", OR, 1'b0);
// ---------- XOR ----------
check_alu(64'h0, ONES, 1'b0, ONES, "XOR 0^F", XOR, 1'b0);
check_alu(ONES, ONES, 1'b0, 64'h0, "XOR F^F", XOR, 1'b1);
check_alu(ALTA, ALT5, 1'b0, ONES, "XOR A^5", XOR, 1'b0);
check_alu(64'h123456789ABCDEF0, 64'h123456789ABCDEF0, 1'b0, 64'h0, "XOR a^a", XOR, 1'b1);
check_alu(64'hFFFFFFFF00000000, ONES, 1'b1, 64'h00000000FFFFFFFF, "XOR W ignore", XOR, 1'b0);

// ---------- SLL, W=0 ----------
check_alu(64'h123456789ABCDEF0, 64'd0, 1'b0, 64'h123456789ABCDEF0, "SLL 0", SLL, 1'b0);
check_alu(64'd1, 64'd1, 1'b0, 64'd2, "SLL 1", SLL, 1'b0);
check_alu(64'd1, 64'd4, 1'b0, 64'h10, "SLL 4", SLL, 1'b0);
check_alu(64'd1, 64'd32, 1'b0, 64'h100000000, "SLL 32", SLL, 1'b0);
check_alu(64'd1, 64'd63, 1'b0, MINS, "SLL 63", SLL, 1'b0);
check_alu(64'd1, 64'h41, 1'b0, 64'd2, "SLL b hauts ignores", SLL, 1'b0);
check_alu(ONES, 64'd4, 1'b0, 64'hFFFFFFFFFFFFFFF0, "SLL bits perdus", SLL, 1'b0);
// ---------- SLL, W=1 ----------
check_alu(64'h12345678, 64'd0, 1'b1, 64'h0000000012345678, "SLLW 0", SLL, 1'b0);
check_alu(64'd1, 64'd1, 1'b1, 64'd2, "SLLW 1", SLL, 1'b0);
check_alu(64'd1, 64'd31, 1'b1, 64'hFFFFFFFF80000000, "SLLW 31", SLL, 1'b0);
check_alu(64'd5, 64'd32, 1'b1, 64'd5, "SLLW b=32 -> 0", SLL, 1'b0);
check_alu(64'h40000000, 64'd1, 1'b1, 64'hFFFFFFFF80000000, "SLLW signe", SLL, 1'b0);

// ---------- SRL, W=0 ----------
check_alu(64'h123456789ABCDEF0, 64'd0, 1'b0, 64'h123456789ABCDEF0, "SRL 0", SRL, 1'b0);
check_alu(MINS, 64'd1, 1'b0, 64'h4000000000000000, "SRL 1", SRL, 1'b0);
check_alu(64'hF0, 64'd4, 1'b0, 64'h0F, "SRL 4", SRL, 1'b0);
check_alu(ONES, 64'd32, 1'b0, 64'h00000000FFFFFFFF, "SRL 32", SRL, 1'b0);
check_alu(MINS, 64'd63, 1'b0, 64'd1, "SRL 63", SRL, 1'b0);
check_alu(ONES, 64'd1, 1'b0, MAXS, "SRL neg", SRL, 1'b0);
// ---------- SRL, W=1 ----------
check_alu(64'hFFFFFFFF00000010, 64'd4, 1'b1, 64'd1, "SRLW bits hauts ignores", SRL, 1'b0);
check_alu(64'h0000000080000000, 64'd0, 1'b1, 64'hFFFFFFFF80000000, "SRLW 0 ext signe", SRL, 1'b0);
check_alu(64'hFFFFFFFF, 64'd4, 1'b1, 64'h000000000FFFFFFF, "SRLW 4", SRL, 1'b0);
check_alu(64'hFFFFFFFF, 64'd1, 1'b1, 64'h000000007FFFFFFF, "SRLW 1", SRL, 1'b0);

// ---------- SRA, W=0 ----------
check_alu(MAXS, 64'd1, 1'b0, 64'h3FFFFFFFFFFFFFFF, "SRA pos", SRA, 1'b0);
check_alu(MINS, 64'd1, 1'b0, 64'hC000000000000000, "SRA neg 1", SRA, 1'b0);
check_alu(ONES, 64'd63, 1'b0, ONES, "SRA F>>>63", SRA, 1'b0);
check_alu(MINS, 64'd0, 1'b0, MINS, "SRA 0", SRA, 1'b0);
check_alu(MINS, 64'd63, 1'b0, ONES, "SRA MIN>>>63", SRA, 1'b0);
// ---------- SRA, W=1 ----------
check_alu(64'h80000000, 64'd4, 1'b1, 64'hFFFFFFFFF8000000, "SRAW neg", SRA, 1'b0);
check_alu(64'h7FFFFFFF, 64'd4, 1'b1, 64'h0000000007FFFFFF, "SRAW pos", SRA, 1'b0);
check_alu(64'hFFFFFFFF00000010, 64'd4, 1'b1, 64'd1, "SRAW bits hauts ignores", SRA, 1'b0);

// ---------- SLT / SLTU ----------
check_alu(64'd1, 64'd2, 1'b0, 64'd1, "SLT 1<2", SLT, 1'b0);
check_alu(64'd1, 64'd2, 1'b0, 64'd1, "SLTU 1<2", SLTU, 1'b0);
check_alu(64'd5, 64'd5, 1'b0, 64'd0, "SLT 5=5", SLT, 1'b1);
check_alu(64'd5, 64'd5, 1'b0, 64'd0, "SLTU 5=5", SLTU, 1'b1);
check_alu(64'd2, 64'd1, 1'b0, 64'd0, "SLT 2>1", SLT, 1'b1);
check_alu(64'd2, 64'd1, 1'b0, 64'd0, "SLTU 2>1", SLTU, 1'b1);
check_alu(ONES, 64'd1, 1'b0, 64'd1, "SLT -1<1", SLT, 1'b0);
check_alu(ONES, 64'd1, 1'b0, 64'd0, "SLTU F<1", SLTU, 1'b1);
check_alu(64'd1, ONES, 1'b0, 64'd0, "SLT 1<-1", SLT, 1'b1);
check_alu(64'd1, ONES, 1'b0, 64'd1, "SLTU 1<F", SLTU, 1'b0);
check_alu(MINS, MAXS, 1'b0, 64'd1, "SLT MIN<MAX", SLT, 1'b0);
check_alu(MINS, MAXS, 1'b0, 64'd0, "SLTU MIN<MAX", SLTU, 1'b1);
check_alu(ONES, 64'd1, 1'b1, 64'd1, "SLT W ignore", SLT, 1'b0);

// ---------- PASS_B et default ----------
check_alu(64'h123, 64'h0, 1'b0, 64'h0, "PASS_B 0", PASS_B, 1'b1);
check_alu(64'h0, ONES, 1'b0, ONES, "PASS_B F", PASS_B, 1'b0);
check_alu(ALT5, ALTA, 1'b0, ALTA, "PASS_B motif", PASS_B, 1'b0);
check_alu(64'h123, 64'h456, 1'b0, 64'h0, "DEFAULT", alu_op_t'(4'b1111), 1'b1);

    if(N_err==0)begin 
        $display("TOUS LES TESTS PASSENT");
    end
    else begin 
        $display("N erreurs=%0d",N_err);
    end

    $finish;
   end
endmodule
 