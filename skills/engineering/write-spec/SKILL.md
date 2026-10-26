---
name: write-spec
description: Draft a specification (what must be built, and which design and policy constraints it must follow) from an accepted intent document, without interviewing anyone, for stakeholders who are not engineers to read. Every undecided behavior becomes an open question for the role that decides it, marked as one to decide before building or one that can wait for planning.
argument-hint: <intent file>
disable-model-invocation: true
---

# Write Spec

Turn an accepted intent into spec.md: what to build and the design and policy constraints it must follow, written for stakeholders, most not engineers.

The test for a finished spec: someone working only from spec.md never has to decide a product behavior or constraint that nobody has decided. Each such gap is an open question for the role that decides it.

This skill often runs as a job when an intent is accepted, with nobody to ask, and even an invoker is rarely the decider. So a draft asks nobody and settles only what the sources settle; the rest become open questions. The skill ends with the saved spec.

## Principles

- **Decisions are people's, not yours.** Every value, default, limit, and exclusion comes from the intent, a source in the workspace, or the role that decides it. Mark each one not taken from the intent: `(decided by <role>, <where>)` for a decision a source records for this work, such as a spec this one supersedes; `(current behavior, S<n> (Name))` for existing behavior you verified; `(required by C<n> (Short name))` for behavior a constraint's own words require. A marker covers the sentence it ends. A sentence that names the item it follows from, as in "the same limit as R2 (Weekly limit)", needs no marker. A policy owner decides nothing by having written the policy. A boundary you draw inside someone's recorded decision, such as which changes count, is a new question. A value you would propose is one of a question's likely answers, never a requirement or a recommendation. Who may see, export, change, or receive data, and any new permission or access, is never yours to grant: unless a source states it, ask the owner of the security or privacy rule.
- **Facts are yours to find.** Read the workspace for how things work today and the rules that apply: ADRs, policies, a `GLOSSARY.md`, the code. Separate what a document claims from what you verified. Cite current behavior only for what you saw the code or system do, down to the functions it calls, in the case the sentence is about. Prose names code in plain words, cited as S<n> (Name); code names go only under Sources. Ask a question of fact only when you could not check it, and say why. A fact you give a decider is computed from the workspace or says what it depends on; never write "most" unless you counted.
- **What, not how.** The spec states what an actor or another system observes, and the rules the work must follow. Modules, files, types, and algorithms belong to the plan. Fix an interface or data format only when someone outside this build depends on it or a stakeholder would notice a change: one sentence on what it is for, then a sample or a link to the schema that owns it. Write a lifecycle as a table of state, event, next state, and who sees what.
- **Plain words, one term per concept.** Use the glossary's terms, else the intent's. Define a new term in one clause where it first appears. Outside Sources, replace engineering words such as API or null with what they mean. A term whose meaning stakeholders disagree on is an open question.
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
- which policy or design rules this work could break, through its behavior, current behavior it keeps, or a choice the plan might make;
- where two rules cannot both hold.

Two people acting at once, rollback, switching off, and moving data over are the plan's, unless a likely answer changes what someone sees; then ask about that result, not the mechanism: what a buyer sees when stock runs out after they were told an item was held, not how a row is locked.

### 3. Settle what the sources settle; ask the rest

Before writing any question, take every numbered clause of each policy this work touches, in order, and record each in that policy's Sources line (see the template) as one of:

- **Settles**: what it requires here, as a constraint or a requirement marked `(required by C<n> (Short name))`, even when today's code or data does not follow it. Never a question: don't ask how to build it, or about cases it settles.
- **Two readings**: two readings that build different things, each with an example and its result, as in "10% off orders over 50 items": off the whole order, 60 items at $2 cost $108; off the items over 50, $118. It is a question to the clause's owner. Today's code is a fact about today, never the answer: test each clause it applies, and each percentage, deadline, and undefined word, for a second reading.
- **Conflict**: with another clause or with the intent, in a case with actual values where both cannot hold; record it under Conflicts (below). A clause that only limits how or where something is done, such as where data may be kept, settles; it is no conflict.
- **n/a**: nothing this work newly does or changes falls under it: `n/a: this work does not <what the clause governs>`, as in "n/a: this work issues no refunds". A clause setting an amount, a limit, or who qualifies applies whenever this work pays, approves automatically, shows, sends, stores, deletes or shares what it governs, even if its calculation stays: a fee-rounding rule applies to a new one-click checkout charging that fee, so test it for two readings.

Re-read the intent the same way. Then address each remaining gap to the role responsible for it: a policy's reading, exception, or waiver to the office or role the policy names as owner; a design limit, or a fact only an engineer can check, to the technical lead for that system; what counts as solving the problem, including a vague word in the outcome and the intent's own questions, to the originator; a case within another function's work, such as the front desk's, to the role running it; other product behavior to whoever decides the product's behavior. Name roles by responsibility, as in "privacy officer, or whoever approves new personal data collection", never people, even those a source names, and never "not named": a decider no source names is expected. One role decides each question, except that the owners of conflicting rules decide together; name another only to confirm an answer that could narrow the outcome (the originator) or make a constraint give way (its owner).

Each question asks for one decision, except that what one role decides about one item (a screen, a message, a record, a case), in one tier, and would likely answer at one sitting, is one question in numbered parts, each with its own answers: "Receipt after a refund: 1. who gets it (a. the payer; b. the account holder); 2. whether it gives the reason (a. yes; b. no)". Never join different items, roles, or tiers. For a choice, give two to four lettered likely answers with the trade-offs that matter, none marked as recommended.

