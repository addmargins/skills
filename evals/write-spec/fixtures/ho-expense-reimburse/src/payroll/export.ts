// Monthly export of approved claims to PayFront (payroll) and of contractor
// claims to Accounts Payable.
//
// Cutoff (FIN-02 5.2): a claim whose last approval step was completed by
// 23:59:59 Europe/London on the 18th goes into that month's run. The job runs at
// 00:30 on the 19th. Payday is the last working day of the month: England and
// Wales bank holidays for the UK company, Berlin public holidays for the German
// company. PayFront sets payday; we only show it in emails.
//
// Conversion (FIN-02 4.2): each line in another currency is converted into the
// payroll currency at the ECB rate for the 18th (rateOn falls back to the last
// earlier rate when the 18th has none). Converted values are sent unrounded, with
// 4 decimal places. PayFront adds up each employee's lines in the run and rounds
// that total half-up to 2 decimal places, once per employee per run. This service
// never rounds an amount that is paid.
//
// Tax (TAX-03 4.1): lines in TAXABLE_CATEGORIES are sent with taxable=Y so that
// PayFront withholds income tax and social security on them.
//
// Recoveries (FIN-02 6.2): amounts Finance Operations enters for recovery go into
// the next run as negative rows.
//
// Contractors are not on payroll. Their approved claims go to the AP file in the
// currency of each line, unconverted; AP pays them with the contractor's next
// invoice.
//
// PayFront has no API. We upload a CSV over SFTP and receive a payslip file
// after payday, from which claims are marked PAID. PayFront holds staff bank
// details; this app never sees them.

import { Category, Claim, Person } from '../model';
import { convertUnrounded, rateOn } from '../fx/ecb';
import { db } from '../db';

export const TAXABLE_CATEGORIES: Record<'UK' | 'DE', Category[]> = {
  UK: ['WELLBEING', 'HOME_INTERNET_UK'],
  DE: ['WELLBEING'],
};

interface PayFrontRow {
  personId: string;
  claimId: string;
  lineId: string;
  amount: string; // major units, 4 decimal places, payroll currency
  taxable: 'Y' | 'N';
}

export function cutoffFor(year: number, month: number): Date {
  return zoned(year, month, 18, 23, 59, 59, 'Europe/London');
}

export async function buildRun(year: number, month: number): Promise<void> {
  const runId = `${year}-${String(month).padStart(2, '0')}`;
  const rateDate = `${runId}-18`;
  const claims: Claim[] = await db.claims.approvedNotExported({ lastApprovalBy: cutoffFor(year, month) });
  const payroll: PayFrontRow[] = [];
  const ap: string[] = [];

  for (const claim of claims) {
    const p: Person = await db.people.get(claim.personId);
    for (const line of claim.lines) {
      const amount = line.approvedAmountMinor ?? line.amountMinor;
      if (p.kind === 'CONTRACTOR') {
        ap.push([p.id, claim.id, line.id, (amount / 100).toFixed(2), line.currency].join(','));
        continue;
      }
      const ccy = p.payrollCurrency!;
      const minor = line.currency === ccy ? amount : convertUnrounded(amount, await rateOn(rateDate, line.currency, ccy));
      payroll.push({
        personId: p.id,
        claimId: claim.id,
        lineId: line.id,
        amount: (minor / 100).toFixed(4),
        taxable: TAXABLE_CATEGORIES[p.entity].includes(line.category) ? 'Y' : 'N',
      });
    }
    claim.status = 'EXPORTED';
    claim.payrollRun = runId;
  }

  payroll.push(...(await db.recoveries.pendingRows(runId)));
  await sftpPut(`payfront/claims-${runId}.csv`, payroll);
  await sftpPut(`ap/contractor-claims-${runId}.csv`, ap);
  await db.claims.saveAll(claims);
}

declare function zoned(y: number, m: number, d: number, h: number, mi: number, s: number, tz: string): Date;
declare function sftpPut(path: string, rows: unknown[]): Promise<void>;
