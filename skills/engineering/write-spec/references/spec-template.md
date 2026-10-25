# Spec: <Title, named after the outcome, not a means>

Intent: <file name of the accepted intent>

Supersedes: <earlier spec file name, only when this revises one>

Status: <number> open questions.

## Summary
<Two or three plain sentences: the problem, who this is for, and what they will see or be able to do, each backed by a requirement.>

## Reviewers
<A name only as a source gives it, else "not named".>
- Originator, <name>: <the problem is solved; From the intent>.
- Owner of <policy>, <name>: <its C items and conflicts>.
- Engineers, <names>: <the work can be planned without deciding product behavior>.
- Technical lead, <name>: <design constraints and the facts they rest on>.
- Product owner, <name>: <scope; routes questions; merges to accept>.

## Requirements
### R1. <Actor>: <short name>
<"Must" sentences: what the actor or another system observes.>

- Given <situation, with actual values>, when <action>, then <what is seen or returned, with actual values>.
- <Another case only when its result does not follow from the rule above.>

## Changes to existing behavior
- Today: <what happens now> (current behavior, <source>). After: <what happens instead, or "see R<n> (Short name)">. Affects: <who, data, or integrations>. Can be undone: <yes, or what cannot be reversed>.

## Constraints
- C1. <Short name>: <the rule in one checkable sentence, citing rather than restating its source>. Kind: <policy, or design (a system, contract, or the intent's own limit)>. Source: <document and section, or person; for design, "verified in <code>" or "claimed in <document>, not verified">. Owner: <who interprets or waives it, or "not named">. Reason: <as the source states it, or "not stated"; never supply one>.

## Conflicts
- <Any two R or C items, by id and name: the case, with actual values, where both cannot hold.> <Agreed by <the owner of each rule that gives way>, <where>, <date>: <which wins, or the exception> | Unresolved: see Q<n>.>

## Out of scope
- <What a reader might expect covered that is not, and why if a reason was given.>

## From the intent
- Outcome "<desired outcome, quoted>": <R<n> (Short name), …>. <Each vague word in it: "<word>" means <value>, with its marker.>
- Question "<intent open question, quoted>": <answered by R<n> (Short name) | answered by Out of scope (<marker>) | carried as Q<n> | no longer applies: <reason>, agreed by <intent originator>, <where>>.

## Open questions
Until a question is answered, build what its "Depends on the answer" names only as its "Until decided" says, and list it in the plan as waiting. The person under "Who answers" replies on this spec's pull request; anyone may settle a question of fact by checking it and saying what they found where. To close a question, write the answer into every line that names it, add it to the Decision log, update Status, and remove it; its id is not reused. Everything else in this spec is decided. If you find a behavior that a user, a stakeholder, or another system would notice and this spec does not settle, add a question here instead of choosing; how to build it is the plan's choice.

- Q1. <Short name>
  - What is unclear: <one sentence.>
  - Depends on the answer: <for each likely answer, which R or C items change and how.>
  - To resolve: <the decision to make, or the fact to check and why it could not be checked yet.>
  - Who answers: <role and name, as under Reviewers; when more than one, what each decides or confirms.>
  - Until decided: <"build R<n> (Short name) except <the case that waits>", or, when all of it waits, "do not build R<n> (Short name)" or "build R<n> (Short name) but do not switch it on"; then "meanwhile, <the actor> sees <what this spec already says they see, such as a Changes row's Today>". Or "nothing waits", when every likely answer builds the same thing.>

## Decision log
- Q<n> (<short name>): <the answer>. <Name>, <role>, <pull request comment link, or "conversation">, <date>. <Lines it changed are marked (decided by <name>, <role>, Q<n>).>
