module regfile #(
    parameter int XLEN=64
    )(
    input logic clk,we,
    input logic [4:0] rs1_addr,rd_addr,rs2_addr,
    input logic [XLEN-1:0] rd_data,
    output logic [XLEN-1:0] rs1_data,rs2_data
 ); 
    logic [XLEN-1:0] reg_mem [0:31];

    always_ff @( posedge clk) begin 
        if (we && rd_addr!=5'd0) begin 
            reg_mem[rd_addr]<=rd_data;
            
        end

    end

    always_comb begin 
            rs1_data=(rs1_addr==0)? '0:reg_mem[rs1_addr];
            rs2_data=(rs2_addr==0)? '0:reg_mem[rs2_addr];


    end


endmodule

