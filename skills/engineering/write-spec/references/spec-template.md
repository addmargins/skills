# Spec: <Title, named after the outcome, not a means>

Intent: <file name of the accepted intent>

Supersedes: <earlier spec file name, only when superseding one>

Status: <number> to decide before building, <number> that can wait for planning.

## Summary
<Two or three plain sentences: the problem, for whom, and what they will see or do, each backed by a requirement.>

## Roles
<Roles by responsibility, never people: what each decides or confirms.>
- Originator (<their role, from the intent>): <the problem is solved; From the intent>.
- <Role confirming an area's rules>: <its A items>.
- Technical lead for <system>: <design constraints and the facts they rest on>.
- Product owner for <product>, or whoever decides its behavior: <scope, and behavior no other role decides>.
- <Any other role a question goes to>: <what it decides>.

## Requirements
### R1. <Actor>: <short name>
<"Must" sentences: what the actor or another system observes, each value in its source's words or, for a value a policy sets, the Q that sets it.>

- Given <situation, with actual values or the Q that sets each>, when <action>, then <what is seen or returned, with actual values or the Q that sets each>.
- <Another case only when its result does not follow from the rule above, or at the exact value of each threshold the spec states, with the result on each side.>

## Changes to existing behavior
- Today: <what happens now> (current behavior, S<n> (Plain name)). After: <what happens instead, or "see R<n> (Short name)">. Affects: <who, data, or integrations>. Can be undone: <yes, or what stays done, such as money paid>.

## What this work touches
Policies or laws commonly govern each area below that this work changes. The role named confirms which apply and what they require. A quoted clause is a lead, not this spec's reading; rules kept elsewhere may govern any area.

### <Role that confirms the rules for these areas>
- A1. <Area, in plain words, such as "Bank details kept for payouts">
  - Affects: <R<n> (Short name), …>.
  - Policy text: <document> (S<n>), <clause number>: "<the clause, word for word>". <One line per clause; with none in the workspace: No policy document for this area found in the workspace.>
  - Confirm in: Q<n>. <The same question for every area under this role.>

## Constraints
- C1. <Short name>: <the limit in one checkable sentence>. Type: limit (<of a system or contract, or set by the intent>). Source: <"verified in S<n> (Plain name)", "claimed in S<n> (Plain name), not verified", or the intent>. Owner: <the role that can change it>. Reason: <only as the source states one, else omit>.

## Out of scope
- <What a reader might expect covered that is not, and any reason given.>

## From the intent
- Outcome "<desired outcome, quoted>": <R<n> (Short name), …>. <Each vague word in it: "<word>" means <value>, with its marker, or is set by Q<n>.>
- Question "<intent open question, quoted>": <answered by R<n> (Short name) | answered by Out of scope (<marker>) | carried as Q<n> | open, but every answer builds the same: <why> | no longer applies: <reason>, agreed by <intent originator>, <where>>.

## Open questions
Everything outside these questions is decided. Those under "Decide before building" leave open a case, a step, or who qualifies, so they are answered before building starts. Those under "Can wait for planning" only fill a value, a wording, a label, or a format, which the plan leaves blank and fills before release. The role under "Who answers" decides; anyone may settle a fact by checking.

### Decide before building
<Each role's area question, then each leaving a case, a step, who qualifies, or a behavior open; else "None.">

- Q1. <Short name>
  - What is unclear: <one sentence, naming the case or slot left open; for one item's parts: "1. <case>: <what changes for it>; 2. …", one case per part; for a role's areas: "1. A1 (<name>); 2. A2 (<name>): which policies or laws apply to each, and what they require", with no clause number or quote.>
  - Depends on the answer: <for each likely answer, which R or C items change and how; for areas: the requirements each area's Affects names.>
  - To resolve: <the concrete decision or check that settles it: what the decider fixes, such as "who receives the receipt after a refund", or the record to check, where, and why it was not checked here; for areas: the role names the rules governing each and confirms or corrects its quotes. Not just "choose a or b".>
  - Who answers: <the role, as under Roles; for an area, its role heading.>

### Can wait for planning
<Questions that only fill a value, a wording, a label, or a format; else "None.">

- Q<n>. <Short name, then the lines above>

## Sources
<details><summary>For engineers: where each cited fact was read (other readers can skip)</summary>

- S1. <Plain name>: <optionally, plain words on what was read; then the file path, and the function, field, or lines read>.

</details>
