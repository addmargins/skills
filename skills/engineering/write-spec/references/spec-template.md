# Spec template

Use these headings in this order. Replace each note in angle brackets. The headings and header labels follow the paired intent: use them as written here when the intent uses clarify-intent's English headings, and use the translations at the end when the intent's headings are in Korean. Field labels and table headers are always in the body's language.

```markdown
# Spec: <What will be true once this is built, named after the outcome as the intent's title is, not after a means>

Intent: [<intent file name>](../intents/<intent file name>)
Status: Draft · <N> open questions, <M> block planning
Verified against: <commit short hash, or "workspace as of YYYY-MM-DD">, <YYYY-MM-DD>
Supersedes: <earlier spec file name, only when a new intent superseded the earlier spec's intent>

## Summary
<Three to five sentences in your own words: what is wrong today, what will be built and for whom, any fixed date from a source, and what is still undecided, naming the most consequential open questions by ID and short name.>

## Scope
- In: <What this spec covers, from the intent.>
- Out: <What the intent excludes, with its reason when it gives one, and anything split off into its own spec.>
- Unchanged: <Existing behavior that must keep working, with the reason when the intent gives one.>
- At the edges: <People or channels outside the scope that a policy or a fact still reaches, each with the question that raises it. Don't widen the scope.>

## Reviewers
| Role | Who | What to check | Questions to answer or confirm |
|---|---|---|---|
| Originator | <name and team, from the intent> | Does this spec solve the problem the intent describes? Was anything dropped or narrowed? | <Q-IDs with short names, or "none"> |
| Product owner | <from the intent or workspace> | Scope and product behavior; routes each policy conflict to its owners | |
| Policy owner: <policy ID> | <owner the policy names> | The <policy ID> rows under Policies, and the cases they name | |
| Technical lead | <name, or "not named; the product owner assigns one"> | Facts and sources (confirm each claimed fact), Left to engineering | |
| Engineers | <name, or "not named"> | Can the work be planned without deciding product behavior? | |

## What <the main user> experiences
<One sentence on whose path this is and where it starts.>

1. <What the person sees, then what they do. One action per step. End with the step's source.>
2. <Where an open question splits the path, show each branch in a sentence and name the question.>

<One or two sentences on any other path, such as what people outside the scope see.>

## Open questions

### Blocks planning
#### Q1. <Short name>
- **<What is unclear>:** <...>
- **<What changes depending on the answer>:** <...>
- **<What would resolve it>:** <...>
- **<Who answers>:** <...>
- **<Holds back>:** <...>
- **<Options>:** <only when they can be listed>
- **<Recommendation (the writer's, not a decision)>:** <optional>
- **<From>:** <...>
- **<Answer>:** <left empty: answer · who · date>

### Needed before release
<Questions in the same shape, or "None".>

### Doesn't block
<Questions in the same shape, or "None".>

## Rules
### <Stage of the path, such as "Starting a cancellation">
- R1. **<Short name>:** <One rule, one sentence plus at most one qualifier.> (<source>)

## Cases
| # | Situation | What the person sees and what happens | Basis |
|---|---|---|---|
| 1 | <A concrete situation with dates and amounts. Mark invented values as examples.> | <The result computed from the rules, or "not decided" and the question.> | <R- and Q-IDs> |

- Turning it off: <How the change can be switched off and what people see then. Only when it applies.>
- What can't be undone: <Such as money already paid out. Only when it applies.>

## Policies
| Policy and clause (owner) | What it requires here | Where this spec stands | How it will be checked |
|---|---|---|---|
| <ID §n (team, name)> | <The requirement, with its numbers as written> | <Rule IDs that meet it, or the question it raises> | <Case numbers, or "<name> reviews <what> before release"> |

Read and not applicable: <Each policy you read that doesn't apply, with a few words on why.>

## How we will know it worked
| Desired outcome (intent) | Rules | How someone other than the writer checks it | Baseline → target |
|---|---|---|---|

## Left to engineering
- <A choice nobody outside engineering would notice, and the rules or questions it must respect.>

## Facts and sources
- <A fact the spec relies on, in plain words.> `<file path>` (<verified in code | stated in a comment or document, not verified; confirmer>)
- Not found: <What you searched for and didn't find, and the question that depends on it.>

## Terms
- **<Term>:** <What it means in this spec, in plain words. Name the policy that defines it, if one does.>

## Decision log
- Q<n> (<short name>): <the answer>. <Who decided>, <YYYY-MM-DD>, <where it was given>.
```

## Notes on each section

**Header.** `Status:` is `Draft`, `Accepted (<name>, <date>)`, or `Superseded by: <file name>`, followed by the counts of open questions and of those that block planning. `Verified against` names the commit the facts were read from, so the technical lead knows what to recheck if the code moves while the spec is in review.

**Summary.** Write it in your own words, not the intent's. The originator reviews this paragraph, and a misreading shows up only in your own words. Keep numbers, names, and dates as the intent gives them.

