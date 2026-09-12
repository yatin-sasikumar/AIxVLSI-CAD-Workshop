#!/usr/bin/env bash

set -e

DESIGN="designs/alu_pipelined"
RUN="runs/alu_pipelined/lint"

mkdir -p "$RUN"

echo "=============================================="
echo " ALU Pipelined - Verilator Lint"
echo "=============================================="

verilator --lint-only -Wall -Wno-fatal \
    "$DESIGN/rtl/pipelined_alu.sv" \
    2>&1 | tee "$RUN/verilator.log"

echo ""
echo "Lint complete."
echo "Log: $RUN/verilator.log"
