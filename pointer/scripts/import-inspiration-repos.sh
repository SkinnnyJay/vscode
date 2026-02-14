#!/usr/bin/env bash
# import-inspiration-repos.sh — Clone (or update) inspiration/forked-project repos on demand.
# Usage: ./scripts/import-inspiration-repos.sh [name ...]
#   With no args: clone or pull all repos listed in scratchpad/research/inspiration-forked-projects/repos.json.
#   With names: clone or pull only those repos (e.g. ./scripts/import-inspiration-repos.sh toad codex-monitor).
# Repos go to scratchpad/research/inspiration-forked-projects/repos/<name>/.
# Requires: git, jq. See scratchpad/research/inspiration-forked-projects/README.md for how to extend.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSPIRATION_DIR="$REPO_ROOT/scratchpad/research/inspiration-forked-projects"
REPOS_JSON="$INSPIRATION_DIR/repos.json"
REPOS_DIR="$INSPIRATION_DIR/repos"

if [[ ! -f "$REPOS_JSON" ]]; then
  echo "import-inspiration-repos: repos.json not found at $REPOS_JSON" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "import-inspiration-repos: jq is required to read repos.json. Install jq and retry." >&2
  exit 1
fi

mkdir -p "$REPOS_DIR"

# Optional: filter by names passed as args
FILTER_NAMES=()
while [[ $# -gt 0 ]]; do
  FILTER_NAMES+=("$1")
  shift
done

clone_or_pull() {
  local name url branch
  name="$1"
  url="$2"
  branch="${3:-main}"
  local dest="$REPOS_DIR/$name"
  if [[ -d "$dest/.git" ]]; then
    echo "Updating $name..."
    (cd "$dest" && git fetch origin && git checkout "$branch" 2>/dev/null || true && git pull --rebase origin "$branch" 2>/dev/null || git pull origin "$branch")
  else
    echo "Cloning $name..."
    git clone --branch "$branch" --single-branch --depth 1 "$url" "$dest" 2>/dev/null || git clone -b "$branch" "$url" "$dest"
  fi
}

# Read repos from JSON and optionally filter
while IFS= read -r line; do
  name=$(jq -r '.name' <<< "$line")
  url=$(jq -r '.url' <<< "$line")
  branch=$(jq -r '.branch // "main"' <<< "$line")
  if [[ -z "$name" || "$name" == "null" ]] || [[ -z "$url" || "$url" == "null" ]]; then
    continue
  fi
  if [[ ${#FILTER_NAMES[@]} -gt 0 ]]; then
    found=0
    for f in "${FILTER_NAMES[@]}"; do
      if [[ "$f" == "$name" ]]; then
        found=1
        break
      fi
    done
    [[ $found -eq 1 ]] || continue
  fi
  clone_or_pull "$name" "$url" "$branch"
done < <(jq -c '.[]' "$REPOS_JSON")

echo "Done. Repos under $REPOS_DIR"
