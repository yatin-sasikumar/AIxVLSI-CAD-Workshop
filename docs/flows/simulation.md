# RTL Simulation

## Overview

RTL simulation is used to verify the functional behavior of the design before synthesis.

The simulation flow compiles the SystemVerilog RTL and its testbench using **Icarus Verilog**, executes the generated simulation, and records the results and waveforms for analysis.

---

## Tool

**Icarus Verilog** is used for RTL compilation and simulation.

**GTKWave** is used to inspect the generated VCD waveform.

---

## Flow

```text
SystemVerilog RTL
       +
Testbench
       ↓
 Icarus Verilog
       ↓
 Simulation
       ├── Console Log
       └── VCD Waveform
                    ↓
                GTKWave