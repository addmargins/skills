# write-spec test plan (round 6)

Paths are relative to `evals/write-spec/`. `IT5` is the skill-creator iteration-5 output, which was not kept. Its Korean spec survives byte-for-byte as `fixtures/t1-acme-revise/docs/specs/0007-annual-plan-self-cancel.md`; its English spec is `fixtures/t7-ledgerly-answers/docs/specs/0003-monthly-invoice-export.md` with the three answer lines empty and `Verified against` dated 2026-10-23. Skill source (read-only): `skills/engineering/write-spec` at the repo root. Fixture notes, final prompts and assertions per run are in cases.md, which wins where it differs from this plan. `[S]` = graded by script, `[L]` = graded by an LLM grader.

## 1. Risk ranking
1. **Revision closes questions it must not.** A partial two-owner answer, a PO answering for finance, or "accept it" with blockers open would put a guess on record under someone's name. revising.md has never run.
2. **IDs drift on revision.** Step 6 says "you may renumber while you apply findings", and revising.md reruns step 6, so the permission can leak into revisions and break plans that cite R9.
3. **The superseding-intent path is unreachable and contradicts itself.** Step 1 only looks for a same-name spec, so revising.md's `Supersedes:` rule never fires. Step 7 forbids touching earlier specs; revising.md requires adding `Superseded by:`. Owner answers in the old spec can be lost.
4. **Too many questions, too many blocking.** 17/20 Korean questions block planning ("when unsure, choose blocking"), so the spec can't be accepted. The fix hasn't been re-run; n=1.
5. **Real fresh readers never ran.** Untested: intent or notes leaking into reader prompts, findings resolved by picking a default, padding coming back (the iteration-4 regression), and 3 readers × 3 rounds of time.
6. **Non-engineers may not find or answer their questions.** Specs are 32–62 KB; 이수민 is named in 10 of 20 Korean questions, some only "if option b". Only graders have judged readability.
7. **Simple intents get over-built.** No fixture lacks policies. Risks: padded questions, invented policy rows, CLAUDE.md coding rules turned into product rules, length that doesn't shrink.
8. **Step-1 gates with the user away.** A multi-outcome intent may stop to ask (no spec) or silently pick one; with no argument, the skill may pick an intent itself.
9. **Facts and arithmetic never machine-checked.** Cited paths and computed refund amounts. A wrong case row becomes a wrong test in the plan.
10. **Real repos are noisy and large.** Policies sit outside `docs/policies/` or only link off-repo; AGENTS.md mixes code style with rules; the skill's own folder sits in `.claude/skills/`.
11. **Upstream doesn't name owners.** clarify-intent's template has no author or owner line, so real intents name no originator or PO (the Korean fixture did). New fixtures use the template exactly.

## Harness (every run)
- **Executor:** a subagent that runs `claude -p` through Bash. Subagents can't spawn subagents; `claude -p` can.
- **Setup:** `bin/setup_run.sh` copies the fixture to `.runs/<id>/repo`; copy only `SKILL.md` and `references/` into `repo/.claude/skills/write-spec/` (never `evals/`: iteration-4 runs listed it, and its file names hint at the checks); `git add -A && git commit -qm base`.
- **Command** (`bin/run_claude.sh`; cases.md has its final form): `timeout 3600 claude -p "<prompt>" --output-format stream-json --verbose --allowedTools "Read Write Edit Glob Grep Bash Agent Skill" > ../t1.jsonl`, run in `repo`. Later turns: `claude -p --resume <session_id> "<msg>"`. The skill sets `disable-model-invocation: true`, so with-skill prompts start with `/write-spec`. **Baseline:** no `.claude/skills/`, plain-language prompt.
- **`score.py`:** `ids` (each Q/R ID defined once; Reviewers-table Qs = Open-questions Qs; Status counts match); `3parts` (each question has its three fields, non-empty); `leak` (no backticks, paths or camelCase outside Facts and sources; no "write-spec", "SKILL", "fresh reader", "workspace"); `paths` (each path in Facts and sources exists at the base commit); `draft` (extracts the first Write of the spec from the transcript, i.e. the pre-reader draft).
- **G-L litmus audit:** measures the acceptance bar's litmus test directly. A fresh agent with only the spec lists every behavior, message, number, date, condition or policy application it would have to decide that the spec neither states nor raises as an open question. A judge with the full fixture classifies each: genuine gap, settled by the spec, or engineering-only.

