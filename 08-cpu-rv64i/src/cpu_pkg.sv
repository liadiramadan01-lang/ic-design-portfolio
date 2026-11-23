package cpu_pkg;
    
    //type d imm
    typedef enum logic[2:0] { 
        imm_I=3'b000,
        imm_S=3'b001,
        imm_B=3'b010,
        imm_U=3'b011,
        imm_J=3'b100
    } imm_sel_t;

    // Operations de l alu
    typedef enum logic[3:0] { 
        ADD=4'b0000,
        SUB=4'b0001,
        AND=4'b0010,
        OR=4'b0011,
        XOR=4'b0100,
        SLL=4'b0101,
        SRL=4'b0110,
        SRA=4'b0111,
        SLT=4'b1000,
        SLTU=4'b1001,
        PASS_B=4'b1010
    } alu_op_t;

    // CLASSE 
    typedef enum logic[2:0] { 
        cls_ADD_direct=3'b000,
        cls_PASS=3'b001,
        cls_BRANCH=3'b010,
        cls_R=3'b011,
        cls_I=3'b100
    } class_t;

    //origine de l ecriture en rd
    typedef enum logic[1:0] { 
        WB_alu=2'b00,
        WB_mem=2'b01,
        WB_pc4=2'b10
    } wb_sel_t;

    //possible entree a (1) de l alu
    typedef enum logic { 
        src_rs1=1'b0,
        src_pc=1'b1
     } src_a_t;

    //possible entree b (2) de l alu
    typedef enum logic { 
        src_rs2=1'b0,
        src_imm=1'b1
    } src_b_t;

endpackage