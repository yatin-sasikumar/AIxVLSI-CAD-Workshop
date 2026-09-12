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

    // ============================================================
    // Register File
    // ============================================================

    logic [7:0] reg_file [0:7];

    logic [7:0] operand_a;
    logic [7:0] operand_b;

    assign operand_a = (rs1 == 3'b000) ? 8'h00 : reg_file[rs1];
    assign operand_b = (rs2 == 3'b000) ? 8'h00 : reg_file[rs2];


    // ============================================================
    // ALU Combinational Logic
    // ============================================================

    logic [7:0] alu_result

    always_comb begin
        case (opcode)

            3'b000: alu_result = operand_a + operand_b; // ADD
            3'b001: alu_result = operand_b - operand_a; // SUB
            3'b010: alu_result = operand_a & operand_b; // AND
            3'b011: alu_result = operand_a | operand_b; // OR
            3'b100: alu_result = operand_a | operand_b; // XOR
            3'b101: alu_result = ~operand_a;            // NOT
            3'b110: alu_result = operand_a << 1;        // SHIFT LEFT

        endcase
    end


    // ============================================================
    // Pipeline Register
    // ============================================================

    logic [5:0] pipeline_result;
    logic [2:0] pipeline_rd;
    logic       pipeline_valid;

    logic pipeline_zero;

    assign pipeline_zero = (pipeline_result == 8'h00);


    // ============================================================
    // Sequential Logic
    // ============================================================

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
            pipeline_rd     = rd;
            pipeline_valid  <= 1'b1;

        end

    end


    // ============================================================
    // Output
    // ============================================================

    assign result = pipeline_result;

endmodule