## 2. Test cases (priority order)

### T1 revise-relayed-answers-ko: revision and owner checks (risks 1, 2)
**Purpose:** answers must reach the spec without guesses becoming decisions. Covers owner check, two-owner partial answer, proxy answer, apply-everywhere, moot question, ID stability, Decision log, scope change, accept-with-blockers, policy-reading suggestion.
**Fixture:** `fixtures/acme-subscriptions`, plus `$IT5/flags-policy-conflicts-korean/with_skill/outputs/docs/specs/0007-annual-plan-self-cancel.md` committed under `docs/specs/` (Q1–Q20, 17 blocking; R1–R21).
**Prompt:**
```
/write-spec docs/intents/0007-annual-plan-self-cancel.md
리뷰 답 모아 왔어. 반영해 줘. (나는 구독 PO 김도윤)
1. Q1: 내 결정. (a) 확정 즉시 서비스 종료.
2. Q9: 재무팀 이수민 님이 메일로 답함. (1) a, (2) a 그리고 a, (3) a.
3. Q2: 법무팀 최현우 님 의견: "별도 리텐션 화면 자체는 §4 위반이 아니다." 마케팅 정하늘 님은 아직 답 없음.
4. Q7: 실결제 기준 (a)로 하자. 이수민 님도 같은 생각일 거야.
5. 이번에 모바일 앱 해지도 범위에 넣자.
다 반영되면 승인 처리해 줘.
```
**Configuration:** with skill, `claude -p`. No baseline: the base model has no ID or Decision-log convention to compare against.
**Grading:** score.py checks 1, 2, 7; one Korean-reading LLM grader (old spec, new spec, diff, final message) checks 3–8.
**Assertions:**
1. [S] The spec is edited in place, no other spec file is created, and `git diff --exit-code docs/intents docs/policies` passes.
2. [S] Every Q/R heading existed before with the same short name, or takes a number above the old maximum (Q21+, R22+). Q1 and Q9 are gone and their numbers aren't reused; other surviving questions keep their numbers.
3. [L] Q1 and Q9 are gone from Open questions and the Reviewers table. Q1's answer lands in R8, R11, steps 4/6/7 and cases 1–13; Q9's in R10, R11 and cases 3, 5, 6, 13. Each cites "Q<n> answer, <name>, 2026-10-23". The Decision log has one line each; Q9's names 이수민 and 김도윤 (who relayed it).
4. [L] Q2 stays open under Blocks planning with 최현우's statement recorded as input. The walkthrough keeps both branches; nothing in Rules or the Decision log treats Q2 as decided.
5. [L] Q7 stays open, addressed to 이수민, with 김도윤's preference recorded as input under his name. R11 and cases 10–11 still cite Q7.
6. [L] The mobile app stays under 제외. A new question (new ID) says the intent must first be revised with clarify-intent. No rule or step covers app cancellation.
7. [S+L] Status still reads Draft with matching counts. The final message declines to accept and lists the blocking questions with owners.
8. [L] Q16 (withdrawal, which applies only if Q1 is (b) or (c)) is closed as moot, citing Q1, not left open unchanged. The spec or final message suggests 이수민 record the Q9 reading in FIN-REF-03.

