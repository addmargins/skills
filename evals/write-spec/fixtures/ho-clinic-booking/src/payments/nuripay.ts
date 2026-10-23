/**
 * 누리페이(PG) 연동.
 *
 * 연동 메모 (플랫폼팀, 2025-11 계약 기준)
 * - 승인은 1회성 카드 결제만 쓴다. 빌링키(카드 저장 후 자동결제)는 계약에 없다.
 * - 취소(전체취소·부분취소)는 원거래 승인일로부터 60일 이내 거래만 API로 할 수 있다.
 *   60일이 지난 거래는 NP-4012(취소 가능 기간 경과)를 돌려주며, 누리페이 관리자 화면에서도
 *   취소되지 않는다. 이 경우 고객 계좌로 직접 송금하는 방법밖에 없다.
 * - 취소 API가 타임아웃 나면 실제로 취소됐는지 알 수 없다. getTransaction()으로 다시 조회해야 한다.
 */
import { http } from '../util/http';

const BASE_URL = process.env.NURIPAY_BASE_URL ?? 'https://api.nuripay.example';

export interface ApproveResult {
  pgTxId: string;
  approvedAt: string; // ISO, UTC
}

export async function approve(input: {
  amount: number;
  cardToken: string;
  orderName: string;
}): Promise<ApproveResult> {
  const res = await http.post(`${BASE_URL}/v1/payments`, input, { timeoutMs: 10_000 });
  return { pgTxId: res.data.tid, approvedAt: res.data.approved_at };
}

export async function cancel(input: { pgTxId: string; amount: number; reason: string }): Promise<void> {
  const res = await http.post(
    `${BASE_URL}/v1/payments/${input.pgTxId}/cancel`,
    { cancel_amount: input.amount, reason: input.reason },
    { timeoutMs: 10_000 },
  );
  if (res.data.code !== '0000') {
    throw new Error(`NURIPAY_CANCEL_FAILED ${res.data.code}`);
  }
}

export async function getTransaction(pgTxId: string): Promise<{ status: string; cancelledAmount: number }> {
  const res = await http.get(`${BASE_URL}/v1/payments/${pgTxId}`, { timeoutMs: 10_000 });
  return { status: res.data.status, cancelledAmount: res.data.cancelled_amount };
}
