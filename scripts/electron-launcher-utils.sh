#!/usr/bin/env bash

function maybe_reexec_with_xvfb() {
	local script_path="$1"
	shift

	local display_unavailable=0
	if [[ -z "${DISPLAY:-}" ]]; then
		display_unavailable=1
	elif command -v xdpyinfo > /dev/null 2>&1 && ! xdpyinfo > /dev/null 2>&1; then
		display_unavailable=1
	fi

	if [[ "$OSTYPE" != "darwin"* ]] && [[ "$display_unavailable" == "1" ]] && command -v xvfb-run > /dev/null 2>&1 && [[ "${VSCODE_SKIP_XVFB_WRAPPER:-0}" != "1" ]]; then
		VSCODE_SKIP_XVFB_WRAPPER=1 xvfb-run -a "$script_path" "$@"
		exit $?
	fi
}

function ensure_electron_binary_with_retry() {
	local binary_path="$1"

	if [[ -e "$binary_path" ]] && [[ ! -x "$binary_path" ]]; then
		chmod +x "$binary_path" 2>/dev/null || true
	fi

	if [[ -x "$binary_path" ]]; then
		return 0
	fi

	echo "Electron binary '$binary_path' missing, retrying setup..."
	npm run electron

	if [[ -e "$binary_path" ]] && [[ ! -x "$binary_path" ]]; then
		chmod +x "$binary_path" 2>/dev/null || true
	fi

	if [[ ! -x "$binary_path" ]]; then
		echo "ERROR: Electron binary '$binary_path' not found after setup."
		return 1
	fi

	return 0
}
