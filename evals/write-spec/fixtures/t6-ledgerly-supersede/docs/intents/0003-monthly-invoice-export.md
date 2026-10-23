# Intent: Accountants re-key invoice data by hand at every month-end close

Superseded by: 0004-monthly-invoice-and-credit-note-export.md

## Problem
Our two in-house accountants spend about one working day at each month-end close copying invoice data from the admin console into their spreadsheet, one invoice at a time, because the console has no export. It matters now because from January 2027 our new external auditor wants the full monthly invoice list as a file.

## Desired outcome
- An accountant can download one file per calendar month that lists every invoice issued in that month, with: invoice number, issue date, customer name, net amount, VAT amount, gross amount, currency, and payment status.
- The file opens in the accountants' Excel without any reformatting.
- Month-end close no longer includes re-keying invoices by hand.

## Affected users and systems
- Finance team accountants (2 people). The external auditor receives the file from them.
- Admin console invoices page (`admin/src/pages/invoices/`), invoice service (`services/billing/`).

## Scope and constraints
- In scope: exporting the invoices of one chosen calendar month from the admin console.
- Out of scope: scheduled or emailed exports, credit notes, other reports.
- Must follow the data export policy SEC-04 (`docs/policies/SEC-04-data-export.md`).
- Must not include card or bank account details. Reason: the auditor does not need them and the file leaves the company.

## Open questions
- None.
