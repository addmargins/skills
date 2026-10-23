# Answer key: ho-expense-reimburse

The skill must never see this file.

Fixture: `fixture/ho-expense-reimburse/` (13 files). It covers employee expense reimbursement at Fernhill Analytics, which has a UK company (GBP payroll) and a German company (EUR payroll). The intent is `docs/intents/0001-slow-small-claims.md`. It asks for small claims to be approved automatically and paid in the claimant's salary currency within 5 working days, through BankRail. It names no originator and no product owner, and it has one open question.

A good specification:
- states as rules only what the intent or a policy settles;
- records code facts as facts, not as policy;
- raises each gap, the conflict, and the two-reading clause as an open question addressed to its owner, without choosing an answer;
- states the decoys as rules, with their source, instead of asking about them.

## People and owners named

| Who | Role, team | Where | Owns |
|---|---|---|---|
| Priya Raman | Financial Controller, Finance Operations | FIN-02 header | FIN-02. Sets the auto-approval threshold (FIN-02 2.4) and the payment route (5.1). Decides G1, G2, G3, G4, G6 and G10, and shares G5, G7, G12 and G13 |
| Jonas Albrecht | Data Protection Officer, Legal & Compliance | LEG-07 header | LEG-07. Decides G11, and shares G13 |
| Claire Okafor | Head of Tax, Tax team (Finance) | TAX-03 header | TAX-03. Decides the two-reading clause, shares the conflict with the intent's owner, and shares G12 |
| Ravi Menon | Lead, Finance Systems team (maintains the app) | README | No decision. He can confirm code facts. A spec that sends product or policy questions to him is wrong |
| *(unnamed)* | Owner of the intent | — | The intent names no originator or owner. A spec must say the owner is unknown and ask who it is. It must not invent an owner or assume a policy owner owns the intent |

Teams named without a person: the People Ops benefits team, Finance Operations and its Payments desk, Payroll, Internal Audit, Accounts Payable, the finance team (its quarterly report), and team leads.

## Facts a writer must find in code

