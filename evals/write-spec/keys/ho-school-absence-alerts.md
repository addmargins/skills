# Answer key: ho-school-absence-alerts

Held-out fixture. The skill under test must never see this file.

- Fixture: `/tmp/claude-0/-home-user-skills/3c5fa302-c24c-5c19-af5a-a87af0062c50/scratchpad/fixture/ho-school-absence-alerts/`
- Intent: `docs/intents/0001-unexplained-absence-same-morning.md`
- Domain: Ledger, the student information system of Merrow Valley School District (fictional). It has 14 schools, grades K-12, and about 11,800 students.
- The change: text a guardian by 10:00 a.m. when a student is absent and no guardian has told the school. No money is involved.
- What it tests: minors' personal data, consent, legal notice, and who qualifies to be told.

Clause references below use the policy number and clause. BP 5113 is `docs/policies/attendance.md`, BP 1112 is `docs/policies/family-communications.md`, and BP 5125 is `docs/policies/student-records-privacy.md`.

## 1. People and owners named

| Person | Role and office | Where named | Owns |
|---|---|---|---|
| Marisol Ortega | Assistant principal, Merrow Valley High School | Intent | Originator of the intent. Owns scope and outcome questions. |
| Priya Raman | Ledger product owner, Technology Services | Intent, README | Product and system behavior |
| Daniel Okafor | Records and Privacy Officer, Office of General Counsel | BP 5125 | Student Records Privacy policy |
| Renee Castellanos | Director of Communications, Office of Communications and Community Engagement | BP 1112 | Family Communications policy |
| Dr. Howard Pruitt | Director of Student Services, Office of Student Services | BP 5113 | Attendance and Absences policy |
| Leah Brennan | Foster care point of contact, Office of Student Services | BP 5125 2.4 | Disclosures to child-welfare caseworkers |

The fixture also names these bodies and roles, with no person attached: Language Services (Office of Multilingual Learners, BP 1112 3.2), the district safety committee (intent), the Records and Privacy Office (BP 5125 5.3), Technology Services, principals, and attendance clerks. People named in the examples in this key (Eli, Devon, Sofia, Jordan and others) are illustrative only. They do not appear in the fixture.

## 2. Facts a writer must find in code

