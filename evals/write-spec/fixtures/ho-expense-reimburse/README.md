# Fernhill Expenses

Fernhill Expenses is the internal app that Fernhill Analytics staff use to claim back money they spent for work. It serves two companies:

- Fernhill Analytics Ltd, in London and Leeds, which pays salaries in GBP.
- Fernhill Analytics GmbH, in Berlin, which pays salaries in EUR.

About 375 employees use it (240 in the UK, 135 in Germany). About 35 contractors, who are engaged through their own companies, are also in the HR feed so that they can claim travel costs.

## How it works today

1. A claimant adds lines (one per expense), photographs the receipts, and submits the claim.
2. The claim goes to an approver. Large claims also go to Finance Operations.
3. Once a month, approved claims are exported to PayFront, our payroll bureau, and paid with salary. Contractors' claims go to Accounts Payable instead.
4. Finance Operations can correct a claim, and recover money paid in error.

Staff can also request a travel advance before a trip. Advances are paid by bank transfer through BankRail, not through payroll.

## Repository layout

```
src/
  model.ts                   people, claims, lines, receipts, approvals
  hr/sync.ts                 nightly import of people from the HR system
  claims/approval.ts         approval routing, receipt checks, decisions
  claims/meal-allowance.ts   German meal allowance calculation
  fx/ecb.ts                  ECB euro reference rates and conversion
  payroll/export.ts          monthly export to PayFront and Accounts Payable
  payouts/bankrail.ts        BankRail payouts (travel advances)
  notify/email.ts            emails to claimants and approvers
docs/
  policies/                  company policies the app must follow; each names its owner
  intents/                   intent documents for proposed changes
```

## Systems we connect to

| System | What for | How |
|---|---|---|
| HR system | People, managers, employment type, status | Nightly CSV over SFTP |
| PayFront | Payroll for both companies; holds staff bank details | Monthly file over SFTP |
| BankRail | Bank transfers (travel advances) | REST API and webhooks |
| European Central Bank | Daily euro reference rates | Public XML feed |
| Accounts Payable | Contractor claims | Monthly CSV |

## Maintainers

The Finance Systems team maintains the app (lead: Ravi Menon). Questions about a policy go to the owner named in that policy.
