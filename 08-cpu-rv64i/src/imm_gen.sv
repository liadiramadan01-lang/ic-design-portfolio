module imm_gen import cpu_pkg::*; #(
    parameter int XLEN = 64
 )(
    input logic [31:0] inst,
    input imm_sel_t imm_sel,
    output logic [XLEN-1:0] imm
 );

    always_comb begin
        case (imm_sel)
            imm_I:begin 
                imm={{(XLEN-12){inst[31]}},inst[31:20]};
            end
            imm_S:begin 
                imm={{(XLEN-12){inst[31]}},inst[31:25],inst[11:7]};
            end
            imm_B:begin 
                imm={{(XLEN-13){inst[31]}},{inst[31]},inst[7],inst[30:25],inst[11:8],1'b0};
            end
            imm_U:begin 
                imm={{(XLEN-32){inst[31]}},inst[31:12],12'b000000000000};
            end
            imm_J:begin 
                imm={{(XLEN-21){inst[31]}},{inst[31]},inst[19:12],inst[20],inst[30:21],1'b0};
            end
            default: begin
                imm='0;
            end
        endcase
    end

endmodule