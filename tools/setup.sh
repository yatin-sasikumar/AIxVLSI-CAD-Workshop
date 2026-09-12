#!/usr/bin/env bash
set -euo pipefail

# AIxVLSI-CAD Workshop - MSYS2 Setup
# Target: MSYS2 UCRT64
#
# Run from the MSYS2 UCRT64 terminal:
#   ./tools/setup.sh

echo "============================================================"
echo " AIxVLSI-CAD Workshop - MSYS2 Setup"
echo "============================================================"
echo

# ------------------------------------------------------------
# Check that we are running inside MSYS2
# ------------------------------------------------------------

if [[ "${MSYSTEM:-}" != "UCRT64" ]]; then
    echo "ERROR: This setup must be run from the MSYS2 UCRT64 terminal."
    echo
    echo "Open:"
    echo "  MSYS2 UCRT64"
    echo
    echo "Then run:"
    echo "  ./tools/setup.sh"
    exit 1
fi

echo "Environment: MSYS2 UCRT64"
echo

# ------------------------------------------------------------
# Step 1: Update package database
# ------------------------------------------------------------

echo "[1/4] Updating MSYS2 package database..."

pacman -Syu --noconfirm

echo
echo "MSYS2 update complete."
echo

# ------------------------------------------------------------
# Step 2: Install required tools
# ------------------------------------------------------------

echo "[2/4] Installing required tools..."

pacman -S --needed --noconfirm \
    git \
    make \
    python \
    python-pip \
    mingw-w64-ucrt-x86_64-toolchain \
    mingw-w64-ucrt-x86_64-iverilog \
    mingw-w64-ucrt-x86_64-verilator \
    mingw-w64-ucrt-x86_64-gtkwave \
    mingw-w64-ucrt-x86_64-yosys

echo
echo "Tool installation complete."
echo

# ------------------------------------------------------------
# Step 3: Verify tools
# ------------------------------------------------------------

echo "[3/4] Verifying installed tools..."
echo

echo "Git:"
git --version
echo

echo "Make:"
make --version | head -n 1
echo

echo "Python:"
python --version
echo

echo "Icarus Verilog:"
iverilog -V 2>&1 | head -n 1
echo

echo "Verilator:"
verilator --version
echo

echo "GTKWave:"
gtkwave --version 2>&1 | head -n 1
echo

echo "Yosys:"
yosys --version
echo

# ------------------------------------------------------------
# Step 4: Final verification
# ------------------------------------------------------------

echo "[4/4] Final verification..."
echo

FAILED=0

check_command() {
    local name="$1"
    local command="$2"

    if command -v "$command" >/dev/null 2>&1; then
        echo "  [OK] $name"
    else
        echo "  [FAIL] $name"
        FAILED=1
    fi
}

check_command "Git" "git"
check_command "Make" "make"
check_command "Python" "python"
check_command "Icarus Verilog" "iverilog"
check_command "Verilator" "verilator"
check_command "GTKWave" "gtkwave"
check_command "Yosys" "yosys"

echo

if (( FAILED != 0 )); then
    echo "============================================================"
    echo " SETUP FAILED"
    echo "============================================================"
    echo
    echo "One or more required tools could not be found."
    echo "Make sure you are using the MSYS2 UCRT64 terminal."
    exit 1
fi

echo "============================================================"
echo " SETUP COMPLETE"
echo "============================================================"
echo
echo "Installed / verified:"
echo "  ✓ Git"
echo "  ✓ Make"
echo "  ✓ Python"
echo "  ✓ Icarus Verilog"
echo "  ✓ Verilator"
echo "  ✓ GTKWave"
echo "  ✓ Yosys"
echo
echo "Workshop flow:"
echo "  ./flows/sim.sh"
echo "  ./flows/lint.sh"
echo "  yosys -s flows/synth.ys"
echo
echo "============================================================"