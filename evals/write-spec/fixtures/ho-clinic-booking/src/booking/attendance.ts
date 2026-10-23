import { repo } from '../db';
import { NO_SHOW_GRACE_MINUTES } from './config';
import { BookingError } from './types';

/**
 * 노쇼 표시 작업. 스케줄러가 NO_SHOW_JOB_INTERVAL_MINUTES(10분)마다 실행한다.
 * 진료 시작 후 NO_SHOW_GRACE_MINUTES(15분)가 지났는데 아직 BOOKED(접수 전)인 예약을 NO_SHOW로 바꾼다.
 */
export async function markNoShows(now = new Date()): Promise<number> {
  const threshold = new Date(now.getTime() - NO_SHOW_GRACE_MINUTES * 60_000).toISOString();
  const due = await repo.bookings.find({ statuses: ['BOOKED'], startsBefore: threshold });
  for (const b of due) {
    b.status = 'NO_SHOW';
    b.updatedAt = now.toISOString();
    await repo.bookings.save(b);
    // 예약금은 PAID 상태 그대로 둔다. 원무팀이 매월 말 노쇼 예약금 보고서를 보고
    // 데스크 콘솔에서 FORFEITED로 처리하거나, 사정이 있으면 환불한다.
  }
  return due.length;
}

/** 데스크 접수. 예약금이 있으면 그날 수납액에서 차감되도록 APPLIED로 바꾼다. */
export async function checkIn(
  bookingId: string,
  staff: { staffId: string; branchId: string },
  now = new Date(),
): Promise<void> {
  const b = await repo.bookings.get(bookingId);
  if (b.branchId !== staff.branchId) throw new BookingError('OTHER_BRANCH');
  if (b.status !== 'BOOKED') {
    // NO_SHOW로 바뀐 예약은 접수할 수 없다. 늦게 온 환자는 당일 접수(워크인)로 새로 받는다.
    throw new BookingError('NOT_CHECKIN_ABLE', { status: b.status });
  }
  b.status = 'CHECKED_IN';
  b.checkedInAt = now.toISOString();
  if (b.deposit?.status === 'PAID') b.deposit.status = 'APPLIED';
  b.updatedAt = now.toISOString();
  await repo.bookings.save(b);
}
