# Spec: Patients cancel or move appointments in the app and get the policy refund

Intent: 0002-app-cancellation-en.md

Status: 3 to decide before building, 1 that can wait for planning.

## Summary
Today a patient who paid a deposit in the app must phone to cancel, and desk staff work out the refund by hand. Patients will be able to cancel in the app up to 3 hours before the appointment and get the deposit policy's refund with no staff input (R1), or move it within the same branch and department (R2).

## Roles
- Originator (head of customer experience): the problem is solved; From the intent.
- Finance team lead, or whoever owns the deposit and refund policy: A1.
- Owner of patient notice rules, or whoever approves what patients are told about money: A2.
- Product owner for the booking app, or whoever decides its behavior: scope, and product behavior no other role decides.

## Requirements
### R1. Patient: Cancel in the app
A patient must be able to cancel their own appointment in the app up to 3 hours before it starts. On confirming, the amount the deposit policy gives must go back to the card that paid, with no staff input. The amount for each cancellation time is set by Q1.

- Given a 2026-11-10 10:00 appointment with a 10,000 won deposit, when the patient cancels at 2026-11-08 15:00, then the appointment is cancelled and the amount Q1 sets for a cancellation 43 hours before goes back to the card, with no staff input.
- Given the same appointment, when the patient tries at 2026-11-10 07:30, then the app does not cancel it and shows the call center number.

The cancellation text names the branch and time, as today (current behavior, S1 (Booking cancellation)).

### R2. Patient: Move within the branch
A patient must be able to move an appointment up to 3 hours before it starts to another open slot in the same branch and department, without paying a second deposit.

- Given a 2026-11-10 10:00 appointment, when the patient moves it to the same doctor's open 2026-11-20 14:30 slot, then the new time is booked and no payment screen appears.

## Changes to existing behavior
- Today: the app's cancel button shows only the call center number, and desk staff cancel and enter the refund (current behavior, S1 (Booking cancellation)). After: see R1 (Cancel in the app). Affects: app patients, call center, branch desks. Can be undone: refunds already made stay made.

## What this work touches
This work changes each area below, and policies or laws often govern areas like these. For each area, the named role confirms which policies or laws apply and what they require. A quoted clause is only a starting point for that role; this spec does not interpret it. Rules kept outside this workspace may also govern any area.

### Finance team lead, or whoever owns the deposit and refund policy
- A1. Deposit refunds made by the app
  - Affects: R1 (Cancel in the app).
  - Policy text: Deposit policy (S2), 4.1: "A cancellation up to one day before the appointment gets the whole deposit back."
  - Policy text: Deposit policy (S2), 4.2: "A later cancellation up to 3 hours before gets 50% back."
  - Policy text: Deposit policy (S2), 4.3: "A cancellation after that gets nothing back."
  - Confirm in: Q1.

### Owner of patient notice rules, or whoever approves what patients are told about money
- A2. Messages to patients about a cancellation
  - Affects: R1 (Cancel in the app).
  - Policy text: Patient notice rules (S3), 2.1: “A cancellation text must give: the branch and the time of the appointment; the amount refunded, if any.”
  - Confirm in: Q2.

## From the intent
- Outcome "A patient can cancel or move their own appointment in the app without calling": R1 (Cancel in the app), R2 (Move within the branch).
- Outcome "A cancellation refunds the amount the deposit policy (`docs/policies/deposit-and-no-show-fee.md`) gives, with no staff input": R1 (Cancel in the app), with the amount confirmed in Q1.
- Question "Whether a patient who moves an appointment may also change the doctor": carried as Q3.

## Open questions
Everything outside these questions is decided. Questions under "Decide before building" leave open a case, a step, who qualifies, money, data, a behavior, or the rules for an area, so they must be answered before building starts. Questions under "Can wait for planning" only fill in a value, a wording, a label, or a format; the plan leaves these blank and fills them in before release. The role under "Who answers" decides. Anyone may settle a question of fact by checking.

### Decide before building
- Q1. Rules for refunds the app makes
  - What is unclear: which policies or laws govern A1 (Deposit refunds made by the app), and what amount they give for each cancellation time, such as 2026-11-09 12:00 for a 2026-11-10 10:00 appointment.
  - Depends on the answer: the amount R1 (Cancel in the app) refunds in each case, and whether any case still needs staff input.
  - To resolve: the role confirms the governing rules; the clauses quoted under A1 are a lead.
  - Who answers: finance team lead, or whoever owns the deposit and refund policy.
- Q2. Rules for cancellation messages
  - What is unclear: which policies or laws govern what patients are told when the app cancels and refunds (A2 (Messages to patients about a cancellation)), and what they require.
  - Depends on the answer: what R1 (Cancel in the app) shows before and after a cancellation, and what its text says.
  - To resolve: the role names the governing rules; the clause quoted under A2 is a lead.
  - Who answers: owner of patient notice rules, or whoever approves what patients are told about money.
- Q3. Changing the doctor when moving
  - What is unclear: whether a move may switch to another doctor in the same department.
  - Depends on the answer: with a, R2 (Move within the branch) shows only the same doctor's slots; with b, it also shows other doctors' slots and a doctor choice.
  - To resolve: decide whether a move may change the doctor; the intent offers a and b.
  - Who answers: originator (head of customer experience).

### Can wait for planning
- Q4. Wording after a move
  - What is unclear: the wording of the confirmation R2 (Move within the branch) shows once the new time is booked.
  - Depends on the answer: only the text on that screen.
  - To resolve: write the wording.
  - Who answers: product owner for the booking app, or whoever decides its behavior.

## Sources
<details><summary>For engineers: where each cited fact was read (other readers can skip this)</summary>

- S1. Booking cancellation: src/booking/cancel.ts, cancelBooking.
- S2. Deposit policy: policies/POL-FIN-007-en.md, section 4.
- S3. Patient notice rules: `policies/POL-NTC-003-en.md`, clause 2.1.

</details>
