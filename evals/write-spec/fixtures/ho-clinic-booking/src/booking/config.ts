// 예약 서비스 설정값.
// 값을 바꾸면 환자 앱의 안내 문구도 함께 바꿔야 한다.

export const CLINIC_TIMEZONE = 'Asia/Seoul';

export const CALL_CENTER_NUMBER = '1588-0000';

/** 앱 예약 1건당 예약금(원). 진료과와 관계없이 같다. 데스크·전화 예약은 예약금을 받지 않는다. */
export const DEPOSIT_KRW = 10_000;

/** 진료 슬롯 길이(분) */
export const SLOT_MINUTES = 15;

/** 앱에서 오늘부터 며칠 뒤까지 예약할 수 있는지 */
export const BOOKING_WINDOW_DAYS = 90;

/** 앱 예약은 진료 시작 60분 전까지 받는다 */
export const MIN_LEAD_MINUTES = 60;

/** 진료 시작 후 이 시간이 지나도록 접수되지 않은 예약은 NO_SHOW로 표시한다 */
export const NO_SHOW_GRACE_MINUTES = 15;

/** markNoShows 작업 실행 간격(분) */
export const NO_SHOW_JOB_INTERVAL_MINUTES = 10;

/** 진료 전날 리마인더 문자를 보내는 시각(KST, 시) */
export const REMINDER_HOUR_KST = 10;

/** 앱 예약 화면에서 동의받는 예약 약관 버전 */
export const CURRENT_TERMS_VERSION = '2026-03';
