// Attendance codes (BP 5113, 2.3 and 3.1).

// The teacher's mark for one class period, or for one session in elementary schools.
export type MarkCode = 'P' | 'T' | 'A' | 'SA';

export const MARK_CODES: Record<MarkCode, { label: string; countsAsPresent: boolean }> = {
  P: { label: 'Present', countsAsPresent: true },
  T: { label: 'Tardy: arrived within the first 15 minutes', countsAsPresent: true },
  A: { label: 'Absent, including arriving more than 15 minutes late', countsAsPresent: false },
  SA: { label: 'School activity: field trip, competition, contest', countsAsPresent: true },
};

// The attendance clerk's reason for a student's absences on one day. It applies to every
// period or session the student missed that day.
export type ReasonCode = 'EX' | 'UV' | 'UX';

export const REASON_CODES: Record<ReasonCode, string> = {
  EX: 'Excused',
  UV: 'Unverified: no guardian has given a reason yet',
  UX: 'Unexcused',
};
