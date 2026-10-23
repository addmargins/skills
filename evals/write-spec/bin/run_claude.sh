#!/usr/bin/env bash
# usage: run_claude.sh <run_id> <out_name> <prompt> [resume_session_id|CONTINUE]
#
# Runs `claude -p <prompt>` in $WRITE_SPEC_RUNS/<run_id>/repo (default runs dir:
# ${TMPDIR:-/tmp}/write-spec-runs, outside the repo so runs can't see plan.md or cases.md) and writes <out_name>.jsonl (stream-json transcript),
# <out_name>.err and <out_name>.meta.json next to repo/.
# A 4th argument resumes that session id; CONTINUE uses --continue instead.
# Env: MODEL, if set, is passed to claude as --model.
set -u
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../../.." && pwd)
runs=${WRITE_SPEC_RUNS:-${TMPDIR:-/tmp}/write-spec-runs}

if [ $# -lt 3 ]; then
  sed -n '2p' "$0" >&2; exit 2
fi
id=$1; out=$2; prompt=$3; resume=${4:-}
d=$runs/$id
cd "$d/repo" || { echo "no run repo at $d/repo; run setup_run.sh first" >&2; exit 1; }
start=$(date +%s)
if [ "$resume" = CONTINUE ]; then extra=(--continue); elif [ -n "$resume" ]; then extra=(--resume "$resume"); else extra=(); fi
if [ -n "${MODEL:-}" ]; then model=(--model "$MODEL"); else model=(); fi
timeout 5400 claude -p "$prompt" ${extra[@]+"${extra[@]}"} ${model[@]+"${model[@]}"} --output-format stream-json --verbose \
  --allowedTools "Read" "Write" "Edit" "Glob" "Grep" "Bash" "Agent" "Task" "Skill" > "$d/$out.jsonl" 2> "$d/$out.err"
rc=$?
end=$(date +%s)
python3 -I - "$d/$out.jsonl" "$((end-start))" "$rc" > "$d/$out.meta.json" <<'PY'
import json, sys
p, secs, rc = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
sid = None; model = None; usage = None; cost = None; result = None; agents = 0
for line in open(p, errors="replace"):
    try: e = json.loads(line)
    except Exception: continue
    if e.get("type") == "system" and e.get("subtype") == "init": sid = e.get("session_id"); model = e.get("model")
    if e.get("type") == "result": usage = e.get("usage"); cost = e.get("total_cost_usd"); result = e.get("result"); sid = e.get("session_id", sid)
    m = e.get("message") or {}
    if isinstance(m, dict) and isinstance(m.get("content"), list) and e.get("type") == "assistant" and not e.get("parent_tool_use_id"):
        agents += sum(1 for c in m["content"] if isinstance(c, dict) and c.get("type") == "tool_use" and c.get("name") in ("Agent", "Task"))
print(json.dumps({"session_id": sid, "model": model, "seconds": secs, "exit": rc, "usage": usage, "cost_usd": cost, "top_level_agent_calls": agents, "result": result}, ensure_ascii=False, indent=1))
PY
echo "done $id/$out rc=$rc $((end-start))s"
