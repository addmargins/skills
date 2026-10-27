# Intent: Cancel and reschedule appointments in the app, refunded by policy, across branches

Supersedes: 0002-app-cancellation-en.md

## Problem
Patients pay a 10,000 won deposit when they book in the app, but cannot cancel or move the appointment there: the app's cancel button only shows the call center number (`src/booking/cancel.ts`). Desk staff work out each refund by hand, so the same case gets different refunds at different branches. Raised by Seoyeon Park, head of customer experience.

## Desired outcome
- A patient can cancel or move their own appointment in the app without calling.
- A cancellation refunds the amount the deposit policy (`docs/policies/deposit-and-no-show-fee.md`) gives, with no staff input.

## Scope and constraints
- In scope: cancel or move up to 3 hours before the appointment; after that, the app points to the call center.
- In scope: a move to the same department at another branch, with no second deposit.

## Open questions
- Whether a patient who moves an appointment may also change the doctor.
  a. Same doctor only.
  b. Any doctor in the same department.
