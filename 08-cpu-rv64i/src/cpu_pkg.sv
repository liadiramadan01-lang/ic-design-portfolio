package cpu_pkg;
    
    typedef enum logic[2:0] { 
        imm_I=3'b000,
        imm_S=3'b001,
        imm_B=3'b010,
        imm_U=3'b011,
        imm_J=3'b100
    } imm_sel_t;

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

    typedef enum logic[2:0] { 
        cls_ADD_direct=3'b000,
        cls_PASS=3'b001,
        cls_BRANCH=3'b010,
        cls_R=3'b011,
        cls_I=3'b100
    } class_t;

endpackage