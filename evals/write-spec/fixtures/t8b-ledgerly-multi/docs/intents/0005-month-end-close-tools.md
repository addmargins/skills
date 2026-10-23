# Intent: Month-end close is slowed by matching payments and chasing overdue invoices by hand

## Problem
At every month-end close, the two in-house accountants spend most of a day on two manual jobs. They compare the company's bank statement with the open invoices and mark each paid invoice as paid in the admin console, one at a time (about 400 payments a month). Then they email each customer whose invoice is overdue, one by one, from their own mailboxes. Close regularly runs two working days late, and customers whom nobody gets round to reminding pay later still.

## Desired outcome
- An accountant can upload the month's bank-statement file in the admin console, and every invoice the statement shows as paid is marked paid in one step instead of one at a time.
- A customer whose invoice is 7 days overdue automatically gets a reminder email, without an accountant writing it.

## Affected users and systems
- Finance team accountants (2 people).
- Customers with overdue invoices.
- Admin console invoices page (`admin/src/pages/invoices/`), invoice service (`services/billing/`).

## Scope and constraints
- In scope: marking invoices paid from a bank-statement file; automatic reminder emails for overdue invoices.
- Out of scope: collecting payments or direct debit, late fees or interest, reminders by letter or phone.
- An invoice must not be marked paid unless the bank statement shows a payment for it. Reason: an invoice marked paid by mistake is never chased.

## Open questions
- None.
