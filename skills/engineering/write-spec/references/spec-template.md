# Spec: <Title. Name it after the outcome, not after a method.>

Intent: <file name of the accepted intent>

Supersedes: <file name of the earlier spec. Keep this line only when this spec replaces one; otherwise delete it.>

Status: <number> to decide before building, <number> that can wait for planning.

## Summary
<Two or three plain sentences: the problem, who has it, and what they will see or do. A requirement must back each sentence.>

## Roles
<Name roles by responsibility, never people. Say what each one decides or confirms.>
- Originator (<their role, from the intent>): <confirms that the problem is solved, and answers for "From the intent">.
- <Role that confirms the rules of an area>: <its A items>.
- Technical lead for <system>: <design constraints, and the facts they depend on>.
- Product owner for <product>, or whoever decides its behavior: <scope, and behavior that no other role decides>.
- <Any other role that a question goes to>: <what it decides>.

## Requirements
### R1. <Actor>: <short name>
<"Must" sentences: what the actor or another system observes. Write each value in its source's words. For a value that a policy sets, name the Q that sets it instead.>

- Given <situation, with real values, or the Q that sets each one>, when <action>, then <what is seen or returned, with real values, or the Q that sets each one>.
- <Add another scenario only (a) when its result does not follow from the rule above, or (b) for each threshold that the spec states: a scenario at the exact value, with the result on each side of it.>

## Changes to existing behavior
- Today: <what happens now> (current behavior, S<n> (Plain name)). After: <what happens instead, or "see R<n> (Short name)">. Affects: <who, which data, or which integrations>. Can be undone: <whether this change can be switched back after release, and what stays done if it is, such as money already paid. This is not about whether a user can undo their own action; that belongs in a requirement or an open question.>.

## What this work touches
This work changes each area below, and policies or laws often govern areas like these. For each area, the named role confirms which policies or laws apply and what they require. A quoted clause is only a starting point for that role; this spec does not interpret it. Other rules, inside or outside this workspace, may also govern any area.

### <Role that confirms the rules for these areas>
- A1. <Area, in plain words, such as "Bank details kept for payouts">
  - Affects: <R<n> (Short name), …>.
  - Policy text: <document> (S<n>), <clause number>: "<the clause, word for word, with its list items>". <One line for each clause. If the workspace has none, write: No policy document for this area found in the workspace.>
  - Confirm in: Q<n>. <The same question for every area under this role.>

## Constraints
- C1. <Short name>: <the limit, in one sentence that can be checked>. Type: limit (<of a system or contract, or set by the intent>). Source: <"verified in S<n> (Plain name)", "claimed in S<n> (Plain name), not verified", or the intent>. Owner: <the role that can change it>. Reason: <only if the source gives one; otherwise leave out "Reason:">.

## Out of scope
- <Something a reader might expect to be covered that is not, with the reason if one was given.>

## From the intent
- Outcome "<desired outcome, quoted>": <R<n> (Short name), …>. <For each vague word in it, either: "<word>" means <value>, with its marker; or: "<word>" is set by Q<n>.>
- Question "<open question from the intent, quoted>": <one of: answered by R<n> (Short name) | answered by Out of scope (<marker>) | carried as Q<n> | open, but every answer builds the same: <why> | no longer applies: <reason>, agreed by <intent originator>, <where that agreement is recorded>>.

## Open questions
Everything outside these questions is decided. Questions under "Decide before building" leave open a case, a step, who qualifies, money, data, a behavior, or the rules for an area, so they must be answered before building starts. Questions under "Can wait for planning" only fill in a value, a wording, a label, or a format; the plan leaves these blank and fills them in before release. The role under "Who answers" decides. Anyone may settle a question of fact by checking.

### Decide before building
<First each role's area question, then each question that leaves open a case, a step, who qualifies, or a behavior. If there are none, write "None.".>

- Q1. <Short name>
  - What is unclear: <One sentence that names the open case or blank. For several parts about one subject: "1. <case>: <what changes for it>; 2. …", one case per part. For a role's areas: "1. A1 (<name>); 2. A2 (<name>): which policies or laws apply to each, and what they require". Give no clause number or quote.>
  - Depends on the answer: <For each likely answer: which R or C items change, and how. For areas: the requirements under each area's Affects.>
  - To resolve: <The concrete decision or check that settles it. For a decision: what the decider fixes, such as "who receives the receipt after a refund". For a fact: the record to check, where it is, and why it was not checked here. For areas: the role names the rules that govern each area, and confirms or corrects its quotes. Never only "choose a or b".>
  - Who answers: <The role, as named under Roles. For an area question: the role in the area's ### heading under What this work touches.>

### Can wait for planning
<Questions that only fill in a value, a wording, a label, or a format. If there are none, write "None.".>

- Q<n>. <Short name, then the same four lines as Q1>

## Sources
<details><summary>For engineers: where each cited fact was read (other readers can skip this)</summary>

- S1. <Plain name>: <optional: plain words on what was read; then the file path, and the function, field, or lines read>.

</details>
