#!/usr/bin/env bash
set -euo pipefail

# AIxVLSI-CAD Workshop - Linux Lab Setup
# Target: Ubuntu 22.04+
# Run as a normal user:
#   ./tools/setup.sh

MIN_DOCKER_VERSION="25.0.5"
VENV_DIR="$HOME/librelane-venv"

echo "============================================================"
echo " AIxVLSI-CAD Workshop - Linux Lab Setup"
echo "============================================================"
echo

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
    echo "ERROR: This setup currently supports Ubuntu only."
    echo "Detected: ${PRETTY_NAME:-unknown}"
    exit 1
fi

if [[ "${VERSION_ID:-0}" =~ ^([0-9]+)\.([0-9]+)$ ]]; then
    UBUNTU_MAJOR="${BASH_REMATCH[1]}"
    if (( UBUNTU_MAJOR < 22 )); then
        echo "ERROR: Ubuntu 22.04 or newer is required."
        exit 1
    fi
else
    echo "ERROR: Could not determine Ubuntu version."
    exit 1
fi

echo "Detected: ${PRETTY_NAME}"
echo

echo "[1/6] Installing required Ubuntu packages..."
sudo apt-get update
sudo apt-get install -y \
    build-essential ca-certificates curl git make \
    python3 python3-pip python3-venv python3-tk \
    iverilog verilator gtkwave yosys
echo "Base tools: OK"
echo

echo "[2/6] Checking Docker..."

install_docker() {
    echo "Docker is not installed. Installing Docker Engine..."

    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings

    if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
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
        docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin

    sudo systemctl enable --now docker
}

if ! command -v docker >/dev/null 2>&1; then
    install_docker
else
    sudo systemctl enable --now docker 2>/dev/null || true
fi

if ! sudo docker info >/dev/null 2>&1; then
    echo "ERROR: Docker daemon is not responding."
    echo "Try: sudo systemctl status docker"
    exit 1
fi

DOCKER_SERVER_VERSION="$(sudo docker version --format '{{.Server.Version}}' 2>/dev/null || true)"

if [[ -z "$DOCKER_SERVER_VERSION" ]]; then
    echo "ERROR: Could not determine Docker server version."
    exit 1
fi

if ! printf '%s\n%s\n' "$MIN_DOCKER_VERSION" "$DOCKER_SERVER_VERSION" | sort -V -C; then
    echo "ERROR: Docker ${DOCKER_SERVER_VERSION} is too old."
    echo "LibreLane requires Docker ${MIN_DOCKER_VERSION} or newer."
    exit 1
fi

echo "Docker ${DOCKER_SERVER_VERSION}: OK"

if ! getent group docker >/dev/null 2>&1; then
    sudo groupadd docker
fi

sudo usermod -aG docker "$USER"
sudo docker run --rm hello-world >/dev/null
echo "Docker daemon: OK"
echo

echo "[3/6] Installing LibreLane..."

if [[ ! -d "$VENV_DIR" ]]; then
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade librelane

echo "LibreLane: $(python3 -m librelane --version)"
echo

echo "[4/6] Verifying installed tools..."

echo "Icarus Verilog: $(iverilog -V 2>&1 | head -n 1)"
echo "Verilator:       $(verilator --version)"
echo "GTKWave:         $(gtkwave --version 2>&1 | head -n 1)"
echo "Yosys:            $(yosys --version)"
echo "Python:           $(python3 --version)"
echo "Docker:           $(sudo docker --version)"
echo "LibreLane:        $(python3 -m librelane --version)"
echo

echo "[5/6] Running LibreLane Docker smoke test..."

sg docker -c \
    "source '$VENV_DIR/bin/activate' && python3 -m librelane --dockerized --smoke-test"

echo "LibreLane Docker environment: OK"
echo

echo "[6/6] Final verification..."

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

check_command "Icarus Verilog" "iverilog"
check_command "Verilator" "verilator"
check_command "GTKWave" "gtkwave"
check_command "Yosys" "yosys"
check_command "Python 3" "python3"
check_command "Docker" "docker"

if [[ -x "$VENV_DIR/bin/python3" ]]; then
    echo "  [OK] LibreLane virtual environment"
else
    echo "  [FAIL] LibreLane virtual environment"
    FAILED=1
fi

echo

if (( FAILED != 0 )); then
    echo "============================================================"
    echo " SETUP FAILED"
    echo "============================================================"
    exit 1
fi

echo "============================================================"
echo " SETUP COMPLETE"
echo "============================================================"
echo
echo "Installed / verified:"
echo "  ✓ Icarus Verilog"
echo "  ✓ Verilator"
echo "  ✓ GTKWave"
echo "  ✓ Yosys"
echo "  ✓ Docker"
echo "  ✓ LibreLane"
echo
echo "LibreLane environment:"
echo "  source $VENV_DIR/bin/activate"
echo
echo "Workshop commands:"
echo "  ./flows/sim.sh"
echo "  ./flows/lint.sh"
echo "  yosys -s flows/synth.ys"
echo
echo "IMPORTANT:"
echo "Docker access was added for user: $USER"
echo "Log out and log back in once before using Docker"
echo "without sudo in a new terminal."
echo
echo "============================================================"
