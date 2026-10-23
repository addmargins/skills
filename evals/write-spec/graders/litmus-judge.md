# Litmus judge (G-L, step 2)

The second half of the litmus audit. Add it as a bullet to the run's grader task (after [grader-brief.md](grader-brief.md)), so the grader, who can see the whole fixture, judges each item from [litmus-reader.md](litmus-reader.md).

The three labels, as plan.md defines G-L:
- GENUINE: a real gap. The spec neither states it nor raises it as an open question, and someone outside engineering would have to decide it.
- SETTLED: the spec already states it or raises it; the reader missed it.
- ENGINEERING: a choice nobody outside engineering would notice.

Fill in:
- `<LITMUS_FILE>`: the reader's list for this run.
- `<BAR>`: the pass bar for the case:
  - T3.7: `Grade T3.7: no GENUINE item touches money, personal data or a legal obligation, and at most 1 other GENUINE item.`
  - T4.8: `Grade T4.8: no GENUINE item.`
  - T9.6: `Grade T9.6: at most 1 GENUINE item, and none about personal data or the audit trail.` For T9, also point the grader to cases.md's grader note #6, which lists three real facts that make a question about them not padding.

```text
Litmus audit: a fresh reader who saw only the spec listed the points they would have to decide, in <LITMUS_FILE>. Judge each item against the repo as GENUINE, SETTLED or ENGINEERING. Report the counts and each GENUINE item's domain (money, personal data, legal, or other). <BAR>
```

If no separate reader ran, the grader can do both halves, first as the fresh reader and then as judge (round 9's T4 grade did this), but a separate reader who has seen nothing else is the stronger test.
