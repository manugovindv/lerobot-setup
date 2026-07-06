#!/bin/bash
set -euo pipefail

CONDA_PREFIX="$HOME/miniforge3"
INSTALLER="Miniforge3-$(uname)-$(uname -m).sh"
ENV_NAME="lerobot"
LEROBOT_DIR="$HOME/lerobot"

echo "============================================"
echo "  LeRobot Automated Setup"
echo "============================================"

# ── 1. Download Miniforge ─────────────────────────────────────────────────────
echo "[1/8] Downloading Miniforge installer..."
wget -q --show-progress \
    "https://github.com/conda-forge/miniforge/releases/latest/download/${INSTALLER}"

# ── 2. Install Miniforge (batch mode, no prompts) ────────────────────────────
echo "[2/8] Installing Miniforge..."
bash "${INSTALLER}" -b -u -p "${CONDA_PREFIX}"
rm -f "${INSTALLER}"

# ── 3. Disable base env auto-activation ──────────────────────────────────────
"${CONDA_PREFIX}/bin/conda" config --set auto_activate_base false 2>/dev/null

# ── 4. Initialise conda in this script session ────────────────────────────────
echo "[3/8] Initialising conda..."
source "${CONDA_PREFIX}/etc/profile.d/conda.sh"
conda init bash --quiet

# ── 5. Create environment ─────────────────────────────────────────────────────
echo "[4/8] Creating conda env '${ENV_NAME}' (python=3.12)..."
conda create -y -n "${ENV_NAME}" python=3.12

# ── 6. Activate environment ───────────────────────────────────────────────────
echo "[5/8] Activating env..."
conda activate "${ENV_NAME}"

# ── 7. Install dependencies ───────────────────────────────────────────────────
echo "[6/8] Installing ffmpeg and pip..."
conda install -y ffmpeg -c conda-forge
conda install -y pip

# ── 8. Clone LeRobot ──────────────────────────────────────────────────────────
echo "[7/8] Cloning LeRobot..."
if [ -d "${LEROBOT_DIR}" ]; then
    echo "  → Directory already exists, pulling latest..."
    git -C "${LEROBOT_DIR}" pull
else
    git clone https://github.com/huggingface/lerobot.git "${LEROBOT_DIR}"
fi

# ── 9. Install LeRobot packages ───────────────────────────────────────────────
echo "[8/8] Installing lerobot packages..."
cd "${LEROBOT_DIR}"
pip install --no-cache-dir -e .
pip install --no-cache-dir -e ".[feetech]"

echo ""
echo "============================================"
echo "  ✓ Setup complete!"
echo "  Activate with:  conda activate ${ENV_NAME}"
echo "============================================"