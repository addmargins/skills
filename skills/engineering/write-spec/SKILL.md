---
name: write-spec
description: Draft a specification (what must be built, and which design and policy constraints it must follow) from an accepted intent document, without interviewing anyone, for stakeholders who are not engineers to read. Every undecided behavior becomes an open question for the role that decides it, marked as one to decide before building or one that can wait for planning.
argument-hint: <intent file>
disable-model-invocation: true
---

# Write Spec

Turn an accepted intent into spec.md: what to build and the design and policy constraints it must follow, written for stakeholders, most not engineers.

The test for a finished spec: someone working only from spec.md never has to decide a product behavior or constraint that nobody has decided. Each such gap is an open question for the role that decides it.

This skill often runs as a job when an intent is accepted, with nobody to ask, and even an invoker is rarely the decider. So a draft asks nobody and settles only what the sources settle; the rest become open questions. The skill's work ends with the saved spec.

## Principles

- **Decisions are people's, not yours.** Every value, default, limit, and exclusion comes from the intent, a source in the workspace, or the role that decides it. Mark each one not taken from the intent: `(decided by <role>, <where>)` for a decision a source records for this work, such as a spec this one supersedes; `(current behavior, S<n> (Name))` for existing behavior you verified; `(required by C<n> (Short name))` for behavior a constraint's own words require. A marker covers the sentence it ends. A sentence that names the item it follows from, as in "the same limit as R2 (Weekly limit)", needs no marker. A policy owner decides nothing by having written the policy. A boundary you draw inside someone's recorded decision, such as which changes count, is a new question. A value you would propose is one of a question's likely answers, never a requirement or a recommendation.
- **Facts are yours to find.** Read the workspace for how things work today and the rules that apply: ADRs, policies, a `GLOSSARY.md`, the code. Separate what a document claims from what you verified. Cite current behavior only for what you saw the code or system do, down to the functions it calls, in the case the sentence is about. Prose names code in plain words, cited as S<n> (Name); code names go only under Sources. Ask a question of fact only when you could not check it, and say why. A fact you give a decider is computed from the workspace or says what it depends on; never write "most" unless you counted.
- **What, not how.** The spec states what an actor or another system observes, and the rules the work must follow. Modules, files, types, and algorithms belong to the plan. Fix an interface or data format only when someone outside this build depends on it or a stakeholder would notice a change: one sentence on what it is for, then a sample or a link to the schema that owns it. Write a lifecycle as a table of state, event, next state, and who sees what.
- **Plain words, one term per concept.** Use the glossary's terms, else the intent's. Define a new term in one clause where it first appears. A term whose meaning stakeholders disagree on is an open question.
- **Compact.** Say each thing once, in the section the template gives it. Omit an empty section, except Changes to existing behavior and Open questions, which say "None.". Add no sections the template lacks.

## Steps

### 1. Read the intent and the workspace

Take the intent file from the arguments or the message. If none is named, list `docs/intents/` and stop rather than guess. If the intent is marked `Superseded by:`, use the one it names. If it has no settled problem or desired outcome, or its outcome can't be checked, stop and suggest `clarify-intent`: open questions in a spec can't repair an intent.

Read the specs in `docs/specs/`. If one is already built on this intent, stop and say which: people edit that spec themselves, and a changed intent gets a new spec. If one is built on an intent this one supersedes, this spec supersedes it (step 7). Then read the parts of the workspace the intent touches.

### 2. Find the gaps

Draft the requirements in your head. For each, list what a builder would otherwise decide alone that changes what a user, a stakeholder, or another system observes. These are prompts for noticing cases, not a checklist:

- scope boundaries a reader might expect covered;
- values, defaults, limits, and thresholds, and the behavior on both sides of each limit;
- each vague word in an outcome, such as "soon": the value it stands for. Current behavior covering part of it is a fact to give with the question, not the answer;
- no permission, nothing there yet;
- in the main flow, which inputs count as each action, which item an input means when more than one fits, and what each actor sees or receives after it, including nothing;
- the same person acting again or reversing their action, such as accepting after declining, and a record corrected after someone was told: what each actor sees;
- a message that promises a person will act, such as "a manager will review it": who, what they see, and by when;
- what each actor sees when something the work relies on fails, and for things under way at go-live, such as an invoice issued before and paid after;
- existing users, records, and integrations: what each sees change, including records made the old way;
- which policy or design rules this work could break, through its behavior, current behavior it keeps, or a choice the plan might make. Check what the code does against each rule's words;
- where two rules cannot both hold.

Two people acting at once, rollback, switching off, and moving data over are the plan's, unless a likely answer changes what someone sees; then ask about that result, not the mechanism: what a buyer sees when stock runs out after they were told an item was held, not how a row is locked.

### 3. Settle what the sources settle; ask the rest

Before writing a question, re-read the words of each rule it touches. If they settle the case, write a requirement marked `(required by C<n> (Short name))`. Don't ask about what the intent or workspace settles, how to build it, or a combination of cases each already settled.

Address each remaining gap to the role responsible for it: a policy's reading, exception, or waiver to the office or role the policy names as owner; a design limit, or a fact only an engineer can check, to the technical lead for that system; what counts as solving the problem, including a vague word in the outcome and the intent's own questions, to the originator; a case within another function's work, such as the front desk's, to the role running it; other product behavior to whoever decides the product's behavior. Name roles by responsibility, as in "privacy officer, or whoever approves new personal data collection", never people, even those a source names, and never "not named": a decider no source names is expected. One role decides each question, except that the owners of conflicting rules decide together; name another only to confirm an answer that could narrow the outcome (the originator) or make a constraint give way (its owner).

