
module alu_control import cpu_pkg::*; (
    input class_t alu_class,
    input logic[2:0] funct3,
    input logic funct7_5,
    output alu_op_t alu_op
    
);

always_comb begin 

    case (alu_class)
        cls_ADD_direct: begin alu_op=ADD; end
        cls_PASS: begin alu_op=PASS_B; end
        cls_BRANCH:begin 
            case (funct3)
                3'b000,3'b001:begin 
                    alu_op=SUB;
                end
                3'b100:begin 
                    alu_op=SLT;
                end
                3'b101:begin 
                    alu_op=SLT;
                end
                3'b110,3'b111:begin 
                    alu_op=SLTU;
                end
                
                default: begin
                    alu_op=ADD; //add convient
                end
            endcase
        end
        cls_R:begin 
            case (funct3)
                3'b000:begin 
                    if (funct7_5==1) begin
                        alu_op=SUB;
                    end else begin
                        alu_op=ADD;
                    end
                end
                3'b001:begin alu_op=SLL; end
                3'b010:begin alu_op=SLT; end
                3'b011:begin alu_op=SLTU; end
                3'b100:begin alu_op=XOR; end
                3'b101:begin 
                    if (funct7_5==1) begin
                        alu_op=SRA;
                    end else begin
                        alu_op=SRL;
                    end
                end
                3'b110:begin alu_op=OR; end
                3'b111:begin alu_op=AND; end
                default: begin
                    alu_op=ADD;
                end
            endcase           
        end
        cls_I: begin 
            case (funct3) 
                3'b000:begin alu_op=ADD; end
                3'b001:begin alu_op=SLL; end
                3'b010:begin alu_op=SLT; end
                3'b011:begin alu_op=SLTU; end
                3'b100:begin alu_op=XOR; end
                3'b101:begin 
                    if (funct7_5==1) begin
                        alu_op=SRA;
                    end else begin
                        alu_op=SRL;
                    end
                end
                3'b110:begin alu_op=OR; end
                3'b111:begin alu_op=AND; end
                default: begin
                    alu_op=ADD;
                end
            
            endcase
            
        end
        
        default: begin
            alu_op=ADD;
        end
    endcase
end
    
endmodule
