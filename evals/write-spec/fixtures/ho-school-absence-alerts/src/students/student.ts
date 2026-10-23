// Student records.
// Paper documents (custody orders, signed consent forms, the Home Language Survey) are
// scanned into DocuVault. Ledger keeps only the fields below.

export interface Student {
  id: string;                 // district student number
  firstName: string;
  lastName: string;
  dateOfBirth: string;        // 'YYYY-MM-DD'
  grade: number;              // 0 = kindergarten
  schoolId: string;
  homeLanguage: string;       // ISO 639-1. From the Home Language Survey at first enrollment:
                              // "Which language does your child use most often at home?"
                              // Used to screen for English learner services.
  fosterCare: boolean;        // set by the foster care point of contact
  households: StudentHousehold[];
  status: 'ACTIVE' | 'WITHDRAWN';
  withdrawnOn?: string;
}

export interface StudentHousehold {
  householdId: string;
  livesHere: boolean;          // the student lives in this household, full time or part time
  isPrimaryResidence: boolean; // exactly one per student; sets the mailing address and bus stop
}

// Age in whole years on a given date. Used by state reporting.
export function ageOn(student: Student, date: string): number {
  const [by, bm, bd] = student.dateOfBirth.split('-').map(Number);
  const [y, m, d] = date.split('-').map(Number);
  return y - by - (m < bm || (m === bm && d < bd) ? 1 : 0);
}
