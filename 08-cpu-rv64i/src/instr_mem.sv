module instr_mem #(
    parameter int DEPTH=4096
 ) (
    input logic clk, en,
    input logic [$clog2(DEPTH)-1:0] addr_m,                         //addr_m=pc[13:2] dans cpu_top
    output logic [31:0] instr
 );

    logic [31:0] memory_i[0:DEPTH-1] ;

    initial begin
        instr=32'h00000013;
        for (int i=0; i<4096; ++i) begin
            memory_i[i] =32'h00000013;
        end 
        $readmemh("tests/program_i.hex",memory_i);
    end
    
    always_ff @(posedge clk ) begin
        if (en) begin
            instr<=memory_i[addr_m];
        end 

    end


endmodule