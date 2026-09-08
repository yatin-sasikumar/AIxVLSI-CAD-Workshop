# Tool Stack

The workshop uses a combination of open-source EDA tools, programming libraries, development tools, and AI frameworks to demonstrate a practical AI-assisted VLSI design workflow.

---

## RTL Design & Verification

| Tool | Purpose |
|---|---|
| **SystemVerilog** | RTL design and hardware description |
| **Icarus Verilog** | RTL simulation |
| **GTKWave** | Waveform visualization and debugging |
| **Verilator** | RTL linting and fast simulation |

---

## Logic Synthesis

| Tool | Purpose |
|---|---|
| **Yosys** | RTL synthesis and hardware netlist generation |

---

## Physical Design

| Tool | Purpose |
|---|---|
| **OpenROAD** | Automated digital physical design |
| **KLayout** | Layout visualization and analysis |
| **Magic** | Layout editing and physical verification |
| **Netgen** | Netlist comparison and LVS |
| **ngspice** | Circuit-level simulation |

---

## Programming & CAD Algorithms

| Tool / Library | Purpose |
|---|---|
| **Python** | Automation, scripting, and AI/EDA integration |
| **NumPy** | Numerical computation |
| **NetworkX** | Graph algorithms and CAD problem modeling |
| **Matplotlib** | Visualization of algorithms and EDA results |
| **Jupyter** | Interactive experimentation and demonstrations |

---

## Development & Reproducibility

| Tool | Purpose |
|---|---|
| **Git** | Version control |
| **GitHub** | Repository hosting and collaboration |
| **Shell / Bash** | Tool automation and flow execution |
| **YAML / JSON** | Configuration and machine-readable results |

---

## AI Stack

The AI component of the workshop is designed to work with either local or approved hosted language models.

| Component | Purpose |
|---|---|
| **Qwen / Local LLMs** | Local AI-assisted analysis and generation |
| **Approved LLM APIs** | Hosted AI assistance where permitted |
| **Structured Tool Calling** | Connecting AI agents to EDA tools |
| **Python AI Interface** | Orchestration of AI and EDA workflows |

---

## Tool-Driven EDA Flow

The tools are used together rather than as isolated applications:

```text
SystemVerilog
     ↓
Icarus / Verilator
     ↓
Yosys
     ↓
OpenROAD
     ↓
KLayout / Magic / Netgen