# RTL Synthesis

## Overview

RTL synthesis transforms the SystemVerilog design into a hardware netlist representation.

The workshop uses **Yosys** for synthesis. At this stage, the design is synthesized into a generic, technology-independent representation. Technology mapping and timing analysis require a target standard-cell library and are handled separately.

---

## Tool

**Yosys** is used for RTL synthesis and netlist generation.

The synthesis flow performs RTL elaboration, process conversion, memory handling, optimization, technology-independent mapping, and netlist generation.

---

## Flow

```text
SystemVerilog RTL
       ↓
   RTL Elaboration
       ↓
 Process / Memory
   Conversion
       ↓
  Optimization
       ↓
 Generic Mapping
       ↓
   Netlist + Stats