#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# AIxVLSI-CAD Workshop - Windows + MSYS2 Setup
#
# Run this script from the MSYS2 terminal.
#
# Prerequisites:
#   1. MSYS2 installed
#   2. VS Code installed
#   3. Docker Desktop installed and RUNNING
#
# This script does NOT install Windows applications.
# It prepares the LibreLane Python environment and verifies
# Dockerized LibreLane.
# ============================================================

PROJECT_DIR="$HOME/AIxVLSI-CAD-Workshop"
VENV_DIR="$HOME/librelane-venv"

echo "============================================================"
echo " AIxVLSI-CAD Workshop - Windows + MSYS2 Setup"
echo "============================================================"
echo

# ---------- 1. Basic checks ----------
echo "[1/5] Checking required programs..."

if ! command -v git >/dev/null 2>&1; then
    echo
    echo "ERROR: Git was not found."
    echo "Please install Git through MSYS2 and run this script again."
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo
    echo "ERROR: Python 3 was not found in MSYS2."
    echo "Please install Python 3 through MSYS2 and run this script again."
    exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
    echo
    echo "ERROR: Docker was not found."
    echo "Please install Docker Desktop for Windows and make sure it is running."
    exit 1
fi

echo "Git:    $(git --version)"
echo "Python: $(python3 --version)"
echo "Docker: $(docker --version)"
echo

# ---------- 2. Docker check ----------
echo "[2/5] Checking Docker Desktop..."

if ! docker info >/dev/null 2>&1; then
    echo
    echo "ERROR: Docker Desktop is not running or Docker is not accessible."
    echo
    echo "Please:"
    echo "  1. Start Docker Desktop"
    echo "  2. Wait until Docker Desktop says it is running"
    echo "  3. Run this setup script again"
    exit 1
fi

echo "Docker Desktop: OK"
echo

echo "Testing Docker..."
docker run --rm hello-world >/dev/null

echo "Docker: OK"
echo

# ---------- 3. LibreLane virtual environment ----------
echo "[3/5] Setting up LibreLane..."

if [[ ! -d "$VENV_DIR" ]]; then
    python3 -m venv "$VENV_DIR"
fi

# Activate LibreLane environment
source "$VENV_DIR/bin/activate"

python3 -m pip install --upgrade pip
python3 -m pip install --upgrade librelane

echo
echo "LibreLane: $(python3 -m librelane --version)"
echo

# ---------- 4. Project check ----------
echo "[4/5] Checking workshop project..."

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo
    echo "WARNING: Workshop project was not found at:"
    echo "  $PROJECT_DIR"
    echo
    echo "Make sure you cloned the repository first."
else
    echo "Workshop project: OK"
    echo "Location: $PROJECT_DIR"
fi

echo

# ---------- 5. LibreLane Docker smoke test ----------
echo "[5/5] Testing Dockerized LibreLane..."
echo
echo "The first run may download a large Docker image."
echo "Please wait until the test finishes."
echo

python3 -m librelane --dockerized --smoke-test

echo
echo "============================================================"
echo " SETUP COMPLETE!"
echo "============================================================"
echo
echo "✓ MSYS2 detected"
echo "✓ Git detected"
echo "✓ Python detected"
echo "✓ Docker Desktop detected"
echo "✓ Docker working"
echo "✓ LibreLane installed"
echo "✓ Dockerized LibreLane smoke test passed"
echo
echo "Your computer is ready for the AIxVLSI-CAD Workshop."
echo
echo "For the workshop:"
echo "  cd ~/AIxVLSI-CAD-Workshop"
echo "  source ~/librelane-venv/bin/activate"
echo
echo "============================================================"