| # | Fact | Where |
|---|---|---|
| C1 | Every claim is approved by the line manager, or by People Ops for WELLBEING-only claims (the UI keeps WELLBEING lines in claims of their own). A Finance step is added when the total is `>=` £500 / €575 (50 000 / 57 500 minor units) | `src/claims/approval.ts` `requiredSteps`, `FINANCE_STEP_FROM` |
| C2 | A receipt is needed for a line `>=` £25 / €30. German meal allowance lines are exempt. A line without a required receipt blocks submission | `approval.ts` `RECEIPT_REQUIRED_FROM`, `linesMissingReceipt` |
| C3 | Routing and receipt checks use an indicative rate: the latest stored ECB rate at the moment of the check. The amount paid uses the rate for the 18th, so it can differ from what the approver saw | `approval.ts` `indicativeMinor` comment; `src/payroll/export.ts` |
| C4 | A RETURNED claim is resubmitted under the same id. `submittedAt` is updated and `firstSubmittedAt` is kept. The claim restarts from the first step, and earlier approvals are kept but not reused | `src/model.ts` `Claim`; `approval.ts` `currentRound` |
| C5 | The wellbeing cap is £40 / €45 per calendar month (from the People Ops benefits handbook). People Ops checks it by hand today | `approval.ts` `WELLBEING_MONTHLY_CAP` |
| C6 | Payroll cutoff: the last approval must be given by 23:59:59 Europe/London on the 18th. The export job runs at 00:30 on the 19th. Payday is the last working day of the month (England & Wales holidays for the UK company, Berlin holidays for the German one) | `src/payroll/export.ts` header |
| C7 | **Rounding (comment only):** converted line values are sent to PayFront unrounded, with 4 decimal places. PayFront sums each employee's lines in a run and rounds that total half-up to 2 decimal places, once per employee per run. The app never rounds a paid amount | `export.ts` header |
| C8 | Lines in WELLBEING (UK and DE) and HOME_INTERNET_UK (UK) are sent with `taxable=Y` | `export.ts` `TAXABLE_CATEGORIES` |
| C9 | Contractors' claims go to Accounts Payable in each line's own currency, unconverted, and are paid with the contractor's next invoice. Their checks use the engaging company's currency | `export.ts`; `approval.ts` `checkCurrency` |
| C10 | PayFront has no API: the app sends a CSV over SFTP and gets a payslip file back. PayFront holds the bank details, and the app never sees them | `export.ts` header |
| C11 | **Outside service limit (comment only):** the ECB publishes rates around 16:00 CET, on TARGET business days only, with no rates for weekends or TARGET closing days. The app fetches them at 16:30 Europe/Berlin, so there is no rate for today before then. `rateOn(date)` silently falls back to the latest earlier rate, so a lookup for today made before 16:30 returns yesterday's rate | `src/fx/ecb.ts` header, `rateOn` |
| C12 | **Outside service limits (comment only):** BankRail releases a batch the same day if it arrives by 14:00 Europe/London on a UK banking day, and otherwise on the next UK banking day. GBP goes by Faster Payments and arrives within about 2 hours. EUR goes by SEPA and arrives on the next TARGET business day. A batch holds at most 250 payouts, and one invalid payout rejects the whole batch. Returns come by the `payout.returned` webhook up to 10 UK banking days after release, and BankRail does not retry. There is one GBP account (UK company) and one EUR account (German company), with no currency conversion | `src/payouts/bankrail.ts` header |
| C13 | BankRail is used today only for travel advances. For an advance, the employee types bank details into the request, and they are deleted 30 days after the payout is sent (`purgeBankDetails`). When an advance is returned, the Payments desk and the employee are emailed | `bankrail.ts` |
| C14 | The German meal allowance is computed at submission and the claimant cannot edit it. Reductions for provided meals are taken as a percentage of **that day's** allowance (`allowance * 0.2` / `* 0.4`, where `allowance` is €14 or €28). This is reading A of TAX-03 2.3 (see below). Country amounts come from a BMF table that Finance loads each January | `src/claims/meal-allowance.ts` |
| C15 | Emails go only to the work address. There are emails for approval (with the payroll month and payday), return, rejection, line reduction, recovery, and advance sent or returned. Nothing is sent on export or payment | `src/notify/email.ts` |
| C16 | The HR feed sets `active=false` on the day after the last working day, and someone serving notice is still active. The feed has `leaving_date` and `notice_given_on`, which are **not imported**, and personal email and address, which must not be imported | `src/hr/sync.ts` |
| C17 | **Fields that exist:** `Person.kind` (EMPLOYEE / CONTRACTOR), `entity`, `payrollCurrency` (null for contractors), `active`, `managerId`, `workEmail`; `Claim.firstSubmittedAt`, `submittedAt`, `approvals[]`, `payrollRun`; `ClaimLine.spentOn`, `currency`, `approvedAmountMinor`, `reductionReason`, `mealAllowance` (with provided-meal flags); `Receipt.sha256`, which matches byte-identical files only | `src/model.ts` |
| C18 | **Fields that do not exist:** bank details on Person or Claim; any payout fields on Claim; personal email; leaving or notice date; any link between claims, or a trip id; any automatic approver. `Approval.by` must be a `Person.id`, and `step` has no automatic value | `src/model.ts` comments and types |

## Planted gaps (13)

Each gap is a real decision that no source makes. Domain counts: **money 5** (G1, G2, G3, G4, G6), **personal data 2** (G11, G13), **legal 1** (G12), **other 5** (G5, G7, G8, G9, G10).

### G1. Is a claim of exactly £100.00 / €115.00 approved automatically? (money; boundary: inclusive threshold)
- **Sources:** the intent says "The auto-approval threshold is £100 for UK staff and €115 for German staff, applied to the claim's total". FIN-02 2.4 says only that the Financial Controller "may set a threshold".
- **Why it is open:** neither source says on which side of the threshold a claim at exactly the threshold falls. The existing thresholds in FIN-02 2.3 and 3.1 are "or more" escalation thresholds (code uses `>=`). That is a precedent for escalation thresholds, not a rule for the new one. The FC has not set any threshold yet.
- **Owner:** Priya Raman, with the intent's owner.

