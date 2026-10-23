import { db } from '../db';
import { voice } from '../notify/voiceClient';
import { messageLog } from '../notify/messageLog';

// The evening call. At 18:00 district time on school days, Ledger phones the family of every
// student who has an A mark today, unless the day's reason is EX. For the two Westbrook
// schools that is 17:00 local time.
//
// The call goes to the first phone listed for the primary contact of the student's
// primary-residence household. It plays a recording, in English only:
//   "This is Merrow Valley Schools. Your student was absent from one or more classes today.
//    Please call your school's attendance line."
// About 40% of these calls end NO_ANSWER (Technology Services, spring 2026).

export const EVENING_CALL_SCHEDULE = { cron: '0 18 * * 1-5', timeZone: 'America/New_York' };

const RECORDING_ID = 'evening-call-en-v3';
const RECORDING_SCRIPT =
  "This is Merrow Valley Schools. Your student was absent from one or more classes today. Please call your school's attendance line.";

export async function runEveningCall(date: string): Promise<void> {
  for (const studentId of db.periodMarks.studentsWithCode(date, 'A')) {
    const day = db.dayRecords.find(studentId, date);
    if (day?.reason === 'EX') continue;

    const student = db.students.get(studentId);
    const home = student.households.find((h) => h.isPrimaryResidence)!;
    const household = db.households.get(home.householdId);
    const contact = db.guardians.get(household.primaryContactGuardianId);
    const phone = contact.phones[0];
    if (!phone) continue;

    const result = await voice.call(phone.number, RECORDING_ID);
    messageLog.add({
      channel: 'VOICE',
      sender: 'EVENING_CALL',
      studentId,
      recipientName: `${contact.firstName} ${contact.lastName}`,
      recipientAddress: phone.number,
      body: RECORDING_SCRIPT,
      sentAt: new Date().toISOString(),
      status: result.answered ? 'DELIVERED' : 'NO_ANSWER',
    });
  }
}