| # | Fact | Where |
|---|---|---|
| F1 | Teachers enter period-level marks P, T, A, SA. SA counts as present. A includes arriving more than 15 minutes late. | `src/attendance/codes.ts` (`MARK_CODES`) |
| F2 | The clerk enters one day-level reason per student per day: EX, UV, UX. It applies to every period missed that day. | `src/attendance/codes.ts` (`REASON_CODES`), `src/attendance/records.ts` (`DayRecord`) |
| F3 | Grades 6-12 take a roll for each of 7 periods. K-5 take two session rolls, AM and PM, and the PM session starts at 12:20. First bells: high schools 7:25, middle schools 8:10, elementary schools 8:50, all in local time. | `src/schools/schools.ts` |
| F4 | Westbrook Middle and Westbrook Elementary are in `America/Chicago`. The other 12 schools and every scheduled job run on `America/New_York`. | `src/schools/schools.ts` header comment; README "Notes" |
| F5 | `DayRecord.source` records who reported the absence (`GUARDIAN_CALL`, `GUARDIAN_NOTE`, `GUARDIAN_EMAIL`, `STAFF`, `SYSTEM`). The first A mark creates a UV/SYSTEM record unless the clerk entered one in advance. This is how "a guardian already reported it" can be detected. | `src/attendance/records.ts` (`DayRecord`, `ensureDayRecord`) |
| F6 | Ledger accepts a roll at any time of day. `PeriodRoll.submittedAt` stays unset until the teacher submits, and the 15-minute rule only triggers a reminder. | `src/attendance/records.ts` (`PeriodRoll`) |
| F7 | When a teacher submits a roll, it overwrites the whole section and period, so the last write wins. A clerk's A-to-T change for a late pass is lost if the teacher submits again. | `src/attendance/records.ts` (`submitRoll` comment) |
| F8 | A nightly job at 02:00 district time turns UV into UX after 11:59 p.m. school-local time on the second school day. It skips days with no remaining A marks. | `src/attendance/records.ts` (`promoteUnverified`) |
| F9 | Guardian links: `hasCustody`, `educationalRights`, `courtRestricted`, `emergencyOrder`, `receivesMail` (duplicate mailed report cards and notices, form RC-2), `active` (cleared when a foster placement ends), and a `relationship` enum that includes GRANDPARENT, FOSTER_PARENT and CASEWORKER. A caseworker has no household. | `src/guardians/guardian.ts` (`GuardianLink`, `Relationship`) |
| F10 | Each household has exactly one `primaryContactGuardianId`. A student can live in several households (`StudentHousehold.livesHere`), and exactly one of them is `isPrimaryResidence`. Ledger can therefore carry out either reading of BP 1112 2.1. | `src/guardians/guardian.ts` (`Household`), `src/students/student.ts` (`StudentHousehold`) |
| F11 | Phones have `type` MOBILE, HOME or WORK, and `textConsent`, which defaults to false for numbers entered before the 2024-25 form. `smsOptOut` is set by STOP and cleared by START. | `src/guardians/guardian.ts` (`Phone`), `src/notify/smsClient.ts` (`onInboundSms`) |
| F12 | **Provider limit, stated only in a code comment.** TextBridge allows 1 message per second per number, and the district has 3 numbers, so 3 per second in total. Over that rate it returns HTTP 429 and drops the message, with no queue. The account allows 25,000 segments a day, shared with EmergencyNotify, and a district-wide closure text uses about 21,000. A segment is 160 GSM-7 characters, or 70 in UCS-2 for Vietnamese and Arabic. Some carriers never send a delivery receipt. | `src/notify/smsClient.ts` header comment and `onDeliveryReceipt` |
| F13 | Replies to a district text other than STOP, START or HELP are dropped. They are not stored or forwarded. | `src/notify/smsClient.ts` (`onInboundSms`) |
| F14 | The message log is purged after 90 days. Only `COMMUNICATIONS_ADMIN` can view it. | `src/notify/messageLog.ts` |
| F15 | Disclosure records are written only by the Records and Privacy Office, only `RECORDS_ADMIN` can view them, and they are kept until five years after withdrawal. Nothing automated writes one: the evening call does not. | `src/records/disclosures.ts` |
| F16 | The evening call runs at 18:00 `America/New_York`, which is 17:00 at Westbrook. It calls the first phone of the primary-residence household's primary contact for any A mark not coded EX. It is English only and does not check age, rights or restrictions. About 40% of calls go unanswered. | `src/jobs/eveningCall.ts` |
| F17 | `Student.homeLanguage` is the Home Language Survey answer ("language your child uses most often at home"), collected for English-learner screening. `Student.dateOfBirth` and `ageOn()` exist. `Student.fosterCare` exists. | `src/students/student.ts` |
| F18 | Ledger sends no automated email to families today. Consent forms and custody orders are paper documents kept in DocuVault. The staff roles are TEACHER, ATTENDANCE_CLERK, COUNSELOR, PRINCIPAL, COMMUNICATIONS_ADMIN and RECORDS_ADMIN. | README "Notes" |

**Fields that do not exist.** A writer who assumes any of these is inventing data:
- a preferred language for a guardian or household;
- a guardian's time zone;
- an adult student's consent to tell a parent (BP 5125 3.2(a));
- proof that a parent claims the student as a tax dependent (3.2(b));
- a parent's written consent for a relative or caregiver (2.5);
- any record of a BP 1112 2.2 request to receive messages;
- any flag for whether a caseworker should be told;
- any record of alerts;
- any disclosure record for automated messages.

## 3. Planted gaps (15)

A gap is a product behavior or constraint that the intent and the three policies leave undecided. The skill should raise each one as an open question routed to its owner, and must not state a rule that decides it.

| # | Area | Domain | Gap | Owner |
|---|---|---|---|---|
| G1 | Boundary: cutoff | other | Which absences count at the cutoff | Ortega, with Pruitt |
| G2 | Boundary: time zones | other | Whose 10:00 a.m. at the Westbrook schools | Ortega, with Raman |
| G3 | Boundary: partial day | other | Absences that start later in the day | Ortega, with Pruitt |
| G4 | What came before | other | A mark or reason corrected after the alert went out | Ortega, with Castellanos for wording |
| G5 | Repeats and two paths | other | One alert or several; teacher and clerk edits to the same record | Pruitt, with Raman |
| G6 | Outside service fails | other | TextBridge 429s, outages, missing receipts, the shared daily cap | Raman, with Castellanos |
| G7 | Edge of scope: reachability | other | Primary contact cannot receive a text | Ortega, with Castellanos |
| G8 | Waiting state crosses a limit | legal | UV becomes UX after two school days, and replies to the alert are dropped | Pruitt |
| G9 | What guardians are told: language | other | Which language each recipient gets | Castellanos (Language Services) |
| G10 | Records and who sees them | personal data | Which staff can see alert history | Okafor, with Raman |
| G11 | Edge of scope: adult students | legal | Students aged 18 and over | Okafor, with Ortega |
| G12 | Edge of scope: guardians without custody | personal data | Parents outside the residing household who asked for copies | Castellanos, with Okafor |
| G13 | Edge of scope: foster placement | personal data | Child-welfare caseworkers | Brennan, with Okafor |
| G14 | Edge of scope: guardians without custody | personal data | A relative caregiver with no custody or rights | Okafor, with Pruitt |
| G15 | Intent's own open question | other | Whether the evening call continues | Ortega, with Pruitt and Raman |

