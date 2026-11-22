module alu import cpu_pkg::*; #(
    parameter int XLEN =64
) (
    input logic [XLEN-1:0] a,b,
    output logic [XLEN-1:0] result,
    output logic zero,
    input logic is_word,
    input alu_op_t alu_op
);
    logic [31:0]result_w;
    logic signed [31:0] s_result_w;
    logic [5:0] shamt ;
    assign shamt =(is_word)? b[4:0]:b[5:0]; // shift amount

 always_comb begin 
    case (alu_op)

        ADD:begin if (is_word)begin
                        result_w=a[31:0]+b[31:0];
                        result={{(XLEN-32){result_w[31]}},result_w};
                    end
                else
                    result=a+b;
            end
        SUB:begin if (is_word)begin
                        result_w=a[31:0]-b[31:0];
                        result={{(XLEN-32){result_w[31]}},result_w};
                    end
                else
                    result=a-b;
            end
        AND:begin 
            result=a & b;
        end
        OR:begin 
            result=a|b;
        end 
        XOR:begin 
            result=a^b;
        end
        SLL:begin if(is_word) begin 
                    result_w=a[31:0]<<shamt;
                    result={{(XLEN-32){result_w[31]}},result_w};
                end
                else
                    result=a<<shamt;
        end
        SRL:begin if(is_word) begin 
                    result_w=a[31:0]>>shamt;
                    result={{(XLEN-32){result_w[31]}},result_w};
                end
                else
                    result=a>>shamt;           
        end
        SRA:begin if(is_word) begin 
                    s_result_w=$signed(a[31:0])>>>shamt;
                    result={{(XLEN-32){s_result_w[31]}},s_result_w};
                end
                else
                    result=$signed(a)>>>shamt;
         end
        SLT:begin
            if($signed(a)<$signed(b))
                result=64'd1;
            else
                result='0;
         end
        SLTU:begin
            if(a<b)
                result=64'd1;
            else
                result='0;
         end
        PASS_B:begin 
            result=b;
        end        
        default: begin
            result='0;
        end
    endcase

 end
    assign zero=(result=='0); 

endmodule
      