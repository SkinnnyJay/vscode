#!/usr/bin/env bash
# Guard staged changes against large binaries and decompiled artifacts.

set -euo pipefail

max_size_bytes=$((5 * 1024 * 1024))

blocked_extensions_regex='(\.class|\.pyc|\.pyo|\.dll|\.so|\.dylib|\.exe|\.jar|\.o|\.obj|\.apk|\.ipa|\.dmg|\.iso|\.bin)$'
blocked_name_regex='(decompile|decompiled|ghidra|jadx|bytecode-dump)'

errors=0

while IFS= read -r staged_path; do
	# Skip deleted files
	if ! git cat-file -e ":${staged_path}" 2>/dev/null; then
		continue
	fi

	lower_path=$(printf '%s' "${staged_path}" | tr '[:upper:]' '[:lower:]')
	size_bytes=$(git cat-file -s ":${staged_path}")

	if [[ "${lower_path}" =~ ${blocked_extensions_regex} ]]; then
		echo "Blocked binary extension in staged file: ${staged_path}"
		errors=1
	fi

	if [[ "${lower_path}" =~ ${blocked_name_regex} ]]; then
		echo "Blocked decompiled artifact pattern in staged file: ${staged_path}"
		errors=1
	fi

	if [ "${size_bytes}" -gt "${max_size_bytes}" ]; then
		echo "Blocked large staged file (>5MB): ${staged_path} (${size_bytes} bytes)"
		errors=1
	fi
done < <(git diff --cached --name-only)

if [ "${errors}" -ne 0 ]; then
	echo "Pre-commit guard failed: remove blocked artifacts or use approved release channel for binaries."
	exit 1
fi
