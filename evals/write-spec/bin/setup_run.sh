#!/usr/bin/env bash
# usage: setup_run.sh <fixture_dir> <run_id> [with|without]
#
# Copies <fixture_dir> to $WRITE_SPEC_RUNS/<run_id>/repo (default runs dir:
# ${TMPDIR:-/tmp}/write-spec-runs, outside the repo so runs can't see plan.md or cases.md), drops any .git, installs the write-spec skill
# (SKILL.md and references/ only, never evals/) into .claude/skills/write-spec/
# unless the mode is "without", and commits everything as "base".
# Env: SKILL_SRC installs a variant skill folder instead of the committed one.
# Prints the run repo's path.
set -eu
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../../.." && pwd)
skill=${SKILL_SRC:-$root/skills/engineering/write-spec}
runs=${WRITE_SPEC_RUNS:-${TMPDIR:-/tmp}/write-spec-runs}

if [ $# -lt 2 ]; then
  sed -n '2p' "$0" >&2; exit 2
fi
src=$1; id=$2; mode=${3:-with}
case $mode in with|without) ;; *) echo "mode must be with or without, not: $mode" >&2; exit 2 ;; esac
[ -d "$src" ] || { echo "no such fixture directory: $src" >&2; exit 1; }
if [ -e "$src/build.sh" ]; then
  echo "$src is a build recipe; run $src/build.sh and pass the directory it prints" >&2; exit 1
fi
[ -f "$skill/SKILL.md" ] || { echo "skill not found at $skill" >&2; exit 1; }

d=$runs/$id; rm -rf "$d"; mkdir -p "$d"
cp -R "$src" "$d/repo"; rm -rf "$d/repo/.git"
if [ "$mode" = with ]; then
  mkdir -p "$d/repo/.claude/skills/write-spec"
  cp "$skill/SKILL.md" "$d/repo/.claude/skills/write-spec/"
  cp -R "$skill/references" "$d/repo/.claude/skills/write-spec/"
fi
cd "$d/repo" && git init -q && git add -A && git -c user.email=t@x -c user.name=test commit -qm base
echo "$d/repo"
