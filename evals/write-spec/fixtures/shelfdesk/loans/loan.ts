export type ItemType = "book" | "dvd" | "reference";

const LOAN_DAYS: Record<Exclude<ItemType, "reference">, number> = {
  book: 21,
  dvd: 7,
};

/** Local calendar date as YYYY-MM-DD. */
export function formatLocalDate(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const day = String(d.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

/**
 * Due date for an item checked out at `checkedOutAt`, as a local date (YYYY-MM-DD).
 * Books are due in 21 days, DVDs in 7.
 */
export function dueDate(type: ItemType, checkedOutAt: Date): string | null {
  // reference items may be borrowed for in-library use; no due date
  if (type === "reference") return null;
  const due = new Date(checkedOutAt);
  due.setDate(due.getDate() + LOAN_DAYS[type]);
  return formatLocalDate(due);
}