**Scope.** Take it from the intent, with the intent's reasons. "At the edges" lists, without widening the scope, people or channels the scope excludes that a policy or a fact still reaches. An example is a customer who signed up in an app the intent leaves out, when a policy says customers cancel where they signed up.

**Reviewers.** This table is the only index of the open questions. Every open question appears in the row of each person who answers or confirms it. Take names from the intent, the policy documents, or the workspace; never guess one. Each row tells a reviewer what to read without reading everything.

**What the user experiences.** This is the path a non-engineer can check against the intent, and on which a policy owner can count steps. It holds only decided behavior and the forks where open questions split it.

**Open questions.** Keep the three class headings in this order, with "None" under an empty one. Put the question that holds back the most first within each class. See open-questions.md for the fields and the classes.

**Rules.** One rule per item, grouped by stage. The source at the end is one of: an intent section; a policy ID and clause; "Q<n> answer, <name>, <date>"; or "derived from <sources>: <the one-line reasoning>". A rule that an open question holds back says so, as in "(the end date is open: Q1 (end of service))".

**Cases.** The acceptance set: each row is a situation and the result a reviewer can check by hand. Include the boundary on each side of every threshold, repeats, and failures, with what the person sees. A row whose result depends on how a policy's words are read names the question about that reading.

**Policies.** One row per applicable clause, including clauses of policies the intent doesn't cite. A conflict is raised as an open question and named in "Where this spec stands"; don't describe it a second time here.

**How we will know it worked.** One row per desired outcome in the intent. The check is something a person other than the writer does or looks at: cases to reproduce, records to count, a share to compare with its baseline.

**Left to engineering.** Only choices nobody outside engineering would notice. Screen copy and layout aren't among them. If nobody is named to design the screens, ask the product owner.

**Facts and sources.** The single list the technical lead confirms. File paths and code names appear only here and in the Intent line.

**Terms.** Only words a policy defines, words specific to this change, and words with tempting synonyms. Define what a thing is, not what it does.

**Decision log.** Omit it until the first answer. It is an index: the decision itself lives in the rules and cases it changed.

## Korean headings and labels

Use these for the parts in the intent's language. The labels of the three parts of an open question are the requester's own words; keep them exactly.

| English | Korean |
|---|---|
| Spec: | Spec: |
| Intent: | Intent: |
| Status: Draft · N open questions, M block planning | 상태: 초안 · 미결정 사항 N건, 계획을 막는 것 M건 |
| Accepted (name, date) | 승인됨 (이름, 날짜) |
| Verified against | 확인한 저장소 버전 |
| Summary | 요약 |
| Scope | 범위 |
| In / Out / Unchanged / At the edges | 포함 / 제외 / 그대로 유지 / 범위 경계 |
| Reviewers | 검토자 |
| Role / Who / What to check / Questions to answer or confirm | 역할 / 누구 / 확인할 것 / 답하거나 확인할 질문 |
| Originator / Product owner / Policy owner / Technical lead / Engineers | 원 작성자 / 제품 책임자 / 정책 소유자 / 기술 리드 / 엔지니어 |
| What <the customer> experiences | <고객>이 겪는 흐름 |
| Open questions | 미결정 사항 |
| Blocks planning / Needed before release / Doesn't block | 계획을 막음 / 출시 전 필요 / 막지 않음 |
| What is unclear | 무엇이 불명확한가? |
| What changes depending on the answer | 그 답에 따라 무엇이 달라지는가? |
| What would resolve it | 무엇을 확인하거나 결정하면 해결되는가? |
| Who answers | 답할 사람 |
| Holds back | 막는 것 |
| Options | 선택지 |
| Recommendation (the writer's, not a decision) | 작성자 제안 (결정 아님) |
| From | 출처 |
| Answer (answer · who · date) | 답변 (답 · 답한 사람 · 날짜) |
| Rules | 규칙 |
| Cases | 경우별 결과 |
| Situation / What the person sees and what happens / Basis | 상황 / 보이는 것과 일어나는 일 / 근거 |
| Turning it off / What can't be undone | 끄는 방법 / 되돌릴 수 없는 것 |
| Policies | 정책 |
| Policy and clause (owner) / What it requires here / Where this spec stands / How it will be checked | 정책·조항 (소유자) / 이 작업에 요구하는 것 / 이 spec의 처리 / 확인 방법 |
| Read and not applicable | 읽었으나 해당 없음 |
| How we will know it worked | 완료 확인 방법 |
| Desired outcome (intent) / How someone other than the writer checks it / Baseline → target | 원하는 결과 (intent) / 작성자가 아닌 사람이 확인하는 방법 / 기준값 → 목표 |
| Left to engineering | 엔지니어에게 맡기는 것 |
| Facts and sources | 사실과 출처 |
| verified in code / stated in a comment or document, not verified | 코드에서 확인함 / 주석이나 문서의 주장, 확인하지 않음 |
| Not found | 찾지 못함 |
| derived from | 도출 |
| Terms | 용어 |
| Decision log | 결정 기록 |
| None | 없음 |
