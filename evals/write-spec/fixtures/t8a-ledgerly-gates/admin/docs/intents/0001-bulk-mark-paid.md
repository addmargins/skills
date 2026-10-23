# Intent: Accountants mark paid invoices one at a time

## Problem
After each weekly bank statement arrives, the two accountants open every invoice that was paid that week in the admin console and mark it paid, one invoice at a time. A typical week has 80 to 120 payments, which takes about two hours. Until someone gets to them, paid invoices still show as open or overdue, so support sometimes chases customers who have already paid.

## Desired outcome
- An accountant can select several invoices on the invoices page and mark them all paid in one action.
- Marking a week's payments takes under 15 minutes.

## Affected users and systems
- Finance team accountants (2 people). Support staff, who read invoice status when customers call.
- Admin console invoices page (`admin/src/pages/invoices/`), invoice service (`services/billing/`), roles (`config/roles.yaml`).

## Scope and constraints
- In scope: marking several selected invoices paid at once from the invoices page.
- Out of scope: importing bank statement files, matching payments to invoices automatically, partial payments.
- Only users whose role can mark invoices paid today may use it. Reason: the same people stay responsible for payment status.

## Open questions
- None.
