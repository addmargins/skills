# Fixtures and run directories (round 6: T1, T4, T6, T7, T8a, T8b, T9)

Paths are relative to `evals/write-spec/`. Runs live in `.runs/<id>/`, or in `$WRITE_SPEC_RUNS/<id>/` when that is set. `IT5` is the skill-creator iteration-5 output, which was not kept. Its Korean spec survives byte-for-byte as `fixtures/t1-acme-revise/docs/specs/0007-annual-plan-self-cancel.md`; its English spec is `fixtures/t7-ledgerly-answers/docs/specs/0003-monthly-invoice-export.md` with the three answer lines empty and `Verified against` dated 2026-10-23. Where this file and plan.md differ, this file wins.

Built 2026-10-23. Nothing in the skills repo was changed, and `claude` was not run. The original fixtures (`acme-subscriptions`, `ledgerly`, `onboarding`) were git repos at commits `dded288`, `b79f2e7` and `f3c15e1`. Here they are plain directories with the same files, which are also the `files/` folders of the skill's own evals. `setup_run.sh` always starts a new history, so a spec's `Verified against: b79f2e7` names ledgerly's original commit, not the run repo's base.

Each new fixture is a plain directory with no `.git`. `bin/setup_run.sh` copies it to `.runs/<id>/repo`, installs only `SKILL.md` and `references/` into `.claude/skills/write-spec/` (never `evals/`), and commits `base`. In round 6 the installed skill matched the skills repo at `5f94dfb`. Hash prefixes: SKILL.md `b2e8e83c2cdb`, revising.md `6ba031a75aa6`, open-questions.md `2b1594e218be`, spec-template.md `78fff52bf5dd`, fresh-readers.md `aba73f8e05e3`.

| Run id | Fixture | Mode | Base commit (round 6; every setup makes a new one) | Tracked files |
|---|---|---|---|---|
| t1 | `fixtures/t1-acme-revise` | with | 4c2f48d | 19 |
| t4-with | `fixtures/shelfdesk` | with | a18b300 | 10 |
| t4-base | `fixtures/shelfdesk` | without | 9d87152 | 5 |
| t6 | `fixtures/t6-ledgerly-supersede` | with | ae48f84 | 13 |
| t7 | `fixtures/t7-ledgerly-answers` | with | 89ed662 | 12 |
| t8a | `fixtures/t8a-ledgerly-gates` | with | 7f59ca2 | 13 |
| t8b | `fixtures/t8b-ledgerly-multi` | with | bc0d107 | 12 |
| t9 | output of `fixtures/t9-documenso/build.sh` | with | 5614026 | 2547 (the skill is on disk but untracked; see the T9 notes) |

Runner: `bin/run_claude.sh <run_id> <out_name> "<prompt>" [resume_session_id|CONTINUE]`, with `MODEL` optionally set. Its timeout is 5400 s; the plan gives T9 90 minutes. Later turns resume the session id that the first turn's `.meta.json` records (or pass `CONTINUE`). In these runs, "today" is 2026-10-23. If a run happens on another day, graders should read every "2026-10-23" in a citation as the run date.

---

## t1: T1 revise-relayed-answers-ko

**Fixture:** `fixtures/t1-acme-revise` = `acme-subscriptions` plus `docs/specs/0007-annual-plan-self-cancel.md`, which is a byte-for-byte copy of `$IT5/flags-policy-conflicts-korean/with_skill/outputs/docs/specs/0007-annual-plan-self-cancel.md`.

