---
name: write-spec
description: Write a draft specification from an accepted intent document. The spec says what must be built, and which confirmations are still needed from policy owners and other roles. It is written for readers who are not engineers. The skill does not interview anyone. Each behavior that nobody has decided becomes an open question for the role that decides it, marked either "decide before building" or "can wait for planning".
argument-hint: <intent file>
disable-model-invocation: true
---

# Write Spec

Turn an accepted intent document into a spec file. The spec says two things:

- what to build;
- what each role must confirm or decide before that.

Most of these roles are not engineers. Each role must be able to find and review its own part.

**The test for a finished spec.** A builder who reads only the spec never has to decide, alone:

- a product behavior that nobody has decided; or
- how a policy or a law applies.

Each such gap becomes an open question for the role that decides it.

This skill often runs as an automated job, with nobody to ask. Even when a person starts it, that person is rarely the one who decides. So:

- Do not ask anyone anything while you draft.
- Write as decided only what the sources decide. Everything else becomes an open question. This run does not answer the open questions.
- The skill ends when the spec is saved.

## Terms used in this skill

- **Intent**: the accepted intent document that the spec is built from.
- **Source**: a workspace file you read, such as the intent, an earlier spec, an ADR, a glossary, a policy document, or code.
- **Role**: a responsibility, such as "finance team lead". A role is never a person's name.
- **Originator**: the role that raised the intent.
- **Builder**: whoever later builds from the spec.
- **Actor**: a person, or another system, that uses the product and sees its behavior.
- **Gap**: a choice that a builder would otherwise make alone, and that a user, a stakeholder, or another system would notice.
- **Item**: anything in the spec with an id: R (requirement), A (area), C (constraint), Q (open question), S (source).
- **Supersede**: replace. A spec supersedes an earlier spec when it replaces it.
- **Area**: a part of the work that policies or laws often govern, such as personal data or refunds (step 3).
- **Open question**: a decision or a fact that the spec leaves open, for one role to answer (step 4). A **question of fact** asks what is true today, not what to decide.
- **Tier**: each open question is in one of two tiers, "Decide before building" or "Can wait for planning" (step 4).
- **Slot**: a blank in a requirement that the answer to an open question fills in, such as "the refund that Q3 sets".
- **Marker**: a note in parentheses at the end of a sentence that says where the sentence comes from (Principle 1).
- **Current behavior**: what the existing system does today, as you saw it in the code.
- **Plan**: the engineering document, written later, that says how to build the spec. This skill does not write it.

## Principles

### 1. Decisions belong to people, not to you

- Every value, default, limit, and exclusion must come from one of these:
  - the intent;
  - a workspace source that is not a policy or a law;
  - the role that decides it, through an open question.
- A value that a policy sets appears in one place only: quoted on the "Policy text" line of its area. In Requirements, Changes to existing behavior, and Constraints, do not write the value. Name the question that sets it instead, for example "the refund that Q3 sets".
- Mark each decision that does not come from the intent. Put the marker at the end of the sentence. There are two markers:
  - `(decided by <role>, <file>)`: only for a decision recorded in the earlier spec that this spec supersedes.
  - `(current behavior, S<n> (Name))`: for existing behavior that you checked yourself.
- A marker covers the whole sentence it ends. A sentence that names the item it follows from needs no marker, for example "the amount Q1 sets" or "as S4 (Data retention decision) records".
- If you draw a new boundary inside a decision that someone recorded, the boundary is a new open question.
- Write each value in its source's words: "a threshold of 50", not "under 50" or "within 50". Words such as "under" decide which side of the value a case falls on. Use them only if the source says which side.
- A value that you would suggest is not a decision. It may appear only as a likely answer to a question.
- Never grant a permission yourself. This covers who may see, export, change, or receive data, and any new permission or access. If no source states it, ask the role that owns the security or privacy rule.

### 2. Facts are yours to find; policies and laws are not yours to interpret

You may read and quote policies and laws. But only the roles that own them say what they mean.