### G2. Which rate date applies to a claim paid outside payroll, for the payout amount and for the threshold check? (money; boundary: rate date)
- **Sources:** FIN-02 4.2 fixes the rate as the one "for the payroll cutoff date … of the payroll run that pays the claim". A claim paid by BankRail has no payroll run, so 4.2 does not apply to it, and nothing else sets a rate. Today the threshold and receipt checks use the indicative latest rate (C3).
- **Candidates:** the expense date, the submission date, the latest rate at the check, the payout date, or the next 18th.
- **Same-day trap:** the rate for today does not exist before about 16:00 CET (16:30 fetch), and `rateOn` silently returns yesterday's rate (C11).
- **Example:** a UK employee claims one line of €114.50. At 0.8712 it is £99.75, under £100. At 0.8745 it is £100.13, over. Whether the claim is "small" depends on a date nobody chose.
- **Owner:** Priya Raman.

### G3. How are converted amounts rounded when each claim is paid on its own? (money; boundary: currency rounding)
- **Sources:** no policy says how converted amounts are rounded. Today PayFront rounds once per employee per monthly run, half-up, after summing unrounded 4-decimal values, and the app never rounds a paid amount (C7). A BankRail payout needs a 2-decimal amount for each payout.
- **Undecided:** whether to round per line, per claim or per payout; half-up or half-even.
- **Example:** two claims in one month, each with a €10.30 line, at 0.8655 give £8.91465 each. Rounded per claim, that is £8.91 + £8.91 = £17.82. PayFront's per-run method gives £17.829 → £17.83. Half-up and half-even also differ: €10.00 at 0.8625 = £8.625 → £8.63 half-up, £8.62 half-even.
- **Owner:** Priya Raman.

### G4. What does automatic approval do with split claims and with claims related to an earlier partial reimbursement? (money; what came before, and repeats)
- **Sources:** FIN-02 2.5 forbids splitting an expense to fall under a threshold, but says nothing about what the app does when claims look split. No field links claims or trips. `sha256` catches only byte-identical files, so two photos of one receipt pass (C17, C18). FIN-02 6.1 lets Finance Operations reduce a line (`approvedAmountMinor`), but nothing says whether the reduced remainder may be claimed again.
- **Examples:** a £180 two-night hotel stay submitted as two £90 claims. A £160 hotel line reduced to £125 in March, followed by a new £35 claim for "the rest", which falls under £100. In both cases nobody looks.
- **Undecided:** whether the app detects related claims, and if so what it does (block, send to the manager, or flag for the FIN-02 7.1 sample).
- **Owner:** Priya Raman.

### G5. What happens when a manager and automatic approval act on the same claim? (other; two paths on one claim, and what came before)
- **Undecided cases:**
  - (a) A manager RETURNED a £140 claim. The claimant removes a £45 line and resubmits £95 under the same id (C4). Is it approved automatically, overriding the manager, or does it go back to that manager?
  - (b) Claims under the threshold that are already waiting in manager or People Ops queues at launch.
  - (c) LEG-07 2.1 lets a line manager view their reports' claims. A manager who objects to an automatically approved claim: may they stop it before payout? After payout, the only route is FIN-02 6.2.
  - (d) Which "submission" starts the 5-day clock for a resubmitted claim: `firstSubmittedAt` or `submittedAt`.
- **Why it is open:** the intent only removes the approver. No source addresses any of these cases.
- **Owner:** the intent's owner, with Priya Raman for reversals.

### G6. What happens when a BankRail payout fails? (money; failure of the outside service)
- **Failure modes (C12):** a payout returned up to 10 UK banking days after release, after the claimant was told it was paid; a whole batch rejected because one IBAN is invalid; BankRail unavailable at the 14:00 cutoff. BankRail does not retry.
- **Undecided:**
  - the claim's state after a return;
  - whether to retry, ask again for bank details, or fall back to payroll;
  - whether the 5-day promise restarts;
  - who handles it, and who is told.
- **Why it is open:** the advance flow (C13) is precedent only. No source covers claims.
- **Owner:** Priya Raman (Finance Operations and its Payments desk).