**Spec checked against the plan (no adaptation needed):** Status reads "Draft · 20 open questions, 17 block planning". Q1–Q17 are under Blocks planning, Q18–Q20 under Needed before release, and the rules run R1–R21.
- Q1 is "해지 뒤 서비스가 끝나는 때". Option (a) is "확정 즉시 서비스가 끝난다", and the product owner 김도윤 chooses. It holds back R8, R11, steps 4·6·7, cases 1–13, and Q16.
- Q9 is "날짜와 개월 수를 세는 법". Its options have three parts, and part (2) has two sub-choices (2026-04-10 = 1 month?, and 2026-01-31's first month ends 2026-02-28?), so "(2) a 그리고 a" fits. Q9 belongs to 이수민 alone and holds back R10, R11, and cases 3, 5, 6, 13.
- Q2 is "리텐션 혜택 화면과 LEG-2026-14 (정책 충돌)". 최현우 must rule on §2 and §4, 정하늘 on options (b)/(c), and 김도윤 routes it.
- Q7 is "프로모션 할인 고객의 환불 기준". It belongs to 이수민, option (a) is 실결제 기준, and it holds back R11 and cases 10–11.
- Q16 is "해지 철회 (Q1이 (b)나 (c)일 때)".
- 모바일 앱 is listed under 제외.

**Prompt (one turn):**
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

**Assertions (as in the plan, unchanged):**
1. [S] The spec is edited in place, no other spec file is created, and `git diff --exit-code docs/intents docs/policies` passes.
2. [S] Every Q/R heading either existed before with the same short name or takes a number above the old maximum (Q21+, R22+). Q1 and Q9 are gone and their numbers aren't reused. Every other surviving question keeps its number.
3. [L] Q1 and Q9 are gone from Open questions and from the Reviewers table. Q1's answer lands in R8, R11, steps 4/6/7, and cases 1–13. Q9's answer lands in R10, R11, and cases 3, 5, 6, 13. Each cites "Q<n> answer, <name>, 2026-10-23". The Decision log has one line for each, and Q9's line names both 이수민 and 김도윤 (who relayed it).
4. [L] Q2 stays open under Blocks planning, with 최현우's statement recorded as input. The walkthrough keeps both branches, and nothing in Rules or the Decision log treats Q2 as decided.
5. [L] Q7 stays open, addressed to 이수민, with 김도윤's preference recorded as input under his name. R11 and cases 10–11 still cite Q7.
6. [L] The mobile app stays under 제외. A new question (with a new ID) says the intent must first be revised with clarify-intent. No rule or step covers app cancellation.
7. [S+L] Status still reads Draft, with matching counts. The final message declines to accept and lists the blocking questions with their owners.
8. [L] Q16 (withdrawal, which applies only if Q1 is (b) or (c)) is closed as moot, citing Q1, rather than left open unchanged. The spec or the final message suggests that 이수민 record the Q9 reading in FIN-REF-03.

---

## t4-with and t4-base: T4 simple-intent-shelfdesk

**Fixture:** `fixtures/shelfdesk`, a new fixture that becomes a git repo through `setup_run.sh`.
- `README.md`: "shelfdesk: circulation desk app for Riverside Public Library." `receipts/` prints loan receipts on the desk's 58 mm printer (32 characters per line), and `loans/` computes due dates.
- `CLAUDE.md`: three bullets: Use pnpm. Tests sit next to the file as *.test.ts. Never commit secrets.
- `loans/loan.ts`: `type ItemType = "book" | "dvd" | "reference"`, plus `formatLocalDate`. `dueDate(type, checkedOutAt): string | null` returns the local date as YYYY-MM-DD: books 21 days, DVDs 7, and `null` for reference items, under the comment "reference items may be borrowed for in-library use; no due date".
- `receipts/print.ts`: `receiptLines(items, at)` returns the library name, the date, one title per line (cut to 32 characters), then "Thank you!".
- `docs/intents/0005-due-date-on-receipt.md`: follows the clarify-intent template exactly, with no author line.
  - Problem: receipts list titles only, so staff hand-write due dates, and members still return items late.
  - Desired outcome: every receipt shows "Due: YYYY-MM-DD" under each title, and staff stop hand-writing due dates.
  - Affected: members and desk staff; `receipts/print.ts` and `loans/loan.ts`.
  - Scope: the printed loan receipt is in. Email receipts, the member app, and loan periods are out.
  - Constraints: every line fits in 32 characters (printers can't be replaced this year), and the existing lines keep their order.
  - Open questions: None.
- There is no `docs/policies/`. Both TypeScript files pass `tsc --strict --noEmit`.

**Prompts, t4-with (one session; turns 2–4 use `--resume`):**
1. `/write-spec docs/intents/0005-due-date-on-receipt.md I'm Dana Okafor, product owner for the desk app.`
2. `Sure, ask me my questions.`
3. `Print "In-library use only" on that line instead of a date.` If turn 2 asks something else, answer that question in plain words instead, and record the substitute text in the run notes.
4. `Looks right. Accept it.`

**Prompt, t4-base (one turn, no skill):**
```
Write a spec for docs/intents/0005-due-date-on-receipt.md. I'm Dana Okafor, product owner.
```
Metrics, not pass/fail: length and question count against t4-with's turn-1 spec, and whether the baseline decides the reference-item line itself.

**Assertions (as in the plan):**
1. [S] After turn 1, the spec is ≤120 lines and ≤12 KB.
2. [S+L] There is exactly one open question, not under Blocks planning, about items with no due date.
3. [L] No Policies row, rule, or Left-to-engineering line draws on anything outside the fixture (no invented GDPR, accessibility, or brand rules), and no CLAUDE.md line appears as a rule or policy.
4. [L] "Due: YYYY-MM-DD", the 32-character limit with its reason, the line order, and all 3 out-of-scope items appear as the intent gives them. No rule decides what a reference item prints before turn 3.
5. [S] Turn 2 asks exactly one question, as lettered options one per line, built from that question's options.
6. [S+L] After turn 3, the question is gone, the rule and the case cite "Q1 answer, Dana Okafor, 2026-10-23", the Decision log has that line, and Status reads "Draft · 0 open questions, 0 block planning".
7. [S] After turn 4, Status reads "Accepted (Dana Okafor, 2026-10-23)".
8. [L] G-L finds no genuine gap.

---

## t6: T6 supersede-intent

**Fixture:** `fixtures/t6-ledgerly-supersede` = `ledgerly` plus:
- `docs/intents/0003-monthly-invoice-export.md`: has a `Superseded by: 0004-monthly-invoice-and-credit-note-export.md` paragraph right after the title. Nothing else changed.
- `docs/intents/0004-monthly-invoice-and-credit-note-export.md`: 0003's text, including its title, with `Supersedes: 0003-monthly-invoice-export.md` after the title. The In-scope line now reads "exporting the invoices of one chosen calendar month from the admin console, and the credit notes issued in that month, one row each, with negative amounts". Out of scope reads "scheduled or emailed exports, other reports", so credit notes are no longer there.
- `docs/specs/0003-monthly-invoice-export.md`: the `$IT5` English spec, revised by hand per revising.md:
  - Q1 and Q3 are removed from Open questions and from the Reviewers table.
  - Status reads "Draft · 7 open questions, 4 block planning". Q2, Q4, Q5, Q6 block planning; Q7, Q8, Q9 are needed before release.
  - R1 cites "Q1 answer, M. Weber, 2026-10-20". R3 and R4 cite "Q3 answer, Lena Vogel, 2026-10-21".
  - The answers are also applied to the Summary, walkthrough steps 3 and 6, cases 1, 4, 6, 7, 8, the SEC-04 §1 Policies row, the first check under How we will know, the Facts pointers, Terms (issue date), and Q8's wording. The full list is under Adaptations.
  - A two-line `## Decision log` at the end:
    - `Q1 (Export permission for the accountants): (a) give the export permission to the finance role. M. Weber, 2026-10-20, email.`
    - `Q3 (Month boundaries): (a) Berlin time decides both the month and the issue date shown. Lena Vogel (product owner), 2026-10-21, review meeting.`

**Spec checked against the plan:** Q1 is "Export permission for the accountants" and its option (a) is "Give the export permission to the finance role". Q3 is "Month boundaries" and its option (a) is "Berlin time decides both the month and the issue date shown". Both match. Before the edit, the spec held 9 questions, 6 blocking, so removing two blocking questions gives the plan's 7/4.

**Prompt:**
```
/write-spec docs/intents/0003-monthly-invoice-export.md Lena here, product owner. Please bring the spec up to date; I can't answer anything today.
```

**Assertions (as in the plan):**
1. [L] The final message says 0003 is superseded and that 0004 was used.
2. [S] `docs/specs/0004-monthly-invoice-and-credit-note-export.md` exists, with `Supersedes: 0003-monthly-invoice-export.md` in its header and Status Draft.
3. [S] The only change to the old spec is one `Superseded by: 0004-…` paragraph right after the title, and both intents are unchanged.
4. [L] Weber's and Vogel's answers each appear in the new spec, either as the cited source of a rule (name, date) or inside an open question that cites the earlier answer. Neither is lost or turned into an unsourced rule.
5. [L] The missing credit-note field on invoices is raised as a question that blocks planning or as a fact the technical lead confirms. No rule invents how credit notes are identified.

Grader note for #3: the baseline for the diff is the base commit's old spec, which is the hand-revised version described above, not the `$IT5` original.

---

## t7: T7 revise-in-file-answers-en

**Fixture:** `fixtures/t7-ledgerly-answers` = `ledgerly` plus `docs/specs/0003-monthly-invoice-export.md`, which is the `$IT5` English spec with three answer lines filled in the field's own format (`- **Answer:** <answer · who · date>`):
- Q2 (Admins and the export permission): `- **Answer:** (b) No · M. Weber · 2026-10-22`
- Q3 (Month boundaries): `- **Answer:** (a) Berlin time · Lena Vogel · 2026-10-22`
- Q7 (Voided invoices): `- **Answer:** (a) include voided invoices · Jonas Krüger (accountant) · 2026-10-22`

The only other change: `Verified against` is dated 2026-10-19 (see Adaptations). Status still reads "Draft · 9 open questions, 6 block planning". The Reviewers table still says the product owner is not named.

**Spec checked against the plan:**
- Q2's options are (a) Yes / (b) No. It holds back R1 for admins and case 5.
- Q3's option (a) is Berlin time. It holds back R3, R4, and cases 6 and 7.
- Q7's option (a) is to include voided invoices. Its "What would resolve it" says the product owner chooses, after the technical lead confirms what "void" means, so an accountant isn't its owner.
- Q8 contains "in the time zone that Q3 (month boundaries) settles".

All of these match the plan.

**Prompt:**
```
/write-spec docs/intents/0003-monthly-invoice-export.md Answers are on the answer lines in the spec. Lena Vogel is the product owner for this work.
```

**Assertions (the plan's, with #1 adapted):**
1. [S] The same file is revised, no new spec is created, and the intent is unchanged. **Q1 and Q4–Q9** keep their numbers and short names, and no new ID is ≤ the old maximum (Q9, R11).
2. [L] Q2 and Q3 are closed and applied (Q2: R1, case 5; Q3: R3, R4, cases 6–7), citing "Q<n> answer, <name>, 2026-10-22". The Decision log says they came from the answer lines.
3. [L] Q7 stays open (its owner is the product owner, not an accountant), with Krüger's answer recorded as input.
4. [S+L] No surviving text treats Q2 or Q3 as open. A script greps each mention, and the judge rules on each hit (for example, Q8's "the time zone that Q3 settles").
5. [S] The Reviewers table names Lena Vogel as product owner and lists exactly the open questions, and the Status counts match.

---

## t8a: T8a step-1 gate, no argument (also the harness preflight)

**Fixture:** `fixtures/t8a-ledgerly-gates` = `ledgerly` plus:
- `admin/docs/intents/0001-bulk-mark-paid.md`: a valid clarify-intent intent with no author. Accountants select several invoices and mark them all paid in one action. Bank-file import, automatic matching, and partial payments are out of scope.
- `docs/intents/0002-invoice-csv.md`: a valid intent (CSV download of the filtered invoice list) with `Superseded by: 0003-monthly-invoice-export.md` after the title.
- `docs/intents/0003-monthly-invoice-export.md` is left as in `ledgerly`, with no `Supersedes:` line, because the plan lists only additions.

**Prompt:**
```
/write-spec
```
Preflight check, as in the plan: the init event lists the subagent tool (Agent or Task), and the slash command loads the skill.

**Assertions (as in the plan):**
1. [S] T8a creates or changes no file.
2. [L] T8a's reply is one choice question with lettered options, one per line, covering the intents in both `docs/intents/` folders. 0002 is left out or shown as superseded by 0003, and no spec content is drafted.

---

## t8b: T8b step-1 gate, several outcomes with the user away

**Fixture:** `fixtures/t8b-ledgerly-multi` = `ledgerly` plus `docs/intents/0005-month-end-close-tools.md`, which follows the clarify-intent template with no author. It has exactly two desired outcomes, each of which works alone:
1. An accountant uploads the month's bank-statement file in the admin console, and every invoice the statement shows as paid is marked paid in one step.
2. A customer whose invoice is 7 days overdue automatically gets a reminder email.

Out of scope: collecting payments or direct debit, late fees or interest, and reminders by letter or phone. Constraint: an invoice must not be marked paid unless the statement shows a payment for it. Open questions: None.

**Prompt:**
```
/write-spec docs/intents/0005-month-end-close-tools.md I'm out until Monday and nobody else can answer. Don't wait for me.
```

**Assertions (as in the plan):**
3. [S] T8b saves a spec at `docs/specs/0005-month-end-close-tools.md` in the same turn.
4. [L] In T8b, Q1 is the first question under Blocks planning. It asks which outcome(s) this spec covers, is addressed to the originator (marked as not named), and offers each outcome alone and both together.
5. [L] In T8b, both outcomes appear in the walkthrough or the rules, or are explicitly held back by Q1; neither is silently dropped. SEC-04 is applied, or listed as read and not applicable, with a reason.

---

## t9: T9 large-real-repo, documenso v2.9.1

**Fixture:** the directory `fixtures/t9-documenso/build.sh` prints. It builds the fixture from `git clone --depth 1 --branch v2.9.1 https://github.com/documenso/documenso` (commit `8f3e189`, 2026-04-23), with `.git` removed, and adds `docs/intents/0001-recipient-stops-reminders.md` (kept as `fixtures/t9-documenso/0001-recipient-stops-reminders.md`); the repo had no `docs/` directory at its root before. The intent follows the clarify-intent template with no author:
- Problem: recipients who won't sign keep getting reminders. "With the default reminder settings, the first comes 5 days after the signing request and then one every 2 days, for as long as the document waits for them." Recipients can't stop them without rejecting the document, and some mark them as spam, which hurts delivery from our domain.
- Desired outcome: from a reminder email, a recipient stops further reminders for that one document without signing or rejecting it, and the sender sees this on the document.
- Affected: recipients and senders. The systems are named in plain words, with no code paths.
- Scope: stopping automatic reminders for one document, from a reminder email, is in. Out of scope: the original signing request email, unsubscribing from all email, and the default reminder timing.
- Constraints: "Must not change the audit trail of signed documents. Reason: it is legal evidence." and "Must follow our published privacy policy." (no path given).
- Open question: "May the sender turn reminders back on for a recipient who stopped them?"

**Prompt (90-minute timeout):**
```
/write-spec docs/intents/0001-recipient-stops-reminders.md Nobody is around to answer today.
```

**Assertions (as in the plan):**
1. [S] The run finishes within 90 minutes, the spec is saved, and nothing outside `docs/specs/` changed.
2. [S] Every path in Facts and sources exists at the commit, and the 5-day and 2-day defaults cite `envelope-reminder.ts`.
3. [L] The spec finds the in-repo privacy page without being given a path. It records that the page only links off-repo, invents none of its content, and names who confirms what the policy requires (a question or a Not found line).
4. [L] No rule, Policies row, or Left-to-engineering line comes from AGENTS.md's build or code-style guidance, `.agents/plans/`, or `.claude/skills/`.
5. [L] The intent's open question is carried forward. Every person named appears in a repo source, and owners nobody named are marked "not named".
6. [L] G-L confirms ≤1 genuine gap, and none about personal data or the audit trail.

**Grader notes (the assertions are unchanged; these add context):**
- #1: documenso's `.gitignore` ignores `.claude` and `CLAUDE.md`, so `git status` in the run repo never shows `.claude/`. Check "nothing outside `docs/specs/` changed" with `git status --porcelain --ignored` minus `.claude/`, or by comparing file lists.
- #2: the defaults live in `packages/lib/constants/envelope-reminder.ts` and are applied as an organisation default in `packages/lib/utils/organisations.ts`. Citing both is fine.
- #4: treat the repo's other engineering and agent guidance the same way as AGENTS.md: `.cursorrules`, `CODE_STYLE.md`, `WRITING_STYLE.md`, `.agents/skills/`, `.agents/scratches/`, and `.opencode/commands/`. There is no `.claude/skills/` in the repo itself; the only one is the installed write-spec.
- #6 / G-L: three facts are real and undecided by the intent, so a question about them is not padding:
  - Every reminder already writes an entry to the document's audit log.
  - Senders can send manual reminders.
  - Organisations created before 2026-04-01 have reminders off by default.

  The T9 notes below give the sources.

---

## Adaptations (each with its reason)

1. **T1: none.** Every number and short name the prompt and assertions use matches the iteration-5 Korean spec, as listed under t1. The spec was copied unchanged.
2. **T6 and T7: `Verified against` is dated 2026-10-19 instead of 2026-10-23** (the commit `b79f2e7` is kept). The answers are dated 2026-10-20, 2026-10-21, and 2026-10-22. Under the original date, the owners would have answered a spec a day or more before it was written. No other line changed for this.
3. **T6: the Reviewers table names Lena Vogel as product owner.** The `$IT5` spec left the product owner unnamed, and Q3's answer comes from "Lena Vogel (product owner)". revising.md lets only owners close a question, so a faithful reviser records who the product owner is.
4. **T6: the answers are applied beyond R1 and R3**, because revising.md says "apply it everywhere it lands" and "fix each reference that still treats it as open":
   - R4 (issue date in Berlin time).
   - Summary.
   - Walkthrough steps 3 and 6.
   - Case 1 (wording), case 4 (now "the other accountant (finance role) starts an export … goes ahead"), cases 6 and 7 (now decided: February/2027-02-01 and July/2027-07-01), and case 8 ("whatever Q3 decides" dropped).
   - The SEC-04 §1 Policies row.
   - The first check under How we will know (Berlin-time months, and the technical lead confirms the list filter's time zone).
   - Facts pointers (→ R1, → R3, R4, → How we will know).
   - Terms (issue date).
   - Q8's "in the time zone that Q3 (month boundaries) settles", now "after it ends in Berlin time (R3)".
   - The technical lead's row.

   No new question was added, so Status matches the plan's 7/4. The open point, which time zone the invoice list's filter uses, stays a fact for the technical lead to confirm. The "count of 2026 invoices in a different month" item was dropped, because it only served the Q3 decision.
5. **T6: plain wording in the Decision log.** Q1's answer reads "(a) give the export permission to the finance role" rather than the plan's "grant finance:export to the finance role", because the spec keeps code names out of every section except Facts and sources. The name, date, and channel are as the plan gives them.
6. **T6: 0004 keeps 0003's title, and credit notes are merged into the one In-scope line.** The plan says "0003's text plus …" and specifies only the scope change.
7. **T7, assertion 1: "Q4–Q9 keep their numbers" becomes "Q1 and Q4–Q9".** In T7, Q1 is also unanswered and survives, so it must keep its number too. The old maximums are Q9 and R11.
8. **T8a: 0003 gets no `Supersedes: 0002-invoice-csv.md` line.** The plan lists only additions. 0002 has no spec, so the superseding rule can't fire either way.
9. **T9: the intent's timing sentence is adjusted to the code.** The plan says "by default every 2 days". The default has two parts (first after 5 days, then every 2 days), and it is an organisation-level default, so the intent says "With the default reminder settings, the first comes 5 days after the signing request and then one every 2 days".
10. **T9: the affected systems are named in plain words, with no code paths.** The plan gives no paths, and this keeps "find it in a large repo" part of the test. As the plan requires, the privacy constraint gives no path.
11. **T4 and T8b: builder choices within the plan.**
    - T4 adds a `formatLocalDate` helper in `loans/loan.ts`, which `receipts/print.ts` uses for the date line. `ReceiptItem` carries `{ title, type }`.
    - T8b's intent has exactly two desired outcomes, with no combined third outcome such as "close on time", so that neither outcome depends on the other.

---

## T9 verification notes (checked against the clone, commit 8f3e189 = tag v2.9.1, 2026-04-23)

| Plan's claim | Finding | Verdict |
|---|---|---|
| 2,546 files | `git ls-files` = 2,546, and `find` (excluding `.git`) = 2,546. With the intent, 2,547. | Confirmed |
| AGENTS.md is build and code-style guidance only | Sections: Build/Test/Lint Commands; Code Style Guidelines; Error Handling & Validation; UI & Styling; TRPC Routes; Translations & Remix. There are no product, privacy, email, or compliance rules. | Confirmed |
| `apps/docs/content/docs/policies/privacy.mdx` only links to documenso.com/privacy | The whole body is "Our full Privacy Policy is available at [documenso.com/privacy](https://documenso.com/privacy)." `terms.mdx` has the same shape. `policies/index.mdx` says "For binding legal terms, refer to the full documents linked above." | Confirmed |
| `compliance/gdpr.mdx` and `esign.mdx` have substance (ESIGN record retention) | gdpr.mdx: controller/processor roles, data categories (identity, document, signature, audit), "Sending email notifications" as a purpose, data subject rights including Objection and Erasure, and deletion rules (deleting a document removes its audit logs). esign.mdx: ESIGN "Record Retention: Electronic records must be accurately preserved and accessible for later reference", "Original documents and audit trails are preserved", and an Audit Trails table. The same folder also has `standards.mdx`, `signature-levels.mdx`, and `certifications.mdx`. | Confirmed |
| `packages/lib/constants/envelope-reminder.ts`: first reminder after 5 days, then every 2 days | `DEFAULT_ENVELOPE_REMINDER_SETTINGS = { sendAfter: { unit: 'day', amount: 5 }, repeatEvery: { unit: 'day', amount: 2 } }` (lines 29–32). It is used only by `generateDefaultOrganisationSettings` (`packages/lib/utils/organisations.ts:146`), which runs when an organisation is created. Team settings default to `null` (inherit). Migration `20260401000000_add_reminder_settings` adds the column with no default, and `resolveNextReminderAt` treats a `null` config as "no reminders", so organisations that existed before that migration have reminders off unless someone turns them on. | Confirmed, with nuance (it is the default for new organisations) |
| The sweep reminds only NOT_SIGNED, non-CC recipients of PENDING documents; REJECTED is a separate status | `send-signing-reminders-sweep.handler.ts` (cron every 15 min) selects recipients with `nextReminderAt <= now`, `signingStatus NOT_SIGNED`, `sendStatus SENT`, `role != CC`, and envelope `status PENDING`, not deleted. `process-signing-reminder.handler.ts` repeats that check and also skips manual distribution (`NONE`) and envelopes whose recipient signing-request emails are turned off. In `schema.prisma`, `SigningStatus` is {NOT_SIGNED, SIGNED, REJECTED} and `DocumentStatus` is {DRAFT, PENDING, COMPLETED, REJECTED}. | Confirmed |

Other facts that bear on grading:
- Each reminder writes a document audit-log entry (`EMAIL_SENT` with `emailType: REMINDER`) and fires the `DOCUMENT_REMINDER_SENT` webhook (`process-signing-reminder.handler.ts`). How a stop is recorded therefore meets the intent's audit-trail constraint: the log of a pending document becomes part of the signed document's evidence.
- Senders can also remind recipients by hand (Resend → "Send reminder"; `apps/docs/content/docs/users/documents/send.mdx`). The intent doesn't say whether a stop also blocks these manual reminders.
- Recipient emails have no unsubscribe mechanism today. The only "unsubscribe" in the code is the Zapier webhook endpoint.
- Agent and engineering guidance outside AGENTS.md: `.cursorrules`, `CODE_STYLE.md`, `WRITING_STYLE.md`, `ARCHITECTURE.md`, `.agents/plans/` (11 plans, none about reminders), `.agents/skills/`, `.agents/scratches/`, and `.opencode/commands/`. The repo has no `.claude/` or `CLAUDE.md` of its own. Both are gitignored, so in run t9 the installed write-spec skill is on disk but not in the base commit. No tracked file is ignored, so all 2,546 files and the intent are in the base commit.

---

## Held-out fixtures (HO)

Three fixtures built by agents that read only the clarify-intent template, never write-spec or these evals. Each has an answer key in `keys/`: planted gaps by domain, one conflict, one policy clause with two readings, three decoys that the sources settle, and facts that live only in code comments. Grade with [graders/task-held-out.md](graders/task-held-out.md). Use them for regression only; don't tune the skill against the keys.

| Fixture | Language | Domain | Owners named | Prompt |
|---|---|---|---|---|
| `ho-clinic-booking` | Korean | Outpatient booking: app cancellation and changes, deposit refunds, no-show fees | Originator; no product owner | `/write-spec docs/intents/0001-self-service-cancellation.md 오늘은 아무도 질문에 답할 수 없어요.` |
| `ho-expense-reimburse` | English | Expense claims in two countries: auto-approval, home-currency payout, tax | None | `/write-spec docs/intents/0001-slow-small-claims.md Nobody can answer questions today.` |
| `ho-school-absence-alerts` | English | Same-morning absence alerts to guardians: minors' records, custody, notices | Originator and product owner | `/write-spec docs/intents/0001-unexplained-absence-same-morning.md I'm Priya Raman, the product owner. I can't answer questions today.` |
