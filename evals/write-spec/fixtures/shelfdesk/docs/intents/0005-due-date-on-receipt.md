# Intent: Members return items late because loan receipts don't show due dates

## Problem
Loan receipts list only the titles a member borrowed. Desk staff hand-write the due date next to each title, and members still return items late.

## Desired outcome
- Every printed loan receipt shows "Due: YYYY-MM-DD" on the line under each title.
- Desk staff stop hand-writing due dates on receipts.

## Affected users and systems
- Library members who borrow items, and the desk staff who check items out.
- Receipt printing (`receipts/print.ts`) and due-date calculation (`loans/loan.ts`).

## Scope and constraints
- In scope: the printed loan receipt.
- Out of scope: email receipts, the member app, loan periods.
- Every line must fit in 32 characters. Reason: the desk printers print 32 characters per line and can't be replaced this year.
- The receipt's existing lines keep their order.

## Open questions
- None.
