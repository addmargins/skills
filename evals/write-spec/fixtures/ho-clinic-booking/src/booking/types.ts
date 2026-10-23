// 예약 서비스 데이터 모델.
// 시각 필드는 모두 ISO 8601 문자열이며 UTC로 저장한다. 화면과 문자에는 KST로 바꿔 보여 준다.

export type Department = 'INTERNAL_MEDICINE' | 'FAMILY_MEDICINE' | 'PEDIATRICS' | 'DERMATOLOGY';

export type BookingSource = 'APP' | 'DESK' | 'PHONE';

export type BookingStatus = 'BOOKED' | 'CHECKED_IN' | 'COMPLETED' | 'CANCELLED' | 'NO_SHOW';

export type DepositStatus =
  | 'PAID' // 결제됨, 아직 쓰이지 않음
  | 'APPLIED' // 내원 접수 때 그날 수납액에서 차감됨
  | 'REFUNDED'
  | 'PARTIALLY_REFUNDED'
  | 'FORFEITED'; // 환불하지 않고 병원 수입으로 처리함

/** 환자 앱 로그인 계정. 휴대폰 본인인증으로 가입한다. */
export interface Account {
  id: string;
  name: string;
  phone: string;
  createdAt: string;
}

/** 진료받는 사람. 계정 주인 본인이거나, 계정 주인이 등록한 가족이다. */
export interface Patient {
  id: string;
  ownerAccountId: string;
  name: string;
  birthDate: string; // YYYY-MM-DD
  phone?: string; // 가족으로 등록한 환자는 비어 있을 수 있다
  chartNo?: string; // EMR 차트번호. 첫 내원 접수 때 생긴다
}

export interface Deposit {
  amount: number; // 원
  status: DepositStatus;
  pgTxId: string; // 누리페이 거래번호
  approvedAt: string; // 누리페이 승인 시각
  refundedAmount: number; // 지금까지 환불한 금액의 합
}

export interface Booking {
  id: string;
  patientId: string;
  accountId?: string; // 앱으로 예약한 계정. 데스크·전화 예약은 없다
  branchId: string;
  department: Department;
  doctorId: string;
  startsAt: string;
  source: BookingSource;
  status: BookingStatus;
  symptomMemo?: string; // 앱 예약 때 환자가 쓴 증상 메모(200자 이내)
  termsVersion?: string; // 앱 예약 때 동의한 예약 약관 버전
  deposit: Deposit | null; // 데스크·전화 예약은 null
  checkedInAt?: string;
  cancelledAt?: string;
  cancelledBy?: string; // 취소한 데스크 직원 ID
  createdAt: string;
  updatedAt: string;
}

export class BookingError extends Error {
  constructor(
    public code: string,
    public detail?: Record<string, unknown>,
  ) {
    super(code);
  }
}
