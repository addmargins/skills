# Answer key: ho-clinic-booking

Held-out fixture for the write-spec skill. The skill must never see this file.

Fixture root: `fixture/ho-clinic-booking/` (13 files, no .git). Everything in the fixture is Korean except code identifiers. The intent document keeps the clarify-intent template's English headings (`# Intent:`, `## Problem`, and so on), because that skill writes those headings verbatim. The body is Korean.

```
README.md
docs/intents/0001-self-service-cancellation.md
docs/policies/deposit-and-no-show-fee.md      (POL-FIN-007, money)
docs/policies/patient-data-handling.md        (POL-PRV-002, personal data)
docs/policies/patient-notice-and-consent.md   (POL-LEG-004, legal/compliance)
src/booking/config.ts
src/booking/types.ts
src/booking/book.ts
src/booking/cancel.ts
src/booking/attendance.ts
src/payments/nuripay.ts
src/notify/sms.ts
src/notify/reminders.ts
```

**What the intent asks for:** patients can cancel or change (same branch, same department, new date and time) an app booking up to 3 hours before the appointment. Refunds of the 10,000 KRW deposit follow the deposit policy automatically. Changes don't ask the patient to pay the deposit again. No-show deposits are processed automatically after the patient is notified under the legal policy. Patients pick a cancellation reason, and Customer Experience sees weekly counts by reason. The change touches money (refunds, forfeiture), health data (cancellation reasons such as "증상이 나아짐", plus booking data), and a legal notice (notice before forfeiture).

---

## 1. People and owners named

