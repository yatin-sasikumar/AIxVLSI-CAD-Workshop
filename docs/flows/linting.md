# RTL Linting

## Overview

RTL linting is used to identify potential design issues in the SystemVerilog source before synthesis.

The workshop uses **Verilator** to analyze the RTL and report issues such as width mismatches, incomplete assignments, unused signals, and other structural or coding problems.

Linting complements simulation by identifying issues that may not be exposed by the available testbench stimulus.

---

## Tool

**Verilator** is used for RTL linting.

The golden RTL is checked using Verilator's lint-only mode with warnings enabled.

---

## Flow

```text
SystemVerilog RTL
       ↓
   Verilator
       ↓
   Lint Analysis
       ├── Warnings
       └── Errors