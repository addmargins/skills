---
name: write-spec
description: Turn an accepted intent document into a specification (what must be built, and which design and policy constraints it must follow) that stakeholders who are not engineers can review, with every undecided behavior left as an open question for the person who decides it.
argument-hint: <intent file>
disable-model-invocation: true
---

# Write Spec

Turn an accepted intent document into a spec: what must be built, and which design and policy constraints it must follow. The intent's originator, the policy owners, the engineers, and the technical lead review it, so write it for readers who are not engineers.

The test for a finished spec: someone working only from spec.md never has to decide, on their own, a product behavior or constraint that nobody has decided. Each such gap is either settled by the person who can decide it or left as an open question for them.

## Principles

- **Decisions are people's, not yours.** Every value, default, limit, and exclusion in the spec comes from the intent, from a source in the workspace, or from a named person. Mark each one not taken from the intent with `(decided by <name or role>, <where>)`, or `(current behavior, <source>)` for existing behavior you verified. A value you would propose goes under an open question as one of the likely answers, never into a requirement and never as a recommended answer.
- **Facts are yours to find.** Before asking anyone, read the workspace for how things work today and for the rules that apply: ADRs, policy documents, a `GLOSSARY.md`, the code. Separate what a document claims from what you verified. A question of fact goes under Open questions only when you could not check it, and says why.
- **What, not how.** The spec states what an actor or another system observes, and the rules the work must follow. Module structure, files, types, and algorithms belong to the plan. Fix an interface or data format only when someone outside this build depends on it, or a stakeholder would notice if it changed: give one plain sentence saying what it is for, then a sample, or a link to the schema that owns it. Write a lifecycle as a table of state, event, next state, and who sees what.
- **Plain words, one term per concept.** Use the glossary's terms, or the intent's terms when there is no glossary. Define a new term in one clause where it first appears. A term whose meaning stakeholders disagree on is an open question.
- **Compact.** Say each thing once, in the section the template gives it. Omit any section that would be empty, except Changes to existing behavior and Open questions, which say "None." instead. Don't add sections for status, approvals, revision history, background, risks, assumptions, testing decisions, or further notes. The problem lives in the intent; the Summary carries one clause of it.

## Workflow

### 1. Read the intent and the workspace

Take the intent file from the invocation arguments or the user's message. If there is none, list `docs/intents/` and ask which one, in one sentence. If the intent is marked `Superseded by:`, use the one it names. If the intent has no settled problem or desired outcome, stop and suggest running `clarify-intent` first.

List each `docs/specs/` in the workspace and read any spec built on the same intent. If one exists, ask whether this is a revision of it.

When a revision answers an open question that needed a decision, write the answer into each item named under the question's "Depends on the answer", with its `(decided by <name or role>, <where>)` marker. Update the From the intent and Policy conflicts lines that pointed at the question, then remove the question. Its id is not reused. Don't keep an answered question in the spec, or an `Answered:` line under it: its "Until decided" line would still hold the work back, and the answer would live in two places.

Read the parts of the workspace the intent touches: current behavior, the ADRs and policies that apply, and the glossary.

### 2. Find the gaps

Draft the requirements in your head from the intent. For each, list what a builder would otherwise decide alone:

- scope boundaries a reader might expect to be covered;
- values, defaults, limits, and thresholds, and the behavior on both sides of each limit;
- cases to consider: no permission, nothing there yet, at the limit and over it, something it relies on being unavailable, and data from before the change. These are prompts for noticing cases, not slots to fill;
- two people or systems acting on the same thing at once: always say what each sees, because no default answer exists;
- what happens to existing users, data, and integrations, and whether the change can be undone;
- which policy or design rules this work could break, through its behavior or through a choice the plan might make;
- where two rules cannot both hold.

### 3. Settle what the user can decide

Ask the user about the gaps in short rounds of two or three numbered questions, each asking one thing. For a choice, give two to four lettered options with the trade-offs that matter. Record each answer as decided by the user, with the conversation and date as the place.

When the user is not the person who decides something, such as a policy owner, ask who is, and leave it as an open question naming them. When the user doesn't know, leave it open instead of rephrasing until they guess. Don't ask about what the intent or the workspace already settles, or about how to build it.

When a requirement collides with a policy or design rule, show the user the case where both cannot hold. Record it under Policy conflicts as agreed only when the policy owner's agreement is recorded with their name and a date or place. A verbal agreement counts when it names both. Otherwise it is an open question for the policy owner, and the conflict line says `Unresolved: see Q<n>`.

### 4. Write the spec

Use the headings of [references/spec-template.md](references/spec-template.md) in that order. The placeholders say what each slot holds. The rules:

