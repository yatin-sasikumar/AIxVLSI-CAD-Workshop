#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# AIxVLSI-CAD Workshop - LibreLane Flow
# ============================================================

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
DESIGN_DIR="$PROJECT_ROOT/designs/alu_pipelined"
RUN_DIR="$PROJECT_ROOT/runs/alu_pipelined/librelane"

echo "============================================================"
echo " AIxVLSI-CAD Workshop - LibreLane"
echo "============================================================"
echo

mkdir -p "$RUN_DIR"

echo "Project : $PROJECT_ROOT"
echo "Design  : $DESIGN_DIR"
echo "Run dir : $RUN_DIR"
echo

source "$HOME/librelane-venv/bin/activate"

export PDK_ROOT="$HOME/.ciel"
export PDK="sky130A"

echo "Running LibreLane..."
echo

python3 -m librelane \
    --dockerized \
    --run-tag alu_pipelined \
    --run-dir "$RUN_DIR" \
    "$DESIGN_DIR/config.json"

echo
echo "============================================================"
echo " LibreLane flow complete"
echo "============================================================"
echo
echo "Results:"
echo "  $RUN_DIR"
