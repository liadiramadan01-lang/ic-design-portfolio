module fifo #(
    parameter DATA_WIDTH = 32, //bits
    parameter DEPTH = 1024 ,//mots
    parameter PTR_WIDTH  = 11 //bits (10 bits index + 1 bit extra)
 ) (
    input logic clk,rst,wr_en,rd_en,
    input logic [DATA_WIDTH-1:0] wr_data,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic full,empty
 );

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1]; //capaciter du fifo (tableau de 32x1024)
    logic [PTR_WIDTH-1:0] rd_ptr,wr_ptr;  // 11 bits — 10bits index + 1 extra
    

    always_ff @(posedge clk or posedge rst) begin 
        if (rst) begin 
            rd_ptr <= 0;
            wr_ptr <= 0;
            
        end
        else begin 
            if(wr_en && !full) begin 
                mem[wr_ptr[9:0]] <= wr_data;
                wr_ptr<=wr_ptr+1;
            end
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr[9:0]];
                rd_ptr<=rd_ptr+1;
                

            end
        end

    end


    always_comb begin 
        empty = (wr_ptr == rd_ptr);
        full  = (wr_ptr[9:0] == rd_ptr[9:0]) && (wr_ptr[10] != rd_ptr[10]);


    end



endmodule