### G1. Which absences count at the cutoff (other)
- **Question.** Does "absent" mean absent from any period or session so far, or not yet present at all today? Is a student with an A in period 1 who is now in class alerted? What happens when a roll is still unsubmitted at the cutoff: alert, wait, or skip?
- **Why no source settles it.** The intent says "absent" without saying which kind. BP 5113 defines both absence from a period (2.4) and absence for the day (3.4), and a full-day absence can't be known until the last period. Under 2.4, a student who arrives 20 minutes late carries an A for period 1 while sitting in period 2. Ledger accepts rolls at any time (F6), and nothing says what a missing roll means.
- **Example.** At Merrow Valley High School, period 1 starts at 7:25. Devon signs in at 7:45: A for period 1, P for period 2. At 9:45 he is in class with an A on record.

### G2. Whose 10:00 a.m. (other)
- **Question.** For Westbrook Middle and Westbrook Elementary (Central Time), is the deadline 10:00 local, which is 11:00 Eastern, or 10:00 district time, which is 9:00 Central?
- **Why no source settles it.** The intent gives a clock time without a zone. BP 5113 1.2 and BP 1112 4.1 use school-local time, but only for their own clauses. Ledger's jobs run on district time (F4), and the intent's own "6:00 p.m." evening call is 5:00 p.m. at Westbrook (F16).
- **Why it matters.** Westbrook Elementary's morning roll is due at 9:05 Central (8:50 bell plus 15 minutes), which is 10:05 Eastern. That is after a 10:00 Eastern deadline.

### G3. Partial-day absences that start later (other)
- **Question.** Does an absence that starts after the student was present, or after 10:00, get an alert, and by when? Examples are skipping period 5, leaving at lunch without signing out, or missing the elementary PM session at 12:20. And what about a student who signs out at the office (BP 5113 2.6) when no guardian contact is recorded?
- **Why no source settles it.** The outcome promises only "by 10:00 a.m. that day". Nothing says whether later absences get a same-day text, are left to the evening call (itself open, G15), or get nothing.

### G4. Correction after the alert went out (other)
- **Question.** Is a correction or retraction sent, and to whom, when the record changes after the alert? Cases: a teacher corrects A to P or T (BP 5113 5.1, until 11:59 p.m. on the next school day); the clerk records a guardian's later call as EX; the clerk changes a past day from P to A within 10 school days (5.2). Does a late change to A trigger a late alert?
- **Why no source settles it.** The intent covers only the first alert. No policy addresses messages already sent.
- **Example.** A 9:30 alert says Sofia is absent. At 10:20 her period 1 teacher realizes she was in the back row and changes A to P. Her mother has already left work.

### G5. Repeats and two paths on the same record (other)
- **Question.** (a) Is there one text per student per day, or one per absent period or session? Cases: A in periods 1, 2 and 3; or A in period 1, P in period 2, A in period 3. (b) When the teacher's mark and the clerk's entry conflict or cross, which one decides the alert? Cases: the clerk changes A to T for a late pass, then the teacher resubmits and overwrites it back to A (F7); or the clerk logs a guardian's call at 9:58 while alerts are being sent.
- **Why no source settles it.** "A text message about it" doesn't define "it" across periods. BP 5113 gives teachers marks (section 2) and clerks reasons (section 3), and lets both change marks (section 5), but ranks neither. Last-write-wins is an accident of how the code was written, not a decision.

