#!/usr/bin/env bash

set -e

DESIGN="designs/alu_pipelined"
RUN="runs/alu_pipelined/simulation"

mkdir -p "$RUN"

echo "=============================================="
echo " ALU Pipelined - Simulation"
echo "=============================================="

echo "[1/2] Compiling..."

iverilog -g2012 \
    -o "$RUN/alu_sim" \
    "$DESIGN/rtl/pipelined_alu.sv" \
    "$DESIGN/tb/pipelined_alu_tb.sv"

echo "[2/2] Running simulation..."

vvp "$RUN/alu_sim" 2>&1 | tee "$RUN/simulation.log"

echo ""
echo "Simulation complete."
echo "VCD: $RUN/pipelined_alu.vcd"
echo "Log: $RUN/simulation.log"