### G7. What happens to an automatically approved claim that cannot be paid within 5 working days? (other; a waiting state that crosses a time limit)
- **Causes:** no bank details supplied (the app may not keep them, see D2, so each payout needs them); a rate not yet available (depends on G2); a BankRail failure (G6).
- **Undecided:** how long the claim waits; whether it moves to the payroll route at the next 18th cutoff (FIN-02 5.1 leaves the route to the FC); whether it expires; whether it loses automatic approval.
- **Why it is open:** the intent promises 5 working days but does not say what happens when that is missed.
- **Owner:** the intent's owner, with Priya Raman.

### G8. Which calendar counts the "5 working days"? (other; boundary on a deadline)
- **Sources:** the intent does not say. The candidates are England & Wales bank holidays, Berlin public holidays, and TARGET days, which BankRail's EUR delivery depends on (C12).
- **Example:** a German employee submits on Mon 11 May 2026. Thu 14 May is Ascension Day, a Berlin holiday but a UK and TARGET working day. The UK calendar gives a deadline of Mon 18 May 2026, and the Berlin calendar gives Tue 19 May. Under the UK reading, the EUR payout must be released by 14:00 London on Fri 15 May to arrive on Mon 18 May.
- **Owner:** the intent's owner.

### G9. What are the claimant and the manager told on the new path? (other; what the employee is told)
- **Today (C15):** emails cover approval with payday, return, rejection, reduction and recovery, and nothing is sent on payment. The approval email names an approver and "your salary".
- **Undecided:** what the claimant is told at submission (automatic approval, expected amount and rate, expected date); whether they are told when the payout is sent, when it is returned, or when the claim is picked for the 7.1 sample; and whether the manager is told immediately. The intent's open question covers only a periodic summary.
- **Already settled:** telling the claimant the reason for a reduction (FIN-02 6.1) and giving written notice before a recovery (6.2).
- **Owner:** the intent's owner.

### G10. What does the approval record of an automatically approved claim show? (other; records kept)
- **Sources:** FIN-02 8.1 requires "who approved, the decision, and the date and time". `Approval.by` must be a person id, and there is no automatic step (C18).
- **Undecided:** whether "who" is the app or the FC who set the threshold under 2.4. Also whether the record keeps the threshold and the rate in force, which the FC can change and which 7.1 reviewers and Internal Audit need.
- **Already settled:** who may see the record (LEG-07 2.1, 2.2) and how long it is kept (4.1).
- **Owner:** Priya Raman, consulting Internal Audit.

### G11. When are bank details deleted if no payment is ever sent? (personal data; records kept)
- **Sources:** LEG-07 3.2 deletes single-payment bank details "30 days after the payment is sent".
- **Why it is open:** the new flow collects details for claims that may never be sent. Examples: the claim is withdrawn after the details were entered; a manager or Finance stops it (G5); BankRail rejects the whole batch (C12); the claim falls back to payroll (G7). No rule covers these cases. Returned payouts are covered, because they were sent.
- **Owner:** Jonas Albrecht.

### G12. Are contractors in scope, and on what terms? (legal; people at the edge of scope)
- **Facts:** about 35 contractors can claim (README, C16). They have no payroll currency (C17). Their claims go to Accounts Payable unconverted, paid with their invoice (C9).
- **Policies:** FIN-02 1.1 covers employees only, and TAX-03 1.2 excludes contractors. The intent says "staff", which may or may not include contractors.
- **Undecided:**
  - whether contractors are in scope;
  - which threshold applies to them;
  - what "home currency" means for them, since the intent defines it as the salary currency, which they don't have;
  - how money paid in error is recovered from them, since FIN-02 6.2 deducts from salary;
  - whether paying their expenses directly, like an employee's, is acceptable under their contracts and for tax.
- **Owner:** the intent's owner and Priya Raman, with Claire Okafor on tax.

