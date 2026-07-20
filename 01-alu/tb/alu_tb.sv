`timescale 1ns/1ps

module alu_tb;

    // Déclaration des signaux
    logic [7:0] a, b;
    logic [2:0] op;
    logic [7:0] result;
    logic       zero;

    // Instanciation de l'ALU
    alu #(.WIDTH(8)) dut (
        .a      (a),
        .b      (b),
        .op     (op),
        .result (result),
        .zero   (zero)
    );

    // Tâche pour afficher le résultat
    task check(
        input [7:0] a_in, b_in,
        input [2:0] op_in,
        input [7:0] expected,
        input string op_name
    );
        a = a_in; b = b_in; op = op_in;
        #10;
        if (result === expected)
            $display("OK  | %s | a=%0d b=%0d | result=%0d", op_name, a_in, b_in, result);
        else
            $display("ERR | %s | a=%0d b=%0d | result=%0d (expected %0d)", op_name, a_in, b_in, result, expected);
    endtask

    // Tests
    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        $display("=== TEST ALU 8 BITS ===");

        // ADD
        check(8'd10,  8'd20,  3'b000, 8'd30,  "ADD    ");
        check(8'd255, 8'd1,   3'b000, 8'd0,   "ADD OVF");

        // SUB
        check(8'd50,  8'd20,  3'b001, 8'd30,  "SUB    ");
        check(8'd0,   8'd1,   3'b001, 8'd255, "SUB NEG");

        // AND
        check(8'b11001100, 8'b10101010, 3'b010, 8'b10001000, "AND    ");

        // OR
        check(8'b11001100, 8'b10101010, 3'b011, 8'b11101110, "OR     ");

        // XOR
        check(8'b11001100, 8'b10101010, 3'b100, 8'b01100110, "XOR    ");

        // NOT
        check(8'b11001100, 8'd0,        3'b101, 8'b00110011, "NOT    ");

        // SHIFT LEFT
        check(8'b00000011, 8'd0,        3'b110, 8'b00000110, "SHL    ");

        // SHIFT RIGHT
        check(8'b00000110, 8'd0,        3'b111, 8'b00000011, "SHR    ");

        // TEST ZERO FLAG
        check(8'd0, 8'd0, 3'b000, 8'd0, "ZERO   ");
        $display("zero flag = %0b (expected 1)", zero);

        $display("=== FIN DES TESTS ===");
        $finish;
    end

endmodule