- **Summary**: two or three sentences: one clause of the intent's problem, who this is for, and what they will see. Each claim about what is built must be backed by a requirement.
- **Requirements**: one behavior someone outside can check per requirement; anything checkable only from inside is plan material or a constraint. The actor goes in the heading. `So that:` quotes the intent outcome or scope item it serves. In scenarios, values and states are always literal. Quote a message's exact wording only when someone decided it or depends on it, such as legal or consent text, a promise about money or deadlines, text a policy owner approves, or text another system parses; otherwise give its meaning. Each "then" names a value, a state, a message's meaning, or what the observer can do next. Add a case only when its result does not follow from the rule above it.
- **Changes to existing behavior**: always present. One row per behavior in use that changes, or "None." when nothing in use changes. When the new behavior needs scenarios, write it as a requirement and point the row at it. When whether it can be undone depends on how the plan does it, record what the stakeholder requires, as a decided value.
- **Constraints**: list a rule only if this work could break it. Cite ADRs and policies in `Source:` instead of restating them. Give the reason as the source states it, or "not stated"; never supply one. When a reader would need a reason the source doesn't give, ask the constraint's owner in an open question.
- **Out of scope**: what a reader might expect this to cover but it does not.
- **From the intent**: one line per intent outcome, quoted, with the requirements that deliver it, and one line per intent open question, quoted, with where it went. Only the intent's originator can retire a question as no longer applying; record who agreed and where.
- **Open questions**: always present. Copy the template's note word for word as the section's first paragraph, because it is the only place where the people who plan and build from the spec, who may not have this skill, learn what waits and what may go ahead. Write "None." under it when there are no questions. For each question:
  - Under "Depends on the answer", name by id each requirement and constraint that would differ for any likely answer, and say how. A named item waits as a whole. If only part of it depends on the answer and the rest should go ahead, that is an interim decision for the decider. A question about a constraint also names each requirement whose behavior would differ, and an unresolved policy conflict names both items.
  - Under "To resolve", say whether it needs a decision or a fact, and who decides. A question of fact gives, under "Depends on the answer", what is built for each likely result as a decided value with its marker; if that is not decided for some result, the question also needs a decision.
  - Write "Until decided" on every question. It says `do not build R<n> (Short name)`, unless the decider named in "To resolve" has accepted what to build meanwhile; then it says what that is and records who accepted it and where. Do not plan or build anything named under an open question's "Depends on the answer" until it is answered, unless its "Until decided" line records what the decider accepted to build meanwhile. An item the line doesn't cover still waits.

Ids are stable. Never renumber: a removed item leaves a gap. Cite an item by id and current name, as in `R2 (Weekly limit)`.

### 5. Check the form

Run `sh <this skill's directory>/scripts/check-spec.sh <spec file>`. It needs a POSIX shell and awk. It finds the intent from the `Intent:` line and an earlier spec from the `Supersedes:` line. Fix every line it prints and run it again until it prints nothing. If you can't run it, check the same things by hand: every heading, field, and reference it would check, and every vague word, such as "appropriately", "as needed", or "etc.", replaced by the value, state, or next action it stands for.

### 6. Check with a fresh reader

You can't run the spec's test yourself, because you fill gaps from this conversation without noticing. Give spec.md and the intent, and nothing else, to a fresh subagent, on a different model when one is available, with this request:

> You will build from this spec and can't ask anyone. List at most 12 items, most important first, in three groups:
> 1. Unmarked behavior: each sentence in a requirement or a Changes row that states a value or behavior the intent does not state and that has no "(decided by …)" or "(current behavior, …)" marker. Give the id and quote the sentence.
> 2. Choices someone outside would notice: each behavior you would have to choose on your own where a user, a stakeholder, or another system would see a different result depending on your choice. Give the R or C id, the situation with literal values, and the two results they would see. Leave out how to build it: data formats, encodings, retries, duplicate deliveries, message length, ordering or timing below what a person would notice, and failures nobody outside sees.
> 3. Each Summary claim that no requirement backs, and each "Until decided" line that holds back something the spec decides elsewhere, or lets something go ahead that the answer would change.

Sort each item into one of three cases:

- **Settled but not written**: you can cite the conversation turn or the workspace file that settled it. Write it in with its marker. If you can't cite one, it is not settled.
- **Not a gap**: the result follows from a requirement or constraint as written, and you can cite it; or the situation can't happen given current behavior the spec states; or only the people building it would notice. Drop it.
- **A gap**: settle it with the user in one round as in step 3, or add an open question naming who decides. Never fill one in yourself.

Then run step 5 and this step once more, giving a new reader only the changed spec and the intent. Stop after that second reader, even if it lists new items. Sort each item it lists as above, and put any gap you can't settle under Open questions. Don't add requirements just to answer the reader.

### 7. Save the spec

- Use the workspace's `docs/specs/`. If there are several, use the one closest to the intent's `docs/intents/`. If there is none, create `docs/specs/` next to that `docs/intents/`. Save a revision in the earlier spec's directory.
- Name the file `NNNN-<slug>.md`. `NNNN` is one more than the highest number prefix in the directory, zero-padded to four digits, starting at `0001`. `<slug>` is a short kebab-case English name for what the title names.
- Don't modify or overwrite specs or intents written before this conversation, with one exception. When the new spec revises an earlier one, fill in the template's `Supersedes` line, and in the earlier file add a `Superseded by: <new file name>` line as its own paragraph right after the title. A revision keeps the ids it inherits.
- If you can't write the file, say so and give the spec in chat.

After saving, tell the user the file path, and list the open questions grouped by who decides each, so the user can send them on. Do not write the plan.
