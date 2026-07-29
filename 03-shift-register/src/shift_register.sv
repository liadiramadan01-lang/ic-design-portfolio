`timescale 1ns/1ps

module shift_register(
    input logic  clk,rst,sin,load,
    input logic [7:0] din,
    output logic [7:0] dout,
    output logic sout
 );
    assign sout = dout[7];

    always_ff @(posedge clk or posedge rst) begin

        if(rst)
            dout<=8'b00000000;
        else if (load) begin
            dout<=din;
        end
        else  begin
            
            dout <= {dout[6:0], sin};
        end

    end


 endmodule