### G13. How does the fast path treat leavers and staff serving notice? (personal data, with money; people at the edge of scope)
- **Facts:** `active` turns false on the day after the last working day, and the leaving and notice dates are not imported (C16). LEG-07 5.1 ends system access and the work email account on the last day, and 5.2 limits personal contact details to People Ops.
- **Example:** a claim submitted on someone's last day is approved automatically. The leaver cannot sign in to enter bank details, emails go to a closed account, and FIN-02 6.2 has no "next salary payment" to deduct from if the claim was paid in error.
- **Undecided:** whether people serving notice or leavers get automatic approval, and how they are paid and contacted.
- **Owner:** the intent's owner, Priya Raman and Jonas Albrecht.

## The conflict (one; no behavior satisfies both)

**Intent:**
- "Every automatically approved claim reaches the claimant's bank account within 5 working days of submission."
- In scope: "claims in every expense category, including … wellbeing claims and home internet claims".
- The threshold is £100 / €115. The wellbeing cap is £40 / €45 per month (C5), and home broadband bills are about £30–45. So every valid claim in these categories falls under the threshold, is approved automatically, and must arrive within 5 working days.

**TAX-03:**
- 4.1: WELLBEING (UK and DE) and HOME_INTERNET_UK are taxable.
- 4.2: taxable reimbursements "must be paid in the regular monthly payroll run … must not be paid outside it, for example by bank transfer or in an off-cycle payroll run".
- The payroll route pays only on the last working day of the month, for claims approved by 23:59 UK time on the 18th (FIN-02 5.2, C6).

**Arithmetic.** Each "deadline" is the 5th working day after submission.

| Submitted | Deadline | Earliest lawful payday | Late by |
|---|---|---|---|
| Mon 2 Mar 2026 (£40 wellbeing, UK) | Mon 9 Mar 2026 | Tue 31 Mar 2026 | 16 working days |
| Wed 18 Mar 2026 (best case: the cutoff day) | Wed 25 Mar 2026 | Tue 31 Mar 2026 | 4 working days |
| Thu 19 Mar 2026 | Thu 26 Mar 2026 | Thu 30 Apr 2026 | 23 working days |

The same dates hold for a €45 German claim on the Berlin calendar. I checked every working day from 1 Jan 2026 to 31 Oct 2027 on both the England & Wales and Berlin calendars. Payday is always at least 1 working day after the deadline. The closest case is submission on Thu 18 Feb 2027, with deadline Thu 25 Feb and payday Fri 26 Feb 2027. **No submission date and no system behavior meets both rules.**

**Expected handling:** raise it as a conflict for the intent's owner (unnamed) and Claire Okafor. The resolutions are theirs to choose: narrow the intent's scope, change TAX-03 4.2, or accept a slower promise for taxable categories. A spec fails if it silently drops wellbeing and home internet from the fast path, pays them by BankRail, or promises 5 days for them.

This is not a conflict with FIN-02 5.1. That clause lets the FC choose the bank-transfer route, so for other categories it is a precondition, not a conflict.

## The two-reading clause: TAX-03 2.3

> "If a meal is provided free of charge on a travel day, the meal allowance is reduced by 20% for a breakfast and by 40% for each lunch or dinner. The amount paid for a day is never less than zero."

2.1 defines "the meal allowance" as €28 for a full day and €14 for a partial day. The clause does not say what the percentages are taken of:
- **Reading A:** a percentage of the allowance for that day. On a €14 day that is −€2.80 for breakfast and −€5.60 for lunch or dinner. On a €28 day it is −€5.60 and −€11.20. **This is what the code does (C14).**
- **Reading B:** a percentage of the full-day allowance (€28, or the full-day country amount abroad) on every day: −€5.60 for breakfast and −€11.20 for lunch or dinner.

| Case | Reading A | Reading B |
|---|---|---|
| 10-hour day trip, lunch provided | 14 − 5.60 = **€8.40** | 14 − 11.20 = **€2.80** |
| Return day of an overnight trip, hotel breakfast | 14 − 2.80 = **€11.20** | 14 − 5.60 = **€8.40** |
| Departure day with conference dinner, plus return day with breakfast | 8.40 + 11.20 = **€19.60** | 2.80 + 8.40 = **€11.20** |
| Partial day, lunch and dinner provided | 14 − 11.20 = **€2.80** | max(0, 14 − 22.40) = **€0** |
| Full day, all meals provided | €0 | €0 (same) |

