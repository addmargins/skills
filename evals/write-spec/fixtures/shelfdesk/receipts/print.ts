import { formatLocalDate, type ItemType } from "../loans/loan";

const LIBRARY_NAME = "Riverside Public Library";
const LINE_WIDTH = 32; // 58 mm desk printer

export interface ReceiptItem {
  title: string;
  type: ItemType;
}

function fit(text: string): string {
  return text.length > LINE_WIDTH ? text.slice(0, LINE_WIDTH) : text;
}

/** Lines of a printed loan receipt, top to bottom. */
export function receiptLines(items: ReceiptItem[], at: Date): string[] {
  return [
    LIBRARY_NAME,
    formatLocalDate(at),
    ...items.map((item) => fit(item.title)),
    "Thank you!",
  ];
}
