#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# AIxVLSI-CAD Workshop - One-Click Ubuntu Setup
# Installs the host-side tools needed for the workshop frontend
# and the LibreLane + Docker backend environment.
#
# Supported target: Ubuntu 22.04+
# Run as your NORMAL USER:
#   bash AIxVLSI_CAD_Workshop_setup.sh
# Do NOT run this script with sudo.
# ============================================================

PROJECT_DIR="$HOME/AIxVLSI-CAD-Workshop"
VENV_DIR="$HOME/librelane-venv"
MIN_DOCKER_VERSION="25.0.5"

echo "============================================================"
echo " AIxVLSI-CAD Workshop - One-Click Setup"
echo "============================================================"
echo

# ---------- Basic checks ----------
if [[ $EUID -eq 0 ]]; then
    echo "ERROR: Run this script as your normal user, not with sudo."
    exit 1
fi

if [[ ! -f /etc/os-release ]]; then
    echo "ERROR: Cannot detect the Linux distribution."
    exit 1
fi

source /etc/os-release

if [[ "${ID:-}" != "ubuntu" ]]; then
    echo "ERROR: This installer is for Ubuntu."
    echo "Detected: ${PRETTY_NAME:-unknown}"
    exit 1
fi

# Require Ubuntu 22.04 or newer.
if [[ "${VERSION_ID:-0}" =~ ^([0-9]+)\.([0-9]+)$ ]]; then
    UBUNTU_MAJOR="${BASH_REMATCH[1]}"
    if (( UBUNTU_MAJOR < 22 )); then
        echo "ERROR: Ubuntu 22.04 or newer is required."
        echo "Detected: ${PRETTY_NAME:-unknown}"
        exit 1
    fi
else
    echo "ERROR: Could not determine Ubuntu version."
    exit 1
fi

echo "Detected: ${PRETTY_NAME}"
echo

# ---------- 1. Ubuntu packages ----------
echo "[1/7] Installing required Ubuntu packages..."
sudo apt-get update

sudo apt-get install -y \
    build-essential \
    make \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    python3 \
    python3-pip \
    python3-venv \
    python3-tk \
    iverilog \
    gtkwave \
    yosys

echo "Ubuntu packages: OK"
echo

# ---------- 2. Docker ----------
echo "[2/7] Checking Docker..."

install_docker() {
    echo "Docker is not installed."
    echo "Installing Docker Engine from Docker's official repository..."

    sudo install -m 0755 -d /etc/apt/keyrings

    if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
        sudo curl -fsSL \
            https://download.docker.com/linux/ubuntu/gpg \
            -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
    fi

    ARCH="$(dpkg --print-architecture)"
    CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"

    if [[ -z "$CODENAME" ]]; then
        echo "ERROR: Could not determine Ubuntu codename."
        exit 1
    fi

    sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${CODENAME}
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt-get update
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin

    sudo systemctl enable --now docker
}

if ! command -v docker >/dev/null 2>&1; then
    install_docker
else
    sudo systemctl enable --now docker 2>/dev/null || true
fi

# Make sure the Docker daemon actually responds.
if ! sudo docker info >/dev/null 2>&1; then
    echo
    echo "ERROR: Docker is installed but the Docker daemon is not responding."
    echo "Try: sudo systemctl status docker"
    exit 1
fi

# Check Docker server version against LibreLane's documented minimum.
DOCKER_SERVER_VERSION="$(sudo docker version --format '{{.Server.Version}}' 2>/dev/null || true)"

if [[ -z "$DOCKER_SERVER_VERSION" ]]; then
    echo "ERROR: Could not read the Docker server version."
    exit 1
fi

if ! printf '%s\n%s\n' "$MIN_DOCKER_VERSION" "$DOCKER_SERVER_VERSION" | sort -V -C; then
    echo
    echo "ERROR: Docker ${DOCKER_SERVER_VERSION} is too old."
    echo "LibreLane requires Docker ${MIN_DOCKER_VERSION} or newer."
    echo
    echo "If you installed Docker from an older Ubuntu package, remove/upgrade"
    echo "that installation and rerun this script."
    exit 1
