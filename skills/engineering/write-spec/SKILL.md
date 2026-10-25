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

- **Decisions are people's, not yours.** Every value, default, limit, and exclusion in the spec comes from the intent, from a source in the workspace, or from a named person. Mark each one not taken from the intent with `(decided in conversation)` for the user's answers, `(decided by <name>, <role>, <where>)` for anyone else's, `(current behavior, <source>)` for existing behavior you verified, or `(required by C<n> (Short name))` for behavior a constraint's own words require. A marker covers the sentence it ends. A sentence that names the item it follows from, as in "the same limit as R2 (Weekly limit)", is already cited and takes no marker. Write a decided marker only for a person who decided it for this work; a policy owner decides nothing by having written the policy. A boundary or definition you draw inside a user's answer, such as which changes count or what "this week" covers, is a new question, not part of their answer. A value you would propose goes under an open question as one of the likely answers, never into a requirement and never as a recommended answer.
- **Facts are yours to find.** Before asking anyone, read the workspace for how things work today and for the rules that apply: ADRs, policy documents, a `GLOSSARY.md`, the code. Separate what a document claims from what you verified. Cite `(current behavior, <source>)` only for what you saw the code or system do, down to the functions it calls, in the same case the sentence is about. A question of fact goes under Open questions only when you could not check it, and says why. A fact you give a decider, in a question or under "To resolve", is computed from the workspace or says what it depends on; never write "most" or "nearly every" unless you counted.
- **What, not how.** The spec states what an actor or another system observes, and the rules the work must follow. Module structure, files, types, and algorithms belong to the plan. Fix an interface or data format only when someone outside this build depends on it, or a stakeholder would notice if it changed: give one plain sentence saying what it is for, then a sample, or a link to the schema that owns it. Write a lifecycle as a table of state, event, next state, and who sees what.
- **Plain words, one term per concept.** Use the glossary's terms, or the intent's terms when there is no glossary. Define a new term in one clause where it first appears. A term whose meaning stakeholders disagree on is an open question.
- **Compact.** Say each thing once, in the section the template gives it. Omit any section that would be empty, except Changes to existing behavior and Open questions, which say "None." instead. Don't add sections for status, approvals, revision history, background, risks, assumptions, testing decisions, or further notes.

## Workflow

### 1. Read the intent and the workspace

Take the intent file from the invocation arguments or the user's message. If there is none, list `docs/intents/` and ask which one, in one sentence. If the intent is marked `Superseded by:`, use the one it names. If the intent has no settled problem or desired outcome, stop and suggest running `clarify-intent` first.

List each `docs/specs/` in the workspace and read any spec built on the same intent. If one exists, ask whether this is a revision of it.

When a revision answers an open question that needed a decision, close it as the template's Open questions note says. Don't leave an `Answered:` line in its place: its "Until decided" line would still hold the work back.

Read the parts of the workspace the intent touches.

### 2. Find the gaps

Draft the requirements in your head from the intent. For each, list what a builder would otherwise decide alone:

- scope boundaries a reader might expect to be covered;
- values, defaults, limits, and thresholds, and the behavior on both sides of each limit;
- each vague word in an intent outcome, such as "soon" or "easily": the value it stands for, which only a person can decide. Current behavior that covers part of it, such as how long a system it relies on takes to respond, is a fact to give with the question, not the answer;
- cases to consider: no permission, nothing there yet, and at the limit and over it. These are prompts for noticing cases, not slots to fill;
- the switch-over: things already under way when the change goes live, such as an invoice issued before it and paid after; and what is sent, held, or lost while something the work relies on is unavailable, including opt-outs and other actions a rule requires;
- in the main flow, which inputs count as each action, such as other spellings or extra words, which item an input refers to when more than one could fit, and what each actor sees or receives after it, including nothing;
- the same person acting again or reversing their own action, such as a second decline, accepting after declining, or a second request while the first is pending: what each actor sees and what state results. Ask a repeat in the same round as its reversal;
- a message or screen that promises a person will act, such as "a manager will review it": who acts, what they see, and by when, in a requirement or an open question;
- two people or systems acting on the same thing at once: always ask the user what each sees, because no default answer exists, even when a requirement seems to cover it;
- what happens to existing users, data, and integrations, and what switching the change off must do: ask the user, because the workspace shows only what is possible;
- which policy or design rules this work could break, through its behavior, through current behavior it keeps, or through a choice the plan might make. Check what the code does against each rule's words;
- where two rules cannot both hold.

### 3. Settle what the user can decide

