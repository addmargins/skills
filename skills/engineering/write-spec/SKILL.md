---
name: write-spec
description: Draft a specification (what must be built, and which design and policy constraints it must follow) from an accepted intent document, without interviewing anyone, for stakeholders who are not engineers to review on a pull request. Every undecided behavior becomes an open question for the person who decides it. Also revises a spec under review from its pull request comments, applying only answers from the person each question names.
argument-hint: <intent file> | <spec file> <review comments or pull request>
disable-model-invocation: true
---

# Write Spec

Turn an accepted intent document into a spec: what must be built, and which design and policy constraints it must follow. The intent's originator, the policy owners, the engineers, the technical lead, and the product owner review it on a pull request, so write it for readers who are not engineers.

The test for a finished spec: someone working only from spec.md never has to decide, on their own, a product behavior or constraint that nobody has decided. Each such gap is an open question for the person who decides it.

This skill often runs as a job when an intent is accepted, with nobody to ask. Even run by hand, the invoker is usually not the decider: a policy's reading belongs to its owner, a design limit to the technical lead, and what solves the problem to the originator. So a draft asks nobody anything. It writes down what the sources settle and turns the rest into questions those people answer on the pull request. The product owner reviews the spec but does not write it; merging accepts it.

By default, draft (steps 1 to 7). Given a spec under review and its comments, revise it ("Revise from review"). Take answers in this conversation only when the invoker explicitly asks ("Answers in conversation").

## Principles

- **Decisions are people's, not yours.** Every value, default, limit, and exclusion comes from the intent, a source in the workspace, or a named person. Mark each one not taken from the intent: `(decided by <name>, <role>, Q<n>)` for an answer in the Decision log, or `(decided by <name>, <role>, <where>)` for a decision a source records for this work; `(current behavior, <source>)` for existing behavior you verified; `(required by C<n> (Short name))` for behavior a constraint's own words require. A marker covers the sentence it ends. A sentence that names the item it follows from, as in "the same limit as R2 (Weekly limit)", needs no marker. A policy owner decides nothing by having written the policy. A boundary you draw inside someone's answer, such as which changes count, is a new question. A value you would propose is one of a question's likely answers, never a requirement and never a recommendation.
- **Facts are yours to find.** Read the workspace for how things work today and for the rules that apply: ADRs, policy documents, a `GLOSSARY.md`, the code. Separate what a document claims from what you verified. Cite `(current behavior, <source>)` only for what you saw the code or system do, down to the functions it calls, in the case the sentence is about. Ask a person a question of fact only when you could not check it, and say why. A fact you give a decider is computed from the workspace or says what it depends on; never write "most" unless you counted.
- **What, not how.** The spec states what an actor or another system observes, and the rules the work must follow. Modules, files, types, and algorithms belong to the plan. Fix an interface or data format only when someone outside this build depends on it or a stakeholder would notice a change: one sentence on what it is for, then a sample or a link to the schema that owns it. Write a lifecycle as a table of state, event, next state, and who sees what.
- **Plain words, one term per concept.** Use the glossary's terms, else the intent's. Define a new term in one clause where it first appears. A term whose meaning stakeholders disagree on is an open question.
- **Compact.** Say each thing once, in the section the template gives it. Omit an empty section, except Changes to existing behavior and Open questions, which say "None.". Add no sections the template lacks, such as background, risks, assumptions, or notes.

## Draft

### 1. Read the intent and the workspace

Take the intent file from the arguments or the message. If none is named, stop and list `docs/intents/`, because a guess drafts the wrong work. If the intent is marked `Superseded by:`, use the one it names. If it has no settled problem or desired outcome, or its outcome can't be checked, stop and suggest `clarify-intent`: questions on a pull request can't repair an intent.

Read each spec in `docs/specs/` built on the same intent. If one is under review, revise it ("Revise from review") instead. If one was accepted, this draft revises it (step 7). Then read the parts of the workspace the intent touches.

### 2. Find the gaps

Draft the requirements in your head. For each, list what a builder would otherwise decide alone. These are prompts for noticing cases, not slots to fill:

- scope boundaries a reader might expect covered;
- values, defaults, limits, and thresholds, and the behavior on both sides of each limit;
- each vague word in an outcome, such as "soon": the value it stands for. Current behavior that covers part of it, such as how long a system takes to respond, is a fact to give with the question, not the answer;
- no permission, nothing there yet, at the limit and over it;
- the switch-over: things under way when the change goes live, such as an invoice issued before and paid after; and what is sent, held, or lost while something the work relies on is down, including opt-outs and other actions a rule requires;
- in the main flow, which inputs count as each action, which item an input means when more than one fits, and what each actor sees or receives after it, including nothing;
- the same person acting again or reversing their action, such as accepting after declining: what each actor sees and what state results;
- a message that promises a person will act, such as "a manager will review it": who, what they see, and by when;
- two people or systems acting on the same thing at once. No default answer exists, so this is a question even when a requirement seems to cover it;
- what happens to existing users, data, and integrations, and what switching the change off must do. The workspace shows only what is possible, so these are questions too;
- which policy or design rules this work could break, through its behavior, current behavior it keeps, or a choice the plan might make. Check what the code does against each rule's words;
- where two rules cannot both hold.

### 3. Settle what the sources settle; ask the rest

Before writing a question, re-read the words of each rule it touches. If they settle the case, write a requirement marked `(required by C<n> (Short name))`. If the workspace answers a question of fact, write the fact with its marker. Don't ask about what the intent or workspace settles, how to build it, or a combination of cases each already settled.

Address each remaining gap to the person the sources make responsible: a policy's reading, exception, or waiver to its owner; a design limit, or a fact only an engineer can check, to its owner, else the technical lead; what counts as solving the problem, including a vague word in the outcome and the intent's own questions, to the originator; other product behavior, such as scope, defaults, and what each actor sees, to the product owner. Use the name a source gives, or "not named". One person decides each question, except that the owners of conflicting rules decide together; name another only to confirm an answer that could narrow the outcome (the originator) or make a constraint give way (its owner).

Each question asks one thing: split one whose parts could get different answers. For a choice, give two to four lettered likely answers with the trade-offs that matter, none marked as recommended.

A question holds back only the case it is about, unless its answer would change the whole requirement; the rest is built and goes live. The held case stays off, and meanwhile the actor sees what they see today, stated from a Changes row or current behavior. If that would contradict what the new behavior already told them, such as a message inviting a reply nobody reads yet, hold back that message too. Any other meanwhile is a decision: offer it only as a likely answer. A question whose every likely answer builds the same thing holds nothing back: "nothing waits".

When a requirement and a rule, or two rules, cannot both hold, record the case under Conflicts. It is agreed only when a source records the agreement of the owner of each rule that gives way, with their name and a date or place. Otherwise the conflict line says `Unresolved: see Q<n>`, a question for those owners that holds back every case the conflict touches, because building either reading there decides it for them.

Order the questions so that a reviewer who answers only their first few unblocks the most: the main flow, conflicts and policy readings, two actors at once, the switch-over, switching off, and promises first; other edge cases next; questions that hold nothing back last. Keep the count down by asking only about cases an actor or reviewer would notice, never by leaving a gap out, because a gap nobody asks about is decided by whoever builds it.

### 4. Write the spec

Use the headings of [references/spec-template.md](references/spec-template.md) in order; its placeholders say what each slot holds, and a name appears only as a source gives it, never guessed or taken from an account handle. Write in the intent's language, but keep headings, ids, field names, markers, and `None.` in English, because check-spec.sh and readers look for them. In a spec not in English, translate the Open questions note and the five question labels faithfully, each label still followed by a colon, and use the same labels in the note and on every question.

- **Requirements**: one behavior someone outside can check per requirement; what only the inside can check is plan material or a constraint. Quote a message's exact wording only when someone decided it or depends on it, such as consent text, a promise about money or deadlines, or text another system parses; otherwise give its meaning. Each "then" names a value, a state, a message's meaning, or what the observer can do next.
- **Changes to existing behavior**: one row per behavior in use that changes; when the new behavior needs scenarios, write a requirement and point the row at it. Whether it can be undone, when that depends on how the plan does it, is a decided value or a question.
- **Constraints**: only rules this work could break. When a reader would need a reason the source doesn't give, ask the constraint's owner.
- **Open questions**: copy the template's note word for word, or its faithful translation, as the first paragraph, because it tells planners and builders, who may not have this skill, what waits and what may go ahead. Keep each line to a sentence or two.
  - Under "Depends on the answer", name by id each requirement and constraint that would differ for any likely answer, and how. A question about a constraint also names the requirements it changes; a conflict names both items.
  - A question of fact gives, for each likely result, what is built as a decided value with its marker; if that is not decided, it also needs a decision.
  - "Until decided" takes one of the template's forms, as step 3 says. Never hold back switching the change off, or a requirement that only keeps current behavior, and switching off is not what a waiting case does meanwhile. Don't write a requirement only to hold a waiting case.

