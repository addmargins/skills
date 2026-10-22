import { Subscription } from "./types";
import { pg } from "./pg-client";
import { settlement } from "./settlement";

// Used by the admin console. CS agents enter the amount they computed by hand;
// this helper only pre-fills a suggestion.
export function suggestProratedRefund(sub: Subscription, now: Date): number {
  const totalDays = 365;
  const usedDays = Math.ceil((now.getTime() - sub.paidAt.getTime()) / 86_400_000);
  const remaining = Math.max(totalDays - usedDays, 0);
  return Math.floor((sub.paidAmount * remaining) / totalDays);
}

export async function issueRefund(sub: Subscription, amount: number, agentId: string, reasonCode: string) {
  // No approval step here: agents escalate large refunds to finance by chat.
  const result = await pg.cancelPayment(sub.paymentId, amount);
  await settlement.record({ subscriptionId: sub.id, amount, reasonCode, actor: agentId });
  return result;
}
