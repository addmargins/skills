# Ledger

Ledger is the student information system of Merrow Valley School District: 14 schools, kindergarten through grade 12, about 11,800 students. Technology Services builds and runs it. Product owner: Priya Raman.

Ledger holds enrollment records, the adults linked to each student, and attendance. Teachers take attendance in Ledger, and each school's attendance clerk records the reasons for absences. Every school-day evening, Ledger phones families about that day's absences (the evening call).

## Repository layout

```
src/
  schools/schools.ts       Schools, grade bands, time zones, how each school takes attendance
  students/student.ts      Student records and the households a student lives in
  guardians/guardian.ts    Adults linked to a student: phones, households, custody and rights flags
  attendance/codes.ts      Attendance and reason codes
  attendance/records.ts    Period marks, rolls, day records, and the nightly UV-to-UX job
  notify/smsClient.ts      TextBridge SMS client: sending, delivery receipts, replies
  notify/messageLog.ts     Log of messages sent through providers, and its purge job
  records/disclosures.ts   Disclosure records kept by the Records and Privacy Office
  jobs/eveningCall.ts      The 6:00 p.m. evening call about absences
docs/
  policies/                District board policies that Ledger must follow
  intents/                 Intent documents for proposed changes
```

## Notes

- Scheduled jobs run on district office time, `America/New_York`. Each school's own time zone is in `src/schools/schools.ts`.
- Phone calls go through the district's voice provider and texts through TextBridge. EmergencyNotify, a separate system, sends closure and lockdown messages through the same TextBridge account. Ledger sends no automated email to families today.
- Paper documents, such as custody orders, signed consent forms, and Home Language Surveys, are scanned into DocuVault, the district's document archive. Ledger keeps only the fields shown in the code.
- Staff see what their Ledger role allows. The roles are `TEACHER`, `ATTENDANCE_CLERK`, `COUNSELOR`, `PRINCIPAL`, `COMMUNICATIONS_ADMIN`, and `RECORDS_ADMIN`.
- The code in this repository is an excerpt and does not build on its own.
