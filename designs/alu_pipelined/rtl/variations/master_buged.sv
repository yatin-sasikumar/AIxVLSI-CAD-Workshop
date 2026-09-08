module pipelined_alu (
    input  logic       clk,
    input  logic       rst,

    input  logic [2:0] rs1,
    input  logic [2:0] rs2,
    input  logic [2:0] rd,
    input  logic [2:0] opcode,

    output logic [7:0] result,
    output logic       zero
);

    // ------------------------------------------------------------
    // Register File
    // ------------------------------------------------------------

    logic [7:0] reg_file [0:7];

    logic [7:0] operand_a;
    logic [7:0] operand_b;

    assign operand_a = (rs1 == 3'b000) ? 8'h00 : reg_file[rs1];
    assign operand_b = (rs2 == 3'b000) ? 8'h00 : reg_file[rs2];


    // ------------------------------------------------------------
    // INTENTIONAL LINT BUG
    // Width mismatch: 8-bit signal assigned to 4-bit signal.
    // Verilator should report a WIDTH warning.
    // ------------------------------------------------------------

    logic [3:0] lint_signal;

    assign lint_signal = operand_a;


    // ------------------------------------------------------------
    // ALU
    // ------------------------------------------------------------

    logic [7:0] alu_result;

    always_comb begin
        case (opcode)

            3'b000: alu_result = operand_a + operand_b; // ADD
            3'b001: alu_result = operand_a - operand_b; // SUB
            3'b010: alu_result = operand_a & operand_b; // AND
            3'b011: alu_result = operand_a | operand_b; // OR

            // ----------------------------------------------------
            // INTENTIONAL FUNCTIONAL BUG
            // XOR incorrectly implemented as OR.
            // ----------------------------------------------------

            3'b100: alu_result = operand_a | operand_b;

            3'b101: alu_result = ~operand_a;            // NOT
            3'b110: alu_result = operand_a << 1;        // SHL
            3'b111: alu_result = operand_a >> 1;        // SHR

            default: alu_result = 8'h00;

        endcase
    end


    // ------------------------------------------------------------
    // Pipeline Register
    // ------------------------------------------------------------

    logic [7:0] pipeline_result;
    logic [2:0] pipeline_rd;
    logic       pipeline_valid;

    logic pipeline_zero;

    assign pipeline_zero = (pipeline_result == 8'h00);


    // ------------------------------------------------------------
    // INTENTIONAL SYNTHESIS BUG
    //
    // This class is legal SystemVerilog and can be parsed by
    // simulation/lint tools, but is not synthesizable by Yosys.
    //
    // It represents accidental software/debug constructs that
    // cannot be converted into hardware.
    // ------------------------------------------------------------

    class synthesis_only_debug;
        int debug_value;

        function new();
            debug_value = 0;
        endfunction
    endclass


    // ------------------------------------------------------------
    // Pipeline / Writeback
    // ------------------------------------------------------------

    integer i;

    always_ff @(posedge clk) begin

        if (rst) begin

            for (i = 0; i < 8; i = i + 1)
                reg_file[i] <= 8'h00;

            pipeline_result <= 8'h00;
            pipeline_rd     <= 3'b000;
            pipeline_valid  <= 1'b0;

        end
        else begin

            if (pipeline_valid && (pipeline_rd != 3'b000))
                reg_file[pipeline_rd] <= pipeline_result;

            pipeline_result <= alu_result;
            pipeline_rd     <= rd;
            pipeline_valid  <= 1'b1;

        end

    end


    // ------------------------------------------------------------
    // Outputs
    // ------------------------------------------------------------

    assign result = pipeline_result;
    assign zero   = pipeline_zero;

endmodule