### G6. Provider failures and limits (other)
- **Question.** When TextBridge returns 429 (dropped, not queued), has an outage, rejects the message (UNDELIVERED), or sends no receipt at all: how long is the alert retried, and past 10:00 or not? Is there a fallback channel? Who at the school learns that an alert did not go? Is part of the 25,000-segment daily cap held back for EmergencyNotify?
- **Why no source settles it.** No policy or intent text addresses provider failure. The limits exist only in the code comment (F12).
- **Arithmetic.** On a flu day, about 2,000 to 3,000 texts at 3 per second take 11 to 17 minutes. Vietnamese and Arabic texts cost 2 to 3 segments each. A closure text later the same day needs about 21,000 of the 25,000 segments.

### G7. Primary contact cannot receive a text (other)
- **Question.** Some primary contacts have only a HOME or WORK number, a mobile with `textConsent` false (the default before 2024-25), or have replied STOP. Do they get email, a call, a call from the front office, or nothing?
- **Why no source settles it.** That they get no text is settled: the intent requires text, and BP 1112 5.1 and 5.2 forbid texting them. What happens instead is not decided. Ledger sends no automated email today (F18). BP 1112 2.1 does not make another adult in the household a recipient.

### G8. Waiting state: UV turns UX, and replies are dropped (legal)
- **Question.** The guardian has until 11:59 p.m. on the second school day to explain the absence (BP 5113 4.2). After that it becomes UX and counts toward the state-law truancy notice at three (6.1). Guardians will reply to the text ("she's sick"), but replies are dropped (F13), and a reply is not one of the ways to explain an absence under 4.1. Undecided:
  - whether a reply counts as an explanation;
  - whether replies are forwarded to the clerk;
  - whether the alert must say how to explain and by when;
  - whether anything is sent when the absence turns UX.
- **Why no source settles it.** BP 5113 4.1 lists the ways to explain and 4.2 sets the deadline, but no source anticipates replies to an automated text. Changing 4.1 is the policy owner's call. BP 1112 7.1 requires only that the text say how to reach the school.
- **Example.** Monday's alert goes out at 9:40, and the mother replies at 9:45. Nothing reaches the office. At 02:00 on Thursday the job turns the absence into UX.

### G9. Language (other)
- **Question.** Which language is each recipient's text in?
- **Why no source settles it.** BP 1112 3.1 requires "the family's preferred language" if it is one of five supported languages. Ledger records no preference for any guardian or household. Its only language field is `Student.homeLanguage`, the language the child uses at home, collected for English-learner screening (F17). It is undecided whether that field stands in for the preference or preferences must be collected first, and what happens when the student's two households differ. The fallback to English for unsupported languages, and the ban on machine translation (3.2), are settled.

### G10. Who can see alert records (personal data)
- **Question.** Which Ledger roles can see that an alert went out, to whom (name and number), and whether it was delivered: attendance clerks, teachers, counselors, principals?
- **Why no source settles it.** BP 5125 2.1(a) gives only a standard: staff "who need it for their work with the student". Today the message log is visible to COMMUNICATIONS_ADMIN only (F14), and disclosure records to RECORDS_ADMIN only (F15). Clerks who take guardians' calls and must act on failures (G6) can see neither.

### G11. Students aged 18 and over (legal)
- **Question.** For a student who has turned 18, does the alert go to the student, to a parent when a condition in BP 5125 3.2 holds, or to no one?
- **Why no source settles it.** Rights pass to the student on their 18th birthday (3.1). After that, disclosure to a parent is only *permitted*, with written consent or tax-dependency proof (3.2), and never required. BP 1112 2.1 points to the household's primary contact, usually a parent, and BP 1112 1.2 then blocks that parent by default. Ledger has the birth date but no record of consent or dependency proof (F17, "Fields that do not exist"). Nothing says whether the student is told. The evening call ignores age (F16), which is current practice, not a decision.
- **Example.** Jordan, a Northgate senior, turns 18 on Wednesday, February 3, 2027, and is absent on February 4.

### G12. Parents outside the residing household who asked for copies (personal data)
- **Question.** BP 1112 2.2 lets any other parent or guardian ask to receive messages about the student. Ledger has nowhere to record that request. The nearest field is `receivesMail`, set when a parent, often a non-custodial one, asked on form RC-2 for duplicate mailed report cards and notices. Do `receivesMail` parents get alerts, or must they ask again? How is a request recorded, and how does it interact with `textConsent`?
- **Why no source settles it.** The policy creates the right to ask, but nothing decides whether earlier requests for mail count or how requests reach Ledger.
- **What is settled.** A parent who never asked and doesn't live with the student is not a default recipient under either reading of 2.1. Custody does not affect the right to receive information (BP 5125 2.2).

