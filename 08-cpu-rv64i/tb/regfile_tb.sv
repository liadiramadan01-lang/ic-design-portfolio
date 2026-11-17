`timescale 1ns/1ps

module regfile_tb;

    //declaration des signaux
    logic clk,we;
    logic [4:0] rs1_addr,rd_addr,rs2_addr;
    logic [XLEN-1:0] rs1_data,rs2_data, rd_data;
    parameter XLEN = 64;


    //instanciation du module
    regfile #(
        .XLEN(64)
     ) dut(
        .clk(clk),
        .we(we),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_data(rd_data)

    );

    //initialisation de l horloge
    initial clk=0;
    always #10 clk=~clk;
    
    task write(
        input logic [4:0]write_addr,
        input logic [63:0] write_data
     );
        @(negedge clk)
        we=1;
        rd_addr=write_addr;
        rd_data=write_data;
        @(negedge clk)
        we=0;
        $display(" Write: %0h", write_data," adresse: %0h",write_addr);
     
        
    endtask
    task read(
        input logic [4:0] read_1_addr,
        input logic [4:0] read_2_addr,
        input logic [63:0] expected_r1,
        input logic [63:0] expected_r2,
        output logic [63:0] read_1_data,
        output logic [63:0] read_2_data
     );
     rs1_addr=read_1_addr;
     rs2_addr=read_2_addr;
     #5
     read_1_data=rs1_data;
     read_2_data=rs2_data;
     #10
     if(read_1_data==expected_r1 && read_2_data==expected_r2)begin
        $display("Ok| Read: %0h", read_1_data," Read: %0h", read_2_data);
     end 
     else begin 
        $display("ERR| Read: %0h", read_1_data," Attendu: %0h", expected_r1," Read: %0h", read_2_data," Attendu: %0h", expected_r2);
     end   
    endtask

    logic [63:0] r1, r2;
    initial begin

        $dumpfile("build/regfile_tb.vcd");
        $dumpvars(0,regfile_tb);

        $display("DEBUT DE LA SIMULATION");

        
        we=0;
        @(posedge clk);
        we=1;
        
        // test écriture
        write(5'd1, 64'hA5A5A5A5C3C3C3C3);
        write(5'd2, 64'hC3C3C3C3BAF99E19);

        @(posedge clk);
        @(posedge clk);
        // test lecture

        read(5'd1,5'd2,64'hA5A5A5A5C3C3C3C3,64'hC3C3C3C3BAF99E19,r1,r2);
        #100

        // test ecriture et lecture a 0
        write(5'd0, 64'hEAB5A5A5C3C3C3FA);
        @(posedge clk);
        read(5'd0,5'd0,'0,'0,r1,r2);

        write(5'd5, 64'hEAB5A5A5C3C3C3FA);
        @(posedge clk);
        write(5'd5, 64'h1A2535A5C3536398);
        @(posedge clk);
        read(5'd5,5'd5,64'h1A2535A5C3536398,64'h1A2535A5C3536398,r1,r2);
        #200
        $display("FIN DE LA SIMULATION");

        $finish;
    end

endmodule
