# Spec: <Title, named after the outcome, not a means>

Intent: <file name of the accepted intent document>

Supersedes: <earlier spec file name, only when this revises one>

Decided in conversation: <the user's name, role, and the conversation's date, only when a marker says (decided in conversation)>

Status: <number> open questions. Waiting: <each R<n> (Short name), the case that waits, and its Q<n>; or "nothing">.

## Summary
<Two or three sentences that a non-engineer can follow: one clause of the problem from the intent, who this is for, and what they will see or be able to do once it is built. Each claim about what is built must be backed by a requirement.>

## Reviewers
<One line per role, for the pull request's reviewer list; "Theirs" lists the Q ids it answers, or "none". Use only names a source such as the intent gives, never guessed names or account handles, else "not named".>
- Originator, <name>: <the problem is solved; From the intent>. Theirs: <Q ids>.
- Owner of <policy>, <name>: <its C items and conflicts>. Theirs: <Q ids>.
- Engineers, <names>: <the work can be planned without deciding product behavior>. Theirs: <Q ids>.
- Technical lead, <name>: <design constraints and what they rest on>. Theirs: <Q ids>.
- Product owner, <name>: <scope; routes questions; merges to accept>. Theirs: <Q ids>.

## Requirements
### R1. <Actor>: <short name>
<What must be true, in "must" sentences, as the actor or another system observes it. Mark each value not taken from the intent.>

- Given <situation, with actual values>, when <action>, then <what is seen or returned, with actual values or state>.
- <Another case only when its result does not follow from the rule above.>

## Changes to existing behavior
- Today: <what happens now>. After: <what happens instead, with actual values, or "see R<n> (Short name)">. Affects: <who, or which data or integrations>. Can be undone: <yes, or what cannot be reversed>. Seen in: <code or system you saw do it>.

## Constraints
- C1. <Short name>: <A rule the work must follow, in one short sentence a reviewer can check. Cite ADRs and policies in Source: instead of restating them.> Kind: <policy, or design (a system, contract, or the intent's own limit)>. Source: <ADR, document and section, regulation, system, or person; for a design constraint, "verified in code" or "claimed in <document>, not verified">. Owner: <who interprets or waives it, or "not named">. Reason: <as the source states it, or "not stated"; never supply one>.

## Conflicts
- <Any two R or C items, by id and name: the case, with actual values, where both cannot hold.> <Agreed by <the owner of each rule that gives way>, <where>, <date>: <which wins, or the exception granted> | Unresolved: see Q<n>.>

## Out of scope
- <What a reader might expect this to cover but it does not, and why when a reason was given. For an exclusion the intent does not make: (decided in conversation) or (decided by <name>, <role>, <where>).>

## From the intent
- Outcome "<desired outcome, quoted>": <R<n> (Short name), …>. <For each vague word in it: "<word>" means <value>, with its marker.>
- Question "<intent open question, quoted>": <answered by R<n> (Short name) | answered by Out of scope (<marker>) | carried as Q<n> | no longer applies: <reason>, agreed by <intent originator>, <where>>.

## Open questions
<Copy the next paragraph word for word, or for a Korean intent the one after it. Korean labels, in order: 무엇이 불명확한가?, 그 답에 따라 무엇이 달라지는가?, 무엇을 확인하거나 결정하면 해결되는가?, 답할 사람, 결정 전까지.>

Until a question below is answered, build the items under its "Depends on the answer" only as its "Until decided" line says, and list them in the plan as waiting on it. The person under "Who answers" replies to that question in this spec's pull request; anyone may settle a question of fact by checking it and saying what they found where. To close a question, revise this spec: write the answer into each item and line that names the question, add it to the Decision log, update Status, and remove the question; its id is not reused. Everything else in this spec is decided. If you find a behavior that a user, a stakeholder, or another system would notice and this spec does not settle, add a question here instead of choosing; how to build it is the plan's choice.

아래 질문에 답이 나오기 전까지는 그 질문의 "그 답에 따라 무엇이 달라지는가?"에 적힌 항목을 "결정 전까지" 줄에 적힌 대로만 만들고, 계획에는 그 질문을 기다리는 항목으로 적는다. "답할 사람"에 적힌 사람은 이 spec의 풀 리퀘스트에서 그 질문에 댓글로 답한다. 사실 확인으로 풀리는 질문은 누구든 확인한 내용과 출처를 남겨 풀 수 있다. 질문을 닫으려면 이 spec을 고친다. 그 질문을 가리키는 모든 항목과 줄에 답을 써 넣고, Decision log에 적고, Status를 고친 뒤 질문을 지운다. 지운 질문의 번호는 다시 쓰지 않는다. 이 spec의 나머지는 모두 결정된 것이다. 사용자, 이해관계자, 다른 시스템이 알아챌 동작인데 이 spec이 정하지 않은 것을 찾으면 직접 정하지 말고 여기에 질문을 더한다. 어떻게 만들지는 계획에서 정한다.

- Q1. <Short name>
  - What is unclear: <one sentence.>
  - Depends on the answer: <which R or C items change, and how, for each likely answer.>
  - To resolve: <the decision to make, or the fact to check and why it could not be checked while writing. For the user's own question: "not yet asked" or "left open by <name>".>
  - Who answers: <role and name, as under Reviewers.>
  - Until decided: <When one case waits: "build R<n> (Short name); for <the case that waits>, meanwhile <what the actor sees, with its marker>", or, if none was accepted, "build R<n> (Short name), but do not switch on <the case that waits>; while it is off, <the actor> sees <what this spec already says, such as a Changes row's Today>". Only when the answer changes the whole requirement, or the user chose to hold the rest: "do not build R<n> (Short name)"; "build R<n> (Short name), but do not switch any of it on" when only going live waits; or, when the decider has accepted what to build meanwhile, "build R<n> (Short name) with <what to build meanwhile>, accepted by <decider>, <where>".>

## Decision log
- Q<n> (<short name>): <the answer>. <Name>, <role>, <pull request comment link, or "conversation">, <date>. <Items it went into carry (decided by <name>, <role>, Q<n>).>
