# Intent: Finance can't get invoice data out of the admin console

Superseded by: 0003-monthly-invoice-export.md

## Problem
The accountants can't get invoice data out of the admin console, so they copy it into their spreadsheet by hand.

## Desired outcome
- An accountant can download the invoices shown on the invoices page as a CSV file.

## Affected users and systems
- Finance team accountants (2 people).
- Admin console invoices page (`admin/src/pages/invoices/`).

## Scope and constraints
- In scope: a CSV download of the invoice list as currently filtered.
- Out of scope: other reports.

## Open questions
- Which columns the accountants need.
