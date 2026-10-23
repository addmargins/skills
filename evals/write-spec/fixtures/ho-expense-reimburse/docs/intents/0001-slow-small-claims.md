# Intent: Staff wait weeks to be repaid for small expense claims

## Problem
Staff who pay for work costs themselves wait weeks to get the money back, even for small amounts. Every claim waits for an approver, and approved claims are paid only with the monthly salary: a claim approved after the 18th is paid at the end of the following month (`src/payroll/export.ts`). In Q1 and Q2 2026, claims under £200 took 26 days on average from submission to payment, according to the finance team's quarterly report. Junior staff carry these costs on personal cards, and team leads report people turning down client visits because of it.

It matters now because the Berlin delivery centre opens in January 2027 and adds about 60 German staff, most of whom will travel to London in their first months.

## Desired outcome
Small claims are approved automatically, without waiting for a line manager or any other approver. The auto-approval threshold is £100 for UK staff and €115 for German staff, applied to the claim's total. Every automatically approved claim reaches the claimant's bank account within 5 working days of submission. It is paid in the claimant's home currency, meaning the currency their salary is paid in, not the currency the expense was paid in. All other claims are approved and paid as they are today.

## Affected users and systems
- Staff of Fernhill Analytics Ltd (UK) and Fernhill Analytics GmbH (Germany) who submit expense claims.
- Line managers and the People Ops benefits team, who approve claims today (`src/claims/approval.ts`).
- Finance Operations, who check claims and pay travel advances through BankRail (`src/payouts/bankrail.ts`).
- Payroll and the monthly PayFront export, through which every claim is paid today (`src/payroll/export.ts`).

## Scope and constraints
- In scope: claims in every expense category, including German meal allowances, wellbeing claims and home internet claims, so that staff don't have to know which kinds of claim are paid quickly.
- Out of scope: travel advances, which BankRail already pays; company card transactions; any change to the approval route for other claims, including the £500 / €575 Finance Operations step.
- Payouts must go through BankRail, which Fernhill already uses for travel advances, so that no new supplier review is needed.
- The change must follow the expense, records and tax policies in `docs/policies/`.

## Open questions
- Should line managers get a regular summary of their team's automatically approved claims, and if so, how often?
