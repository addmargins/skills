---
name: write-spec
description: Draft a specification (what must be built, and which confirmations from policy owners and other roles the work needs) from an accepted intent document, without interviewing anyone, for stakeholders who are not engineers to read. Every undecided behavior becomes an open question for the role that decides it, marked as one to decide before building or one that can wait for planning.
argument-hint: <intent file>
disable-model-invocation: true
---

# Write Spec

Turn an accepted intent into spec.md: what to build, and what each role must confirm or decide first, so those roles, most not engineers, can review their part.

The test for a finished spec: someone working only from spec.md never has to decide a product behavior, or how a policy or law applies, that nobody has decided. Each such gap is an open question for the role that decides it.

This skill often runs as a job, with nobody to ask, and even an invoker is rarely the decider. So a draft asks nobody and settles only what the sources settle; the rest become open questions, which one run does not answer. The skill ends with the saved spec.

## Principles

- **Decisions are people's, not yours.** Every value, default, limit, and exclusion comes from the intent, a source in the workspace, or the role that decides it. Mark each one not taken from the intent: `(decided by <role>, <where>)` for a decision a source records for this work, such as a spec this one supersedes; `(current behavior, S<n> (Name))` for existing behavior you verified. A marker covers the sentence it ends; a sentence naming the item it follows from needs none. A boundary you draw inside someone's recorded decision is a new question. Give a value in its source's words ("a threshold of 50", not "under 50" or "within 50") unless the source says which side of it a case falls. A value you would propose is only a question's likely answer. Who may see, export, change, or receive data, and any new permission or access, is never yours to grant: unless a source states it, ask the owner of the security or privacy rule.
- **Facts are yours to find; policies and laws are not yours to read.** Read the workspace for how things work today: ADRs, a `GLOSSARY.md`, policy documents, the code. Cite current behavior only for what you saw the code do in the case the sentence is about. Prose names code in plain words, cited as S<n> (Name); code names go only under Sources. Ask a question of fact only when you could not check it, and say why. A fact you give a decider is computed from the workspace or says what it depends on; never write "most" unless you counted. Which policies or laws apply, and what they require, is for the roles that own them (step 3).
- **What, not how.** The spec states what an actor or another system observes, and the limits the work must stay within. Modules, files, types, and algorithms belong to the plan. Fix an interface or data format only when someone outside this build depends on it: what it is for, then a sample or a link to its schema. Write a lifecycle as a table of state, event, next state, and who sees what.
- **Plain words, one term per concept.** Use the glossary's terms, else the intent's. Define a new term where it first appears. Outside Sources, replace engineering words such as API or null with what they mean. A term whose meaning stakeholders disagree on is an open question.
- **Compact.** Say each thing once, in the section the template gives it. Omit an empty section, except Changes to existing behavior and Open questions, which say "None.". Add no sections the template lacks.

## Steps

### 1. Read the intent and the workspace

Take the intent file from the arguments or the message. If none is named, list `docs/intents/` and stop rather than guess. If the intent is marked `Superseded by:`, use the one it names. If it has no settled problem or desired outcome, or its outcome can't be checked, stop and suggest `clarify-intent`: open questions in a spec can't repair an intent.

Read the specs in `docs/specs/`. If one is already built on this intent, stop and say which: people edit that spec themselves, and a changed intent gets a new spec. If one is built on an intent this one supersedes, this spec supersedes it (step 8). Then read what the intent touches.

### 2. Find the gaps

Draft the requirements in your head. For each, list what a builder would otherwise decide alone that a user, a stakeholder, or another system would notice. Prompts, not a checklist:

- scope boundaries a reader might expect covered;
- values, defaults, limits, and thresholds, the behavior on both sides of each, and none at all, such as no permission;
- each vague word in an outcome, such as "soon": the value it stands for;
- which inputs count as each action, which item an input means when more than one fits, and what each actor sees or receives after it, including nothing;
- the same person acting again or reversing their action, and a record corrected after someone was told;
- a message that promises a person will act: who, what they see, and by when;
- what each actor sees when something the work relies on fails, and for things under way at go-live;
- existing users, records, and integrations: what each sees change;
- a limit of a system or contract the work could break.

Two people acting at once, rollback, switching off, and moving data over are the plan's, unless an answer changes what someone sees; then ask about that result.

### 3. Name what the work touches

Policies and laws are often outside the workspace or unwritten, so never judge them. From the intent and the code, find each area where this work changes what they commonly govern: personal data collected, shared, kept, or deleted; money paid, refunded, or taxed; notices or messages to customers or the public; permissions and access; records kept or deleted; anything the intent or a workspace document names. For each, state what happens today and after, the requirements it affects, and the role that confirms which policies or laws apply and what they require. Quote each governing clause of a workspace document word for word, with its number, as a lead; if there is none, say no policy document for this area was found in the workspace, never that none applies.

Never decide whether or how a clause applies, whether two conflict, or that none does; never summarize a clause, derive a requirement from one, or take today's code as its answer. Two areas or quotes bearing on one requirement are stated as a fact.

### 4. Ask the rest

Address each area and remaining gap to the role responsible: an area to the role owning its rules, as in "privacy officer, or whoever approves new personal data collection", or the owner a quoted document names; a design limit, or a fact only an engineer can check, to the technical lead for that system; what counts as solving the problem, including vague words in the outcome and the intent's own questions, to the originator; a case within another function's work to the role running it; other product behavior to whoever decides the product's behavior. Name roles by responsibility, never people, even those a source names, nor "not named". One role decides each question; name another only to confirm an answer that could narrow the outcome (the originator).