- Read the workspace to learn how things work today: ADRs, a `GLOSSARY.md`, policy documents, the code.
- Cite current behavior only for what you saw the code do, in the same case the sentence is about.
- In prose, name code in plain words ("booked", not BOOKED), and cite it as S<n> (Name). Code names appear only under Sources.
- Ask a question of fact only when you could not check the fact yourself. In the question, say why you could not.
- A fact you give to a decider is either computed from the workspace, or it says what it depends on. Never write "most" unless you counted.
- Which policies or laws apply, and what they require, is for the roles that own them to say (step 3).

### 3. What, not how

- The spec states what a person (an actor) or another system can observe, and the limits the work must stay within.
- Modules, files, types, and algorithms belong to the plan.
- Define an exact interface or data format only when someone outside this build depends on it. Then say what it is for, and give a sample or a link to its schema.
- Write a lifecycle as a table with four columns: state, event, next state, and who sees what.

### 4. Plain words, one term for each idea

- Use the terms in the workspace glossary. If the glossary has no term for an idea, use the intent's term.
- Define each new term where it first appears.
- Outside Sources, replace engineering words such as "API" or "null" with what they mean.
- If stakeholders disagree about what a term means, that is an open question.

### 5. Short

- Say each thing once, in the section that the template gives it.
- Leave out each section that has nothing in it. Exception: "Changes to existing behavior" and "Open questions" always stay. Write "None." under "Changes to existing behavior" when nothing changes, and under each of the two tier headings that has no questions.
- Do not add sections that the template does not have.

## Steps

### 1. Read the intent and the workspace

1. Take the intent file from the arguments or the message. If no file is named, list `docs/intents/` and stop. Do not guess.
2. If the intent says `Superseded by:`, use the intent it names.
3. Check the intent. Stop and suggest `clarify-intent` if:
   - it has no settled problem or no settled desired outcome; or
   - its outcome cannot be checked.

   Open questions in a spec cannot repair an intent.
4. Read the specs in `docs/specs/`.
   - If a spec was already written from this intent, stop and say which one. People edit that spec themselves, and a changed intent gets a new spec.
   - If a spec was written from an older intent that this intent supersedes, your spec supersedes that spec (step 8).
5. Read the code and documents that the intent names or affects.

### 2. Find the gaps

Draft the requirements in your head. For each one, list its gaps. These prompts give ideas; they are not a checklist:

- scope boundaries that a reader might expect to be covered;
- values, defaults, limits, and thresholds: the behavior on each side of each one, and when there is none at all, such as no permission;
- each vague word in an outcome, such as "soon": the value it stands for;
- which inputs count as each action; which record or object an input means when more than one fits; what each actor sees or receives afterwards, including nothing;
- the same person acting again, or undoing their action; a record that is corrected after someone was already told about it;
- a message that promises that a person will do something: who, what they will see, and by when;
- what each actor sees when something the work depends on fails; what happens to things that are in progress at go-live;
- existing users, records, and integrations: what each one sees change;
- a limit of a system or a contract that the work could break.

These are for the plan, not the spec: two people acting at the same time, rollback, switching the work off, and moving data over. Exception: if an answer changes what someone sees, ask about that visible result.

### 3. Name the areas the work touches

Policies and laws are often outside the workspace, or not written down. So you never judge them.

From the intent and the code, find each area: a place where this work changes something that policies or laws commonly govern. For example:

- personal data that is collected, shared, kept, or deleted;
- money that is paid, refunded, or taxed;
- notices or messages to customers or the public;
- permissions and access;
- records that are kept or deleted;
- anything that the intent or a workspace document names.

For each area:

- Name the requirements it affects.
- Name the role that confirms which policies or laws apply and what they require.
- Quote each clause of a workspace document that may govern the area, word for word, with its number. A quote is only a starting point for that role. It is not your reading of the clause.
- If you find no such clause, write: "No policy document for this area found in the workspace." Never write that no policy applies.

Never do any of these:

