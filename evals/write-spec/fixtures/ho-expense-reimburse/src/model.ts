// Core types for Fernhill Expenses.
// Amounts are integers in minor units (pence, cents) unless a comment says otherwise.

export type Entity = 'UK' | 'DE'; // Fernhill Analytics Ltd / Fernhill Analytics GmbH
export type PayrollCurrency = 'GBP' | 'EUR';

export interface Person {
  id: string;
  kind: 'EMPLOYEE' | 'CONTRACTOR';
  entity: Entity; // for contractors, the company that engages them
  workEmail: string;
  managerId: string | null;
  costCentre: string;
  payrollCurrency: PayrollCurrency | null; // null for contractors, who are not on payroll
  active: boolean; // false from the day after the last working day (src/hr/sync.ts)
  // Not held in this app: bank details (PayFront only), personal email, home address,
  // leaving date, notice date.
}

export type Category =
  | 'TRAVEL'
  | 'HOTEL'
  | 'MEALS_UK' // UK staff: actual meal costs on business travel
  | 'MEAL_ALLOWANCE_DE' // German staff: daily allowance, computed (src/claims/meal-allowance.ts)
  | 'CLIENT_ENTERTAINMENT'
  | 'SUPPLIES'
  | 'HOME_INTERNET_UK'
  | 'WELLBEING'
  | 'OTHER';

export type ClaimStatus =
  | 'DRAFT'
  | 'SUBMITTED'
  | 'RETURNED' // sent back to the claimant for changes; can be resubmitted
  | 'APPROVED'
  | 'REJECTED' // final
  | 'WITHDRAWN'
  | 'EXPORTED' // in a PayFront run (or the AP file, for contractors)
  | 'PAID'; // set from PayFront's payslip file after payday

export interface Claim {
  id: string;
  personId: string;
  status: ClaimStatus;
  firstSubmittedAt: string | null; // ISO timestamp of the first submission
  submittedAt: string | null; // latest submission; a RETURNED claim is resubmitted under the same id
  lines: ClaimLine[];
  approvals: Approval[]; // full history, including RETURNED decisions
  payrollRun: string | null; // e.g. '2026-03', set on export
  // No field links a claim to another claim or to a trip.
}

export interface ClaimLine {
  id: string;
  category: Category;
  spentOn: string; // date on the receipt, YYYY-MM-DD
  description: string;
  amountMinor: number; // in `currency`, as on the receipt
  currency: string; // ISO 4217; whatever the claimant paid in
  receiptId: string | null;
  approvedAmountMinor: number | null; // set only when Finance Operations reduces the line (FIN-02 6.1), in `currency`
  reductionReason: string | null;
  mealAllowance: MealAllowanceDetail | null; // MEAL_ALLOWANCE_DE only
}

export interface MealAllowanceDetail {
  country: string; // ISO 3166-1 alpha-2 of the destination; 'DE' for domestic trips
  days: Array<{
    date: string;
    kind: 'FULL' | 'PARTIAL'; // FULL = 24 hours away; PARTIAL = more than 8 hours, or departure/return day
    breakfastProvided: boolean;
    lunchProvided: boolean;
    dinnerProvided: boolean;
  }>;
}

export interface Receipt {
  id: string;
  storageKey: string; // object store key of the image
  sha256: string; // of the uploaded file; matches only byte-identical uploads
  contentType: string;
  uploadedAt: string;
}

export interface Approval {
  step: 'MANAGER' | 'PEOPLE_OPS' | 'FINANCE';
  by: string; // Person.id of whoever decided; required
  decision: 'APPROVED' | 'RETURNED' | 'REJECTED';
  at: string;
  comment: string | null;
}
