`timescale 1ns/1ps

module control_unit_tb import cpu_pkg::*;;

    // signaux
    logic [6:0] opcode;
    logic reg_write,mem_read,mem_write,branch,jump,is_word,jalr_sel;
    src_a_t alu_src_a;
    src_b_t alu_src_b;
    wb_sel_t wb_sel;
    imm_sel_t imm_sel;
    class_t alu_class;

    //instantiations du module dut
    control_unit dut(
        .opcode(opcode),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .jump(jump),
        .is_word(is_word),
        .jalr_sel(jalr_sel),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .wb_sel(wb_sel),
        .imm_sel(imm_sel),
        .alu_class(alu_class)

    );

    int N_err=0;

    task control(
        input logic [6:0] opcode_in,
        input logic reg_write_exp,
        input logic mem_read_exp,
        input logic mem_write_exp,
        input logic branch_exp,
        input logic jump_exp,
        input logic is_word_exp,
        input logic jalr_sel_exp,
        input src_a_t alu_src_a_exp,
        input src_b_t alu_src_b_exp,
        input wb_sel_t wb_sel_exp,
        input imm_sel_t imm_sel_exp,
        input class_t alu_class_exp,
        input string name

     );
        opcode=opcode_in;
        #20;

     if (reg_write===reg_write_exp && mem_read===mem_read_exp && mem_write===mem_write_exp && branch===branch_exp && jump===jump_exp && is_word===is_word_exp && jalr_sel===jalr_sel_exp && alu_src_a===alu_src_a_exp && alu_src_b===alu_src_b_exp && wb_sel===wb_sel_exp && imm_sel===imm_sel_exp && alu_class===alu_class_exp) begin
        $display("OK | %s", name);
     end 
     else begin
        N_err=N_err+1;
        $display("ERR | %s | N erreurs=%0d", name, N_err);
     end
        
    endtask



    initial begin 
        $dumpfile("build/control_unit_tb.vcd");
        $dumpvars(0,control_unit_tb);

        control(7'b0110011, 1,0,0,0,0,0,0, src_rs1, src_rs2, WB_alu, imm_I, cls_R,          "op-r");
        control(7'b0111011, 1,0,0,0,0,1,0, src_rs1, src_rs2, WB_alu, imm_I, cls_R,          "op-r-w");
        control(7'b0010011, 1,0,0,0,0,0,0, src_rs1, src_imm, WB_alu, imm_I, cls_I,          "op-imm");
        control(7'b0011011, 1,0,0,0,0,1,0, src_rs1, src_imm, WB_alu, imm_I, cls_I,          "op-imm-w");
        control(7'b0000011, 1,1,0,0,0,0,0, src_rs1, src_imm, WB_mem, imm_I, cls_ADD_direct, "load");
        control(7'b0100011, 0,0,1,0,0,0,0, src_rs1, src_imm, WB_alu, imm_S, cls_ADD_direct, "store");
        control(7'b1100011, 0,0,0,1,0,0,0, src_rs1, src_rs2, WB_alu, imm_B, cls_BRANCH,     "branch");
        control(7'b0110111, 1,0,0,0,0,0,0, src_rs1, src_imm, WB_alu, imm_U, cls_PASS,       "lui");
        control(7'b0010111, 1,0,0,0,0,0,0, src_pc,  src_imm, WB_alu, imm_U, cls_ADD_direct, "auipc");
        control(7'b1101111, 1,0,0,0,1,0,0, src_pc,  src_imm, WB_pc4,  imm_J, cls_ADD_direct, "jal");
        control(7'b1100111, 1,0,0,0,1,0,1, src_rs1, src_imm, WB_pc4,  imm_I, cls_ADD_direct, "jalr");
        control(7'b1111111, 0,0,0,0,0,0,0, src_rs1, src_rs2, WB_alu, imm_I, cls_ADD_direct, "opcode illegal");


        // ---------- Enchaînements : détection de latch ----------
// load (mem_read=1) puis op-r : mem_read doit retomber à 0, wb_sel à WB_alu
control(7'b0000011, 1,1,0,0,0,0,0, src_rs1, src_imm, WB_mem, imm_I, cls_ADD_direct, "seq: load");
control(7'b0110011, 1,0,0,0,0,0,0, src_rs1, src_rs2, WB_alu, imm_I, cls_R,          "seq: op-r apres load");

// store (mem_write=1) puis op-r : mem_write doit retomber à 0
control(7'b0100011, 0,0,1,0,0,0,0, src_rs1, src_imm, WB_alu, imm_S, cls_ADD_direct, "seq: store");
control(7'b0110011, 1,0,0,0,0,0,0, src_rs1, src_rs2, WB_alu, imm_I, cls_R,          "seq: op-r apres store");

// branch (branch=1) puis op-imm : branch doit retomber à 0
control(7'b1100011, 0,0,0,1,0,0,0, src_rs1, src_rs2, WB_alu, imm_B, cls_BRANCH,     "seq: branch");
control(7'b0010011, 1,0,0,0,0,0,0, src_rs1, src_imm, WB_alu, imm_I, cls_I,          "seq: op-imm apres branch");

// jalr (jump=1, jalr_sel=1) puis jal : jalr_sel doit retomber à 0
control(7'b1100111, 1,0,0,0,1,0,1, src_rs1, src_imm, WB_pc4, imm_I, cls_ADD_direct, "seq: jalr");
control(7'b1101111, 1,0,0,0,1,0,0, src_pc,  src_imm, WB_pc4, imm_J, cls_ADD_direct, "seq: jal apres jalr (jalr_sel=0)");

// op-r-w (is_word=1) puis op-r : is_word doit retomber à 0
control(7'b0111011, 1,0,0,0,0,1,0, src_rs1, src_rs2, WB_alu, imm_I, cls_R,          "seq: op-r-w");
control(7'b0110011, 1,0,0,0,0,0,0, src_rs1, src_rs2, WB_alu, imm_I, cls_R,          "seq: op-r apres op-r-w (is_word=0)");

// auipc (src_pc) puis op-r : alu_src_a doit revenir à src_rs1
control(7'b0010111, 1,0,0,0,0,0,0, src_pc,  src_imm, WB_alu, imm_U, cls_ADD_direct, "seq: auipc");
control(7'b0110011, 1,0,0,0,0,0,0, src_rs1, src_rs2, WB_alu, imm_I, cls_R,          "seq: op-r apres auipc (src_a=rs1)");

// instruction valide puis opcode illégal : tout retombe aux défauts
control(7'b0000011, 1,1,0,0,0,0,0, src_rs1, src_imm, WB_mem, imm_I, cls_ADD_direct, "seq: load");
control(7'b0000000, 0,0,0,0,0,0,0, src_rs1, src_rs2, WB_alu, imm_I, cls_ADD_direct, "seq: illegal 0000000 apres load");

        if(N_err==0)begin 
            $display("TOUS LES TESTS PASSENT");
        end
        else begin 
            $display("N erreurs=%0d",N_err);
        end

        $finish;
    end
    
endmodule