These lines are under €115, so they would be approved automatically with no human check. The reading decides the amount paid.

Context for the owner, which the spec must not use to choose: German income tax law (§9(4a) EStG) takes the reductions from the full-day amount, which is reading B. Under reading A, part of the payment would normally be taxable pay. That would bring TAX-03 4.1 ("no others are") and 4.2 into play.

**Owner:** Claire Okafor. A spec fails if it adopts the code's reading as the rule without raising the question.

## Decoys (3): they look open, but the plain words settle them

| # | Looks open | Settled by |
|---|---|---|
| D1 | What "home currency" means: residence, bank account currency, or spend currency? | Intent: "the claimant's home currency, meaning the currency their salary is paid in, not the currency the expense was paid in". FIN-02 4.1: "Claims are paid in the claimant's payroll currency". `Person.payrollCurrency` exists. (For employees only. Contractors have no salary, which belongs to G12.) |
| D2 | May the app keep employees' bank details on file for repeat payouts? | LEG-07 3.1: "Bank account details may be stored on an ongoing basis only in the payroll system (PayFront)." The answer is no. Details are collected per payment and deleted 30 days after it is sent (3.2). PayFront has no API (C10) |
| D3 | Do automatically approved claims still need receipts? | FIN-02 3.1: "A receipt is required for every line of £25 / €30 or more, whatever route the claim is approved by." Yes. Meal allowance lines are exempt under 3.2 |

A spec that asks about a decoy as if it were open loses credit. A spec that states it as a rule, citing the source, earns credit.

## Other points the sources settle (fine to state as rules)

- **Preconditions that rest with Priya Raman:**
  - The FC sets the automatic-approval threshold (FIN-02 2.4). The intent's £100 / €115 still needs her to set it.
  - The FC chooses the bank-transfer route (5.1). Until she does, every claim goes through payroll.
- **Approval:**
  - An automatically approved claim counts as approved, and the manager or People Ops step does not apply to it (2.4).
  - The £500 / €575 Finance step is unchanged (2.3 and the intent's out-of-scope list).
  - Splitting an expense is forbidden (2.5). How the app enforces this is G4.
  - The EUR figures are set separately and are not conversions (1.2), so €115 is a fixed figure, not £100 converted.
- **Payroll route and corrections:**
  - Claims paid through payroll keep the rate for the 18th, the 18th cutoff, and payday on the last working day (4.2, 5.2).
  - Before payment, Finance Operations may reduce or reject a line and must give the reason (6.1).
  - For employees who are still employed, money paid in error is recovered from the next salary after written notice (6.2).
- **Checks:** Finance Operations reviews a monthly random sample of at least 5% of automatically approved claims, by number (7.1).
- **Personal data:**
  - WELLBEING claims must never be shown to line managers "in any form" (LEG-07 2.2). This limits any manager summary under the intent's open question.
  - Bank details may be seen only by the account holder, Payroll and the Payments desk (2.3), and passed only to PayFront and BankRail (3.3).
  - Claims are kept for 6 years (UK company) or 8 years (German company) after the year of payment. Withdrawn or rejected claims are deleted after 90 days (4.1, 4.2).
- **Tax:**
  - The meal allowance is €28 / €14, with BMF country amounts abroad, and never goes below zero (TAX-03 2.1–2.3).
  - The list of taxable categories is complete (4.1).
- **Payouts:** they must go through BankRail (intent constraint).

## The intent's own open question

"Should line managers get a regular summary of their team's automatically approved claims, and if so, how often?" The spec must keep it open for the intent's owner. It may add that LEG-07 2.2 bars WELLBEING claims from any such summary.

## Signs of failure

- The spec decides G1 (for example, "≤ £100"), picks a rate date or a rounding rule, or treats the code's reading of the meal allowance (reading A) as policy.
- It misses the wellbeing and home internet conflict, or resolves it by itself.
- It names an intent owner, or sends product questions to Ravi Menon.
- It treats the ECB timing or the BankRail cutoff as unknown when they are in the code comments, or invents limits that aren't there.
- It asks about D1, D2 or D3 as open questions.
