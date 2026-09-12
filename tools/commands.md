# Workshop Commands

All commands below are intended for the **MSYS2 UCRT64 terminal**.

> **Important:** Run the commands from the repository root unless stated otherwise.


## 1. Setup the Environment

Run the automated setup script:

```bash
bash ./tools/setup.sh
```

If permission is denied:

```bash
chmod +x tools/setup.sh
./tools/setup.sh
```

---


# VLSI CAD Flow

## 1 Run RTL Lint

```bash
./flows/lint.sh
```

Lint log:

```text
runs/alu_pipelined/lint/verilator.log
```

## 2. Run RTL Simulation

```bash
./flows/sim.sh
```

Simulation outputs are stored under:

```text
runs/alu_pipelined/simulation/
```

## 3. View Simulation Waveforms

```bash
gtkwave runs/alu_pipelined/simulation/pipelined_alu.vcd
```

## 4. Run Synthesis

```bash
yosys -s flows/synth.ys
```

Synthesized netlist:

```text
runs/alu_pipelined/synthesis/netlist.v
```


---


# Quick Reference

| Task | Command |
|---|---|
| Clone repository | `git clone https://github.com/yatin-sasikumar/AIxVLSI-CAD-Workshop.git` |
| Enter repository | `cd AIxVLSI-CAD-Workshop` |
| Check location | `pwd` |
| List files | `ls` |
| Setup environment | `./tools/setup.sh` |
| Fix setup permission | `chmod +x tools/setup.sh` |
| Run simulation | `bash ./flows/sim.sh` |
| Open waveform | `gtkwave runs/alu_pipelined/simulation/pipelined_alu.vcd` |
| Run lint | `bash ./flows/lint.sh` |
| Run synthesis | `yosys -s flows/synth.ys` |
| Run physical design| `bash ./flows/physical.sh` |
| Check Icarus | `iverilog -V` |
| Check Verilator | `verilator --version` |
| Check Yosys | `yosys --version` |
| Check GTKWave | `gtkwave --version` |
| Check Python | `python --version` |

---

## Terminal Requirement

Use the **MSYS2 UCRT64** terminal.

The `.sh` scripts and Yosys commands should be executed from the **repository root**.
