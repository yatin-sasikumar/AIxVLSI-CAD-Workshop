# Submission Instructions

## 1. Open MSYS2

Open **MSYS2 UCRT64** from the Start Menu.

All workshop commands must be run from the **MSYS2 UCRT64** terminal.

---

## 2. Clone the Workshop Repository

```bash
git clone https://github.com/yatin-sasikumar/AIxVLSI-CAD-Workshop.git
cd AIxVLSI-CAD-Workshop
```

Run setup once:

```bash
chmod +x tools/setup.sh
./tools/setup.sh
```

---

## 3. Create Your Own Repository

Create a **new GitHub repository** for your submission.

Clone your repository in your VS CODE env and use it for your design.

Example:

```bash
git clone https://github.com/<your-username>/<your-repository>.git
cd <your-repository>
```

---

## 4. Use the Workshop Flow With Your Own RTL

The workshop repository contains the flow scripts. The scripts currently point to the example `alu_pipelined` design.

For your submission, change the design path in the scripts to your own RTL.

### Simulation — `flows/sim.sh`

Open:

```bash
nano flows/sim.sh
```

Change the design path and file names:

```bash
DESIGN="path/to/your/design"
```

and replace the RTL/testbench filenames with your own files.

Then run:

```bash
./flows/sim.sh
```

---

### Lint — `flows/lint.sh`

Open:

```bash
nano flows/lint.sh
```

Change the design path and RTL filename to your own design.

Run:

```bash
./flows/lint.sh
```

---

### Synthesis — `flows/synth.ys`

Open:

```bash
nano flows/synth.ys
```

Change:

```text
read_verilog -sv ...
```

to your RTL file and change:

```text
hierarchy -top ...
```

to your top-level module name.

Then run:

```bash
yosys -s flows/synth.ys
```

---

## 5. Submission Files

Your GitHub repository must contain:

```text
rtl/
└── design.sv

tb/
└── design_tb.sv

waveform.vcd

netlist.v
```

The three available tracks are:

- Binary to Gray Code Converter
- Priority Encoder
- Parity Generator

---

## 6. Submit

Push your files to your GitHub repository:

```bash
git add .
git commit -m "Workshop submission"
git push
```

Copy your GitHub repository link and paste it into the **Google Form** provided.
