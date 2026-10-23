import { Approval, Claim, ClaimLine, Person } from '../model';
import { convertUnrounded, latestRate } from '../fx/ecb';

// FIN-02 2.3 and 3.1, in payroll-currency minor units. Both are "or more" limits.
// The EUR figures are set by Finance, not converted from GBP (FIN-02 1.2).
export const FINANCE_STEP_FROM = { GBP: 50_000, EUR: 57_500 }; // £500 / €575
export const RECEIPT_REQUIRED_FROM = { GBP: 2_500, EUR: 3_000 }; // £25 / €30

// Wellbeing allowance per calendar month of spentOn (People Ops benefits handbook).
// People Ops checks it by hand when approving; the approval screen shows the
// month-to-date total.
export const WELLBEING_MONTHLY_CAP = { GBP: 4_000, EUR: 4_500 }; // £40 / €45

export type Step = Approval['step'];
type Ccy = 'GBP' | 'EUR';

// Contractors have no payroll currency. Their claims are checked in the currency
// of the company that engages them.
export function checkCurrency(p: Person): Ccy {
  return p.payrollCurrency ?? (p.entity === 'UK' ? 'GBP' : 'EUR');
}

// Indicative value of a line in the claimant's currency, using the latest
// published ECB rate at the moment of the check. Used for routing, receipt checks
// and display only. The amount actually paid is converted later, at the rate for
// the payroll cutoff date (src/payroll/export.ts), so it can differ from what the
// approver saw.
async function indicativeMinor(line: ClaimLine, ccy: Ccy): Promise<number> {
  const amount = line.approvedAmountMinor ?? line.amountMinor;
  if (line.currency === ccy) return amount;
  return convertUnrounded(amount, await latestRate(line.currency, ccy));
}

export async function indicativeTotalMinor(claim: Claim, p: Person): Promise<number> {
  const ccy = checkCurrency(p);
  let sum = 0;
  for (const line of claim.lines) sum += await indicativeMinor(line, ccy);
  return Math.round(sum); // display and routing only
}

// Steps a submitted claim must pass, in order. The UI keeps WELLBEING lines in
// claims of their own, so a claim is either all WELLBEING or has none.
export async function requiredSteps(claim: Claim, p: Person): Promise<Step[]> {
  const first: Step = claim.lines[0]?.category === 'WELLBEING' ? 'PEOPLE_OPS' : 'MANAGER';
  const total = await indicativeTotalMinor(claim, p);
  return total >= FINANCE_STEP_FROM[checkCurrency(p)] ? [first, 'FINANCE'] : [first];
}

// Lines that need a receipt and have none (FIN-02 3.1, 3.2). Blocks submission.
export async function linesMissingReceipt(claim: Claim, p: Person): Promise<ClaimLine[]> {
  const ccy = checkCurrency(p);
  const missing: ClaimLine[] = [];
  for (const line of claim.lines) {
    if (line.category === 'MEAL_ALLOWANCE_DE' || line.receiptId) continue;
    if ((await indicativeMinor(line, ccy)) >= RECEIPT_REQUIRED_FROM[ccy]) missing.push(line);
  }
  return missing;
}

// Decisions since the latest submission. A resubmitted claim starts again from
// the first step: earlier approvals stay in the history but are not reused.
function currentRound(claim: Claim): Approval[] {
  return claim.approvals.filter((a) => claim.submittedAt !== null && a.at >= claim.submittedAt);
}

export async function nextStep(claim: Claim, p: Person): Promise<Step | null> {
  const done = new Set(currentRound(claim).filter((a) => a.decision === 'APPROVED').map((a) => a.step));
  return (await requiredSteps(claim, p)).find((s) => !done.has(s)) ?? null;
}

// The MANAGER step goes to Person.managerId as it is when the approver opens the
// queue, so a pending claim follows the claimant if their manager changes.
export async function decide(
  claim: Claim,
  p: Person,
  step: Step,
  byPersonId: string,
  decision: Approval['decision'],
  comment: string | null,
): Promise<Claim> {
  if (claim.status !== 'SUBMITTED') throw new Error(`claim ${claim.id} is ${claim.status}`);
  if ((await nextStep(claim, p)) !== step) throw new Error(`step ${step} is not next`);
  claim.approvals.push({ step, by: byPersonId, decision, at: new Date().toISOString(), comment });
  if (decision === 'RETURNED') claim.status = 'RETURNED';
  else if (decision === 'REJECTED') claim.status = 'REJECTED';
  else if ((await nextStep(claim, p)) === null) claim.status = 'APPROVED';
  return claim;
}