Each role gets one question for all its areas, a numbered part per area by its A id: which policies or laws apply and what they require. No question restates or cites a clause by number; the area quotes it. Any other question asks for one decision, except that what one role decides about one item (a screen, a message, a record, a case), in one tier, is one question in numbered parts, each with its own answers: "Receipt after a refund: 1. who gets it (a. the payer; b. the account holder); 2. whether it gives the reason (a. yes; b. no)". Each numbered part names its own case and what changes for it; never fold one case into a broader part. Never join different items, roles, or tiers. For a choice, give two to four lettered likely answers with their trade-offs, none recommended.

Tier each question. **Can wait for planning** holds only a slot the plan leaves blank and fills before release: a value, a wording, a label, or a format. Everything else is **Decide before building**: every area's question, and any question that leaves open a case, a flow step, who qualifies or is told, an amount of money, what data is kept or shown, or a behavior. When unsure, choose the first. Put area questions first in their tier.

A requirement states only what is decided. It never says that a case or a requirement waits, stays off, or is held: questions under "Decide before building" are answered before building starts. A requirement names a question only where its answer fills a slot, as in "the refund amount is set by Q3". A question whose every likely answer builds the same thing is no gap. Keep the count down by checking facts and combining questions as above, never by leaving a gap or an area out.

### 5. Write the spec

Use the headings of [references/spec-template.md](references/spec-template.md) in order, filling its placeholders. Write in the intent's language, but keep headings, ids, field names, markers, and `None.` in English. In a spec not in English, translate faithfully the notes under What this work touches and Open questions, the four question labels (each still followed by a colon, the same in the note and on every question), the Sources summary, and the sentence for an area with no policy document.

- **Requirements**: one behavior someone outside can check per requirement. Quote a message's exact wording only when someone decided it or depends on it; otherwise give its meaning. Each "then" names a value, a state, a message's meaning, or what the observer can do next. Where the intent says a behavior follows a policy, say so in its words and leave what the policy gives to the area's question.
- **Changes to existing behavior**: one row per behavior in use that changes, pointing to a requirement when it needs scenarios.
- **What this work touches**: the template's note, translated in a spec not in English, then the areas grouped by role.
- **Constraints**: only limits of a system or contract, or set by the intent, that this work could break.
- **Open questions**: the template's note, then the questions. Keep each line to a sentence or two. "To resolve" names the concrete decision or check, not just "choose a or b". A question of fact gives what each likely result builds.
- **Sources**: an appendix for engineers, folded so other readers pass it by. Keep the template's `<details>` lines and the blank lines around the list.

Ids are stable within a spec and across one that supersedes it: never renumber; a removed item leaves a gap. Cite an item by id and current name, as in `R2 (Weekly limit)`.

Then trace each "must" sentence in Requirements and Changes to existing behavior to the intent's words, current behavior that stays as it is, a decided marker, or a named item. Current behavior never settles a case this work creates, or what a policy or law requires. Cut what you cannot trace, even what the intent seems to lean toward or a quoted clause seems to say, and ask it as step 4 says.

### 6. Check the form

Run `sh <this skill's directory>/scripts/check-spec.sh <spec file>` and fix what it prints until it prints nothing. If a line is wrong about the spec, don't change correct text to silence it; say so in your final message. If you can't run it, do the checks listed at its top by hand.

### 7. Check with a fresh reader

You can't run the spec's test yourself: you fill gaps from what you read without noticing. Once per draft, give spec.md and the intent, and nothing else, to one fresh subagent, on a different model when one is available, with this request:

> You will build from this spec and can't ask anyone. List at most 10 findings, most important first, each with its R, A, C, or Q id: a choice you would make yourself that a user, a stakeholder, or another system would notice, with literal values and what each would see; a quoted sentence deciding something the intent does not, with no marker or named item behind it; a requirement that applies, reads, or works out a policy or law instead of leaving it to its area's question; or a change to personal data, money, notices, access, or records that "What this work touches" leaves out. Don't list what an open question already asks, unless another sentence answers it. Leave out how to build it and failures nobody outside sees.

Sort each finding:

- **Settled but not written**: a workspace file and line, not a policy or law, settles it. Write it in with its marker.
- **Not a gap**: an item's words cover that very case, it can't happen given current behavior the spec states, or only builders would notice. Drop it, but never a likely answer.
- **A gap, a sentence that decides too much, or a missed area**: cut each sentence back to what its source settles, add the area as step 3 says, and ask the rest as step 4 says. Never fill a gap yourself, and never add a marker whose source does not settle the sentence.

Don't ask a second reader. Run step 6 again, then re-read each line you changed against the test at the top.

### 8. Save

Save in the workspace's `docs/specs/`, the one closest to the intent if there are several, or a new one next to its `docs/intents/`; a superseding spec goes in the earlier spec's directory. Name it `NNNN-<slug>.md`: the next unused four-digit number there, from `0001`, and a short kebab-case English slug. A superseding spec fills in `Supersedes`. Change no other file, the earlier spec included. If you can't write the file, give the spec in your reply.

End with a short message: the spec's path and Status line, then each role that has questions, with their ids and short names in the spec's order. Do not write the plan.