Ask the user about the gaps in short rounds of two or three numbered questions: about 20 before the first draft, and one round per fresh reader after it. Ask first about the main flow, then two people acting at once, the switch-over, switching off, and promises, all before any other edge case; only other edge cases may go unasked when the budget runs out. Within that order, and above all after the draft, prefer questions whose answer unblocks something that would otherwise stay off, and say in a few words what each one holds; combinations that unblock nothing come last. A promise the user makes in an answer gets its who and by when in the next round. Each question asks one thing: split a question whose parts could get different answers, such as what happens meanwhile and what happens if the answer is no. Ask instead of stating an assumption for the user to correct, or telling them a case follows from their answer; only a held case's meanwhile is proposed, as below. For a choice, give two to four lettered options with the trade-offs that matter. Record each answer as decided by the user, by the name and role they give you in this conversation, because the spec's readers don't know who "the user" was; never from the account, the session, or the workspace. If you don't know them, ask in your first round. Write them and the date once, in the spec's `Decided in conversation:` line, and mark each answer `(decided in conversation)`. That line names one conversation: a revision keeps the line it inherits and marks the answers from its own conversation in full, as in `(decided by Sam Lee, club manager, conversation of 2026-10-14)`.

Before any question goes out, re-read the words of each policy or design rule it touches; if they settle the case, write it as a requirement marked `(required by C<n> (Short name))` and drop the question. When only someone else can decide something, such as how a rule applies beyond its words, don't put it to the user, not even as options: ask who decides if you don't know, leave it as an open question naming them, and tell the user in one line. Whether the rest goes live before that person decides is the user's question: ask it on its own, never in the same question as what the held case does meanwhile. Each thing you tell the user you will raise with someone else becomes an open question. When the user doesn't know or would leave a question open, first tell them what it would hold back; then leave it open, with "left open by <name>" under "To resolve", instead of rephrasing until they guess. A gap the user can decide that you have not put to them by the time you save is an open question for them, with "not yet asked" under "To resolve". When the user says "you decide" or "whatever's normal", never pick: give the options and ask them to choose, or leave it open with them as the decider. Don't ask about what the intent or the workspace already settles, about how to build it, about a case the user's own words already name if you can quote them, or about a combination of cases each already settled unless a reader flags it.

An open question holds back only the case it is about, unless its answer would change the whole requirement; the rest is built and goes live. What the actor sees meanwhile in a held case is a decision: it must fit what they were already told (a message that invited a reply can't be followed by one saying replies aren't read) and obey the strictest likely answer, such as "keep them" or "send nothing", so it decides nothing of an owner's. Just before saving, put the held cases to the user in one question, each with a proposed meanwhile they accept or change on its own, and mark each accepted one `(decided in conversation)`. A meanwhile nobody accepted never goes in the spec: if the user declines one, only that case stays off.

When a requirement collides with a policy or design rule, show the user the case where both cannot hold. Record it under Policy conflicts as agreed only when the policy owner's agreement is recorded with their name and a date or place. A verbal agreement counts when it names both. Otherwise it is an open question for the policy owner, and the conflict line says `Unresolved: see Q<n>`.

### 4. Write the spec

Use the headings of [references/spec-template.md](references/spec-template.md) in that order. The placeholders say what each slot holds. The rules:

- **Summary**: two or three sentences: one clause of the intent's problem, who this is for, and what they will see. Each claim about what is built must be backed by a requirement.
- **Requirements**: one behavior someone outside can check per requirement; anything checkable only from inside is plan material or a constraint. The actor goes in the heading. In scenarios, values and states are always literal. Quote a message's exact wording only when someone decided it or depends on it, such as legal or consent text, a promise about money or deadlines, text a policy owner approves, or text another system parses; otherwise give its meaning. Each "then" names a value, a state, a message's meaning, or what the observer can do next. Add a case only when its result does not follow from the rule above it.
- **Changes to existing behavior**: always present. One row per behavior in use that changes. When the new behavior needs scenarios, write it as a requirement and point the row at it. When whether it can be undone depends on how the plan does it, record what the stakeholder requires, as a decided value.
- **Constraints**: list a rule only if this work could break it. Cite ADRs and policies in `Source:` instead of restating them. Give the reason as the source states it, or "not stated"; never supply one. When a reader would need a reason the source doesn't give, ask the constraint's owner in an open question.
- **Out of scope**: what a reader might expect this to cover but it does not.
- **From the intent**: one line per intent outcome, quoted, with the requirements that deliver it, and one line per intent open question, quoted, with where it went. For each vague word in an outcome, add `"<word>" means <value>` to its line, with its marker. Only the intent's originator can retire a question as no longer applying; record who agreed and where.
- **Open questions**: always present. Copy the template's note word for word as the section's first paragraph, because it tells those who plan and build, who may not have this skill, what waits and what may go ahead. Write "None." under it when there are no questions. Keep each question short: a sentence for what is unclear, and a sentence or two per line. For each question:
  - Under "Depends on the answer", name by id each requirement and constraint that would differ for any likely answer, and say how. A question about a constraint also names each requirement whose behavior would differ, and an unresolved policy conflict names both items.
  - Under "To resolve", say whether it needs a decision or a fact, and who decides. A question of fact gives, under "Depends on the answer", what is built for each likely result as a decided value with its marker; if that is not decided for some result, the question also needs a decision.
  - Write "Until decided" on every question. When one case waits, it says `build R<n> (Short name); for <the case that waits>, meanwhile <what the actor sees>` with that meanwhile's marker, or, if none was accepted, `build R<n> (Short name), but do not switch on <the case that waits>`. Only when the answer would change the whole requirement, or the user chose to hold the rest until then, does it say `do not build R<n> (Short name)`, or `build R<n> (Short name), but do not switch any of it on` when only going live waits; if the decider named in "To resolve" has accepted what to build meanwhile, it says what that is and who accepted it, and where. Never hold back switching the change off, or a requirement that only keeps current behavior: both go ahead whatever is still open, and switching off is not what a waiting case does meanwhile. Don't write a requirement only to hold a waiting case.

