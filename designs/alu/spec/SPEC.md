# 8-bit ALU Specification

## 1. Overview

The ALU is an 8-bit combinational arithmetic and logic unit.

It accepts two 8-bit operands and a 3-bit operation code, and produces an 8-bit result and a zero flag.

---

## 2. Interface

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `A` | Input | 8 bits | First operand |
| `B` | Input | 8 bits | Second operand |
| `opcode` | Input | 3 bits | Operation selection |
| `result` | Output | 8 bits | Operation result |
| `zero` | Output | 1 bit | High when `result` is zero |

---

## 3. Operations

| Opcode | Operation | Description |
|---|---|---|
| `000` | ADD | `result = A + B` |
| `001` | SUB | `result = A - B` |
| `010` | AND | `result = A & B` |
| `011` | OR | `result = A \| B` |
| `100` | XOR | `result = A ^ B` |
| `101` | NOT | `result = ~A` |
| `110` | SHIFT LEFT | `result = A << 1` |
| `111` | SHIFT RIGHT | `result = A >> 1` |

---

## 4. Zero Flag

The `zero` output shall be asserted when the ALU result is zero.

```text
zero = 1  → result == 0
zero = 0  → result != 0