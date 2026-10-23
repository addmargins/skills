export type PlanType = "monthly" | "annual";
export interface Subscription {
  id: string;
  customerId: string;
  plan: PlanType;
  listPriceMonthly: number; // 월 정가
  paidAmount: number;       // 실결제금액 (after promo discount)
  promoCode?: string;
  paidAt: Date;
  paymentId: string;
  status: "active" | "canceled" | "expired";
  endsAt: Date;             // end of the paid period
}
