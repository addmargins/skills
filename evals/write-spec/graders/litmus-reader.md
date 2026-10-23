# Litmus reader (G-L, step 1)

The first half of the litmus audit (T3.7, T4.8, T9.6): a fresh reader who has only the spec lists what they would have to decide on their own. [litmus-judge.md](litmus-judge.md) is the second half.

How to run it:
1. Copy the run's final spec into an empty directory outside the run repo and outside this harness, so the reader has nothing nearby to open. Round 9 used a folder of its own beside the grade files, holding `<run_id>-spec.md`.
2. Give the prompt below to a fresh agent with no other context.

Fill in:
- `<SPEC_COPY>`: absolute path of that copy.
- `<LITMUS_FILE>`: where the list goes, for example `<run_id>-litmus.md` beside the copy.

```text
You will build what a specification describes. You have only one file: <SPEC_COPY>. Read only that file; open no other file. You can't ask anyone.
List every point where, to build it, you would have to decide on your own something the spec neither states nor raises as an open question:
- how the product behaves in some situation,
- what a person sees or is told,
- a number, limit, date, or condition,
- or how to apply a policy.
For each, quote the sentence or name the step, rule, or case it comes from, and say what you would have to decide. Leave out choices nobody outside engineering would notice, such as code structure or storage. Leave out points already raised as open questions, unless the question lacks something you'd need.
Write the list to <LITMUS_FILE> as numbered items, or "none". Reply with only the number of items.
```
