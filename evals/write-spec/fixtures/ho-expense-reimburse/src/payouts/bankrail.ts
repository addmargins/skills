// BankRail payouts. Used today only for travel advances (FIN-02 5.3).
//
// Fernhill has two BankRail accounts: GBP for Fernhill Analytics Ltd and EUR for
// Fernhill Analytics GmbH. A payout is made from the account of the claimant's
// company, in that account's currency. BankRail does no currency conversion for us.
//
// Timings and limits (BankRail service schedule, 2025 contract):
// - A batch received by 14:00 Europe/London on a UK banking day is released that
//   day. A batch received later, or on a day that is not a UK banking day, is
//   released on the next UK banking day.
// - GBP payouts go by Faster Payments and normally reach the payee within
//   2 hours of release.
// - EUR payouts go by SEPA credit transfer and reach the payee's bank on the
//   next TARGET business day after release.
// - At most 250 payouts per batch.
// - If any payout in a batch fails validation (bad IBAN checksum, sort code not
//   reachable by Faster Payments), BankRail rejects the whole batch.
// - The payee's bank can return a payout (closed account, wrong account, name
//   mismatch). BankRail reports it by the payout.returned webhook up to 10 UK
//   banking days after release, and the money comes back to our account.
//   BankRail does not retry.
//
// Bank details: the employee types them into the advance request form. We send
// them to BankRail with the payout and delete them 30 days after the payout is
// sent (LEG-07 3.2; see purgeBankDetails). We never read bank details from PayFront.

import { db } from '../db';
import { notifyPaymentsDesk, sendEmail } from '../notify/email';

export const BATCH_LIMIT = 250;

export interface BankDetails {
  holderName: string;
  sortCode?: string; // GBP
  accountNumber?: string; // GBP
  iban?: string; // EUR
}

export interface Advance {
  id: string;
  personId: string;
  amountMinor: number;
  currency: 'GBP' | 'EUR'; // the currency of the claimant's company
  status: 'REQUESTED' | 'APPROVED' | 'SENT' | 'RETURNED' | 'SETTLED';
  bankDetails: BankDetails | null;
  bankRailPayoutId: string | null;
  sentAt: string | null; // when BankRail released the payout
}

export async function submitBatch(advances: Advance[]): Promise<void> {
  if (advances.length > BATCH_LIMIT) throw new Error('split the batch');
  const res = await bankRail('POST', '/v2/payout-batches', {
    payouts: advances.map((a) => ({
      reference: `FERNHILL ADV ${a.id}`,
      amount: a.amountMinor,
      currency: a.currency,
      payee: a.bankDetails,
    })),
  });
  if (res.status === 'REJECTED') throw new Error(`batch rejected: ${res.reason}`);
  for (const a of advances) {
    a.status = 'SENT';
    a.bankRailPayoutId = res.payoutIds[a.id];
  }
  await db.advances.saveAll(advances);
}

// Webhook: payout.released sets sentAt; payout.returned lands here.
export async function onPayoutReturned(evt: { payoutId: string; reason: string }): Promise<void> {
  const a = await db.advances.byPayoutId(evt.payoutId);
  a.status = 'RETURNED';
  await db.advances.save(a);
  await notifyPaymentsDesk(`Advance ${a.id} returned: ${evt.reason}`);
  await sendEmail(a.personId, 'advanceReturned', { advanceId: a.id });
}

// Daily job.
export async function purgeBankDetails(now: Date): Promise<void> {
  const cutoff = new Date(now.getTime() - 30 * 24 * 3600 * 1000).toISOString();
  for (const a of await db.advances.sentBefore(cutoff)) {
    a.bankDetails = null;
    await db.advances.save(a);
  }
}

declare function bankRail(method: string, path: string, body: unknown): Promise<any>;
