# LLM grader brief

The common opening for every LLM grader. Give a fresh agent (a Claude Code subagent, or `claude -p` started outside the run repos) this brief, a blank line, one case task, a blank line, and `Your grade_id is "<GRADE_ID>".`

Fill in the UPPERCASE placeholders. Lowercase ones such as `<spec>` and `<path>` are part of the text the grader reads.

- `<REPO>`: absolute path of this skills repo.
- `<HARNESS>`: `<REPO>/evals/write-spec`.
- `<RUNS>`: the runs directory (`$WRITE_SPEC_RUNS`, or `<HARNESS>/.runs`).
- `<GRADES>`: a directory for grade files, outside every run repo.
- `<GRADE_ID>`: usually the run id.
- In the case tasks, `<RUN_ID>`, `<BASELINE_RUN_ID>` and `<BASELINE_LINES>` are what they say.

```text
You are grading one test run of the Claude Code skill "write-spec". The skill is at <REPO>/skills/engineering/write-spec/ (SKILL.md and references/); read it so you know what it requires. Don't edit anything under <REPO> or any run's repo.
Test plan: <HARNESS>/plan.md. Fixture notes and final prompts and assertions per run: <HARNESS>/cases.md; where it adapts the plan, cases.md wins.
Run directories are under <RUNS>/<run_id>/. Each holds:
- repo/: the workspace after the run. It is a git repo with a base commit; use git -C repo status, git diff, and git show HEAD:<path> for the before state.
- t1.jsonl (t2.jsonl, ... for later turns): the stream-json transcript. Don't read it whole; grep it or use the script below.
- t1.meta.json (t2.meta.json, ...): time, cost, the final message as "result", and the count of top-level subagent calls.
Scoring script: python3 -I <HARNESS>/score.py <check> ... Checks: ids <spec>, 3parts <spec>, leak <spec>, paths <spec> <repo_dir>, draft <jsonl> <spec_rel_path>, readers <jsonl>. The skill now intends each Reviewers row to list the questions plus other asks addressed to that person, so judge the ids check's reviewer match by that rule.
Grade every assertion strictly and literally, quoting evidence. A behavior the spec decides itself, even if marked provisional or assumed, counts as deciding it; a recommendation that sits only inside an open question does not.
Write <GRADES>/<grade_id>.json with this shape: {"grade_id":..., "assertions":[{"id":..., "text":..., "passed":bool, "evidence":...}], "metrics":{...}, "defects":[{"what":..., "evidence":..., "skill_fix":...}], "notes":...}. Under "defects", list only real skill defects. Reply with the pass count and the top two defects in at most four lines.
```

## Case tasks

T2 and T3 runs use [task-t2-t3.md](task-t2-t3.md). For other cases, write one paragraph that names the run and the assertions to grade from cases.md. Two that were used in round 9:

```text
One run: <RUN_ID>. It is a rerun of T1 revise-relayed-answers-ko on the same fixture as t1. Grade T1 assertions 1–8 as cases.md states them for t1. Metrics: open and blocking counts before and after, reader rounds, seconds, cost. Also say whether the run ran a second reader round after applying round-1 findings.
```

```text
One run: <RUN_ID>. It is a rerun of T4 turn 1 only, on shelfdesk, with no later turns. Grade T4 assertions 1, 2, 3, 4 and 8 as cases.md states them for t4-with; for 8, do the litmus audit yourself, as fresh reader and then as judge. The baseline spec is in <RUNS>/<BASELINE_RUN_ID>/repo/docs/specs/, at <BASELINE_LINES> lines. Report the length ratio and say whether it is at most 1.5×.
```
