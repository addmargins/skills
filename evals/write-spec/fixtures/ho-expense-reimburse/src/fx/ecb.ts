// Euro foreign exchange reference rates from the European Central Bank.
//
// The ECB publishes one set of reference rates a day, normally around 16:00 CET,
// and only on TARGET business days. There are no rates for weekends or for
// TARGET closing days (1 January, Good Friday, Easter Monday, 1 May, 25 and
// 26 December). Rates are quoted as 1 EUR = x units of the other currency; any
// other pair is crossed through EUR.
//
// fetchDaily() runs at 16:30 Europe/Berlin on weekdays and stores the day's rates
// in fx_rates. Until it has run, there is no row for today.

import { db } from '../db';

const FEED = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml';

export async function fetchDaily(): Promise<void> {
  const xml = await (await fetch(FEED)).text();
  const date = /time=['"](\d{4}-\d{2}-\d{2})['"]/.exec(xml)?.[1];
  if (!date) throw new Error('ECB feed: no date');
  for (const m of xml.matchAll(/currency=['"]([A-Z]{3})['"] rate=['"]([\d.]+)['"]/g)) {
    await db.fxRates.upsert({ rateDate: date, currency: m[1], perEur: Number(m[2]) });
  }
}

async function perEur(currency: string, onOrBefore?: string): Promise<number> {
  if (currency === 'EUR') return 1;
  const row = await db.fxRates.latest(currency, onOrBefore); // rate_date <= onOrBefore, newest first
  if (!row) throw new Error(`no ECB rate for ${currency}`);
  return row.perEur;
}

// Rate to convert `from` into `to` for a date: the rate stored for that date or,
// if there is none, the latest rate stored before it.
export async function rateOn(date: string, from: string, to: string): Promise<number> {
  return (await perEur(to, date)) / (await perEur(from, date));
}

// Latest stored rate, whatever its date. Used for indicative amounts.
export async function latestRate(from: string, to: string): Promise<number> {
  return (await perEur(to)) / (await perEur(from));
}

// Converts minor units of one currency into minor units of another. No rounding.
export function convertUnrounded(amountMinor: number, rate: number): number {
  return amountMinor * rate;
}
