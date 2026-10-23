# T2/T3 grading task

The case task for one T2/T3 run (a first draft with real fresh readers). Append it to [grader-brief.md](grader-brief.md), then add `Your grade_id is "<RUN_ID>".`

Fill in:
- `<RUN_ID>`: the run id. Put `ko` in Korean run ids; the task uses that to pick the assertions.
- `<REPO>`: absolute path of this skills repo.
- `<LITMUS_FILE>`: the list the litmus reader wrote for this run (see [litmus-reader.md](litmus-reader.md)). Run the reader first.

The litmus bullet is [litmus-judge.md](litmus-judge.md) with the T3.7 bar.

```text
One run: <RUN_ID>. It belongs to T2 (real fresh readers) and T3 (variance and classification).
- Korean runs (ids containing "ko") use the fixture acme-subscriptions and the 12 assertions in <REPO>/skills/engineering/write-spec/evals/flags-policy-conflicts-korean/graders/*.md.
- English runs use ledgerly and the 11 assertions in <REPO>/skills/engineering/write-spec/evals/finds-hidden-gaps-english/graders/*.md.
- Grade those assertions with ids prefixed "E".
- Then grade plan T2 assertions 1–6 and T3 assertions 2, 3, 5 and 6:
  - For T2.3, count rounds with "score.py readers".
  - For T2.5, check whether the report lists the last round's unapplied findings.
  - For T3.2, classify every question by references/open-questions.md's class definitions and report the share.
  - For T3.6, recompute the Korean refund amounts in Python.
- Litmus audit: a fresh reader who saw only the spec listed the points they would have to decide, in <LITMUS_FILE>. Judge each item against the repo as GENUINE, SETTLED or ENGINEERING. Report the counts and each GENUINE item's domain (money, personal data, legal, or other). Grade T3.7: no GENUINE item touches money, personal data or a legal obligation, and at most 1 other GENUINE item.
- Also record these metrics: seconds, cost, reader rounds, reader calls per round, open and blocking counts, blocking share, spec lines and bytes.
```
