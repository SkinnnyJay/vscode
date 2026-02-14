#!/usr/bin/env bash
# Pointer IDE setup: ensure Node version and install deps.

set -euo pipefail

required_major=22

if ! command -v node >/dev/null 2>&1; then
	echo "Node.js is required. Install Node ${required_major}.x and re-run make setup."
	exit 1
fi

node_version="$(node -v | tr -d 'v')"
node_major="$(printf "%s" "${node_version}" | cut -d. -f1)"

if [ "${node_major}" -lt "${required_major}" ]; then
	echo "Node.js ${required_major}.x is required. Detected ${node_version}."

	if [ -x "/opt/homebrew/opt/node@22/bin/node" ]; then
		echo "Homebrew Node 22 detected at /opt/homebrew/opt/node@22/bin/node."
		echo "To use it for this shell:"
		echo "  export PATH=\"/opt/homebrew/opt/node@22/bin:\$PATH\""
		echo "To make it permanent (zsh):"
		echo "  echo 'export PATH=\"/opt/homebrew/opt/node@22/bin:\$PATH\"' >> ~/.zshrc"
	fi

	if [ -f "${HOME}/.nvm/nvm.sh" ]; then
		echo "nvm detected. To install and use Node 22:"
		echo "  source ~/.nvm/nvm.sh"
		echo "  nvm install 22"
		echo "  nvm use 22"
	fi

	echo "Then re-run: make setup"
	exit 1
fi

echo "Node ${node_version} detected. Installing dependencies..."
npm install
