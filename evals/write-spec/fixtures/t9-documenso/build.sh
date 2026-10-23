#!/usr/bin/env bash
# usage: build.sh [out_dir]
#
# Builds the T9 fixture: documenso at tag v2.9.1 (commit 8f3e189), shallow,
# with .git removed, plus docs/intents/0001-recipient-stops-reminders.md.
# The result is about 110 MB, so it is built on demand and not kept in git.
# Default out_dir: $WRITE_SPEC_RUNS/_build/t9-documenso (WRITE_SPEC_RUNS
# defaults to evals/write-spec/.runs). Prints out_dir; pass it to
# bin/setup_run.sh.
set -eu
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../../../.." && pwd)
runs=${WRITE_SPEC_RUNS:-$root/evals/write-spec/.runs}
out=${1:-$runs/_build/t9-documenso}
intent=0001-recipient-stops-reminders.md

if [ -e "$out" ]; then
  if [ -f "$out/docs/intents/$intent" ]; then rm -rf "$out"  # an earlier build
  else echo "$out exists and is not an earlier build; remove it or pick another out_dir" >&2; exit 1; fi
fi
mkdir -p "$(dirname "$out")"
git clone -q --depth 1 --branch v2.9.1 https://github.com/documenso/documenso "$out"
head=$(git -C "$out" rev-parse HEAD)
case $head in
  8f3e189*) ;;
  *) echo "v2.9.1 resolved to $head, expected 8f3e189" >&2; exit 1 ;;
esac
rm -rf "$out/.git"
mkdir -p "$out/docs/intents"
cp "$here/$intent" "$out/docs/intents/$intent"
echo "$out"
