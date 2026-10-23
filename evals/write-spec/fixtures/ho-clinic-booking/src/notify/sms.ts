/**
 * 메시지허브 문자 발송.
 *
 * send()는 메시지허브가 발송 요청을 받았다는 것만 알려 준다. 실제로 수신됐는지는
 * 나중에 onDeliveryReport 웹훅으로 온다(보통 수 분, 통신사 사정에 따라 더 늦을 수 있다).
 */
import { repo } from '../db';
import { http } from '../util/http';
import { logger } from '../util/logger';
import type { Booking } from '../booking/types';

export async function send(to: string, text: string): Promise<{ messageId: string }> {
  const res = await http.post('https://api.messagehub.example/v2/sms', {
    to,
    from: process.env.SMS_SENDER,
    text,
  });
  return { messageId: res.data.message_id };
}

/** 메시지허브 수신 결과 웹훅. 지금은 로그만 남기고 따로 저장하지 않는다. */
export async function onDeliveryReport(report: {
  messageId: string;
  result: 'DELIVERED' | 'FAILED';
  failCode?: string;
  reportedAt: string;
}): Promise<void> {
  logger.info('sms.delivery', report);
}

/** 예약 문자를 받을 번호. 환자 번호가 없으면(가족으로 등록된 환자) 예약한 계정 주인의 번호로 보낸다. */
export async function contactPhoneFor(b: Booking): Promise<string> {
  const patient = await repo.patients.get(b.patientId);
  if (patient.phone) return patient.phone;
  const owner = await repo.accounts.get(patient.ownerAccountId);
  return owner.phone;
}
