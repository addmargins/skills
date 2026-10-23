import { randomUUID } from 'node:crypto';
import { repo } from '../db';
import * as nuripay from '../payments/nuripay';
import {
  BOOKING_WINDOW_DAYS,
  CURRENT_TERMS_VERSION,
  DEPOSIT_KRW,
  MIN_LEAD_MINUTES,
} from './config';
import { Booking, BookingError, Department } from './types';

const MINUTE = 60_000;
const DAY = 24 * 60 * MINUTE;

export interface AppBookingRequest {
  accountId: string;
  patientId: string; // 계정에 등록된 본인 또는 가족
  branchId: string;
  department: Department;
  doctorId: string;
  startsAt: string; // ISO, UTC
  symptomMemo?: string;
  cardToken: string; // 누리페이 결제창에서 받은 1회용 토큰
  agreedTermsVersion: string;
}

export async function createAppBooking(req: AppBookingRequest, now = new Date()): Promise<Booking> {
  const startsAt = new Date(req.startsAt).getTime();
  if (startsAt < now.getTime() + MIN_LEAD_MINUTES * MINUTE) throw new BookingError('TOO_LATE_TO_BOOK');
  if (startsAt > now.getTime() + BOOKING_WINDOW_DAYS * DAY) throw new BookingError('TOO_FAR_AHEAD');
  if (req.agreedTermsVersion !== CURRENT_TERMS_VERSION) throw new BookingError('TERMS_NOT_AGREED');

  const patient = await repo.patients.get(req.patientId);
  if (patient.ownerAccountId !== req.accountId) throw new BookingError('NOT_YOUR_PATIENT');

  await repo.slots.hold(req.doctorId, req.startsAt); // 이미 찬 슬롯이면 예외

  // 예약금은 예약할 때 바로 승인한다. 카드 정보는 저장하지 않는다(1회 결제).
  const pay = await nuripay.approve({ amount: DEPOSIT_KRW, cardToken: req.cardToken, orderName: '진료 예약금' });

  const booking: Booking = {
    id: randomUUID(),
    patientId: req.patientId,
    accountId: req.accountId,
    branchId: req.branchId,
    department: req.department,
    doctorId: req.doctorId,
    startsAt: req.startsAt,
    source: 'APP',
    status: 'BOOKED',
    symptomMemo: req.symptomMemo?.slice(0, 200),
    termsVersion: req.agreedTermsVersion,
    deposit: {
      amount: DEPOSIT_KRW,
      status: 'PAID',
      pgTxId: pay.pgTxId,
      approvedAt: pay.approvedAt,
      refundedAmount: 0,
    },
    createdAt: now.toISOString(),
    updatedAt: now.toISOString(),
  };
  await repo.bookings.insert(booking);
  return booking;
}

/** 데스크 콘솔에서 만드는 예약(지점 방문 또는 전화). 예약금이 없다. */
export async function createDeskBooking(
  input: Pick<Booking, 'patientId' | 'branchId' | 'department' | 'doctorId' | 'startsAt'> & {
    source: 'DESK' | 'PHONE';
  },
  now = new Date(),
): Promise<Booking> {
  await repo.slots.hold(input.doctorId, input.startsAt);
  const booking: Booking = {
    id: randomUUID(),
    ...input,
    status: 'BOOKED',
    deposit: null,
    createdAt: now.toISOString(),
    updatedAt: now.toISOString(),
  };
  await repo.bookings.insert(booking);
  return booking;
}

/**
 * 환자 앱의 '내 예약' 목록.
 * 계정에 등록된 환자(본인·가족)의 예약을 예약 경로(APP/DESK/PHONE)와 관계없이 모두 보여 준다.
 */
export async function listBookingsForAccount(accountId: string): Promise<Booking[]> {
  const patients = await repo.patients.findByOwner(accountId);
  return repo.bookings.find({
    patientIds: patients.map((p) => p.id),
    statuses: ['BOOKED', 'CHECKED_IN'],
  });
}
