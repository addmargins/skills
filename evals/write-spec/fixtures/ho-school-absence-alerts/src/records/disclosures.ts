import { db } from '../db';

// Disclosure records (BP 5125, section 5). The Records and Privacy Office writes these when it
// releases records on request: transcripts to colleges, subpoenas, caseworker requests.
// Nothing else in Ledger writes them.
export interface DisclosureRecord {
  id: string;
  studentId: string;
  disclosedAt: string;   // UTC
  recipient: string;     // person and organization
  description: string;   // what was disclosed
  handledBy: string;     // staff id in the Records and Privacy Office
}

export const DISCLOSURE_VIEW_ROLES = ['RECORDS_ADMIN'] as const;

export function recordDisclosure(r: Omit<DisclosureRecord, 'id'>): DisclosureRecord {
  return db.disclosures.insert(r);
}

// Kept until five years after the student withdraws (BP 5125, 5.2). The message-log purge
// does not touch this table.
export function purgeDisclosures(now: Date): number {
  return db.disclosures.deleteWhere({ studentWithdrawnBefore: yearsAgo(now, 5) });
}

function yearsAgo(now: Date, years: number): string {
  const d = new Date(now);
  d.setFullYear(d.getFullYear() - years);
  return d.toISOString().slice(0, 10);
}
