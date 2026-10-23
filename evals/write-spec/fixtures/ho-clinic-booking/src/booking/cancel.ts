import { repo } from '../db';
import * as nuripay from '../payments/nuripay';
import { contactPhoneFor, send } from '../notify/sms';
import { branchName, formatKst } from '../util/format';
import { CALL_CENTER_NUMBER } from './config';
import { BookingError } from './types';

export type Actor =
  | { kind: 'patient'; accountId: string }
  | { kind: 'staff'; staffId: string; branchId: string };

/**
 * 예약 취소.
 *
 * 지금은 데스크 콘솔에서만 취소한다. 데스크 직원이 예약금 정책을 보고 환불액을 직접 계산해
 * refundAmount로 넘긴다. 0이면 예약금을 환불하지 않는다.
 */
export async function cancelBooking(
  bookingId: string,
  actor: Actor,
  refundAmount = 0,
  now = new Date(),
): Promise<void> {
  if (actor.kind === 'patient') {
    // 앱 취소는 아직 없다. 앱은 이 오류를 받으면 대표번호 안내 화면을 띄운다.
    throw new BookingError('APP_CANCEL_NOT_SUPPORTED', { callCenter: CALL_CENTER_NUMBER });
  }

  const b = await repo.bookings.get(bookingId);
  if (b.branchId !== actor.branchId) throw new BookingError('OTHER_BRANCH');
  if (b.status !== 'BOOKED') throw new BookingError('NOT_CANCELLABLE');

  if (b.deposit) {
    const remaining = b.deposit.amount - b.deposit.refundedAmount;
    if (!Number.isInteger(refundAmount) || refundAmount < 0 || refundAmount > remaining) {
      throw new BookingError('INVALID_REFUND_AMOUNT', { remaining });
    }
    if (refundAmount > 0) {
      await nuripay.cancel({ pgTxId: b.deposit.pgTxId, amount: refundAmount, reason: 'DESK_CANCEL' });
      b.deposit.refundedAmount += refundAmount;
    }
    b.deposit.status =
      b.deposit.refundedAmount === b.deposit.amount
        ? 'REFUNDED'
        : b.deposit.refundedAmount > 0
          ? 'PARTIALLY_REFUNDED'
          : 'FORFEITED';
  }

  b.status = 'CANCELLED';
  b.cancelledAt = now.toISOString();
  b.cancelledBy = actor.staffId;
  b.updatedAt = now.toISOString();
  await repo.bookings.save(b);
  await repo.slots.release(b.doctorId, b.startsAt);

  const refundText = refundAmount > 0 ? ` 예약금 ${refundAmount.toLocaleString('ko-KR')}원을 환불했습니다.` : '';
  await send(
    await contactPhoneFor(b),
    `[호연의원 ${branchName(b.branchId)}] ${formatKst(b.startsAt)} 예약이 취소되었습니다.${refundText}`,
  );
}