fi

echo "Docker server: ${DOCKER_SERVER_VERSION} (OK)"

# Docker group is required for normal non-root Docker use.
if ! getent group docker >/dev/null 2>&1; then
    sudo groupadd docker
fi

sudo usermod -aG docker "$USER"

# Test Docker immediately using the docker group without requiring logout.
echo "Testing Docker..."
sudo docker run --rm hello-world >/dev/null
sg docker -c 'docker run --rm hello-world >/dev/null'
echo "Docker: OK"
echo

# ---------- 3. LibreLane Python environment ----------
echo "[3/7] Creating LibreLane Python environment..."

if [[ ! -d "$VENV_DIR" ]]; then
    python3 -m venv "$VENV_DIR"
fi

# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

python3 -m pip install --upgrade pip
python3 -m pip install --upgrade librelane

echo "LibreLane: $(python3 -m librelane --version)"
echo

# ---------- 4. Verify host tools ----------
echo "[4/7] Verifying installed tools..."

echo "Python:  $(python3 --version)"
echo "Git:     $(git --version)"
echo "Icarus:  $(iverilog -V 2>&1 | head -n 1)"
echo "Yosys:   $(yosys -V)"
echo "GTKWave: $(gtkwave --version 2>&1 | head -n 1)"
echo "Docker:  $(sudo docker --version)"
echo "LibreLane: $(python3 -m librelane --version)"
echo

# ---------- 5. LibreLane Docker smoke test ----------
echo "[5/7] Running LibreLane Docker smoke test..."
sg docker -c \
    "source '$VENV_DIR/bin/activate' && \
     python3 -m librelane --dockerized --smoke-test"

echo "LibreLane Docker environment: OK"
echo

# ---------- 6. Workshop directory check ----------
echo "[6/7] Checking workshop project..."

if [[ -d "$PROJECT_DIR" ]]; then
    echo "Workshop project found:"
    echo "  $PROJECT_DIR"
else
    echo "Workshop project directory does not exist yet."
    echo "That is OK - the installer does not create project source files."
fi
echo

# ---------- 7. Final summary ----------
echo "[7/7] Setup complete."
echo
echo "============================================================"
echo " EVERYTHING REQUIRED FOR THE CORE WORKSHOP IS READY"
echo "============================================================"
echo
echo "HOST TOOLS INSTALLED:"
echo "  ✓ Git"
echo "  ✓ Icarus Verilog"
echo "  ✓ GTKWave"
echo "  ✓ Yosys"
echo "  ✓ Python 3 + pip + venv + tkinter"
echo "  ✓ build-essential + make"
echo "  ✓ Docker Engine"
echo "  ✓ LibreLane"
echo
echo "BACKEND TOOLS PROVIDED THROUGH LIBRELANE'S DOCKER ENVIRONMENT:"
echo "  ✓ OpenROAD"
echo "  ✓ Yosys (backend/container copy)"
echo "  ✓ Magic"
echo "  ✓ KLayout"
echo "  ✓ Netgen"
echo "  ✓ Other LibreLane flow dependencies"
echo
echo "NOT INSTALLED BY THIS SCRIPT:"
echo "  - Host KLayout GUI"
echo "  - Host OpenROAD GUI"
echo "  - OpenLane 1"
echo "  - Separate host Magic/Netgen installations"
echo "  - Verilator (not required for this workshop flow)"
echo
echo "PDK:"
echo "  LibreLane manages the compatible PDK through its PDK/Ciel mechanism."
echo "  The default Sky130 flow uses sky130A."
echo
echo "IMPORTANT:"
echo "  Docker group membership was added for: $USER"
echo "  Log out and log back in once (or reboot) before using Docker"
echo "  normally without sudo in a fresh terminal."
echo
echo "After logging back in:"
echo "  source ~/librelane-venv/bin/activate"
echo "  docker run --rm hello-world"
echo
echo "Then your backend flow can be run from the project directory."
echo "============================================================"