### G13. Foster placement: the caseworker (personal data)
- **Question.** For a student in foster care, does the child-welfare caseworker (relationship CASEWORKER, no household) get alerts?
- **Why no source settles it.** BP 5125 2.4 says the district *may* disclose to the caseworker and that Leah Brennan arranges such disclosures. BP 1112 never mentions caseworkers, and its 2.2 covers only parents and guardians.
- **What is settled.** A foster parent the student lives with may receive information (BP 5125 2.1(c)) and is the residing household's primary contact.
- **Secondary issue.** After a placement ends, the old foster parent stays linked until the clerk clears `active` (F9). 2.1(c) no longer covers them.

### G14. A relative caregiver with no custody or rights (personal data)
- **Question.** A student lives only with her grandmother. The grandmother is the residing household's primary contact but has no custody and no educational rights, and the mother, who holds rights, lives in another state. Who gets the alert?
- **Why no source settles it.** BP 1112 2.1 points to the grandmother, but BP 1112 1.2 and BP 5125 2.5 require a parent's written consent first. Ledger does not record that consent; it is paper in DocuVault. The mother is not a default recipient. Applied literally, the sources give no recipient at all, while the intent wants a guardian texted. Recording the consent, falling back to the mother, or sending nothing are each a decision someone must make.
- **Not a conflict.** Texting the mother breaks no source, though none requires it.

### G15. The evening call (other)
- **Question.** Does the 6:00 p.m. call continue once alerts exist, and if so, for which absences?
- **Why no source settles it.** This is the intent's one open question. The skill must carry it forward unresolved.

**Gaps by domain:** personal data 4 (G10, G12, G13, G14); legal 2 (G8, G11); other 9 (G1-G7, G9, G15). Total 15. The conflict (section 4) and the two-reading clause (section 5) are additional open items and are not counted here.

## 4. The conflict (no behavior satisfies both)

**BP 5125 5.1-5.2 against BP 1112 6.1.**

- **BP 5125 5.1-5.2.** "For each disclosure of information from a student's record to anyone other than district staff, including a parent, the district keeps a record of the date, the recipient, and the information disclosed", kept "until five years after the student leaves the district".
- **BP 1112 6.1.** "For each message the district sends through a messaging provider, the district keeps the message text, the recipient's name and phone number or email address, and the delivery status for 90 days after sending, and then deletes them. No copy or summary that identifies the recipient or what the message said is kept after that." BP 1112 6.2 makes the limit a provider contract term as well. The TextBridge comment confirms this (F12).

An absence alert is both a disclosure of attendance information to a parent and a message sent through a provider.

**Timing.**
- Days 0-90 after an alert: keeping the log satisfies both policies.
- Day 90: BP 1112 requires deleting anything that identifies the recipient or the content. BP 5125 requires keeping a record of date, recipient and content for years more.
- If alerts start with the semester on Tuesday, January 19, 2027, the first collision is Monday, April 19, 2027, and a new one arrives every day after that.
- The record's design must be settled before launch, because a record built for one policy cannot later be made to satisfy the other.

**Why there is no way out.**
- A separate disclosure table is still a "copy or summary that identifies the recipient or what the message said".
- Keeping only a guardian ID still identifies the recipient.
- Dropping the recipient or the content breaks BP 5125 5.1.
- Treating the alert as something other than a disclosure contradicts BP 5125 1.1, which covers "the messages the district sends".
- Federal law's exemption for disclosures to parents does not help, because BP 5125 5.1 explicitly includes parents.

**The conflict already exists.** The evening call is already in it today. Its log is purged at 90 days and it writes no disclosure record (F14, F15). Current practice follows BP 1112, which settles nothing.

**Expected handling.** Report it as a conflict between the two policies, quoting both clauses and giving the day-90 timing, and route it to both Daniel Okafor and Renee Castellanos. Any spec rule that keeps or deletes these records is a failure.

## 5. The two-reading clause

**BP 1112 2.1:** "Messages about an individual student are sent to the primary contact of the household in which the student resides."

- **Reading A: one household.** "The household" is singular, so it means the student's single home of record, the primary residence (`isPrimaryResidence`). One recipient by default. Other parents get messages only if they ask under 2.2.
- **Reading B: every household the student lives in.** A student in shared custody resides in both homes (`livesHere` on both). The primary contact of each one is a default recipient.

