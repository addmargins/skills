# Spec: <Title, named after the outcome, not a means>

Intent: <file name of the accepted intent document>

Supersedes: <earlier spec file name, only when this revises one>

Decided in conversation: <the user's name, role, and the conversation's date, only when a marker says (decided in conversation)>

## Summary
<Two or three sentences a non-engineer can follow: the problem from the intent, who this is for, and what they will see or be able to do once it is built.>

## Requirements
### R1. <Actor>: <short name>
<What must be true, in "must" sentences, as the actor or another system observes it. Mark each value not taken from the intent: (decided in conversation), (decided by <name>, <role>, <where>), (current behavior, <source>), or (required by C<n> (Short name)).>

- Given <situation, with actual values>, when <action>, then <what is seen or returned, with actual values or state>.
- <Another case only when its result does not follow from the rule above.>

## Changes to existing behavior
- Today: <what happens now>. After: <what happens instead, with actual values, or "see R<n> (Short name)">. Affects: <who, or which data or integrations>. Can be undone: <yes, or what cannot be reversed>.
<Or "None." when nothing in use changes.>

## Constraints
- C1. <Short name>: <A rule the work must follow, stated so a reviewer can tell whether it holds.> Source: <ADR, document and section, regulation, system, or person>. Owner: <who interprets or waives it>. Reason: <as the source states it, or "not stated">.

## Policy conflicts
- <R<n> (Short name) and C<n> (Short name): the case where both cannot hold.> <Agreed with <policy owner>, <date or where>: <which wins, or the exception granted> | Unresolved: see Q<n>.>

## Out of scope
- <What a reader might expect this to cover but it does not, and why when a reason was given. For an exclusion the intent does not make: (decided in conversation) or (decided by <name>, <role>, <where>).>

## From the intent
- Outcome "<desired outcome, quoted>": <R<n> (Short name), …>. <For each vague word in it: "<word>" means <value>, with its marker.>
- Question "<intent open question, quoted>": <answered by R<n> (Short name) | carried as Q<n> | no longer applies: <reason>, agreed by <intent originator>, <where>>.

## Open questions
Until a question below is answered, plan and build the items named under its "Depends on the answer" only as its "Until decided" line says, and list them in the plan as waiting on that question. Anyone may settle a question of fact by checking it and recording what they found and where. To close a question that needs a decision, revise this spec: write the answer into each item named under its "Depends on the answer", marked (decided by <name>, <role>, <where>), update the From the intent and Policy conflicts lines that point at the question, and remove the question. Its id is not reused. Everything else in this spec is decided. If you find a behavior that a user, a stakeholder, or another system would notice and this spec does not settle, add a question here instead of choosing; how to build it is the plan's choice.

- Q1. <What is unclear.>
  - Depends on the answer: <which R or C items change, and how, for each likely answer.>
  - To resolve: <the decision to make and who makes it, or the fact to check and why it could not be checked while writing.>
  - Until decided: <"do not build R<n> (Short name)"; "do not build R<n> (Short name) for <the case that waits>; meanwhile <what that case does, with its marker>"; "build R<n> (Short name) <except for the case that waits>, but do not switch it on"; or "build R<n> (Short name) with <what to build meanwhile>, accepted by <decider>, <where>".>