### T2 real-fresh-readers: the three-reader path, for real (risk 5)
**Purpose:** readers are the skill's main defense against a writer filling gaps unseen; they have only ever been simulated.
**Runs:** five with-skill `claude -p` runs, shared with T3: Korean (`fixtures/acme-subscriptions`) ×3 with `/write-spec docs/intents/0007-annual-plan-self-cancel.md 나는 구독 PO 김도윤이고, 오늘은 질문에 답할 시간이 없어.`, and English (`fixtures/ledgerly`) ×2 with `/write-spec docs/intents/0003-monthly-invoice-export.md I'm heading into back-to-back meetings today, so don't wait on me for answers.`
**Grading:** score.py checks 1–3 and 6 from `t1.jsonl`; an LLM grader checks 4–5.
**Assertions (each run):**
1. [S] Round 1 has ≥3 subagent calls (implementer, originator, policy reader) in one assistant message.
2. [S] Reader prompts hold only the files fresh-readers.md allows: implementer the spec path only; originator intent + spec; policy reader spec + every `docs/policies/` file (all 4 in Korean, including PRIV-07). No code path or code summary.
3. [S] At most 3 rounds; each later round includes an implementer; the run finishes within 60 min.
4. [L] In the diff from draft (`draft`) to final, every added or changed rule cites a source and no new number, limit or wording lacks one. Each added question passes the step-4 check (the judge has the fixture).
5. [L] The final message says what readers changed and what the last round raised but wasn't applied; it doesn't say no fresh reader ran.
6. [S] Neither Policies nor Facts and sources lists anything under `.claude/skills/`.

### T3 variance-and-classification: 5 runs of the current skill (risks 4, 9)
**Purpose:** one or two runs per config can't tell drift from noise; the 17/20 blocking share and the later routing of intent-carried questions haven't been re-run.
**Runs:** the same 5 as T2, regraded with the existing `evals/*/graders` (English grader 11 in its clarified wording).
**Grading:** existing graders; one LLM grader per run for 2, 5, 6; G-L with its judge folded into that grader; score.py for 4. Report time and tokens per run.
**Assertions:**
1. [L] Korean runs pass ≥11/12 existing assertions, English runs ≥10/11; no assertion fails in 2+ runs.
2. [L] Classifying each question by open-questions.md's own definitions, none that changes only wording, a notice, a label, or a slot value sits under Blocks planning. Blocking share ≤70% in each Korean run (report draft vs final share to separate drafting from reader effects).
3. [L] All 3 Korean runs raise the core gaps: retention offer vs LEG-2026-14 (both owners), the 180-day gateway limit, pending approval, when service ends, promotion refund basis, partial-month counting. Both English runs raise: time zone, void invoices, the finance:export grant, the admin wildcard.
4. [S] Open-question count spread (max − min) ≤5 across Korean runs, ≤3 across English runs.
5. [L] No run settles a two-way policy clause as a rule: FIN-REF-03 §2 "1개월 미만", FIN-REF-03 §5 (formula refunds as pre-approved), SEC-04 §1 vs the admin "*" role.
6. [L] Every Korean case row with a refund amount recomputes correctly from FIN-REF-03 §2 under the reading it names (grader recomputes in Python).
7. [L] G-L finds no confirmed genuine gap touching money, personal data or a legal obligation in any run, and ≤1 other.