Ids are stable. Never renumber: a removed item leaves a gap. Cite an item by id and current name, as in `R2 (Weekly limit)`.

### 5. Check the form

Run `sh <this skill's directory>/scripts/check-spec.sh <spec file>`. It needs a POSIX shell and awk, finds the intent and any earlier spec from the `Intent:` and `Supersedes:` lines, and checks that every R, C, and Q id mentioned is defined once and cited by its current name; From the intent quotes each intent outcome and open question; Open questions starts with the template's note word for word; Changes to existing behavior and Open questions are present and say "None." exactly when they list nothing; `(decided in conversation)` has its `Decided in conversation:` line; and a revision keeps each inherited name on its old id. Fix each line it prints and run it again until it prints nothing. If a line is wrong about the spec, don't change correct text to silence it; tell the user. If you can't run it, check those six things by hand.

Then check by hand that each requirement has a scenario, each constraint has `Source:`, `Owner:`, and `Reason:`, and each open question has its three lines.

### 6. Check with a fresh reader

You can't run the spec's test yourself, because you fill gaps from this conversation without noticing. Give spec.md and the intent, and nothing else, to a fresh subagent, on a different model when one is available, with this request:

> You will build from this spec and can't ask anyone. List at most 12 items, most important first, in three groups:
> 1. Unmarked behavior: each sentence in a requirement or a Changes row that states a value or behavior the intent does not state and that has none of these markers: "(decided by …)"; "(decided in conversation)", which refers to the person and date on the spec's "Decided in conversation:" line; "(current behavior, …)"; or "(required by C<n> …)". A sentence that names the R or C item it follows from counts as marked. Give the id and quote the sentence.
> 2. Choices someone outside would notice: each behavior you would have to choose on your own where a user, a stakeholder, or another system would see a different result depending on your choice. Give the R or C id, the situation with literal values, and the two results they would see. Leave out how to build it: data formats, encodings, retries, duplicate deliveries, message length, ordering or timing below what a person would notice, and failures nobody outside sees.
> 3. Each Summary claim that no requirement backs, and each "Until decided" line that holds back something the spec decides elsewhere, or lets something go ahead that the answer would change.

Sort each item into one of three cases:

- **Settled but not written**: you can quote the user's words from the conversation, or name the workspace file and the line, that settle it. Write it in with its marker. A paraphrase, a gloss, or your reading of an answer is not a citation; the item is then a gap.
- **Not a gap**: the result follows from a requirement or constraint as written, and you can cite it; it follows only when the user's words or a rule's words cover that very case, not a boundary you drew, such as which orders count; or the situation can't happen given current behavior the spec states; or only the people building it would notice. Drop it. If the reader flagged a sentence that only restates or follows from another item, name that item in the sentence, as in "as R2 (Weekly limit) says", or delete the sentence. To answer a reader, never delete a likely answer, a waiting case, or what a question says happens meanwhile; that is a gap.
- **A gap**: settle it with the user in one round as in step 3, or add an open question naming who decides. Never fill one in yourself.

Then run step 5 and this step once more, giving a new reader only the changed spec and the intent. Stop after that second reader, even if it lists new items. Sort each item it lists as above, and put any gap you can't settle under Open questions. Don't add requirements just to answer the reader. Before saving, ask the meanwhile question of step 3, then re-read each line you added or changed after the second reader, Until decided lines included, against the test at the top: it decides nothing nobody decided, and contradicts no decided answer or anything an actor was already told.

### 7. Save the spec

- Use the workspace's `docs/specs/`. If there are several, use the one closest to the intent's `docs/intents/`. If there is none, create `docs/specs/` next to that `docs/intents/`. Save a revision in the earlier spec's directory.
- Name the file `NNNN-<slug>.md`. `NNNN` is one more than the highest number prefix in the directory, zero-padded to four digits, starting at `0001`. `<slug>` is a short kebab-case English name for what the title names.
- Don't modify or overwrite specs or intents written before this conversation, with one exception. When the new spec revises an earlier one, fill in the template's `Supersedes` line, and in the earlier file add a `Superseded by: <new file name>` line as its own paragraph right after the title.
- If you can't write the file, say so and give the spec in chat.

After saving, tell the user the file path, and list the open questions grouped by who decides each, so the user can send them on; within each group, list the "not yet asked" and the "left open by <name>" ones apart. Do not write the plan.
