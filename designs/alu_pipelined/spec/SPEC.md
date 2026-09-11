# Pipelined ALU with Register File Specification

## 1. Overview

The Pipelined ALU is an 8-bit arithmetic and logic datapath containing
an 8 × 8-bit register file and a single pipeline stage.

Unlike the basic combinational ALU, operands are selected from the
register file using register addresses. The selected operands are
processed by the ALU, and the result is passed through a pipeline
register before being written back to the register file.

The design is intended to demonstrate:

- Register-file based datapaths
- Clocked RTL design
- Pipeline registers
- Pipeline latency
- Register-to-register timing
- Critical-path analysis
- Timing constraints and slack
- Maximum operating frequency
- Area introduced by sequential elements
- Basic architectural optimization

---

## 2. Architecture

The datapath consists of three primary blocks:

1. Register File
2. Combinational ALU
3. Pipeline / Writeback logic

Conceptually:

```text
             Register File
          +-------------------+
 rs1 ---->| Read Port 1       |----+
          |                   |    |
 rs2 ---->| Read Port 2       |--+ |
          +-------------------+  | |
                                 | |
                                 v v
                            +----------+
 opcode ------------------->|   ALU    |
                            +----+-----+
                                 |
                                 v
                         +---------------+
                         | Pipeline      |
                         | Register      |
                         +-------+-------+
                                 |
                                 v
                         +---------------+
                         | Writeback     |
                         +-------+-------+
                                 |
                                 v
                         Register File

---

## 3. Opcode Definitions

The ALU supports eight operations selected using a 3-bit opcode.

| Opcode | Operation | Description |
|--------|-----------|-------------|
| `000` | ADD | `operand_a + operand_b` |
| `001` | SUB | `operand_a - operand_b` |
| `010` | AND | `operand_a & operand_b` |
| `011` | OR | `operand_a \| operand_b` |
| `100` | XOR | `operand_a ^ operand_b` |
| `101` | NOT | `~operand_a` |
| `110` | Shift Left | `operand_a << 1` |
| `111` | Shift Right | `operand_a >> 1` |

The opcode is applied to the two operands read from the register file. The resulting ALU output is captured by the pipeline register on the active clock edge before being written back to the destination register.