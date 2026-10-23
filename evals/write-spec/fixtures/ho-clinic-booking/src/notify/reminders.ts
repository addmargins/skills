import { repo } from '../db';
import { CALL_CENTER_NUMBER } from '../booking/config';
import { branchName, formatKstTime, kstDateString } from '../util/format';
import { contactPhoneFor, send } from './sms';

/**
 * 진료 전날 리마인더.
 * 스케줄러가 매일 REMINDER_HOUR_KST(10시, KST)에 실행하며, 다음 날(KST) 예약이 있는 환자에게 보낸다.
 * 데스크·전화 예약도 같이 보낸다.
 */
export async function sendTomorrowReminders(now = new Date()): Promise<void> {
  const tomorrow = kstDateString(new Date(now.getTime() + 24 * 60 * 60_000));
  const bookings = await repo.bookings.find({ statuses: ['BOOKED'], kstDate: tomorrow });
  for (const b of bookings) {
    await send(
      await contactPhoneFor(b),
      `[호연의원 ${branchName(b.branchId)}] 내일 ${formatKstTime(b.startsAt)} 예약이 있습니다. ` +
        `변경·취소 문의 ${CALL_CENTER_NUMBER}`,
    );
  }
}
