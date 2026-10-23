import { MarkCode, ReasonCode } from './codes';
import { db } from '../db';
import { schoolDaysAfter, endOfDayLocal } from '../calendar';

// One mark per student, section, period (or session), and day.
export interface PeriodMark {
  studentId: string;
  sectionId: string;
  date: string;        // school-local date, 'YYYY-MM-DD'
  period: number;      // 1-7; in elementary schools 1 = morning session, 2 = afternoon session
  code: MarkCode;
  markedBy: string;    // staff id of whoever wrote it last: the teacher or an attendance clerk
  markedAt: string;    // UTC timestamp of the last write
}

// A teacher's submission of the whole roll for one section and period.
export interface PeriodRoll {
  sectionId: string;
  date: string;
  period: number;
  teacherId: string;
  submittedAt?: string; // unset until submitted. Ledger reminds the teacher at 15 minutes but
                        // accepts a roll at any time of day.
}

// The reason for a student's absences on one day (BP 5113, section 3). At most one per student per day.
export interface DayRecord {
  studentId: string;
  date: string;
  reason: ReasonCode;
  source: 'GUARDIAN_CALL' | 'GUARDIAN_NOTE' | 'GUARDIAN_EMAIL' | 'STAFF' | 'SYSTEM';
  enteredBy: string;    // staff id, or 'system'
  enteredAt: string;    // UTC
  changeNote?: string;  // required for a change after the teacher's correction window (BP 5113, 5.2)
}

// Submitting a roll rewrites every student's mark for that section and period, so the last write
// wins: a clerk's change made since the teacher's previous submission (for example A -> T for a
// student who signed in late with a pass) is overwritten if the teacher submits again.
export function submitRoll(roll: PeriodRoll, marks: PeriodMark[]): void {
  db.periodMarks.replaceAll({ sectionId: roll.sectionId, date: roll.date, period: roll.period }, marks);
  db.periodRolls.upsert({ ...roll, submittedAt: new Date().toISOString() });
  for (const m of marks) if (m.code === 'A') ensureDayRecord(m.studentId, m.date);
}

// An attendance clerk changes a single mark.
export function clerkSetMark(mark: PeriodMark, clerkId: string, changeNote?: string): void {
  db.periodMarks.upsert({ ...mark, markedBy: clerkId, markedAt: new Date().toISOString() });
  if (mark.code === 'A') ensureDayRecord(mark.studentId, mark.date);
  if (changeNote) db.auditLog.add({ kind: 'MARK_CHANGE', mark, clerkId, changeNote });
}

// The first A mark of the day creates the day record as UV with source SYSTEM, unless the
// clerk has already entered one (for example from a guardian's call before school).
function ensureDayRecord(studentId: string, date: string): void {
  if (db.dayRecords.find(studentId, date)) return;
  db.dayRecords.insert({
    studentId,
    date,
    reason: 'UV',
    source: 'SYSTEM',
    enteredBy: 'system',
    enteredAt: new Date().toISOString(),
  });
}

// Nightly at 02:00 district time. A UV record becomes UX once 11:59 p.m. (school-local) on the
// second school day after the absence has passed (BP 5113, 4.2). Days whose A marks have all been
// corrected away are skipped.
export function promoteUnverified(now: Date): void {
  for (const rec of db.dayRecords.where({ reason: 'UV' })) {
    const deadline = endOfDayLocal(schoolDaysAfter(rec.date, 2, rec.studentId), rec.studentId);
    if (now <= deadline) continue;
    if (!db.periodMarks.exists({ studentId: rec.studentId, date: rec.date, code: 'A' })) continue;
    db.dayRecords.update(rec, { reason: 'UX', source: 'SYSTEM', enteredBy: 'system', enteredAt: now.toISOString() });
  }
}
