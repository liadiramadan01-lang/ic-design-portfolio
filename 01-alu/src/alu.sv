module alu #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [2:0]       op,
    output logic [WIDTH-1:0] result,
    output logic             zero
);

    always_comb begin
        case (op)
            3'b000 : result = a + b;
            3'b001 : result = a - b;
            3'b010 : result = a & b;
            3'b011 : result = a | b;
            3'b100 : result = a ^ b;
            3'b101 : result = ~a;
            3'b110 : result = a << 1;
            3'b111 : result = a >> 1;
            default: result = '0;
        endcase
    end

    assign zero = (result == '0);

endmodule