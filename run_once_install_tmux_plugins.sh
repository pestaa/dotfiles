#!/bin/bash

TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ -d "$TPM_DIR" ]; then
  echo "Installing tmux plugins via TPM..."
  "$TPM_DIR/bin/install_plugins"
  echo "Tmux plugins installed successfully!"
else
  echo "Warning: TPM directory not found at $TPM_DIR."
  echo "Skipping tmux plugin installation."
fi