Ids are stable once the spec is on a pull request: never renumber, and a removed item leaves a gap. Cite an item by id and current name, as in `R2 (Weekly limit)`.

### 5. Check the form

Run `sh <this skill's directory>/scripts/check-spec.sh <spec file>` (POSIX shell and awk). Fix each line it prints and run it again until it prints nothing. If a line is wrong about the spec, don't change correct text to silence it; say so in the hand-off. If you can't run it, do the checks listed at its top by hand. Then check that each requirement has a scenario and each constraint has `Kind:`, `Source:`, `Owner:`, and `Reason:`.

### 6. Check with a fresh reader

You can't run the spec's test yourself, because you fill gaps from what you read without noticing. Give spec.md and the intent, and nothing else, to a fresh subagent, on a different model when one is available, with the text of [references/reader-prompt.md](references/reader-prompt.md) as its request. Sort each item it lists:

- **Settled but not written**: you can name the workspace file and line, or the Decision log entry, that settles it. Write it in with its marker. Your reading of a source is not a citation.
- **Not a gap**: it follows from a requirement or constraint you can cite, whose words cover that very case, not a boundary you drew; or it can't happen given current behavior the spec states; or only the builders would notice. Drop it. If the reader flagged a sentence that only restates another item, name that item in it ("as R2 (Weekly limit) says") or delete it. Never delete a likely answer, a waiting case, or a question's meanwhile to answer a reader.
- **A gap**: add an open question as step 3 says. Never fill it in yourself.

Then run step 5 and this step once more with a new reader, the changed spec, and the intent. Stop after that second reader; sort what it lists the same way, and don't add requirements just to answer it. Last, re-read each line you changed after it against the test at the top: it decides nothing nobody decided and contradicts nothing decided or already told to an actor.

### 7. Save and hand off

Save in the workspace's `docs/specs/`, the one closest to the intent if there are several, or a new one next to its `docs/intents/`; a revision goes in the earlier spec's directory. Name the file `NNNN-<slug>.md`: one more than the highest number prefix there, four digits from `0001`, and a short kebab-case English slug for the title. Change no other spec or intent, except that a spec revising an accepted one fills in `Supersedes`, and the earlier file gets a `Superseded by: <new file name>` paragraph right after its title. If you can't write the file, give the spec in your reply.

End with the file path and a block the caller can paste as the pull request description:

```
Spec for <intent file>: <spec path>. <n> open questions.

Review requested from:
- <Role>, <name or "not named">: <what they check, from Reviewers>. Answers: <Q<n> (Short name), … in the spec's order, or "none">.

Reply to a question on this pull request; only the person it names decides it. Merging accepts the spec, and questions still open wait in the plan as their "Until decided" says.
```

Opening the pull request is the caller's or the job's work; do it only when asked and the environment can. Do not write the plan.

## Revise from review

Take the spec and its pull request comments and reviews, pasted or fetched when tools allow (`gh pr view <n> --comments`, review comments through `gh api`). Edit the spec in place, since it is not accepted yet; an accepted spec changes only through a new spec that supersedes it. Sort each comment:

- **An answer from the person the question's "Who answers" names**: close the question as the template's note says, marking each line it changes `(decided by <name>, <role>, Q<n>)` and giving the comment's link and date in the Decision log. If it narrows the outcome or makes a constraint give way and the person who must confirm that has not, keep it open and say who still must. A boundary the answer leaves open is a new question.
- **A question of fact**: settled by anyone who says what they found where; check it yourself first when you can.
- **An answer from anyone else**: input, not a decision. The question stays open; add the answer as a likely answer if it is new.
- **A behavior the spec doesn't settle**: a new question, as step 3 says, with the next unused id.
- **Anything else**: fix wording or errors that change no decision; a fix that would is a new question for the decider.

Then run step 5, and step 6 with one fresh reader, even for a small change: the answer you wrote in is text no reader has tested, and it may decide a boundary its author left open. End with one reply line per comment for the caller to post: what changed where, or why the question stays open and who must answer. Repeat the step 7 block if who answers what has changed.

## Answers in conversation

Only when the invoker explicitly asks to answer now. Take their name and role from what they say, never from the account, the session, or the workspace. Put to them only the questions whose "Who answers" names them, a few at a time, and close each answer as "Revise from review" says, with "conversation" and today's date in the Decision log. Don't put other questions to them, even as options. If they say "you decide", the question stays open.
