#!/bin/bash

# Configuration
VENV_DIR="env"
KERNEL_NAME="Python ($VENV_DIR)"
PACKAGES="scikit-learn pandas numpy tensorflow matplotlib seaborn jupyterlab notebook"
PYTHON_BIN="$VENV_DIR/bin/python"
PIP_BIN="$VENV_DIR/bin/pip"

echo "🌌 Starting ML Environment Setup..."

# --- 1. Virtual Environment Creation ---
if [ -d "$VENV_DIR" ]; then
    echo "✅ Virtual environment '$VENV_DIR' already exists."
else
    echo "🔨 Creating virtual environment '$VENV_DIR'..."
    if command -v python3 &> /dev/null; then
        python3 -m venv "$VENV_DIR"
        if [ $? -eq 0 ]; then
            echo "✨ Virtual environment created successfully."
        else
            echo "❌ Failed to create virtual environment. Aborting."
            exit 1
        fi
    else
        echo "❌ python3 command not found. Please install Python 3. Aborting."
        exit 1
    fi
fi

# --- 2. Dependency Installation ---
echo "📦 Installing core packages ($PACKAGES) inside $VENV_DIR..."
# Ensure pip is up-to-date and then install packages
if [ -f "$PIP_BIN" ]; then
    "$PIP_BIN" install --upgrade pip setuptools wheel
    "$PIP_BIN" install $PACKAGES ipykernel
    if [ $? -eq 0 ]; then
        echo "✅ All ML packages and ipykernel installed successfully."
    else
        echo "⚠️ Warning: Some package installations failed. Check error messages above."
    fi
else
    echo "❌ Pip executable not found in '$PIP_BIN'. Venv creation may have failed."
    exit 1
fi

# --- 3. Ipykernel Registration Check and Registration ---
# Check if the desired kernel name is already registered
# Note: We use the kernel's display name for a robust check
if jupyter kernelspec list --json 2>/dev/null | grep -q "\"$KERNEL_NAME\""; then
    echo "✅ Jupyter kernel '$KERNEL_NAME' is already registered. Good to go."
else
    echo "📝 Registering Jupyter kernel '$KERNEL_NAME'..."
    # The --display-name flag gives the name that appears in the Jupyter interface
    # The --name flag is the directory name in the kernelspec location (using 'env' here)
    if [ -f "$PYTHON_BIN" ]; then
        "$PYTHON_BIN" -m ipykernel install --user --name="$VENV_DIR" --display-name="$KERNEL_NAME"
        if [ $? -eq 0 ]; then
            echo "🎉 Kernel registered! You can now select '$KERNEL_NAME' in Jupyter/VS Code."
        else
            echo "❌ Failed to register ipykernel. Ensure Jupyter is installed globally (pip install jupyter)."
        fi
    else
        echo "❌ Python executable not found for registration. Aborting."
    fi
fi

echo "🚀 Setup complete. Run 'source $VENV_DIR/bin/activate' to activate the environment in your shell, or launch Jupyter and select the '$KERNEL_NAME' kernel."
echo "Note: 'pickle' is a built-in Python module and doesn't require a separate installation."