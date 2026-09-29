#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_root="$repo_root/.agents/skills"
install_home="${1:-${HOME:?HOME is not set}}"
codex_home="${CODEX_HOME:-$install_home/.codex}"

if [[ ! -d "$source_root" ]]; then
  echo "Skill directory not found: $source_root" >&2
  exit 1
fi

skill_dirs=("$source_root"/*)
if [[ ! -e "${skill_dirs[0]}" ]]; then
  echo "No skills found under $source_root" >&2
  exit 1
fi

destinations=(
  "$install_home/.agents/skills"
  "$install_home/.claude/skills"
  "$codex_home/skills"
  "$install_home/.config/opencode/skills"
)

for skill_source in "${skill_dirs[@]}"; do
  [[ -d "$skill_source" ]] || continue
  skill_name="${skill_source##*/}"

  for skills_dir in "${destinations[@]}"; do
    mkdir -p "$skills_dir"
    target="$skills_dir/$skill_name"

    if [[ -L "$target" && "$(readlink "$target")" == "$skill_source" ]]; then
      printf 'Already linked: %s\n' "$target"
    elif [[ -e "$target" || -L "$target" ]]; then
      printf 'Skipped existing skill: %s\n' "$target" >&2
    else
      ln -s "$skill_source" "$target"
      printf 'Linked: %s -> %s\n' "$target" "$skill_source"
    fi
  done
done
