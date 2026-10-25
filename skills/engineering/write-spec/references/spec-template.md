# Spec: <Title, named after the outcome, not a means>

Intent: <file name of the accepted intent>

Supersedes: <earlier spec file name, only when revising one>

Status: <number> to resolve before accepting, <number> to carry into the plan.

## Summary
<Two or three plain sentences: the problem, who it is for, and what they will see or do, each backed by a requirement.>

## Reviewers
<Roles, never people, each by its responsibility.>
- Originator (<their role, from the intent>): <the problem is solved; From the intent>.
- Owner of <policy> (<the office or role it names>): <its C items and conflicts>.
- Engineers for <systems>: <the work can be planned without deciding product behavior>.
- Technical lead for <system>: <design constraints and the facts they rest on>.
- Product owner for <product>, or whoever decides its behavior: <scope; routes questions; merges to accept>.
- <Any other role a question goes to>: <what it decides>.

## Requirements
### R1. <Actor>: <short name>
<"Must" sentences: what the actor or another system observes.>

- Given <situation, with actual values>, when <action>, then <what is seen or returned, with actual values>.
- <Another case only when its result does not follow from the rule above, or one at the exact value of each threshold the rule names, with the result on each side.>

## Changes to existing behavior
- Today: <what happens now> (current behavior, S<n> (Plain name)). After: <what happens instead, or "see R<n> (Short name)">. Affects: <who, data, or integrations>. Can be undone: <yes, or what stays done, such as money paid or texts sent>.

## Constraints
- C1. <Short name>: <the rule in one checkable sentence, citing rather than restating its source>. Kind: <policy, or design (a system, contract, or the intent's own limit)>. Source: <document title and section, or the deciding role; for design, "verified in S<n> (Plain name)" or "claimed in S<n> (Plain name), not verified">. Owner: <the role that interprets or waives it>. Reason: <only as the source states one; omit the field when it states none>.

## Conflicts
- <Any two R or C items, by id and name: the case, with actual values, where both cannot hold.> <Agreed by <the role owning each rule that gives way>, <where>, <date>: <which wins, or the exception> | Unresolved: see Q<n>.>

## Out of scope
- <What a reader might expect covered that is not, and why if a reason was given.>

## From the intent
- Outcome "<desired outcome, quoted>": <R<n> (Short name), …>. <Each vague word in it: "<word>" means <value>, with its marker.>
- Question "<intent open question, quoted>": <answered by R<n> (Short name) | answered by Out of scope (<marker>) | carried as Q<n> | open, but every answer builds the same: <why> | no longer applies: <reason>, agreed by <intent originator>, <where>>.

## Open questions
Everything outside these questions is decided, and the spec is accepted only once none is left under "Resolve before accepting". One under "Carry into the plan" holds back only its case: it stays off and actors see today's behavior, unless its "Until decided" says otherwise. The role under "Who answers" decides on the pull request; anyone may settle a fact by checking.

### Resolve before accepting
<Conflicts, policy readings, and questions whose answer changes what gets built; else "None.">

- Q1. <Short name>
  - What is unclear: <one sentence, naming the case that waits.>
  - Depends on the answer: <for each likely answer, which R or C items change and how.>
  - To resolve: <the decision to make, or the fact to check and why it could not be checked yet.>
  - Who answers: <the role, as under Reviewers; when more than one, what each decides or confirms.>
  - Until decided: <carry-over only, when more than the case waits: "build R<n> (Short name) except <what waits>; meanwhile, <the actor> sees <what this spec says they see>".>

### Carry into the plan
<Questions that only fill a value, a wording, a label, or one case the plan can leave as a slot; else "None.">

- Q<n>. <Short name, then the lines above>

## Decision log
- Q<n> (<short name>): <the answer>. <Who answered, as the pull request shows them>, for <role>, <comment link, or "conversation">, <date>. <Lines it changed are marked (decided by <role>, Q<n>).>

## Sources
<For engineers: each file a marker or constraint cites, under the plain name the prose uses.>
- S1. <Plain name>: <file path, and the function, field, or lines read>.
