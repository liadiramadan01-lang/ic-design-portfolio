`timescale 1ns/1ps

module imm_gen_tb import cpu_pkg::*;;
    logic [31:0] inst;
    imm_sel_t imm_sel;
    logic [63:0] imm;
    
    imm_gen #(.XLEN(64)
     ) dut(
        .inst(inst),
        .imm_sel(imm_sel),
        .imm(imm)
    );

    task check(
        input logic [31:0] instr,
        input imm_sel_t sel,
        input logic [63:0] expected,
        input string nom
     );

        imm_sel=sel;
        inst=instr;
        #5;
        if (imm===expected) begin
            $display("OK| immediat: %0h | instruction: %s", imm, nom);
        end else begin
            $display("ERR| immediat: %0h | Attendu: %0h |instruction: %s ", imm, expected, nom);
        end
    endtask

    initial begin

        $dumpfile("build/imm_gen_tb.vcd");
        $dumpvars(0,imm_gen_tb);

        
        $display("DEBUT DE LA SIMULATION");

        //addi x1,x0,5
        check(32'h00500113,imm_I,64'd5,"ADDI");
        //addi x1,x0,-1
        check(32'hFFF00113,imm_I,64'hFFFFFFFFFFFFFFFF,"ADDI");
        //sw x1,2(x0)
        check(32'h00202123,imm_S,64'd2,"SW");
        //sw x2,-1(x1)
        check(32'hFE212FA3,imm_S,64'hFFFFFFFFFFFFFFFF,"SW");
        //beq x0,x0,8
        check(32'h00000463,imm_B,64'd8,"BEQ");
        //beq x0,x0,-8
        check(32'hFE000CE3,imm_B,64'hFFFFFFFFFFFFFFF8,"BEQ");
        //lui x1,0x12345
        check(32'h12345137,imm_U,64'h0000000012345000,"LUI");
        //lui x2,0xF7891
        check(32'hF7891137,imm_U,64'hFFFFFFFFF7891000,"LUI");
        //jal x3,8
        check(32'h008001EF,imm_J,64'd8,"JAL");
        //jal x4,-4
        check(32'hFFDFF26F,imm_J,64'hFFFFFFFFFFFFFFFC,"JAL");
        //cas non supporter (n appartient a aucun type)
        check(32'hFFF00113,imm_sel_t'(3'b111),64'h0000000000000000,"ADDI");


        $display("FIN DE LA SIMULATION");
        $finish;
    end

endmodule

