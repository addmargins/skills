// Test fixture for check-spec.mjs: the code the sample specs cite as S1 (Booking cancellation).
export type BookingStatus = 'BOOKED' | 'CANCELLED';

export enum CancelledBy {
	PATIENT_APP,
	DESK_STAFF,
}

export const CANCEL_LIMITS = { HOURS_BEFORE: 3 };

export function cancelBooking(bookingId: string, by: CancelledBy): BookingStatus {
	return 'CANCELLED'; // a comment naming NOT_DECLARED declares nothing
}