| Person | Team / role | Where named | Owns |
|---|---|---|---|
| 박서연 | 고객경험팀 팀장 | intent (Problem) | **Originator** of the intent. She is not a product owner. |
| 김도윤 | 재무팀 팀장 | deposit-and-no-show-fee.md header | Money policy POL-FIN-007. Clause 제7조② also says 재무팀 decides how to refund when the original payment method can't be refunded. |
| 이하은 | 정보보호팀, 개인정보 보호책임자 | patient-data-handling.md header | Privacy policy POL-PRV-002. Clauses 제3조③ (new data or new roles need prior approval) and 제5조③ (retention of records the policy doesn't list) give her team those decisions. |
| 정민재 | 법무·컴플라이언스팀 변호사 | patient-notice-and-consent.md header | Legal policy POL-LEG-004 (consent and notice before forfeiture). |
| 최지훈 | 원무팀 파트장 | README (담당) | Front-desk operations at the branches. |
| 플랫폼팀 | team, no person named | README, nuripay.ts comment | Develops the booking service. |

**No product owner is named anywhere.** A good spec flags this. It routes product-behavior questions (G2, G11, G12, and the intent's own open question) to the originator 박서연 "until a product owner is named", or asks who owns them. It must not invent an owner.

---

## 2. Facts the writer must find in code

| # | Fact | Where |
|---|---|---|
| F1 | The deposit is 10,000 KRW per app booking, the same for every department. Desk and phone bookings have `deposit: null`. | `src/booking/config.ts` `DEPOSIT_KRW`; `book.ts` `createDeskBooking`; `types.ts` `Booking.deposit` |
| F2 | App bookings open 90 days ahead (`BOOKING_WINDOW_DAYS`) and close 60 minutes before the start (`MIN_LEAD_MINUTES`). Slots are 15 minutes. | `config.ts`; enforced in `book.ts` `createAppBooking` |
| F3 | The deposit is approved at booking time as a one-time card payment, and the card isn't stored. NuriPay has no billing key in the contract. | `book.ts` comment; `nuripay.ts` header comment |
| F4 | **Outside-service limit, stated only in a code comment:** NuriPay full and partial cancels work only within **60 days of the original approval**. After that the API returns `NP-4012`, the NuriPay admin screen can't cancel either, and the only option is a bank transfer to the customer. A timed-out cancel has an unknown outcome and must be re-queried with `getTransaction()`. | `src/payments/nuripay.ts` header comment |
| F5 | App cancellation isn't supported: `cancelBooking` throws `APP_CANCEL_NOT_SUPPORTED` for a patient actor. Desk staff type the refund amount by hand. It must be an integer from 0 to the remaining deposit. `refundedAmount` is cumulative, and the status becomes `REFUNDED`, `PARTIALLY_REFUNDED`, or `FORFEITED` when 0 is refunded. Staff can only cancel bookings of their own branch (`OTHER_BRANCH`). A cancellation SMS is sent. | `src/booking/cancel.ts` |
| F6 | The no-show job runs every 10 minutes. It marks `BOOKED` bookings 15 or more minutes past their start as `NO_SHOW`, judging **only by check-in status**. Marking therefore happens between T+15 and T+25. The deposit stays `PAID`, and 원무팀 settles it by hand at month end. | `src/booking/attendance.ts` `markNoShows`; `config.ts` |
| F7 | `checkIn` refuses any booking that isn't `BOOKED`. A booking already marked `NO_SHOW` can't be checked in, and the patient must be registered as a walk-in. Check-in moves the deposit to `APPLIED`, which deducts it from that day's bill. | `attendance.ts` `checkIn` |
| F8 | Timestamps are stored in UTC and shown in KST. `CLINIC_TIMEZONE = 'Asia/Seoul'`. | `types.ts` header; `config.ts` |
| F9 | `send()` only confirms that MessageHub accepted the message. Delivery results arrive later by webhook and are **only logged, not stored**. | `src/notify/sms.ts` |
| F10 | SMS goes to `patient.phone`, or to the owning account's phone when the patient has none (family members). | `sms.ts` `contactPhoneFor` |
| F11 | The reminder SMS goes out at **10:00 KST the day before**, desk and phone bookings included. The text names the branch, the time, and "변경·취소 문의 1588-0000". It has no department. | `src/notify/reminders.ts`; `config.ts` `REMINDER_HOUR_KST` |
| F12 | The app's "내 예약" list shows bookings of every patient registered to the account **regardless of source** (APP, DESK, PHONE). | `book.ts` `listBookingsForAccount` |
| F13 | Each app booking stores the terms version (`CURRENT_TERMS_VERSION = '2026-03'`). There is no separate consent timestamp, only `createdAt`. | `config.ts`, `book.ts`, `types.ts` |
| F14 | Fields that **exist**: `Account{id,name,phone,createdAt}`; `Patient{ownerAccountId, birthDate, phone?, chartNo?}` (exactly one owner account); `Booking{accountId?, source, department, doctorId, symptomMemo?, termsVersion?, deposit{amount,status,pgTxId,approvedAt,refundedAmount}, checkedInAt?, cancelledAt?, cancelledBy? (staff ID)}`. | `types.ts` |
| F15 | Fields that **don't exist**: arrival time (only `checkedInAt`), cancellation reason, a patient as `cancelledBy` (staff ID only), change history or original `startsAt`, email anywhere, bank account, billing key, notice or SMS delivery records, objection records, the relationship between account owner and patient (guardian, adult child, and so on), a second account per patient, and a no-show count. | `types.ts` (by absence) |
| F16 | Today a desk "change" is a cancellation plus a new desk booking, which has no deposit. Phone cancellations go call center → branch desk. No-show deposits are handled monthly by hand. | `README.md` |

Policy-versus-code facts the spec should notice: today's monthly no-show handling already breaks 제6조② (24 hours). The no-show job judges by check-in, while 제6조① says "내원" (arrival). No delivery results are stored, but legal 제4조② requires them.

---

## 3. The conflict (no behavior satisfies both)

**Money policy (deposit-and-no-show-fee.md) 제6조:**
- ① A no-show is **confirmed** when the patient hasn't arrived by 15 minutes after the appointment time.
- ② After confirmation the whole deposit is forfeited as the no-show fee, and "충당 처리는 노쇼가 확정된 때부터 **24시간 이내**에 마친다".

**Legal policy (patient-notice-and-consent.md) 제4조:**
- ① Before forfeiting, the patient must be told the reason and its time, the amount, and how and by when to object. The notice must come "**그 사유가 생긴 뒤**", that is, after the no-show.
- ③ No forfeiture "고지 문자를 보낸 때부터 **48시간**이 지나기 전에는".
- ④ If an objection arrives in that period, no forfeiture until it is resolved.

**Arithmetic.** Take an appointment on Wed 2026-11-18 at 10:00 KST.
- The no-show is confirmed at 10:15 Wed. The job records it between 10:15 and 10:25.
- The earliest legal notice is 10:15 Wed, because it can't precede the cause.
- The earliest legal forfeiture is notice + 48h = **10:15 Fri 11-20**.
- The money deadline is confirmation + 24h = **10:15 Thu 11-19**.
- The permitted window is empty. The earliest allowed moment is 24 hours after the deadline. An objection under ④ pushes it later still.

**Why there's no way out:**
- Notifying before the appointment doesn't count, because ① requires notice after the cause.
- Not forfeiting breaks 제6조②, which says "충당하고 환불하지 않는다". Clinic-cause cancellations under 제5조 are the only exception.
- Forfeiting within 24 hours breaks 제4조③.

The intent asks for both at once ("고지 지침에 따라 환자에게 알린 뒤 … 예약금 정책대로 처리"). It is undecided which clause gives way, or whether 제6조② could, for example, count from the end of the objection period. **Owners: 김도윤 (재무팀) and 정민재 (법무팀) together.** The spec must raise this as a blocking open question, not pick a side.

---

## 4. The two-reading clause

**deposit-and-no-show-fee.md 제4조 제1호:** "진료 1일 전까지 취소한 경우: 예약금 전액". 제2호 starts where 제1호 ends ("제1호의 기한이 지난 뒤 진료 예정 시각 3시간 전까지 … 50%"). 제2조 says all times are KST, so the calendar reading is well defined.

- **Reading A:** "1일 전" means **24 hours before the appointment time**.
- **Reading B:** "1일 전까지" means **through the end of the calendar day before the appointment day** (D−1 23:59:59 KST).

Both readings are natural Korean. 제2호 says "진료 예정 시각" while 제1호 says only "진료", which favors B. The parallel "N 전까지" structure favors A. No other source settles it. The desk code has no rule, because staff type the amount, and the README only says staff "follow the policy".

**Worked numbers.** Deposit 10,000 KRW. Appointment Wed 2026-11-18 10:00 KST.

| Cancelled at (KST) | Hours before | Reading A | Reading B |
|---|---|---|---|
| Tue 11-17 09:00 | 25 | 10,000 | 10,000 |
| Tue 11-17 15:00 | 19 | **5,000** | **10,000** |
| Tue 11-17 23:30 | 10.5 | **5,000** | **10,000** |
| Wed 11-18 06:00 | 4 | 5,000 | 5,000 |
| Wed 11-18 07:30 | 2.5 | 0 | 0 |

Evening clinic example: appointment Thu 2026-11-19 20:30, cancelled Wed 11-18 22:00 (22.5 hours before). Reading A refunds **5,000**; reading B refunds **10,000**.

The full-refund deadline under B is always later than under A, by (24 h − the appointment's clock time): 14 hours for a 10:00 appointment, 3.5 hours for 20:30. Under B, the 50% window for a 09:00 appointment is only 00:00–06:00. A cancellation in the gap gets a 5,000 KRW difference.

It also interacts with G12. Under reading A, the 10:00 D−1 reminder reaches anyone booked before 10:00 after their full-refund deadline has passed.

**Owner: 김도윤 (재무팀).** The spec should give both readings with an example and ask. It must not pick one, and it must not copy the 24-hour reading from a guess.

---

## 5. Planted gaps (12): real decisions nobody has made

Domains: **money 3** (G1, G3, G4) · **legal 3** (G6, G7, G10) · **personal data 2** (G8, G9) · **other 4** (G2, G5, G11, G12).

### G1. A change inside the 50% window, and which time the refund tiers use afterwards
- **Domain:** money. **Category:** what came before (earlier changes, a partly forfeited deposit), repeats.
- **Case:** appointment Wed 10:00. At Wed 06:00 (tier 2 under both readings) the patient moves it to the next Wednesday 10:00, then cancels on the Saturday before. If the tiers use the new time, the refund is 10,000. If the change counted as a tier-2 cancellation, 5,000 was forfeited at the change and 5,000 carried over. That's a 5,000 difference per booking. Unlimited repeated changes can push a booking forward indefinitely and dodge 제4조 entirely.
- **Why no source settles it:**
  - 제4조 speaks only of "환자가 예약을 취소하면" and is silent on changes.
  - The intent allows changes up to 3 hours before and says the patient doesn't pay the deposit again. It doesn't say whether any part is forfeited, which time the tiers use after a change, or how many changes are allowed.
  - Today a desk "change" *is* a cancellation plus a new booking (README), which points the other way.
  - If part is forfeited, the next question is also open: does a later no-show or cancellation work on the 5,000 that's left?
- **Owner:** 김도윤 (재무팀). The number of changes is shared with the product owner (none named).

### G2. Bookings and change targets that start inside the 3-hour window
- **Domain:** other (product). **Category:** boundaries.
- **Case:** the app still sells bookings up to 60 minutes before the start (F2). A booking made at 13:00 for 14:30 the same day can never be cancelled or changed in the app (the intent's 3-hour cutoff), and its deposit is non-refundable from the moment it is paid (tier 3). The same question applies to a change made at T−5h into a slot that starts in 2 hours.
- **Why no source settles it:** the 60-minute lead (code) and the 3-hour cutoff (intent) were set separately. Neither the intent nor any policy says whether the app keeps selling such bookings, whether it warns the patient, or whether a change may target a slot inside the window. The refund amount itself *is* settled by the words of 제4조 (0 or 50%), so a "grace period" would be a policy change, not a gap fill.
- **Owner:** product owner (none named; route via 박서연), with 김도윤 (deposit) and 최지훈 (same-day slot fill).

### G3. Refunds the payment provider can't make
- **Domain:** money. **Category:** outside-service limit and failure.
- **Case:** a booking made Fri 2026-10-23 for Wed 2027-01-20 (89 days ahead, allowed). It is cancelled Tue 2027-01-05, 15 days early, so the full refund is due under both readings. The approval is **74 days** old, so NuriPay returns NP-4012 and no API or admin refund is possible (F4).
- **Changes make it worse:** the deposit keeps its original `approvedAt` (paid 10-23 for 11-20, moved twice to 2027-01-15, cancelled 01-10 = 79 days).
- **Timeouts:** a timed-out cancel has an unknown result.
- **Why no source settles it:**
  - 제7조① says to refund to the original payment method. 제7조② says only that 재무팀 decides what happens when that's impossible, and nothing has been decided.
  - The intent forbids shortening the 90-day window and requires keeping NuriPay, which blocks both easy fixes.
  - No bank-account field exists (F15). Collecting bank accounts would be new personal data under privacy 제3조③.
  - Also undecided: whether the booking is cancelled (slot released) while its refund is stuck or uncertain, and what the patient sees.
- **Owner:** 김도윤 (재무팀, named by 제7조②). 이하은 joins if bank accounts are collected.

### G4. Running late: the desk changes a booking inside the 3-hour window
- **Domain:** money. **Category:** two paths on the same booking (desk and app).
- **Case:** at T−30 minutes the patient calls: "20분 늦어요, 뒤 시간으로 옮겨 주세요." The app can't change it (3-hour cutoff, and the intent says to direct patients to the call center). Today's desk practice cancels and makes a new desk booking (README). Under automatic tiers that is a tier-3 cancellation: 0 refund, plus a new booking with no deposit. The patient who called ahead loses 10,000. A patient who walks in at T+14 has the deposit applied.
- **Why no source settles it:** policy 제4조 covers cancellations only. The intent covers app changes only up to 3 hours and leaves the desk's options after that unsaid. The intent's "누가 처리해도 환불액이 같다" fixes amounts for cancellations, not whether a late desk move is a cancellation.
- **Owner:** 김도윤 (deposit treatment) with 최지훈 (desk practice).

### G5. A patient waiting at reception crosses the 15-minute mark
- **Domain:** other (operations, with a money consequence). **Category:** waiting state that crosses a time limit; two paths (the job and the desk).
- **Case:** a 09:00 patient arrives at 09:08, but the morning queue means the desk checks them in at 09:22. The job ran at 09:20 and marked the booking `NO_SHOW`. `checkIn` now refuses it (F7), so the patient becomes a walk-in and the deposit is headed for forfeiture.
- **Why no source settles it:**
  - Policy 제6조① defines a no-show as not having *arrived* (내원) by T+15, so by policy this patient is **not** a no-show. Whether the fee applies is therefore settled: it doesn't.
  - What's undecided is the product behavior. How is arrival established and recorded (there's no `arrivedAt`, F15)? Can the desk reverse a `NO_SHOW`, and who may? What happens to a no-show notice already sent?
  - Legal 제4조③ only gives the patient a chance to object. It doesn't define a desk correction path.
- **Owner:** 최지훈 (원무팀), with 김도윤. Product owner if a kiosk or app arrival check is chosen.

### G6. How objections are filed and decided
- **Domain:** legal. **Category:** waiting state (an objection pending across the deadlines).
- **Why no source settles it:**
  - Legal 제4조①3 requires the notice to state how and by when to object. ④ freezes forfeiture while an objection is pending.
  - No source says how a patient objects (an app screen, a phone call, a reply SMS), who reviews it (branch desk, branch manager, 재무팀), on what grounds, how fast, what the patient is told, or what an accepted objection does: refund the deposit, reverse `NO_SHOW`, or apply the deposit to a later visit.
  - The objection deadline is not fixed either. ③ sets a 48-hour minimum before forfeiture, not a filing deadline.
- **Owner:** 정민재 (procedure), with 최지훈 (who reviews at the branches).

### G7. The no-show notice SMS fails or can't be confirmed
- **Domain:** legal. **Category:** outside-service failure.
- **Why no source settles it:**
  - Legal 제4조② requires notice *by SMS* with the send time and the delivery result recorded. ③ counts 48 hours from sending.
  - MessageHub reports delivery later and can report `FAILED` (F9). Number changed, wrong number, or no patient phone so it went to the account owner (F10).
  - Undecided:
    - Does a failed delivery count as "알린" (notified)?
    - Is forfeiture still allowed after 48 hours?
    - Retry, and how many times?
    - Any fallback channel? There is no email (F15), and push isn't SMS.
    - What if no result ever arrives?
- **Owner:** 정민재.

### G8. Cancellation reasons: health data, who sees them, how long they're kept
- **Domain:** personal data. **Category:** records kept and who can see them.
- **Why no source settles it:**
  - The intent's sample choices include "증상이 나아짐" and free text "기타(직접 입력)". Under privacy 제2조, information that reveals health status is sensitive.
  - The privacy access table (제3조①) has no row for 고객경험팀 and no item "cancellation reason". 제3조③ requires 정보보호팀's prior approval to collect new data or to give an unlisted role access, and that approval hasn't been given.
  - Also open:
    - Raw reasons or aggregated counts only?
    - Is free text allowed?
    - Do desk, call center, or finance see the reasons?
    - Retention: the reason isn't in 제5조①/②, so 제5조③ applies.
- **Owner:** 이하은 (정보보호팀), with 박서연 (what the weekly analysis actually needs).

### G9. Keeping no-show, notice and objection records once the booking is deleted
- **Domain:** personal data. **Category:** records kept.
- **Why no source settles it:**
  - Booking records (date, branch, department, doctor, symptom memo) are destroyed 1 year after the appointment (제5조①). Payment and refund records are kept 5 years (제5조②).
  - Forfeiture is not plainly a "결제·환불 기록". Notice records (send time and result, required by legal 제4조②) and objection records (which may contain health details such as "응급실에 갔다") are not listed.
  - Undecided: what a no-show or forfeiture record may keep after the booking is gone. Department can't go into it, because finance may not see health data (제3조②). Also undecided: how long notice and objection records are kept, and who may read objection text.
- **Owner:** 이하은 (제5조③ names 정보보호팀), with 김도윤 and 정민재.

### G10. Family-managed patients: who may act, who gets notified, who may object
- **Domain:** legal (with personal data). **Category:** people at the edges of scope.
- **Case:** an adult child's account manages an elderly parent who has no phone in the system.
  - Each patient has exactly one owner account (F14), so the parent can't manage their own bookings in the app.
  - SMS goes to the account owner (F10).
  - The refund goes to the account owner's card (제7조①).
- **Why no source settles it:**
  - Legal 제4조① says to notify "환자에게". It doesn't say whether notifying the account owner counts, or who may object.
  - Sending a no-show notice to a family member's phone discloses a clinic booking to another person (privacy 제4조 only bans department, doctor, and memo).
  - It's also undecided whether the patient can cancel through the desk while the owner's app shows the booking.
  - The intent names "가족을 등록해 가족의 예약을 관리하는 앱 계정 사용자" as affected users but decides nothing. Children (소아청소년과) with a parent as the account owner are the uncontroversial case.
- **Owner:** 정민재 (notice and objection rights), with 이하은 (disclosure to family).

### G11. Desk and phone bookings without a deposit, shown in the app
- **Domain:** other. **Category:** people at the edges of scope.
- **Case:** the app lists desk and phone bookings (F12). These are often for elderly patients registered by family.
- **Why no source settles it:**
  - The intent says patients can cancel or change "자기 예약" in the app. It doesn't say whether that includes deposit-free bookings.
  - If such a booking is changed in the app, it's undecided whether the new booking must take a deposit, which would also need legal 제2조 consent at that point.
  - Settled parts, not to be raised: money policy 제1조 excludes deposit-free bookings, so there are no refund tiers and no no-show fee for them.
- **Owner:** product owner (none named; route via 박서연), with 최지훈. 김도윤 joins if a deposit is taken on change.

### G12. What the reminder tells the patient
- **Domain:** other. **Category:** what the patient is told.
- **Case:** the existing D−1 10:00 reminder says "변경·취소 문의 1588-0000" (F11), which is wrong once the app can cancel. It doesn't mention the refund deadline. Under reading A it reaches every patient booked before 10:00 after their full-refund deadline has passed.
- **Why no source settles it:** legal 제2조 covers what is shown *before booking*, and 제3조 what is shown *before cancelling*. No source covers reminders: their timing, whether they state the deadline and amounts, or what deposit-free bookings get.
- **Owner:** product owner (none named; route via 박서연). 정민재 reviews the wording if it states fee terms.

### Intent's own declared open question (not counted among the 12)
Whether a change may switch to another doctor in the same department: (a) same doctor only, or (b) any doctor in the department. The spec should carry it forward as open, owned by the originator or product owner, and not decide it.

---

## 6. Decoys (look undecided; the plain words settle them)

| # | Looks undecided because… | Settled by (exact words) | Correct treatment |
|---|---|---|---|
| D1 | **Time zone.** Timestamps are stored in UTC (`types.ts`). Patients may be abroad. Reading B of 제4조 needs a calendar day. | deposit-and-no-show-fee.md **제2조**: "이 정책의 시각과 기한은 모두 한국 표준시(KST)를 기준으로 한다." | State as a rule: every deadline is computed in KST. The 3-hour, 15-minute, 24-hour and 48-hour limits are durations anyway. Not an open question. |
| D2 | **What the cancellation, refund or no-show SMS may say.** The temptation is to name the department or doctor so the patient recognizes the booking. | patient-data-handling.md **제4조**: "환자에게 보내는 문자메시지와 앱 푸시 알림에는 진료과, 담당 의료진 이름, 증상 메모를 쓰지 않는다." | State as a rule. It is compatible with legal 제4조①: reason, time, amount and how to object need no department. |
| D3 | **The clinic cancels** (휴진, a doctor's schedule change). The intent only talks about patient actions, and the desk code takes a hand-typed amount. | deposit-and-no-show-fee.md **제5조**: "병원 사정으로 병원이 예약을 취소한 경우에는 취소 시점과 관계없이 예약금 전액을 환불하며, 위약금은 없다." | State as a rule: full refund at any time, no fee. Not an open question. |

---

## 7. Other settled rules the spec should state (not planted decoys; raising them as open is a false positive)

- Deposit is 10,000 KRW per booking (제3조①), and the intent keeps it unchanged. It is deducted from that day's bill on check-in (제3조②).
- Refund tiers per 제4조: full / 50% / 0. The full-refund deadline carries the ambiguity in section 4. The 3-hour limit is inclusive ("3시간 전까지").
- The money policy applies only to bookings that took a deposit (제1조).
- A no-show is confirmed at T+15 without arrival (제6조①), and the whole deposit is forfeited (제6조②). The *timing* of forfeiture is the conflict in section 3.
- Refunds go to the original payment method (제7조①). Exceptions belong to 재무팀 (제7조②), see G3.
- Before booking, all cost terms are shown and consent recorded with time and terms version (legal 제2조). Before a patient cancels, the refund amount is shown (legal 제3조).
- The no-show notice is SMS, states the reason and its time, the amount, and how and by when to object, and records the send time and result (legal 제4조①②). Legal rules apply on every channel (legal 제5조).
- Call center and finance can't see health data (privacy 제3조②). Desk staff see only their own branch (privacy 제3조①, and `OTHER_BRANCH` in code).
- Booking records are kept 1 year from the appointment date. Payment and refund records are kept 5 years from the transaction (privacy 제5조①②).
- From the intent:
  - App cancel or change is allowed until 3 hours before; after that, direct the patient to the call center.
  - Changes stay within the same branch and department.
  - The patient doesn't pay the deposit again on a change.
  - NuriPay stays until at least June 2027.
  - The 90-day window is not shortened.
  - Out of scope: cross-branch or cross-department changes, waitlists, restricting repeat no-show patients, and redesigning the desk console UI.

## 8. Acceptable extra findings (not planted; don't penalize, don't require)

- What happens when the deposit exceeds that day's bill (제3조② doesn't say).
- The same booking being changed in the app while the desk checks it in, or while the job marks it at the same moment. Mostly design, but a spec may raise the expected outcome.
- Whether pre-launch bookings (terms `2026-03`) need fresh consent for automatic processing. The amounts haven't changed, so this is weak.
- The no-show job's 10-minute cadence means `NO_SHOW` is recorded up to 10 minutes after the policy's confirmation time.

## 9. What a passing spec does

- Raises G1–G12 (or most of them) as open questions addressed to the owners in section 5, without choosing an answer.
- Raises the section 3 conflict as blocking, with the 24 h vs 48 h arithmetic, for 김도윤 and 정민재.
- Quotes 제4조 제1호 with both readings and a numeric example, for 김도윤.
- States D1–D3 and the section 7 items as rules with their sources, and doesn't ask about them.
- Uses the code facts in section 2, especially the NuriPay 60-day limit (F4), the check-in-based no-show job (F6/F7), the missing fields (F15) and the 10:00 reminder (F11), rather than assuming them.
- Notes that no product owner is named.