- decide whether or how a clause applies, whether two clauses conflict, or that no clause applies;
- summarize a clause, or derive a requirement from a clause;
- treat today's code as the answer to what a policy requires.

If two areas or two quotes bear on one requirement, state that as a fact, with no judgment.

### 4. Ask the rest as open questions

**Who answers.** Send each area and each remaining gap to the role responsible for it:

| The question is about | Who answers |
|---|---|
| An area | The role that owns its rules, such as "privacy officer, or whoever approves new personal data collection", or the owner that a quoted document names |
| A design limit, or a fact that only an engineer can check | The technical lead for that system |
| What counts as solving the problem, including vague words in the outcome and the intent's own open questions | The originator |
| A case inside the work of another team, such as support or finance | The role that runs that team's work |
| Any other product behavior | Whoever decides the product's behavior |

- Name roles by responsibility. Never name people, even people a source names. Never write "not named".
- Exactly one role decides each question. One exception: if an answer could make the desired outcome smaller, also name the originator, to confirm that answer.

**How to build questions.**

- **Area questions.** Each role gets one question for all of its areas. The question has one numbered part per area, by its A id. Each part asks which policies or laws apply, and what they require. The question does not restate a clause or cite it by number, because the area already quotes it.
- **Other questions.** Each question asks for one decision. Exception: when one role decides several things about one subject (a screen, a message, a record, or a case) in one tier, make one question with numbered parts. Each part has its own likely answers. Example: "Receipt after a refund: 1. who gets it (a. the payer; b. the account holder); 2. whether it gives the reason (a. yes; b. no)".
- Each numbered part names its own case, and what changes for that case. Never fold one case into a broader part.
- Never put different subjects, different roles, or different tiers into one question.
- For a choice, give two to four likely answers, lettered a, b, c, d, each with its trade-offs. Do not recommend any of them.

**Tiers.** Put each question in one tier:

- **Can wait for planning**: only a question whose answer is a value, a wording, a label, or a format, and that the plan can leave blank and fill in before release.
- **Decide before building**: every other question. This includes every area question, and every question that leaves open a case, a step in a flow, who qualifies or who is told, an amount of money, what data is kept or shown, or a behavior. An amount of money is never "Can wait for planning", even though it is a value.
- If you are not sure, choose "Decide before building".
- In each tier, put area questions first.

**Requirements and open questions.**

- A requirement states only what is decided. It never says that a case or a requirement is delayed, turned off, or on hold. Every "Decide before building" question is answered before building starts.
- A requirement names a question only where the answer fills a slot in it.
- If every likely answer to a question would build the same thing, it is not a gap. Do not ask it.
- Keep the number of questions low by checking facts yourself and by combining questions as described above. Never do it by leaving out a gap or an area.

### 5. Write the spec

Use the headings of [references/spec-template.md](references/spec-template.md) in order, and fill in its placeholders.

Write in the intent's language. Always keep these in English: headings, ids, field names such as `Status:`, `Affects:`, `Policy text:`, and `Confirm in:`, markers, and `None.`. If the spec is not in English, translate these faithfully: the notes under "What this work touches" and "Open questions", the four labels of each question (What is unclear, Depends on the answer, To resolve, Who answers), the Sources summary, and the sentence for an area with no policy document.

What each section holds:

- **Requirements**: each requirement is one behavior that someone outside the build can check. Quote a message's exact wording only when someone decided that wording or depends on it; otherwise give its meaning. Each "then" names a value, a state, the meaning of a message, or what the observer can do next. Where the intent says that a behavior follows a policy, say so in the intent's words.
- **Changes to existing behavior**: one bullet for each behavior in use today that changes. When the new behavior needs Given/when/then cases, write "see R<n> (Short name)" after "After:".
- **What this work touches**: the template's note, then the areas, grouped by role.
- **Constraints**: only limits that this work could break. A limit comes from a system or a contract, or is set by the intent.
- **Open questions**: the template's note, then the questions. Keep each line to one or two sentences. "To resolve" names the concrete decision or check, not just "choose a or b". A question of fact says what each likely result would build.
- **Sources**: an appendix for engineers, inside a folded `<details>` block, so that other readers can skip it.

