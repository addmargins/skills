import { http } from '../http';
import { phones } from '../guardians/phones';
import { messageLog } from './messageLog';

// TextBridge SMS client.
//
// Limits from the TextBridge contract (TS-2024-07). Keep this comment up to date:
//   - 1 message per second per sending number. We have three long-code numbers, so 3 messages
//     per second for the whole district. Above that rate TextBridge answers HTTP 429 and drops
//     the message. Nothing is queued on their side, so the caller must retry.
//   - 25,000 segments per day for the whole account, shared with EmergencyNotify. A district-wide
//     closure text uses about 21,000 segments.
//   - A segment holds 160 GSM-7 characters. A single character outside GSM-7 (Vietnamese or
//     Arabic letters, curly quotes) turns the whole message into UCS-2, at 70 characters a segment.
//   - TextBridge deletes message content and recipient numbers 90 days after sending (contract, 9).

const TEXTBRIDGE_URL = process.env.TEXTBRIDGE_URL!;
const SENDING_NUMBERS = ['+15550100201', '+15550100202', '+15550100203'];
const HELP_TEXT = 'Merrow Valley Schools. For help call +1 555 010 0100. Reply STOP to stop texts.';

export type SendStatus =
  | 'ACCEPTED'        // taken by TextBridge; a delivery receipt may follow
  | 'RATE_LIMITED'    // HTTP 429, dropped
  | 'INVALID_NUMBER'
  | 'LANDLINE'        // the number cannot receive texts
  | 'OPTED_OUT'       // the number has replied STOP
  | 'PROVIDER_ERROR'; // 5xx or timeout

let next = 0;
function nextSendingNumber(): string {
  next = (next + 1) % SENDING_NUMBERS.length;
  return SENDING_NUMBERS[next];
}

export async function sendSms(to: string, body: string): Promise<{ status: SendStatus; providerId?: string }> {
  const res = await http.post(`${TEXTBRIDGE_URL}/v2/messages`, { from: nextSendingNumber(), to, body }, { timeoutMs: 10_000 });
  if (res.status === 429) return { status: 'RATE_LIMITED' };
  if (res.status >= 500 || res.timedOut) return { status: 'PROVIDER_ERROR' };
  if (res.body.error === 'not_mobile') return { status: 'LANDLINE' };
  if (res.body.error === 'invalid_number') return { status: 'INVALID_NUMBER' };
  if (res.body.error === 'unsubscribed') return { status: 'OPTED_OUT' };
  return { status: 'ACCEPTED', providerId: res.body.id };
}

// Delivery receipts arrive by webhook: DELIVERED, or UNDELIVERED when the carrier rejects the
// message. Some carriers never send a receipt.
export function onDeliveryReceipt(providerId: string, status: 'DELIVERED' | 'UNDELIVERED'): void {
  messageLog.updateStatus(providerId, status);
}

// Replies to any of the district's numbers. Only the keywords are acted on: STOP sets
// Phone.smsOptOut, START clears it, HELP answers with HELP_TEXT. Any other reply is acknowledged
// to TextBridge and dropped. It is not stored or forwarded to anyone.
export function onInboundSms(from: string, body: string): void {
  const word = body.trim().toUpperCase();
  if (word === 'STOP') return phones.setOptOut(from, true);
  if (word === 'START') return phones.setOptOut(from, false);
  if (word === 'HELP') {
    void sendSms(from, HELP_TEXT);
    return;
  }
}
