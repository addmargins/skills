# Held-out grading task (HO)

The case task for one first-draft run on a held-out fixture (`ho-*`). These fixtures were built by agents that never saw the skill, and each has an answer key in `keys/`. Don't tune the skill against the keys; a fixture whose key has shaped the skill stops being held out. Append this task to [grader-brief.md](grader-brief.md), then add `Your grade_id is "<RUN_ID>".`

Fill in:
- `<RUN_ID>`: the run id.
- `<FIXTURE>`: the fixture name, such as `ho-clinic-booking`.
- `<REPO>`: absolute path of this skills repo.
- `<LITMUS_FILE>`: the list the litmus reader wrote for this run (see [litmus-reader.md](litmus-reader.md)). Run the reader first.

```text
One run: <RUN_ID>, a first draft on the held-out fixture <FIXTURE>. Its answer key is <REPO>/evals/write-spec/keys/<FIXTURE>.md. The key was written by the fixture's builder and can be wrong: when the fixture's own files settle a point the key calls a gap, or the reverse, follow the files and say so.
Grade these assertions with ids H1–H8:
- H1 [S]: score.py ids, 3parts, leak and paths pass on the final spec.
- H2 [L]: Each planted gap in the key is RAISED (an open question addressed to a fitting owner, or a fact marked not confirmed with a confirmer when the gap rests on a fact), SETTLED (a fixture source settles it and the spec states it with that source), DECIDED (the spec states a behavior no source settles, outside Open questions, even if marked provisional), or MISSED. List each gap with its label and evidence. Pass when no gap is DECIDED and RAISED + SETTLED cover at least 75% of the key's gaps.
- H3 [L]: The key's conflict is an open question addressed to the owners on both sides, shows the arithmetic or timing that proves it, and is routed by the product owner (or says who routes it when none is named). No rule or step treats one side as winning.
- H4 [L]: The key's two-reading clause is not settled: no rule, step or case result applies one reading, unless the row gives the result under each reading. The policy owner is asked.
- H5 [L]: None of the key's decoys is an open question. A decoy stated as a rule with its source is right.
- H6 [L]: Each fact the key says lives only in a code comment is marked as claimed or not yet confirmed, with a confirmer, wherever the spec relies on it.
- H7 [L]: Every person named appears in a fixture source with that role; owners no source names are marked as not named, and no question is addressed to an invented person.
- H8 [L]: Litmus audit: a fresh reader who saw only the spec listed the points they would have to decide, in <LITMUS_FILE>. Judge each item against the fixture and the key as GENUINE, SETTLED or ENGINEERING. Report the counts and each GENUINE item's domain (money, personal data, legal, or other). Pass when no GENUINE item touches money, personal data or a legal obligation, and at most 1 other GENUINE item.
Also record these metrics: seconds, cost, reader rounds and calls per round (score.py readers), open and blocking counts, gaps RAISED/SETTLED/DECIDED/MISSED, spec lines and bytes.
```
