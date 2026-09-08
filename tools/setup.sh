#!/usr/bin/env bash

set -e

echo "=============================================="
echo " AI × VLSI CAD Workshop - Environment Setup"
echo "=============================================="
echo ""

echo "Installing required MSYS2 packages..."

pacman -S --needed --noconfirm \
    mingw-w64-ucrt-x86_64-iverilog \
    mingw-w64-ucrt-x86_64-verilator \
    mingw-w64-ucrt-x86_64-yosys \
    mingw-w64-ucrt-x86_64-gtkwave \
    mingw-w64-ucrt-x86_64-python



iverilog -V
verilator --version
yosys --version
gtkwave --version


echo ""
echo "=============================================="
echo " Setup complete!"
echo "=============================================="
echo ""
echo "You can now run:"
echo "  ./flows/sim.sh"
echo "  ./flows/lint.sh"
echo "  yosys -s flows/synth.ys"
echo ""