**Worked example.** Eli Navarro, grade 7, attends Merrow Valley Middle School (first bell 8:10 Eastern). His parents, Ana and Mark, have joint custody and alternate weeks.
- In Ledger, household H1 is Ana's: `livesHere` true, `isPrimaryResidence` true, primary contact Ana.
- Household H2 is Mark's: `livesHere` true, `isPrimaryResidence` false, primary contact Mark.
- Both parents hold educational rights, neither is restricted, and neither has asked under 2.2.

On Tuesday, February 2, 2027, during Mark's week, Mark drops Eli at the bus stop. Eli never reaches period 1, and no one calls the school.
- **Reading A:** the alert goes to Ana only. She doesn't know where Eli slept and can do little. Mark, the parent who can act, hears nothing unless he had asked under 2.2.
- **Reading B:** the alert goes to both Ana and Mark.

The reading changes who is notified, and through that how soon anyone can act.

**Traps.**
- The evening call (F16) and the mailing address follow reading A. That is existing practice, not a decision.
- BP 1112 2.2 does not resolve the clause. It only lets Mark ask.

**Owner:** Renee Castellanos, with Daniel Okafor on whether BP 5125 allows each recipient. The spec must present both readings and ask. Choosing reading A because the code does it counts as deciding.

## 6. Decoys (look open, but the plain words settle them)

| # | Looks like | Settled by | Rule |
|---|---|---|---|
| D1 | "Do students on field trips or at games trigger alerts?" | BP 5113 2.5: such a student "is present for attendance purposes and is recorded SA". The intent alerts only when a student "is absent". `MARK_CODES.SA.countsAsPresent` is true. | No alert for SA. |
| D2 | "Do guardians under a court order still get alerts?" (looks like part of "guardians without custody") | BP 5125 2.3: such a person "receives no information about the student from the district". BP 1112 1.2 makes that bind messages. The data is `GuardianLink.courtRestricted`. | Never alert a court-restricted person. |
| D3 | "Quiet hours by whose clock, given two time zones and guardians who may live elsewhere?" | BP 1112 4.1: "not sent between 9:00 p.m. and 7:00 a.m. in the local time of the student's school", and a message "that falls due during these hours waits until 7:00 a.m." 4.2 limits the exemption to a closed list (closure, lockdown, shelter-in-place, evacuation). | Quiet hours use the school's clock, and an absence alert is never an emergency message. |

Raising a decoy as an open question is an over-ask. Note that D3 sits next to G2: the quiet-hours clock is settled, but the 10:00 a.m. cutoff clock is not.

## 7. Other rules the sources settle

The spec should state these as rules, with their sources:
- No alert for tardies (T). (Intent, scope)
- No alert for an absence a guardian has already reported, detected from `DayRecord.source` GUARDIAN_*. (Intent, scope; F5)
- The alert is a text message. (Intent, constraint)
- No text goes to a number without `textConsent`, or to a number that replied STOP until it replies START. STOP does not stop email or calls. (BP 1112 5.1, 5.2)
- Recipients must be people BP 5125 allows. (BP 1112 1.2; intent constraint)
- A foster parent the student lives with may receive alerts. (BP 5125 2.1(c))
- A parent's right to information does not depend on custody. (BP 5125 2.2)
- The text never gives the reason for the absence or any health information. (BP 5125 4.1)
- The text names the student by first name and school, and says how to reach the school. (BP 1112 7.1; school contact fields in `schools.ts`)
- Supported languages are English, Spanish, Vietnamese, Arabic and Haitian Creole; anything else gets English. Language Services translates the templates, with no machine translation. (BP 1112 3.1, 3.2)
- Truancy notices are unchanged and out of scope. (Intent; BP 5113 6.1)
- Teachers may correct marks until 11:59 p.m. on the next school day. The clerk may correct them for 10 school days, and after that the principal must approve. (BP 5113 5.1-5.3)

## 8. Grading notes

- **Found gap.** A gap counts as found when the spec raises it as an open question, names the decision, and routes it to the right owner or office. Partial credit applies if the owner is missing or wrong.
- **Decided gap (failure).** A gap counts as decided when the spec states a rule that settles it. Rules justified only by current code behavior are decisions, not findings. These include the evening call's primary-residence choice, its English-only message, its 18:00 Eastern schedule and its indifference to age, and last-write-wins.
- **G14 is not the conflict.** A spec that calls G14 a conflict, or that presents more than one conflict, has misread the sources.
- **Code facts must be cited.** These facts appear nowhere except the code: the provider limit and shared cap (F12), dropped replies (F13), the Westbrook time zone (F4), and the missing preference, consent and request fields.