Each question asks one thing: split one whose parts could get different answers, except that what one role decides about one item, in one tier, is one question in numbered parts. For a choice, give two to four lettered likely answers with the trade-offs that matter, none marked as recommended.

Put each question in a tier, so readers know which to decide first. **Decide before building**: a conflict; a policy's reading, exception, or waiver; any whose answer changes what gets built: a flow's steps, who qualifies or is told, an amount of money, what data is kept or shown, or a whole requirement. **Can wait for planning**: one whose likely answers differ only in a value, a wording, a label, or a format, such as a message's text, or in one case the plan can leave as a slot. When unsure, choose the first: an early decision costs a day; a guess built in costs a release.

Name each question where its answer goes, as in "the full-refund deadline is set by Q1" or "an order over the limit waits for Q4". The case a question leaves open stays off, and actors see today's behavior, until it is decided; the Open questions note says this once. Add an "Until decided" line only to the rare question under "Can wait for planning" where more must wait, such as a message's line inviting a reply nobody reads. Any other meanwhile is a decision: offer it only as a likely answer. A question whose every likely answer builds the same thing is no gap.

When a requirement and a rule, or two rules, cannot both hold, record the case under Conflicts. It is agreed only when a source records, with a date or place, the agreement of the role owning each rule that gives way. Otherwise the conflict line says `Unresolved: see Q<n>`, a question to decide before building for those owners, because building either reading decides it for them.

In each tier, put conflicts and policy readings first, then the main flow. Keep the count down by checking facts and combining questions as above; never by leaving a gap out or capping the count, because a gap nobody asks about is decided by whoever builds it.

### 4. Write the spec

Use the headings of [references/spec-template.md](references/spec-template.md) in order; its placeholders say what each slot holds. Write in the intent's language, but keep headings, ids, field names, markers, and `None.` in English. In a spec not in English, translate the Open questions note and the five question labels faithfully, each label still followed by a colon, and use the same labels in the note and on every question.

- **Requirements**: one behavior someone outside can check per requirement; what only the inside can check is plan material or a constraint. Quote a message's exact wording only when someone decided it or depends on it, such as consent text, a promise about money or deadlines, or text another system parses; otherwise give its meaning. Each "then" names a value, a state, a message's meaning, or what the observer can do next.
- **Changes to existing behavior**: one row per behavior in use that changes; when the new behavior needs scenarios, write a requirement and point the row at it.
- **Constraints**: only rules this work could break. When a reader would need a reason the source doesn't give, ask the constraint's owner.
- **Open questions**: start with the template's note, word for word or translated as above; it tells planners and builders what waits. Keep each line to a sentence or two.
  - Under "Depends on the answer", a question about a constraint also names the requirements it changes; a conflict names both items.
  - A question of fact gives, for each likely result, what is built as a decided value with its marker; if that is not decided, it also needs a decision.
  - An "Until decided" line never holds back a whole requirement. Don't write a requirement only to hold a waiting case.

Ids are stable within a spec and across a spec that supersedes it: never renumber, and a removed item leaves a gap. Cite an item by id and current name, as in `R2 (Weekly limit)`.

### 5. Check the form

Run `sh <this skill's directory>/scripts/check-spec.sh <spec file>`. Fix what it prints until it prints nothing. If a line is wrong about the spec, don't change correct text to silence it; say so in your final message. If you can't run it, do the checks listed at its top by hand.

### 6. Check with a fresh reader

You can't run the spec's test yourself, because you fill gaps from what you read without noticing. Once per draft, give spec.md and the intent, and nothing else, to one fresh subagent, on a different model when one is available, with this request:

> You will build from this spec and can't ask anyone. List at most 10 findings, most important first, each with its R, C, or Q id: a choice you would make yourself that a user, a stakeholder, or another system would notice, with literal values and what each would see; a quoted sentence deciding something the intent does not, with no marker or named item behind it; or two quoted sentences that cannot both hold. An open question leaves off only the case it names. Leave out how to build it and failures nobody outside sees.

Sort each finding:

- **Settled but not written**: you can name the workspace file and line that settles it. Write it in with its marker. Your reading of a source is not a citation.
- **Not a gap**: it follows from a requirement or constraint you can cite, whose words cover that very case, not a boundary you drew; or it can't happen given current behavior the spec states; or only the builders would notice. Drop it. A flagged sentence that only restates another item names that item or goes. Never delete a likely answer or a waiting case to answer a reader.
- **A gap, a sentence that decides too much, or two that cannot both hold**: cut each sentence back to what its source settles, and ask the rest as step 3 says, in the tier it gives; two rules that cannot both hold are a conflict. Never fill a gap yourself, and never add a marker whose source does not settle the sentence just to answer a finding. When a finding says an open question stops more than its case, name that case where it waits; never hold back a whole requirement.

Don't ask a second reader. Run step 5 again, then re-read each line you changed against the test at the top: it decides nothing nobody decided and contradicts nothing decided or already told to an actor.

### 7. Save

Save in the workspace's `docs/specs/`, the one closest to the intent if there are several, or a new one next to its `docs/intents/`; a superseding spec goes in the earlier spec's directory. Name it `NNNN-<slug>.md`: the next unused four-digit number there, from `0001`, and a short kebab-case English slug. A superseding spec fills in `Supersedes`. Change no other file, the earlier spec included. If you can't write the file, give the spec in your reply.

End with a short message: the spec's path and Status line, then each role that has questions, with their ids and short names in the spec's order. Do not write the plan.
