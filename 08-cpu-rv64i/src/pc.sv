module pc #(
    parameter int XLEN=64

 )(
    input logic clk,rst,pc_write,
    input logic [XLEN-1:0] pc_next,
    output logic [XLEN-1:0] pc
 );
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc<='0; // reset adresses
        end 
        else if (pc_write==1) begin
                pc<=pc_next;
        end
    end
endmodule

