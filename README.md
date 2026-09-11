# AI × VLSI CAD Workshop

**AI × VLSI CAD Workshop by V-Space**

A hands-on workshop exploring VLSI CAD workflows, EDA tools, RTL design, verification, synthesis, physical design, and the application of AI to hardware design workflows.

---

## Workshop Workflow

The workshop follows a tool-driven hardware design flow:

```text
Problem
   ↓
Algorithm
   ↓
RTL Design
   ↓
Simulation
   ↓
Linting
   ↓
Synthesis
   ↓
Physical Design
   ↓
Measurement & Analysis
   ↓
AI-assisted Improvement
```

The objective is to understand how a hardware design moves through different stages of the VLSI CAD flow and how AI can be incorporated into these workflows.

---

## Repository Structure

```text
AIxVLSI-CAD-Workshop/
│
├── designs/
│   └── alu_pipelined/
│       ├── rtl/
│       ├── tb/
│       └── config.json
│
├── docs/
│   ├── workshop/
│   │   ├── overview.md
│   │   └── toolstack.md
│   │
│   └── flows/
│       ├── simulation.md
│       ├── linting.md
│       ├── synthesis.md
│       └── physical_design.md
│
├── flows/
│   ├── sim.sh
│   ├── lint.sh
│   ├── synth.ys
│   └── physical.sh
│
├── runs/
│   └── alu_pipelined/
│
├── submissions/
│
├── tools/
│   ├── setup.sh
│   └── commands.md
│
├── .gitignore
├── LICENSE
└── README.md
```

---

## Getting Started

The workshop is designed to run on **Linux lab systems**.

Before starting, make sure you have access to:

- Ubuntu 22.04 or newer
- VS Code
- Internet access
- Sufficient permissions to install packages using `sudo`

Clone the repository:

```bash
git clone https://github.com/yatin-sasikumar/AIxVLSI-CAD-Workshop.git
```

Enter the repository:

```bash
cd AIxVLSI-CAD-Workshop
```

Run the automated setup:

```bash
chmod +x tools/setup.sh
./tools/setup.sh
```

The setup script installs and verifies the required tools, including:

- Icarus Verilog
- Verilator
- GTKWave
- Yosys
- Docker
- LibreLane

---

## Running the Flows

### Simulation

```bash
./flows/sim.sh
```

View the generated waveform:

```bash
gtkwave runs/alu_pipelined/simulation/pipelined_alu.vcd
```

### RTL Linting

```bash
./flows/lint.sh
```

### Synthesis

```bash
yosys -s flows/synth.ys
```

### Physical Design

```bash
./flows/physical.sh
```

Physical design results are generated under:

```text
runs/alu_pipelined/librelane/
```

---

## Documentation

Detailed documentation is available under `docs/`.

### Workshop

- `docs/workshop/overview.md` — Workshop overview and workflow
- `docs/workshop/toolstack.md` — Tools used throughout the workshop

### CAD Flows

- `docs/flows/simulation.md` — RTL simulation
- `docs/flows/linting.md` — RTL linting
- `docs/flows/synthesis.md` — RTL synthesis
- `docs/flows/physical_design.md` — Physical design using LibreLane

### Setup & Commands

- `tools/commands.md` — Quick command reference
- `tools/setup.sh` — Automated Linux environment setup

---

## Flagship Design

The workshop uses a **pipelined ALU and register-file datapath** as the primary hardware design.

The design provides:

- 8 × 8-bit register file
- Two read ports
- One write port
- 8 ALU operations
- Pipeline register
- Zero flag
- Synchronous reset
- RAW hazard handling in the verification variation

The design is used to demonstrate the progression from RTL through simulation, linting, synthesis, and physical design.

---

## Toolchain

The core workshop flow uses:

```text
SystemVerilog
     ↓
Icarus Verilog
     ↓
GTKWave
     ↓
Verilator
     ↓
Yosys
     ↓
LibreLane
     ↓
OpenROAD / Magic / KLayout / Netgen
```

LibreLane provides the backend physical-design environment through its Dockerized flow.

---

## Workshop Philosophy

The workshop focuses on using EDA tools to **build, measure, debug, and improve hardware designs** rather than treating each tool as an isolated step.

The central loop is:

```text
Build
  ↓
Measure
  ↓
Analyze
  ↓
Improve
  ↓
Verify
  ↓
Repeat
```

AI is introduced as an assistant within this loop, while actual hardware results remain grounded in tool-generated evidence.

---

## License

This repository is distributed under the license specified in `LICENSE`.

---

**V-Space | AI × VLSI CAD Workshop**
