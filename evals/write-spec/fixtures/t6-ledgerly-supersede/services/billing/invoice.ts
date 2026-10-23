export interface Invoice {
  number: string;          // e.g. "LG-2026-001234"
  issuedAt: Date;          // stored in UTC
  customerId: string;
  netAmount: number;       // minor units (cents)
  vatAmount: number;
  grossAmount: number;
  currency: "EUR" | "CHF" | "USD";
  status: "open" | "paid" | "overdue" | "void";
}
