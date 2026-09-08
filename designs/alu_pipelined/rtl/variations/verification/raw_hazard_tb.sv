`timescale 1ns/1ps

module pipelined_alu_tb;

    logic       clk;
    logic       rst;

    logic [2:0] rs1;
    logic [2:0] rs2;
    logic [2:0] rd;
    logic [2:0] opcode;

    logic [7:0] result;
    logic       zero;


    // ------------------------------------------------------------
    // DUT
    // ------------------------------------------------------------

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


    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // ------------------------------------------------------------
    // Test counters
    // ------------------------------------------------------------

    integer tests_passed = 0;
    integer tests_failed = 0;


    // ------------------------------------------------------------
    // Reset
    // ------------------------------------------------------------

    task reset_dut;
        begin
            rst    = 1'b1;
            rs1    = 3'b000;
            rs2    = 3'b000;
            rd     = 3'b000;
            opcode = 3'b000;

            @(posedge clk);
            @(posedge clk);

            rst = 1'b0;

            #1;

            // Simulation-only initialization
            dut.reg_file[0] = 8'h00;
            dut.reg_file[1] = 8'h05;
            dut.reg_file[2] = 8'h03;
            dut.reg_file[3] = 8'h00;
            dut.reg_file[4] = 8'h00;
            dut.reg_file[5] = 8'h0F;
            dut.reg_file[6] = 8'hF0;
            dut.reg_file[7] = 8'hAA;
        end
    endtask


    // ------------------------------------------------------------
    // Apply an instruction
    // ------------------------------------------------------------

    task apply_instruction(
        input [2:0] in_rs1,
        input [2:0] in_rs2,
        input [2:0] in_rd,
        input [2:0] in_opcode
    );
        begin
            rs1    = in_rs1;
            rs2    = in_rs2;
            rd     = in_rd;
            opcode = in_opcode;
        end
    endtask


    // ------------------------------------------------------------
    // Check result
    // ------------------------------------------------------------

    task check_result(
        input [7:0] expected,
        input [127:0] test_name
    );
        begin

            if (result === expected) begin
                $display("[PASS] %s : result = %h",
                         test_name, result);
                tests_passed = tests_passed + 1;
            end
            else begin
                $display("[FAIL] %s : expected = %h, got = %h",
                         test_name, expected, result);
                tests_failed = tests_failed + 1;
            end

        end
    endtask


    // ------------------------------------------------------------
    // Main test
    // ------------------------------------------------------------

    initial begin

        $dumpfile("raw_hazard.vcd");
        $dumpvars(0, pipelined_alu_tb);

        reset_dut();


        // ========================================================
        // Test 1
        //
        // Establish:
        //
        // R3 = R1 + R2
        //
        // 5 + 3 = 8
        // ========================================================

        $display("");
        $display("==============================================");
        $display("TEST 1: Generate R3");
        $display("==============================================");

        apply_instruction(
            3'd1,
            3'd2,
            3'd3,
            3'b000       // ADD
        );

        @(posedge clk);
        #1;

        check_result(
            8'h08,
            "R1 + R2 -> R3"
        );


        // ========================================================
        // Test 2
        //
        // RAW HAZARD
        //
        // Immediately use R3:
        //
        // R4 = R3 + R1
        //
        // Expected:
        //
        // R4 = 8 + 5 = 13
        //
        // Golden RTL does NOT handle this hazard.
        // Hazard-fixed RTL stalls for one cycle.
        // ========================================================

        $display("");
        $display("==============================================");
        $display("TEST 2: RAW Hazard");
        $display("==============================================");

        apply_instruction(
            3'd3,
            3'd1,
            3'd4,
            3'b000       // ADD
        );

        @(posedge clk);
        #1;

        // Hazard-fixed design should still have R3's result
        // because the dependent instruction was stalled.

        check_result(
            8'h08,
            "RAW hazard causes one-cycle stall"
        );


        // --------------------------------------------------------
        // Next cycle: dependent instruction should now execute.
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        check_result(
            8'h0D,
            "Dependent instruction uses updated R3"
        );


        // --------------------------------------------------------
        // Verify actual register writeback.
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        if (dut.reg_file[4] === 8'h0D) begin
            $display("[PASS] R4 writeback = 0D");
            tests_passed = tests_passed + 1;
        end
        else begin
            $display("[FAIL] R4 writeback : expected 0D, got %h",
                     dut.reg_file[4]);
            tests_failed = tests_failed + 1;
        end


        // ========================================================
        // Test 3
        //
        // No hazard.
        //
        // R5 = R1 + R2
        //
        // Makes sure normal operation still works.
        // ========================================================

        $display("");
        $display("==============================================");
        $display("TEST 3: Non-dependent instruction");
        $display("==============================================");

        apply_instruction(
            3'd1,
            3'd2,
            3'd5,
            3'b000
        );

        @(posedge clk);
        #1;

        check_result(
            8'h08,
            "Independent ADD"
        );


        // ========================================================
        // Test 4
        //
        // Hazard through rs2 instead of rs1.
        //
        // R6 = R1 + R2
        // R7 = R1 + R6
        //
        // ========================================================

        $display("");
        $display("==============================================");
        $display("TEST 4: RAW hazard through rs2");
        $display("==============================================");

        apply_instruction(
            3'd1,
            3'd2,
            3'd6,
            3'b000
        );

        @(posedge clk);
        #1;

        check_result(
            8'h08,
            "Generate R6"
        );


        // Dependent instruction
        apply_instruction(
            3'd1,
            3'd6,
            3'd7,
            3'b000
        );

        @(posedge clk);
        #1;

        check_result(
            8'h08,
            "Hazard stall holds R6 result"
        );


        @(posedge clk);
        #1;

        check_result(
            8'h0D,
            "R1 + updated R6"
        );


        // --------------------------------------------------------
        // End
        // --------------------------------------------------------

        $display("");
        $display("==============================================");
        $display("RAW HAZARD TEST SUMMARY");
        $display("==============================================");
        $display("Tests Passed : %0d", tests_passed);
        $display("Tests Failed : %0d", tests_failed);

        if (tests_failed == 0)
            $display("******** ALL HAZARD TESTS PASSED ********");
        else
            $display("******** HAZARD TEST FAILED ********");

        $display("==============================================");

        $finish;

    end

endmodule
