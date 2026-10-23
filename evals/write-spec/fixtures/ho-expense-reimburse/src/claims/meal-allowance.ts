// German meal allowance (TAX-03 section 2). Amounts in euro cents.
// Computed when the claim is submitted; the claimant cannot edit the amount.

import { MealAllowanceDetail } from '../model';
import { db } from '../db';

const DOMESTIC = { FULL: 2_800, PARTIAL: 1_400 }; // TAX-03 2.1

// Abroad (TAX-03 2.2): each January, Finance loads the BMF country table for the
// year into bmf_country_rates (country, year, full_cents, partial_cents).
async function ratesFor(country: string, year: number): Promise<{ FULL: number; PARTIAL: number }> {
  if (country === 'DE') return DOMESTIC;
  const row = await db.bmfCountryRates.get(country, year);
  if (!row) throw new Error(`no BMF rate for ${country} ${year}`);
  return { FULL: row.full_cents, PARTIAL: row.partial_cents };
}

export async function mealAllowanceCents(detail: MealAllowanceDetail): Promise<number> {
  let total = 0;
  for (const day of detail.days) {
    const rates = await ratesFor(detail.country, Number(day.date.slice(0, 4)));
    const allowance = day.kind === 'FULL' ? rates.FULL : rates.PARTIAL;

    // TAX-03 2.3: meals provided free of charge.
    let reduction = 0;
    if (day.breakfastProvided) reduction += Math.round(allowance * 0.2);
    if (day.lunchProvided) reduction += Math.round(allowance * 0.4);
    if (day.dinnerProvided) reduction += Math.round(allowance * 0.4);

    total += Math.max(0, allowance - reduction);
  }
  return total;
}
