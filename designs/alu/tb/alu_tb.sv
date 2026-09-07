`timescale 1ns/1ps

module alu_tb;

    logic [7:0] A;
    logic [7:0] B;
    logic [2:0] opcode;
    logic [7:0] result;
    logic       zero;

    // Instantiate the ALU
    alu dut (
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(result),
        .zero(zero)
    );

    // Task for checking a test case
    task automatic check(
        input logic [7:0]  test_A,
        input logic [7:0]  test_B,
        input logic [2:0]  test_opcode,
        input logic [7:0]  expected
    );
        begin
            A      = test_A;
            B      = test_B;
            opcode = test_opcode;

            #1;

            if (result !== expected || zero !== (expected == 8'h00)) begin
                $display(
                    "FAIL: A=%h B=%h opcode=%b | Expected=%h zero=%b | Got=%h zero=%b",
                    A, B, opcode, expected, (expected == 8'h00), result, zero
                );
            end
            else begin
                $display(
                    "PASS: A=%h B=%h opcode=%b | Result=%h zero=%b",
                    A, B, opcode, result, zero
                );
            end
        end
    endtask

    initial begin

        $display("======================================");
        $display("        8-bit ALU Testbench");
        $display("======================================");

        // ADD
        check(8'h05, 8'h03, 3'b000, 8'h08);
        check(8'hFF, 8'h01, 3'b000, 8'h00);

        // SUB
        check(8'h05, 8'h03, 3'b001, 8'h02);
        check(8'h03, 8'h05, 3'b001, 8'hFE);

        // AND
        check(8'hF0, 8'h0F, 3'b010, 8'h00);
        check(8'hAA, 8'hFF, 3'b010, 8'hAA);

        // OR
        check(8'hF0, 8'h0F, 3'b011, 8'hFF);
        check(8'h00, 8'h00, 3'b011, 8'h00);

        // XOR
        check(8'hAA, 8'hFF, 3'b100, 8'h55);
        check(8'h55, 8'h55, 3'b100, 8'h00);

        // NOT
        check(8'hAA, 8'h00, 3'b101, 8'h55);
        check(8'hFF, 8'h00, 3'b101, 8'h00);

        // SHIFT LEFT
        check(8'h03, 8'h00, 3'b110, 8'h06);
        check(8'h80, 8'h00, 3'b110, 8'h00);

        // SHIFT RIGHT
        check(8'h08, 8'h00, 3'b111, 8'h04);
        check(8'h01, 8'h00, 3'b111, 8'h00);

        $display("======================================");
        $display("             Test Complete");
        $display("======================================");

        $finish;
    end

endmodule