Tier each question. **Can wait for planning** holds only a slot the plan leaves blank and fills before release: a value, a wording, a label, or a format, such as a button's label or how many results a page lists. Everything else is **Decide before building**: every conflict and policy reading, and any question that leaves open a situation, a case, a flow step, who qualifies or is told, an amount of money, what data is kept or shown, or a behavior, such as whether a cancelled order's discount code can be used again. When unsure, choose the first.

A requirement states only what is decided. It never says that a case or a requirement waits, stays off, or is held: questions under "Decide before building" are answered before building starts. A requirement names a question only where its answer fills a slot, as in "the refund amount is set by Q3". A question whose every likely answer builds the same thing is no gap.

When a requirement and a rule, or two rules, cannot both hold, record the case under Conflicts. It is agreed only when a source records, with a date or place, the agreement of the role owning each rule that gives way. Otherwise the line says `Unresolved: see Q<n>`, a question for those owners, because building either reading decides it for them.

In each tier, put conflicts and policy readings first, then the main flow. Keep the count down by checking facts and combining questions as above; never by leaving a gap out or capping the count, because a gap nobody asks about is decided by whoever builds it.

### 4. Write the spec

Use the headings of [references/spec-template.md](references/spec-template.md) in order; its placeholders say what each slot holds. Write in the intent's language, but keep headings, ids, field names, markers, and `None.` in English. In a spec not in English, translate the Open questions note, the four question labels, and the Sources summary faithfully, each label still followed by a colon, and use the same labels in the note and on every question.

- **Requirements**: one behavior someone outside can check per requirement; what only the inside can check is plan material or a constraint. Quote a message's exact wording only when someone decided it or depends on it, such as consent text, a promise about money or deadlines, or text another system parses; otherwise give its meaning. Each "then" names a value, a state, a message's meaning, or what the observer can do next.
- **Changes to existing behavior**: one row per behavior in use that changes; when the new behavior needs scenarios, write a requirement and point the row at it.
- **Constraints**: only rules this work could break. When a reader would need a reason the source doesn't give, ask the constraint's owner.
- **Open questions**: start with the template's note, word for word or translated as above. Keep each line to a sentence or two.
  - Under "Depends on the answer", a question about a constraint also names the requirements it changes; a conflict names both items.
  - A question of fact gives, for each likely result, what is built as a decided value with its marker; if that is not decided, it also needs a decision.
- **Sources**: an appendix for engineers, folded so other readers pass it by. Keep the template's `<details>` and `</details>` lines and the blank lines around the list, with the summary word for word or translated as above. A line may start with a few plain words on what was read, before the file and the names, using no engineering words.

Ids are stable within a spec and across a spec that supersedes it: never renumber, and a removed item leaves a gap. Cite an item by id and current name, as in `R2 (Weekly limit)`.

Then trace each "must" sentence in Requirements and Changes to existing behavior to the intent's words, a clause, current behavior, a decided marker, or a named item. Current behavior settles only what stays as it is, never a case this work creates or one a clause words differently. Cut what you cannot trace, even what the intent seems to lean toward, and ask it as step 3 says.

### 5. Check the form

Run `sh <this skill's directory>/scripts/check-spec.sh <spec file>`. Fix what it prints until it prints nothing. If a line is wrong about the spec, don't change correct text to silence it; say so in your final message. If you can't run it, do the checks listed at its top by hand.

### 6. Check with a fresh reader

You can't run the spec's test yourself, because you fill gaps from what you read without noticing. Once per draft, give spec.md and the intent, and nothing else, to one fresh subagent, on a different model when one is available, with this request:

> You will build from this spec and can't ask anyone. List at most 10 findings, most important first, each with its R, C, or Q id: a choice you would make yourself that a user, a stakeholder, or another system would notice, with literal values and what each would see; a quoted sentence deciding something the intent does not, with no marker or named item behind it; or two quoted sentences that cannot both hold, including an "n/a" under Sources that a requirement contradicts. Don't list what an open question already asks. Leave out how to build it and failures nobody outside sees.

Sort each finding:

- **Settled but not written**: you can name the workspace file and line that settles it. Write it in with its marker. Your reading of a source is not a citation.
- **Not a gap**: it follows from a requirement or constraint you can cite, whose words cover that very case, not a boundary you drew; or it can't happen given current behavior the spec states; or only the builders would notice. Drop it. A flagged sentence that only restates another item names that item or goes. Never delete a likely answer to answer a reader.
- **A gap, a sentence that decides too much, or two that cannot both hold**: cut each sentence back to what its source settles, and ask the rest as step 3 says, in the tier it gives; two rules that cannot both hold are a conflict. Never fill a gap yourself, and never add a marker whose source does not settle the sentence just to answer a finding.

Don't ask a second reader. Run step 5 again, then re-read each line you changed against the test at the top: it decides nothing nobody decided and contradicts nothing decided or already told to an actor.

### 7. Save

Save in the workspace's `docs/specs/`, the one closest to the intent if there are several, or a new one next to its `docs/intents/`; a superseding spec goes in the earlier spec's directory. Name it `NNNN-<slug>.md`: the next unused four-digit number there, from `0001`, and a short kebab-case English slug. A superseding spec fills in `Supersedes`. Change no other file, the earlier spec included. If you can't write the file, give the spec in your reply.

End with a short message: the spec's path and Status line, then each role that has questions, with their ids and short names in the spec's order. Do not write the plan.
