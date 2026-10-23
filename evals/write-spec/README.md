# write-spec scenario harness

`skills/engineering/write-spec/evals/` is the skill-creator benchmark: three single-turn cases that skill-creator runs and grades. This folder is the scenario harness. Its nine cases (T1–T9) run the installed skill with real `claude -p` in fixture repos: revisions, multi-turn answers, superseding intents, step-1 gates and a large real repo. Graders are scripts and LLM agents. Run it again after any change to the skill.

- `plan.md`: the test plan, with risks, cases, assertions and pass criteria (§4).
- `cases.md`: the final fixture notes, prompts and assertions for each run. It wins where it differs from the plan.
- `fixtures/`: one plain directory per fixture. `t9-documenso/` holds only a build script and the intent.
- `bin/`: `setup_run.sh` and `run_claude.sh`.
- `score.py`: the script checks.
- `graders/`: prompts for the LLM grader, the litmus audit and the T5 role-play.
- `build/t6_revise.py`: how the T6 fixture's spec was made. It is a record; you don't need to run it.

## Cases

| Case | What it tests | Fixture |
|---|---|---|
| T1 | Revising with relayed answers (Korean): owner checks, partial and proxy answers, stable IDs, moot questions, no acceptance while blocking questions are open | `t1-acme-revise` |
| T2 | The real fresh-reader rounds: who is called, which files reader prompts may name, at most 3 rounds | `acme-subscriptions` (Korean ×3), `ledgerly` (English ×2) |
| T3 | The same five runs: variance, blocking share ≤70%, core gaps found, refund arithmetic, litmus | as T2 |
| T4 | A short intent with no policies: a short spec, one question, the in-session answer loop and acceptance, plus a baseline without the skill | `shelfdesk` |
| T5 | Whether non-engineer reviewers can find and answer their own questions (role-play only; nothing is executed) | specs from other runs |
| T6 | A superseding intent: a new spec, one line added to the old one, earlier answers carried over | `t6-ledgerly-supersede` |
| T7 | Answers filled in on the spec's answer lines: the spec is revised, not rewritten | `t7-ledgerly-answers` |
| T8 | Step-1 gates: no argument (T8a, also the harness preflight), and two outcomes while the user is away (T8b) | `t8a-ledgerly-gates`, `t8b-ledgerly-multi` |
| T9 | A large real repo (documenso v2.9.1): finding policies outside the expected paths, and ignoring agent and code-style guidance | `t9-documenso` (built) |

`onboarding` is not used by T1–T9. It is the fixture of the skill-level eval `stops-on-uncheckable-outcome`, kept here for ad-hoc runs.

## Set up and run one case

You need `claude`, `git`, `python3` and `timeout`. The prompts for each case are in cases.md.

```bash
cd evals/write-spec
export WRITE_SPEC_RUNS=/tmp/write-spec-runs     # optional; this is the default
bin/setup_run.sh fixtures/shelfdesk t4-with     # add "without" as a 3rd argument for a baseline without the skill
MODEL=sonnet bin/run_claude.sh t4-with t1 "/write-spec docs/intents/0005-due-date-on-receipt.md I'm Dana Okafor, product owner for the desk app."
MODEL=sonnet bin/run_claude.sh t4-with t2 "Sure, ask me my questions." CONTINUE   # or the session_id in t1.meta.json
```

- `setup_run.sh` copies the fixture to `<runs>/<run_id>/repo` and installs the current skill's `SKILL.md` and `references/` into `.claude/skills/write-spec/`. It never installs `evals/`. It then commits everything as `base`.
- Each turn writes `<out>.jsonl` (the transcript), `<out>.err` and `<out>.meta.json` (session id, model, seconds, cost, top-level subagent calls, final message) next to `repo/`.
- For T9, build the fixture first: `bin/setup_run.sh "$(fixtures/t9-documenso/build.sh)" t9`. This clones about 110 MB.
- Put `ko` in Korean run ids, because the T2/T3 grading task uses it to choose assertions.
- Keep `WRITE_SPEC_RUNS` outside this repo. Claude Code reads CLAUDE.md files in a run repo's parent directories, and a run that can reach plan.md or cases.md can read the assertions.
- `SKILL_SRC=<folder>` installs a variant of the skill instead of the committed one, for A/B experiments.

## Grade a run

1. **Script checks** cover the `[S]` assertions. Each case's Grading line in plan.md says which checks apply.
   ```bash
   python3 -I score.py ids    <spec.md>            # IDs defined once, Reviewers table = open questions, Status counts
   python3 -I score.py 3parts <spec.md>            # each open question has its fields
   python3 -I score.py leak   <spec.md>            # no code names or skill words outside Facts and sources
   python3 -I score.py paths  <spec.md> <repo>     # cited paths exist at the base commit
   python3 -I score.py draft  <run>/t1.jsonl docs/specs/<name>.md   # saves the pre-reader draft
   python3 -I score.py readers <run>/t1.jsonl      # reader rounds and the paths in reader prompts
   ```
2. **LLM grader** for the `[L]` assertions. Give a fresh agent `graders/grader-brief.md` plus a case task: `graders/task-t2-t3.md` for T2/T3, or a one-paragraph task for other cases (the brief has examples). The grader writes `<grade_id>.json`.
3. **Litmus audit** (T3.7, T4.8, T9.6) tests whether the spec leaves decisions to the builder. Copy the final spec to an empty folder. Run `graders/litmus-reader.md` in a fresh agent that sees only that copy. Then add `graders/litmus-judge.md` to the run's grader task.
4. **T5**: one role-player agent per stakeholder follows `graders/t5-roleplay-procedure.md`, and a judge grades their outputs as plan.md T5 describes.

The bar for "ready" is in plan.md §4.

## Costs seen so far

Executor: Sonnet. The figures cover one `claude -p` turn and leave out graders.

| Run | Cost | Time |
|---|---|---|
| English first draft (T2/T3, ledgerly) | $1.1–1.6 | 5–8 min |
| Korean first draft (T2/T3, acme-subscriptions) | about $3 | 16 min |
| Korean revision (T1) | $2.3 | 10 min |
| Simple intent (T4, turn 1) | $0.5 | 2 min |
