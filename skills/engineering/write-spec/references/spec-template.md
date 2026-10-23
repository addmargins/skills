# Spec template

Use these headings in this order and replace each note in angle brackets. SKILL.md step 5 says what goes in each section. Keep the headings and header lines in English. Write field labels and table headers in the intent's language; a Korean spec uses the labels at the end.

```markdown
# Spec: <What will be true once this is built, named after the outcome, not a means>

Intent: [<intent file name>](../intents/<intent file name>)
Status: Draft · <N> open questions, <M> block planning
Verified against: <commit short hash the facts were read from, or "workspace as of YYYY-MM-DD">, <YYYY-MM-DD>
Supersedes: <earlier spec file name, only when a new intent superseded the earlier spec's intent>

## Summary
<Three to five sentences in your own words: what is wrong today, what will be built and for whom, any fixed date from a source, and the most consequential open questions.>

## Scope
- In: <From the intent.>
- Out: <From the intent, with its reason when it gives one.>
- Unchanged: <Existing behavior that must keep working, with the intent's reason.>
- At the edges: <People or channels outside the scope that a policy or a fact still reaches, and who should settle each.>

## Reviewers
| Role | Who | What to check | Questions to answer or confirm |
|---|---|---|---|
| Originator | <from the intent> | Does this spec solve the problem the intent describes? Was anything dropped or narrowed? | |
| Product owner | <from the intent or workspace> | Scope and product behavior; routes each policy conflict to its owners | |
| Policy owner: <policy ID> | <owner the policy names> | The <policy ID> rows under Policies | |
| Technical lead | <name, or "not named; the product owner assigns one"> | Facts and sources, Left to engineering | |
| Engineers | <name, or "not named"> | Can the work be planned without deciding product behavior? | |

## What <the main user> experiences
1. <What the person sees, then what they do. One action per step, with its source. Where an open question splits the path, show each branch and name the question.>

## Open questions

### Blocks planning
#### Q1. <Short name>
- **<What is unclear>:** <...>
- **<What changes depending on the answer>:** <...>
- **<What would resolve it>:** <...>
- **<Holds back>:** <...>
- **<Options>:** <only when they can be listed>
- **<Recommendation (the writer's, not a decision)>:** <optional>
- **<Answer>:** <left empty: answer · who · date>

### Needed before release
<Questions in the same shape, or "None".>

## Rules
### <Stage of the path>
- R1. **<Short name>:** <One rule.> (<source>)

## Cases
| # | Situation | What the person sees and what happens | Basis |
|---|---|---|---|
| 1 | <Concrete dates and amounts; invented values marked as examples> | <Computed from the rules, or "not decided" and the question> | <IDs> |

- Turning it off: <only when it applies>
- What can't be undone: <only when it applies>

## Policies
| Policy and clause (owner) | What it requires here | Where this spec stands | How it will be checked |
|---|---|---|---|

Read and not applicable: <Each policy you read that doesn't apply, and why.>

## How we will know it worked
| Desired outcome (intent) | How someone other than the writer checks it | Baseline → target |
|---|---|---|

## Left to engineering
- <A choice nobody outside engineering would notice, and the rules or checks that bound it.>

## Facts and sources
- <A fact in plain words.> `<file path>` (<verified in code | stated in a comment or document, not verified; confirmer>)
- Not found: <What you searched for and didn't find, and the question that depends on it.>

## Terms
- **<Term>:** <What it is, in plain words, and the policy that defines it, if one does.>
```

## Korean labels

The three parts of an open question are the requester's own words. Keep them exactly.

| English | Korean |
|---|---|
| In / Out / Unchanged / At the edges | 포함 / 제외 / 그대로 유지 / 범위 경계 |
| Role / Who / What to check / Questions to answer or confirm | 역할 / 누구 / 확인할 것 / 답하거나 확인할 질문 |
| Originator / Product owner / Policy owner / Technical lead / Engineers | 원 작성자 / 제품 책임자 / 정책 소유자 / 기술 리드 / 엔지니어 |
| What is unclear | 무엇이 불명확한가? |
| What changes depending on the answer | 그 답에 따라 무엇이 달라지는가? |
| What would resolve it | 무엇을 확인하거나 결정하면 해결되는가? |
| Holds back | 막는 것 |
| Options | 선택지 |
| Recommendation (the writer's, not a decision) | 작성자 제안 (결정 아님) |
| Answer (answer · who · date) | 답변 (답 · 답한 사람 · 날짜) |
| Situation / What the person sees and what happens / Basis | 상황 / 보이는 것과 일어나는 일 / 근거 |
| Turning it off / What can't be undone | 끄는 방법 / 되돌릴 수 없는 것 |
| Policy and clause (owner) / What it requires here / Where this spec stands / How it will be checked | 정책·조항 (소유자) / 이 작업에 요구하는 것 / 이 spec의 처리 / 확인 방법 |
| Read and not applicable | 읽었으나 해당 없음 |
| Desired outcome (intent) / How someone other than the writer checks it / Baseline → target | 원하는 결과 (intent) / 작성자가 아닌 사람이 확인하는 방법 / 기준값 → 목표 |
| verified in code / stated in a comment or document, not verified | 코드에서 확인함 / 주석이나 문서의 주장, 확인하지 않음 |
| Not found / derived from / None | 찾지 못함 / 도출 / 없음 |
