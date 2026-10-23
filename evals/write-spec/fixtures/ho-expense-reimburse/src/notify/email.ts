// Emails sent by the app. Every email goes to Person.workEmail: the app has no
// other address for anyone (src/hr/sync.ts). Work accounts close at the end of a
// person's last working day (LEG-07 5.1).
//
// Nothing is sent when a claim is exported or paid.

import { db } from '../db';

type Vars = Record<string, string>;

export const templates: Record<string, (v: Vars) => string> = {
  // To whoever acts on the next step.
  claimSubmitted: (v) => `${v.claimantName} submitted claim ${v.claimId} for ${v.indicativeTotal}.`,

  // To the claimant, when the last required step approves.
  claimApproved: (v) =>
    `Claim ${v.claimId} was approved by ${v.approverName}. It will be paid with your ` +
    `${v.payrollMonth} salary on ${v.payday}. Lines in other currencies are converted at ` +
    `the rate for the 18th, so the amount paid may differ slightly from ${v.indicativeTotal}.`,
  claimReturned: (v) => `${v.approverName} returned claim ${v.claimId} for changes: ${v.comment}`,
  claimRejected: (v) => `${v.approverName} rejected claim ${v.claimId}: ${v.comment}`,
  lineReduced: (v) =>
    `Finance Operations reduced a line of claim ${v.claimId} from ${v.oldAmount} to ${v.newAmount}. Reason: ${v.reason}`,
  recoveryNotice: (v) =>
    `We paid you ${v.amount} too much for claim ${v.claimId}. ` +
    `We will deduct it from your next salary payment (FIN-02 6.2).`,

  advanceSent: (v) => `Your travel advance of ${v.amount} has been sent to your bank.`,
  advanceReturned: (v) =>
    `Your bank returned travel advance ${v.advanceId}. The Payments desk will contact you.`,
};

export async function sendEmail(personId: string, template: string, vars: Vars): Promise<void> {
  const p = await db.people.get(personId);
  await smtp(p.workEmail, templates[template](vars));
}

export async function notifyPaymentsDesk(text: string): Promise<void> {
  await smtp('payments-desk@fernhill.example', text);
}

declare function smtp(to: string, body: string): Promise<void>;
