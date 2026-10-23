# Intent: Families hear about an unexplained absence the same morning

## Problem
When a student misses school and no guardian has told the school why, the family's first notice is the automated evening call at 6:00 p.m. (`src/jobs/eveningCall.ts`), and many families don't answer it. Until then, a student who left home for school and never arrived is unaccounted for all day. Marisol Ortega, assistant principal at Merrow Valley High School, raised this after two such cases in September 2026, in which the families learned of the absence that evening. After reviewing those cases in October, the district safety committee asked every school to shorten the time before a family hears about an unexplained absence. Ms. Ortega wants the change in place when the second semester starts on January 19, 2027.

## Desired outcome
On a school day, when a student is absent and no guardian has told the school about the absence, a guardian of that student receives a text message about it by 10:00 a.m. that day.

## Affected users and systems
- Parents and guardians of students at all 14 district schools, kindergarten through grade 12 (`src/schools/schools.ts`).
- Attendance clerks in each school's front office, who record the reasons for absences and take guardians' calls.
- Teachers, who record attendance for each class period, or for the morning and afternoon sessions in elementary schools (`docs/policies/attendance.md`, section 2).
- Ledger, the district's student information system, which Technology Services runs. Priya Raman is its product owner. Ledger sends text messages through TextBridge (`src/notify/smsClient.ts`).

## Scope and constraints
- In scope: absences that no guardian has reported to the school. Ms. Ortega leaves out absences a guardian has already reported, because the family already knows. Ledger records who reported each absence (`src/attendance/records.ts`).
- Out of scope: tardies (code T). Ms. Ortega wants this for absences only.
- Out of scope: the truancy notices in section 6 of the attendance policy (`docs/policies/attendance.md`), which stay as they are.
- Out of scope: changes to how teachers take attendance or to the attendance codes.
- The alert goes by text message. Ms. Ortega requires this because families read texts within minutes during the working day, while the evening call shows that many don't answer phone calls.
- Who receives an alert follows the Student Records Privacy policy (`docs/policies/student-records-privacy.md`) and the Family Communications policy (`docs/policies/family-communications.md`). Ms. Ortega doesn't want this change to set new rules about who may be told about a student.

## Open questions
- Whether the 6:00 p.m. evening call should continue once text alerts are in place, and if so, for which absences.
