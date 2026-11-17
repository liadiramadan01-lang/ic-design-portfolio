package cpu_pkg;
    
    typedef enum logic[2:0] { 
        imm_I=3'b000,
        imm_S=3'b001,
        imm_B=3'b010,
        imm_U=3'b011,
        imm_J=3'b100
    } imm_sel_t;

endpackage