`timescale 1ns/1ps

module pipelined_alu_tb;

    // ============================================================
    // DUT INTERFACE
    // ============================================================

    logic       clk;
    logic       rst;

    logic [2:0] rs1;
    logic [2:0] rs2;
    logic [2:0] rd;
    logic [2:0] opcode;

    logic [7:0] result;
    logic       zero;


    // ============================================================
    // DUT
    // ============================================================

    pipelined_alu dut (
        .clk    (clk),
        .rst    (rst),
        .rs1    (rs1),
        .rs2    (rs2),
        .rd     (rd),
        .opcode (opcode),
        .result (result),
        .zero   (zero)
    );


    // ============================================================
    // CLOCK
    // 10 ns period = 100 MHz
    // ============================================================

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end


    // ============================================================
    // TEST COUNTERS
    // ============================================================

    integer pass_count;
    integer fail_count;


    // ============================================================
    // TASK: CHECK RESULT
    // ============================================================

    task automatic check_result (
        input logic [7:0] expected_result,
        input logic       expected_zero
    );

        begin

            if ((result === expected_result) &&
                (zero   === expected_zero)) begin

                $display(
                    "PASS: Result=%h Zero=%b",
                    result,
                    zero
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "FAIL: Expected Result=%h Zero=%b | Got Result=%h Zero=%b",
                    expected_result,
                    expected_zero,
                    result,
                    zero
                );

                fail_count = fail_count + 1;

            end

        end

    endtask


    // ============================================================
    // TASK: ISSUE ALU OPERATION
    //
    // Inputs are applied before the rising edge.
    // The rising edge captures the ALU result into the pipeline
    // register.
    // ============================================================

    task automatic execute_op (
        input logic [2:0] test_rs1,
        input logic [2:0] test_rs2,
        input logic [2:0] test_rd,
        input logic [2:0] test_opcode,
        input logic [7:0] expected_result
    );

        begin

            rs1    = test_rs1;
            rs2    = test_rs2;
            rd     = test_rd;
            opcode = test_opcode;

            @(posedge clk);

            #1;

            check_result(
                expected_result,
                (expected_result == 8'h00)
            );

        end

    endtask


    // ============================================================
    // MAIN TEST
    // ============================================================

    initial begin
        $dumpfile("runs/alu_pipelined/simulation/pipelined_alu.vcd");
        $dumpvars(0, pipelined_alu_tb);
        pass_count = 0;
        fail_count = 0;


        $display("==============================================");
        $display("   Pipelined ALU + Register File Testbench");
        $display("==============================================");


        // --------------------------------------------------------
        // INITIAL INPUTS
        // --------------------------------------------------------

        rs1    = 3'b000;
        rs2    = 3'b000;
        rd     = 3'b000;
        opcode = 3'b000;

        rst = 1'b1;


        // --------------------------------------------------------
        // RESET
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        rst = 1'b0;

        $display("");
        $display("Reset complete");


        // --------------------------------------------------------
        // MANUALLY INITIALIZE REGISTER FILE
        //
        // This is testbench-only hierarchical access.
        // It does NOT create hardware inputs.
        // --------------------------------------------------------

        dut.reg_file[0] = 8'h00;
        dut.reg_file[1] = 8'h05;
        dut.reg_file[2] = 8'h03;
        dut.reg_file[3] = 8'h00;
        dut.reg_file[4] = 8'h00;
        dut.reg_file[5] = 8'h0F;
        dut.reg_file[6] = 8'hF0;
        dut.reg_file[7] = 8'hAA;


        $display("");
        $display("Register file initialized:");
        $display("R0 = %h", dut.reg_file[0]);
        $display("R1 = %h", dut.reg_file[1]);
        $display("R2 = %h", dut.reg_file[2]);
        $display("R3 = %h", dut.reg_file[3]);
        $display("R4 = %h", dut.reg_file[4]);
        $display("R5 = %h", dut.reg_file[5]);
        $display("R6 = %h", dut.reg_file[6]);
        $display("R7 = %h", dut.reg_file[7]);


        // ========================================================
        // ALU OPERATION TESTS
        // ========================================================

        $display("");
        $display("--------------- ADD ----------------");

        // R3 = R1 + R2
        // 05 + 03 = 08
        execute_op(
            3'd1,
            3'd2,
            3'd3,
            3'b000,
            8'h08
        );


        $display("");
        $display("--------------- SUB ----------------");

        // R4 = R1 - R2
        // 05 - 03 = 02
        execute_op(
            3'd1,
            3'd2,
            3'd4,
            3'b001,
            8'h02
        );


        $display("");
        $display("--------------- AND ----------------");

        // R3 = R6 & R5
        // F0 & 0F = 00
        execute_op(
            3'd6,
            3'd5,
            3'd3,
            3'b010,
            8'h00
        );


        $display("");
        $display("--------------- OR -----------------");

        // R3 = R6 | R5
        // F0 | 0F = FF
        execute_op(
            3'd6,
            3'd5,
            3'd3,
            3'b011,
            8'hFF
        );


        $display("");
        $display("--------------- XOR ----------------");

        // R3 = R7 ^ R6
        // AA ^ F0 = 5A
        execute_op(
            3'd7,
            3'd6,
            3'd3,
            3'b100,
            8'h5A
        );


        $display("");
        $display("--------------- NOT ----------------");

        // R3 = ~R7
        // ~AA = 55
        execute_op(
            3'd7,
            3'd0,
            3'd3,
            3'b101,
            8'h55
        );


        $display("");
        $display("------------- SHIFT LEFT ------------");

        // R3 = R1 << 1
        // 05 << 1 = 0A
        execute_op(
            3'd1,
            3'd0,
            3'd3,
            3'b110,
            8'h0A
        );


        $display("");
        $display("------------ SHIFT RIGHT ------------");

        // R3 = R7 >> 1
        // AA >> 1 = 55
        execute_op(
            3'd7,
            3'd0,
            3'd3,
            3'b111,
            8'h55
        );


        // ========================================================
        // ZERO FLAG TEST
        // ========================================================

        $display("");
        $display("------------- ZERO FLAG -------------");

        // F0 & 0F = 00
        execute_op(
            3'd6,
            3'd5,
            3'd3,
            3'b010,
            8'h00
        );


        // ========================================================
        // R0 READ TEST
        // ========================================================

        $display("");
        $display("-------------- R0 TEST --------------");

        // R0 must always read as zero.
        // R0 + R0 = 00
        execute_op(
            3'd0,
            3'd0,
            3'd3,
            3'b000,
            8'h00
        );


        if (dut.reg_file[0] === 8'h00) begin

            $display("PASS: R0 remains zero");
            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "FAIL: R0 changed to %h",
                dut.reg_file[0]
            );

            fail_count = fail_count + 1;

        end


        // ========================================================
        // R0 WRITE PROTECTION TEST
        // ========================================================

        $display("");
        $display("---------- R0 WRITE TEST ------------");

        // Attempt:
        // R0 = R1 + R2
        //
        // R1 + R2 = 08, but the write must be ignored.

        execute_op(
            3'd1,
            3'd2,
            3'd0,
            3'b000,
            8'h08
        );


        if (dut.reg_file[0] === 8'h00) begin

            $display("PASS: Write to R0 ignored");
            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "FAIL: Write to R0 occurred. R0=%h",
                dut.reg_file[0]
            );

            fail_count = fail_count + 1;

        end


        // ========================================================
        // REGISTER WRITEBACK TEST
        // ========================================================

        $display("");
        $display("---------- WRITEBACK TEST ------------");

        // R3 = R1 + R2
        // Expected R3 = 08

        execute_op(
            3'd1,
            3'd2,
            3'd3,
            3'b000,
            8'h08
        );

	@(posedge clk);
	#1;
        if (dut.reg_file[3] === 8'h08) begin

            $display("PASS: R3 correctly written with 08");
            pass_count = pass_count + 1;

        end
        else begin

            $display(
                "FAIL: R3 expected 08, got %h",
                dut.reg_file[3]
            );

            fail_count = fail_count + 1;

        end


        // ========================================================
        // ARITHMETIC WRAPAROUND
        // ========================================================

        $display("");
        $display("-------- ARITHMETIC WRAPAROUND -------");

        // FF + 01 = 00
        dut.reg_file[5] = 8'hFF;
        dut.reg_file[6] = 8'h01;

        execute_op(
            3'd5,
            3'd6,
            3'd3,
            3'b000,
            8'h00
        );


        // ========================================================
        // FINAL SUMMARY
        // ========================================================

        $display("");
        $display("==============================================");
        $display("              TEST SUMMARY");
        $display("==============================================");

        $display("Tests Passed : %0d", pass_count);
        $display("Tests Failed : %0d", fail_count);

        if (fail_count == 0) begin
            $display("");
            $display("*************** ALL TESTS PASSED ************");
        end
        else begin
            $display("");
            $display("*************** TESTS FAILED ****************");
        end

        $display("==============================================");

        $finish;

    end

endmodule