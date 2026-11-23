
module control_unit import cpu_pkg::*; (
    input logic [6:0] opcode,
    output logic reg_write,mem_read,mem_write,branch,jump,is_word,jalr_sel,
    output src_a_t alu_src_a,
    output src_b_t alu_src_b,
    output wb_sel_t wb_sel,
    output imm_sel_t imm_sel,
    output class_t alu_class
 );

 always_comb begin
    reg_write=0;
    mem_read=0;
    mem_write=0;
    branch=0;
    jump=0;
    is_word=0;
    jalr_sel=0;
    imm_sel=imm_I; 
    alu_src_a=src_rs1;
    alu_src_b=src_rs2;
    wb_sel=WB_alu; 
    alu_class=cls_ADD_direct;

    case (opcode)
        7'b0110011:begin       //op_r
            reg_write=1;
            alu_src_a=src_rs1;
            alu_src_b=src_rs2;
            wb_sel=WB_alu;
            alu_class=cls_R;
            is_word=0;
            jalr_sel=0;
        end   
        7'b0111011: begin       //op_r_w
            reg_write=1;
            alu_src_a=src_rs1;
            alu_src_b=src_rs2;
            wb_sel=WB_alu;
            alu_class=cls_R;
            is_word=1;
            jalr_sel=0;
        end  
        7'b0010011: begin       //op_imm
            reg_write=1;
            alu_src_a=src_rs1;
            alu_src_b=src_imm;
            wb_sel=WB_alu;
            imm_sel=imm_I;
            alu_class=cls_I;
            is_word=0;
            jalr_sel=0;
        end  
        7'b0011011:begin         //op_imm_w
            reg_write=1;
            alu_src_a=src_rs1;
            alu_src_b=src_imm;
            wb_sel=WB_alu;
            imm_sel=imm_I;
            alu_class=cls_I;
            is_word=1;
            jalr_sel=0;
        end 
        7'b0000011:begin         //load
            reg_write=1;
            alu_src_a=src_rs1;
            alu_src_b=src_imm;
            mem_read=1;
            wb_sel=WB_mem;
            imm_sel=imm_I;
            alu_class=cls_ADD_direct;
            is_word=0;
            jalr_sel=0;
        end 
        7'b0100011:begin           //store
            reg_write=0;
            alu_src_a=src_rs1;
            alu_src_b=src_imm;
            mem_write=1;
            imm_sel=imm_S;
            alu_class=cls_ADD_direct;
            is_word=0;
            jalr_sel=0;
        end  
        7'b1100011:begin            //Branch
            reg_write=0;
            alu_src_a=src_rs1;
            alu_src_b=src_rs2;
            branch=1;
            imm_sel=imm_B;
            alu_class=cls_BRANCH;
            is_word=0;
            jalr_sel=0;
        end  
        7'b0110111:begin           //lui
            reg_write=1;
            alu_src_b=src_imm;
            wb_sel=WB_alu;
            imm_sel=imm_U;
            alu_class=cls_PASS;
            jalr_sel=0;
        end 
        7'b0010111:begin           //auipc
            reg_write=1;
            alu_src_a=src_pc;
            alu_src_b=src_imm;
            wb_sel=WB_alu;
            imm_sel=imm_U;
            alu_class=cls_ADD_direct;
            is_word=0;
            jalr_sel=0;
        end 
        7'b1101111:begin           //jal
            reg_write=1;
            alu_src_a=src_pc;
            alu_src_b=src_imm;
            wb_sel=WB_pc4;
            jump=1;
            imm_sel=imm_J;
            alu_class=cls_ADD_direct;
            is_word=0;
            jalr_sel=0;
        end
        7'b1100111:begin         //jalr
            reg_write=1;
            alu_src_a=src_rs1;
            alu_src_b=src_imm;
            wb_sel=WB_pc4;
            jump=1;
            imm_sel=imm_I;
            alu_class=cls_ADD_direct;
            is_word=0;
            jalr_sel=1;
        end

        
        default: begin
            reg_write=0;
            mem_read=0;
            mem_write=0;
            alu_class=cls_ADD_direct;
            is_word=0;
            branch=0;
            jump=0;
        end
    endcase
 end
    
endmodule