Ids:

- Ids stay the same within a spec, and in a later spec that supersedes it. Never renumber. If you remove an item, do not reuse its id.
- Cite an item by its id and its current name, for example `R2 (Weekly limit)`.

Then trace each "must" sentence in Requirements and in Changes to existing behavior. Each one must come from one of these:

- the intent's words;
- current behavior that stays as it is;
- the spec that this spec supersedes;
- a named item.

It must never come from a policy. Current behavior never settles a case that this work creates, or what a policy or law requires. Cut each sentence you cannot trace, even one the intent seems to lean toward or a quoted clause seems to say. Ask it as an open question instead, as step 4 says.

### 6. Check the form

Run `node <this skill's directory>/scripts/check-spec.mjs <spec file>`. Fix what it prints, and run it again, until it prints nothing, or only lines that say "not verified".

A pass means only this: the ids, references, counts, and quotes resolve, and the prose has no backticks or workspace paths. It does not mean the spec is good.

- If a printed line is wrong about the spec, do not change correct text just to silence it. Say so in your final message.
- If node is not installed, say in your final message that the check did not run. Never say that it passed.

### 7. Check with a fresh reader

You cannot run the test for a finished spec on your own draft, because you fill gaps from what you have read without noticing. So give spec.md and the intent, and nothing else, to one fresh subagent, once. Use a different model if one is available. Send this request:

> You will build from this spec, and you cannot ask anyone. List at most 10 findings, most important first. Give each finding the id (R, A, C, or Q) it is about. Report only findings of these kinds:
>
> 1. A choice you would have to make yourself that a user, a stakeholder, or another system would notice. Give literal values, and what each of them would see.
> 2. A sentence that decides something the intent does not decide, with no marker or named item behind it. Quote the sentence.
> 3. A sentence outside Open questions that settles a value an open question asks about. This includes a sentence that puts a case on one side of that value, as words like "under", "within", "up to", or "or more" do.
> 4. A requirement that applies, reads, or works out a policy or a law, instead of leaving it to its area's question.
> 5. A change to personal data, money, notices, access, or records that "What this work touches" leaves out.
>
> Do not list what an open question already asks, unless another sentence answers it. Leave out how to build it, and failures that nobody outside would see.

Sort each finding into one of three kinds:

- **Settled but not written**: a workspace file and line settles it, and that file is not a policy or a law. Write it into the spec, with its marker or with the S item it comes from.
- **Not a gap**: an item's words cover that exact case; or the case cannot happen, given current behavior that the spec states; or only builders would notice it. Drop the finding. Never remove a likely answer from a question to answer a finding.
- **A gap, a sentence that decides too much, or a missed area**: shorten each such sentence until it says only what its source settles. Add a missed area as step 3 says. Ask the rest as step 4 says. Never fill a gap yourself. Never add a marker whose source does not settle the sentence.

Do not ask a second reader after you revise. Run step 6 again. Then re-read each line you changed, against the test for a finished spec at the top of this skill.

### 8. Save

- **Folder**:
  1. A spec that supersedes another goes in the earlier spec's folder.
  2. Otherwise, use the workspace's `docs/specs/`. If there are several, use the one closest to the intent.
  3. If there is none, create `docs/specs/` next to the intent's `docs/intents/`.
- **File name**: `NNNN-<slug>.md`. NNNN is the next unused four-digit number in that folder, starting from `0001`. The slug is a short English name in kebab-case (lowercase words joined by hyphens).
- A spec that supersedes another fills in `Supersedes:`.
- Change no other file. This includes the earlier spec.
- If you cannot write the file, give the spec in your reply.

End with a short message that gives:

- the spec's path and its Status line;
- each role that has questions, with the ids and short names of its questions, in the spec's order;
- any quote that check-spec could not verify.

Never say that passing check-spec shows the spec is good. Do not write the plan.
