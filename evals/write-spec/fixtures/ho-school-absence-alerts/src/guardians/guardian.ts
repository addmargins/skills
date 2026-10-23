// Adults linked to students, the households they live in, and the links between them.
// Ledger calls every linked adult a "guardian", whatever the legal relationship. The flags on
// GuardianLink say what each one may do.

export type Relationship =
  | 'MOTHER'
  | 'FATHER'
  | 'STEPPARENT'
  | 'GRANDPARENT'
  | 'OTHER_RELATIVE'
  | 'LEGAL_GUARDIAN'
  | 'FOSTER_PARENT'
  | 'CASEWORKER'
  | 'OTHER';

export interface Guardian {
  id: string;
  firstName: string;
  lastName: string;
  phones: Phone[];       // in the order the family listed them
  email?: string;
}

export interface Phone {
  number: string;        // E.164
  type: 'MOBILE' | 'HOME' | 'WORK';
  textConsent: boolean;  // "OK to text this number" box. It was added to the annual update form
                         // in 2024-25; numbers entered before then stay false until the family
                         // fills in a new form.
  smsOptOut: boolean;    // set by a STOP reply, cleared by START (see notify/smsClient.ts)
}

export interface Household {
  id: string;
  address: Address;
  primaryContactGuardianId: string; // exactly one per household
}

// One row per student and linked adult.
export interface GuardianLink {
  studentId: string;
  guardianId: string;
  householdId?: string;       // unset for adults outside the student's households, such as caseworkers
  relationship: Relationship;
  hasCustody: boolean;        // from the custody section of the enrollment form
  educationalRights: boolean; // holds educational rights (BP 5125, 1.2)
  courtRestricted: boolean;   // a court order on file limits this person's access to records or contact
  emergencyOrder?: number;    // 1 = call first in an emergency
  receivesMail: boolean;      // gets duplicate copies of mailed report cards and notices;
                              // set when a parent asks the office for copies (form RC-2)
  active: boolean;            // cleared by the clerk when the relationship ends, e.g. a foster placement
}

export interface Address {
  line1: string;
  line2?: string;
  city: string;
  state: string;
  zip: string;
}