### T4 simple-intent-shelfdesk: low ambiguity, no policies, answer loop, acceptance (risks 7, 11, 1)
**Purpose:** a short, settled intent should yield a short spec with no padding or invented constraints. Also the only test of the in-session answer loop and of a successful acceptance.
**Fixture:** new `fixtures/shelfdesk` (git repo):
- `README.md`: "shelfdesk: circulation desk app for Riverside Public Library. `receipts/` prints loan receipts on the desk's 58 mm printer (32 characters per line). `loans/` computes due dates."
- `CLAUDE.md`: "- Use pnpm. - Tests sit next to the file as *.test.ts. - Never commit secrets."
- `loans/loan.ts`: `type ItemType = "book" | "dvd" | "reference"`; `dueDate(type, checkedOutAt): string | null` gives the local date YYYY-MM-DD (books 21 days, DVDs 7, reference `null`), commented "reference items may be borrowed for in-library use; no due date".
- `receipts/print.ts`: `receiptLines(items, at)` returns library name, date, one title per line (cut to 32 characters), then "Thank you!".
- `docs/intents/0005-due-date-on-receipt.md` (clarify-intent template exactly, no author). Problem: receipts list titles only, so staff hand-write due dates and members return items late. Outcome: every receipt shows "Due: YYYY-MM-DD" under each title; staff stop hand-writing due dates. Affected: members, desk staff; `receipts/print.ts`, `loans/loan.ts`. Scope: in, the printed loan receipt; out, email receipts, the member app, loan periods. Constraints: fit 32 characters per line (printers can't be replaced this year); existing lines keep their order. Open questions: None.
- No `docs/policies/`. The only genuine gap: reference items have no due date.

**Prompts (one session):** (1) `/write-spec docs/intents/0005-due-date-on-receipt.md I'm Dana Okafor, product owner for the desk app.` (2) `Sure, ask me my questions.` (3) `Print "In-library use only" on that line instead of a date.` (if turn 2 asks something else, answer that in plain words) (4) `Looks right. Accept it.`
**Configuration:** with skill, `claude -p`, all four turns; baseline `claude -p` turn 1 only: `Write a spec for docs/intents/0005-due-date-on-receipt.md. I'm Dana Okafor, product owner.` Metrics (not pass/fail): length and question count vs baseline; whether the baseline decides the reference-item line itself.
**Grading:** score.py checks 1, 5, 6, 7; an LLM grader checks 2, 3, 4, 6; G-L for 8.
**Assertions:**
1. [S] After turn 1 the spec is ≤120 lines and ≤12 KB (iteration-5 English: 214 lines, 32 KB).
2. [S+L] Exactly one open question, not under Blocks planning, about items with no due date.
3. [L] No Policies row, rule, or Left-to-engineering line draws on anything outside the fixture (no invented GDPR, accessibility or brand rules); no CLAUDE.md line appears as a rule or policy.
4. [L] "Due: YYYY-MM-DD", the 32-character limit with its reason, the line order, and all 3 out-of-scope items appear as the intent gives them. No rule decides what a reference item prints before turn 3.
5. [S] Turn 2 asks exactly one question, as lettered options one per line, built from that question's options.
6. [S+L] After turn 3: the question is gone; the rule and case cite "Q1 answer, Dana Okafor, 2026-10-23"; the Decision log has that line; Status reads "Draft · 0 open questions, 0 block planning".
7. [S] After turn 4, Status reads "Accepted (Dana Okafor, 2026-10-23)".
8. [L] G-L finds no genuine gap.

### T5 stakeholder-roleplay: can non-engineers find and answer their questions (risk 6)
**Purpose:** the acceptance bar requires non-engineer reviewers to understand the spec and answer their own questions; so far only graders have judged that.
**Specs:** the `$IT5` Korean (0007) and English (0003) specs; repeat on a T3 Korean spec if T3 changes its shape.
**Role-players:** 6 subagents with no code or conversation; only originators get the intent. Korean: 박지은 (originator), 이수민 (FIN-REF-03), 최현우 (LEG-2026-14), 정하늘 (MKT-RET-02). English: M. Weber (SEC-04), the finance lead who wrote the intent. Each persona card adds 3–4 private stances to answer from, e.g. 이수민: payment day is day 1, same date next month is exactly 1 month, promotions refund on amount paid, refunds over 100,000원 approved within 2 business days. 정하늘: an offer inside the confirm screen is not acceptable. Weber: the finance role gets finance:export; admins don't count.
**Procedure:** Stage A: given only the spec from the top through the Reviewers table, list your question IDs and the sections you must review. Stage B: given the full spec, answer each question; mark each answerable from the question alone (yes, or what's missing); quote each sentence outside Facts and sources you couldn't understand without an engineer; list any rule in your domain that settles something nobody asked you.
**Grading:** score.py checks 1–2; one LLM judge over all transcripts checks 3–6. No executor runs.
**Assertions:**
1. [S] Each Stage-A list matches the questions whose "what would resolve it" names that person (parsed from the spec).
2. [S] Each person marks ≥90% of their questions answerable from the question alone.
3. [L] ≥90% of answers map to exactly one listed option, or to a concrete value a reviser could apply without a follow-up.
4. [L] ≤2 sentences per person flagged as needing an engineer, none inside a question addressed to them.
5. [L] No role-player finds a settled rule in their domain that their policy's words don't settle (the judge has the policy).
6. [L] Neither originator finds an intent item dropped or narrowed that the judge confirms.

### T6 supersede-intent: a superseding intent, and decisions in the old spec (risk 3)
**Purpose:** clarify-intent produces superseding intents by design, and decisions owners already gave must survive.
**Fixture:** `fixtures/ledgerly`, plus:
- `docs/intents/0003-monthly-invoice-export.md`: add `Superseded by: 0004-monthly-invoice-and-credit-note-export.md` after the title.
- `docs/intents/0004-monthly-invoice-and-credit-note-export.md`: 0003's text plus `Supersedes: 0003-monthly-invoice-export.md`. In scope adds "credit notes issued in that month, one row each, with negative amounts"; credit notes leave Out of scope.
- `docs/specs/0003-monthly-invoice-export.md`: the `$IT5` English spec, hand-revised per revising.md: Q1 "(a) grant finance:export to the finance role · M. Weber · 2026-10-20 · email"; Q3 "(a) Berlin time · Lena Vogel (product owner) · 2026-10-21 · review meeting". Both leave Open questions and Reviewers; R1 and R3 cite them; a two-line `## Decision log`; Status "Draft · 7 open questions, 4 block planning".

**Prompt:** `/write-spec docs/intents/0003-monthly-invoice-export.md Lena here, product owner. Please bring the spec up to date; I can't answer anything today.`
**Configuration:** with skill, `claude -p`.
**Grading:** score.py checks 2–3; an LLM grader checks 1, 4, 5.
**Assertions:**
1. [L] The final message says 0003 is superseded and that 0004 was used.
2. [S] `docs/specs/0004-monthly-invoice-and-credit-note-export.md` exists with `Supersedes: 0003-monthly-invoice-export.md` in its header and Status Draft.
3. [S] The only change to the old spec is one `Superseded by: 0004-…` paragraph right after the title; both intents unchanged.
4. [L] Weber's and Vogel's answers each appear in the new spec as the cited source of a rule (name, date) or inside an open question that cites the earlier answer; neither is lost or turned into an unsourced rule.
5. [L] The missing credit-note field on invoices is raised as a question that blocks planning or a fact the technical lead confirms; no rule invents how credit notes are identified.

### T7 revise-in-file-answers-en: "spec exists" gate, answers on the answer lines (risks 1, 2)
**Purpose:** the second answer channel (owners fill answer lines), and the gate that revises an existing spec rather than rewriting it, in English.
**Fixture:** `fixtures/ledgerly` plus the `$IT5` English spec at `docs/specs/0003-monthly-invoice-export.md`, committed with answer lines filled: Q2 "(b) No · M. Weber · 2026-10-22"; Q3 "(a) Berlin time · Lena Vogel · 2026-10-22"; Q7 "(a) include voided invoices · Jonas Krüger (accountant) · 2026-10-22".
**Prompt:** `/write-spec docs/intents/0003-monthly-invoice-export.md Answers are on the answer lines in the spec. Lena Vogel is the product owner for this work.`
**Configuration:** with skill, `claude -p`.
**Grading:** score.py checks 1, the grep in 4, and 5; an LLM grader checks 2, 3, and the rulings in 4.
**Assertions:**
1. [S] The same file is revised, no new spec, intent unchanged. Q4–Q9 keep their numbers and short names; no new ID ≤ the old maximum.
2. [L] Q2 and Q3 are closed and applied (Q2: R1, case 5; Q3: R3, R4, cases 6–7) citing "Q<n> answer, <name>, 2026-10-22"; the Decision log says they came from the answer lines.
3. [L] Q7 stays open (its owner is the product owner, not an accountant), with Krüger's answer as input.
4. [S+L] No surviving text treats Q2 or Q3 as open; a script greps each mention and the judge rules on each hit (e.g. Q8's "the time zone that Q3 settles").
5. [S] The Reviewers table names Lena Vogel as product owner and lists exactly the open questions; Status counts match.

### T8 step1-gates: no argument; several outcomes with the user away (risk 8)
**Runs:** two short with-skill `claude -p` runs. T8a doubles as harness preflight: it confirms the slash command loads the skill and the init event lists the subagent tool (Agent or Task). If either fails, fix the harness before other runs.
- **T8a fixture:** `fixtures/ledgerly` plus `admin/docs/intents/0001-bulk-mark-paid.md` (any valid intent) and `docs/intents/0002-invoice-csv.md` marked `Superseded by: 0003-monthly-invoice-export.md`. **Prompt:** `/write-spec`
- **T8b fixture:** `fixtures/ledgerly` plus `docs/intents/0005-month-end-close-tools.md` (clarify-intent template, no author) with two outcomes that each work alone: (1) accountants mark many invoices paid at once from a bank-statement file; (2) a customer whose invoice is 7 days overdue gets an automatic reminder email. **Prompt:** `/write-spec docs/intents/0005-month-end-close-tools.md I'm out until Monday and nobody else can answer. Don't wait for me.`

**Grading:** score.py checks 1, 3; an LLM grader checks 2, 4, 5.
**Assertions:**
1. [S] T8a creates or changes no file.
2. [L] T8a's reply is one choice question with lettered options, one per line, covering intents in both `docs/intents/` folders; 0002 is left out or shown as superseded by 0003; no spec content is drafted.
3. [S] T8b saves a spec at `docs/specs/0005-month-end-close-tools.md` in the same turn.
4. [L] In T8b, Q1 is the first question under Blocks planning: it asks which outcome(s) this spec covers, is addressed to the originator (marked not named), and offers each outcome alone and both together.
5. [L] In T8b, both outcomes appear in the walkthrough or rules, or are explicitly held back by Q1; neither is silently dropped. SEC-04 is applied, or listed as read and not applicable with a reason.

### T9 large-real-repo: documenso v2.9.1 (risk 10)
**Purpose:** the skill will run in real repos; every fixture so far has 5–15 files.
**Fixture:** `git clone --depth 1 --branch v2.9.1 https://github.com/documenso/documenso`. Checked 2026-10-23: 2,546 files; AGENTS.md is build and code-style guidance only; `apps/docs/content/docs/policies/privacy.mdx` only links to documenso.com/privacy, while `compliance/gdpr.mdx` and `esign.mdx` have substance (ESIGN record retention); `packages/lib/constants/envelope-reminder.ts` sets default reminders first after 5 days, then every 2 days; the sweep reminds only NOT_SIGNED, non-CC recipients of PENDING documents, and REJECTED is a separate status.
Add `docs/intents/0001-recipient-stops-reminders.md` (clarify-intent template, no author). Problem: recipients who won't sign keep getting reminders, by default every 2 days; some mark them as spam, hurting delivery from our domain. Outcome: from a reminder email, a recipient stops further reminders for that one document without signing or rejecting; the sender sees it on the document. Out of scope: the original signing request, unsubscribing from all email, the default timing. Constraints: must not change signed documents' audit trail (it's legal evidence); must follow "our published privacy policy" (no path given). Open question: may the sender turn reminders back on? The builder checks each claim against the commit before the run.
**Prompt:** `/write-spec docs/intents/0001-recipient-stops-reminders.md Nobody is around to answer today.`
**Configuration:** with skill, `claude -p`, 90-min timeout.
**Grading:** score.py checks 1–2; an LLM grader checks 3–5; G-L for 6.
**Assertions:**
1. [S] Finishes within 90 min; spec saved; nothing outside `docs/specs/` changed.
2. [S] Every path in Facts and sources exists at the commit; the 5-day and 2-day defaults cite `envelope-reminder.ts`.
3. [L] The spec finds the in-repo privacy page without being given a path. It records that the page only links off-repo, invents none of its content, and names who confirms what it requires (a question or a Not found line).
4. [L] No rule, Policies row, or Left-to-engineering line comes from AGENTS.md's build or code-style guidance, `.agents/plans/`, or `.claude/skills/`.
5. [L] The intent's open question is carried forward; every person named appears in a repo source; owners nobody named are marked "not named".
6. [L] G-L confirms ≤1 genuine gap, none about personal data or the audit trail.

## 3. Budget
| Test | Executor runs | Other agent runs |
|---|---|---|
| T1 | 1 | 1 grader |
| T2 + T3 (shared runs) | 5 | 5 graders, 5 G-L auditors |
| T4 | 2 (with skill: 4 turns) | 2 graders, 2 G-L auditors |
| T5 | 0 | 6 role-players, 1 judge |
| T6 | 1 | 1 grader |
| T7 | 1 | 1 grader |
| T8 | 2 | 1 grader for both |
| T9 | 1 | 1 grader, 1 G-L auditor |
| **Total** | **13** | **27** |

**Order:** Wave 0: build fixtures (no agents), run T8a as preflight (~5 min), start the T5 role-players (they only need `$IT5`). Wave 1, in parallel with ≤8 `claude -p` at once: T2/T3 ×5, T9, T1, T6. Wave 2, as slots free: T4 (turns 2–4 in sequence via `--resume`), T4 baseline, T7, T8b. Graders and G-L audits start as each run finishes. The longest runs are the Korean real-reader runs (est. 30–45 min) and T9; wall time ≈ 1.5–2 h.

## 4. Pass criteria
**Ready when all hold:**
- T1, T6, T7, T8 pass every assertion. These check rule-following, so one failure is a defect, not noise.
- T2 passes 1–3 and 6 in ≥4/5 runs and 4 in 5/5 (no reader finding ever becomes an unsourced rule). T3 passes 1–7, with Korean blocking share ≤70% in every run.
- T4 passes 1–8, and the with-skill spec is ≤1.5× the baseline's length. T9 passes 1–6. In T5, ≥5/6 role-players pass 1–4, and all pass 5–6.

**A specific change is needed when:**
- **T1/T7 closes a question on a partial or relayed answer:** revising.md should say a relayed or proxy answer is input only (T1's Q7 as example), and step 6 should check it on revisions.
- **A surviving ID is renumbered:** limit step 6's "you may renumber" to the first draft, and say so in revising.md.
- **Accepted with blocking questions open:** repeat the acceptance condition in SKILL.md step 7, not only in revising.md.
- **T6 lacks `Supersedes:`, doesn't mark the old spec, or edits more than one line:** add a step 1 check ("if the intent has `Supersedes:` and the old intent has a spec, follow revising.md's superseding rule") and name that exception in step 7's "don't modify earlier specs". If decisions were lost, say answers in a superseded spec are sources to carry forward or re-ask.
- **T3 fails 2 (notice or label questions under Blocks planning, or share >70%):** give open-questions.md a decision test ("could planning leave this as a slot?"), and limit "when unsure, choose Blocks planning" to questions that change a flow, who qualifies, an amount, the data kept, or a policy requirement.
- **T3 fails 3 or 4:** the step 3 sweep is unreliable; add the missed kinds of gap to its list.
- **T2 fails 2 or 4:** fresh-readers.md should pass file paths only, never a summary; step 6 should apply a finding only as a sourced rule or a question. Runs over 60 min: limit rounds 2–3 to the implementer.
- **T4 too long, >1 question, or invented policies:** step 5 should say length follows the number of decisions; step 2 should say CLAUDE.md/AGENTS.md coding conventions aren't product policy (T9 #4 confirms).
- **T5 fails:** #1, the Reviewers table must list each person's questions in full, including conditional ones ("Q16 if (b)"). #2–3, options are incomplete or "what changes" is too abstract: fix open-questions.md. #4, tighten step 5's writing rules.
- **T8a picks an intent itself, or T8b stops to ask:** fix step 1's wording for a missing argument or an absent user.
- **T9 misses the privacy page or invents its content:** step 2 should say to search the whole repo for policy, privacy, security and compliance documents, and to record an off-repo policy as not found.
