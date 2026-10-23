"""How fixtures/t6-ledgerly-supersede/docs/specs/0003-monthly-invoice-export.md was made.

usage: python3 -I build/t6_revise.py <spec.md>   (edits the file in place)

Input: the iteration-5 English spec, i.e. fixtures/t7-ledgerly-answers/docs/specs/
0003-monthly-invoice-export.md with its three "- **Answer:**" lines emptied and
"Verified against: b79f2e7, 2026-10-23". It applies Q1 (M. Weber) and Q3
(Lena Vogel) per revising.md; cases.md (t6, Adaptations 2-6) explains each edit.
After the script, case 4's situation was reworded by hand to "The other
accountant (finance role) starts an export for December 2026." The committed
fixture is the reference; this script only records how it was built.
"""
import sys, re
p = sys.argv[1]
s = open(p, encoding="utf-8").read()

def rep(old, new):
    global s
    n = s.count(old)
    assert n == 1, (n, old[:80])
    s = s.replace(old, new)

def cut_block(start, end):
    """Remove text from `start` (inclusive) up to `end` (exclusive)."""
    global s
    i = s.index(start); j = s.index(end, i)
    assert s.count(start) == 1
    s = s[:i] + s[j:]

Q1 = "Q1 answer, M. Weber, 2026-10-20"
Q3 = "Q3 answer, Lena Vogel, 2026-10-21"

# Header
rep("Status: Draft · 9 open questions, 6 block planning", "Status: Draft · 7 open questions, 4 block planning")
rep("Verified against: b79f2e7, 2026-10-23", "Verified against: b79f2e7, 2026-10-19")

# Summary
rep("The new external auditor wants this list as a file from January 2027. Planning can't start until Security & Compliance decides whether the accountants get the export permission that policy SEC-04 requires and that their role lacks today (Q1, export permission for the accountants), and whether admins count as holding it (Q2, admins and the export permission). The product owner must also decide which time zone sets where a month starts and ends (Q3, month boundaries), when the payment status is read (Q4, payment status timing), and which customer name is shown (Q5, which customer name), and the originator must confirm what file the auditor needs (Q6, the auditor's file needs).",
    "The new external auditor wants this list as a file from January 2027. Security & Compliance has given the accountants' role the export permission that policy SEC-04 requires, and the product owner has decided that Berlin time sets where a month starts and ends. Planning can't start until Security & Compliance decides whether admins count as holding the export permission (Q2, admins and the export permission). The product owner must also decide when the payment status is read (Q4, payment status timing) and which customer name is shown (Q5, which customer name), and the originator must confirm what file the auditor needs (Q6, the auditor's file needs).")

# Reviewers
rep("| Product owner | Not named in the intent or elsewhere in the repository. Whoever accepts this spec names one. | Scope and product behavior. Routes each policy conflict to its owners. | Q3 (month boundaries), Q4 (payment status timing), Q5 (which customer name), Q7 (voided invoices), Q8 (a month that hasn't ended), Q9 (headings and wording) |",
    "| Product owner | Lena Vogel | Scope and product behavior. Routes each policy conflict to its owners. | Q4 (payment status timing), Q5 (which customer name), Q7 (voided invoices), Q8 (a month that hasn't ended), Q9 (headings and wording) |")
rep("| The SEC-04 rows under Policies | Q1 (export permission for the accountants), Q2 (admins and the export permission) |",
    "| The SEC-04 rows under Policies | Q2 (admins and the export permission) |")
rep("Confirm the facts behind Q1 (who holds the finance role), Q2 (who holds the admin role, and how \"all permissions\" works today), Q3 (issue times stored in UTC, the invoice list's time zone, how many 2026 invoices fall in a different month in Berlin time than in UTC), Q4",
    "Confirm the facts behind R1 (who holds the finance role), Q2 (who holds the admin role, and how \"all permissions\" works today), R3 and R4 (issue times stored in UTC), the first check under How we will know it worked (the invoice list's time zone), Q4")

# Walkthrough
rep("3. They start the export. Only a user whose role has the export permission can do this. (R1) Whether the accountants' role gets that permission is open: Q1 (export permission for the accountants).",
    "3. They start the export. Only a user whose role has the export permission can do this, and the accountants' role has it. (R1)")
rep("(R3, R4, R8) Still open: which invoices issued around midnight belong to the month, Q3 (month boundaries); whether voided invoices are in it, Q7 (voided invoices);",
    "The month starts and ends at midnight Berlin time, and each issue date is the Berlin date. (R3, R4, R8) Still open: whether voided invoices are in it, Q7 (voided invoices);")

# Open questions: remove Q1 and Q3
cut_block("#### Q1. Export permission for the accountants\n", "#### Q2. Admins and the export permission\n")
cut_block("#### Q3. Month boundaries\n", "#### Q4. Payment status timing\n")
rep("If it isn't allowed, a month can be chosen only after it ends, in the time zone that Q3 (month boundaries) settles.",
    "If it isn't allowed, a month can be chosen only after it ends in Berlin time (R3).")

# Rules
rep("Whether the accountants and admins hold the permission is open: Q1 and Q2. (SEC-04 §1; intent, desired outcome 1)",
    f"The accountants' role, finance, has it ({Q1}). Whether admins hold it is open: Q2. (SEC-04 §1; intent, desired outcome 1)")
rep("Where a month starts and ends is open (Q3), and so is whether voided invoices count (Q7). (Derived from intent, desired outcome 1: \"every invoice issued in that month\")",
    f"A month starts and ends at midnight Berlin time ({Q3}). Whether voided invoices count is open: Q7. (Derived from intent, desired outcome 1: \"every invoice issued in that month\")")
rep("The issue date waits on Q3, the customer name on Q5, the payment status on Q4, and the headings and wording on Q9. (Intent, desired outcome 1)",
    f"The issue date is the date in Berlin time ({Q3}). The customer name waits on Q5, the payment status on Q4, and the headings and wording on Q9. (Intent, desired outcome 1)")

# Cases
rep("| 1 | On 2027-02-03 an accountant whose role has the export permission chooses January 2027.",
    "| 1 | On 2027-02-03 an accountant (finance role, which has the export permission) chooses January 2027.")
rep("| 4 | One of the accountants tries to export with the finance role as it is today, without the export permission. | They can't export, as in case 3, unless Q1 gives them the permission. | R1, Q1 |",
    "| 4 | A user whose only role is finance starts an export. | The export goes ahead, as in case 1: the finance role has the export permission. | R1 |")
rep("| Not decided whether it is in the January or the February file, or whether its issue date shows 2027-01-31 or 2027-02-01: Q3. | R3, R4, Q3 |",
    "| It is in the February file, with issue date 2027-02-01. | R3, R4 |")
rep("| Not decided whether it is in the June or the July file, or which issue date it shows: Q3. | R3, R4, Q3 |",
    "| It is in the July file, with issue date 2027-07-01. | R3, R4 |")
rep("| In the January file with issue date 2027-01-15, whatever Q3 decides. | R3, R4 |",
    "| In the January file with issue date 2027-01-15. | R3, R4 |")

# Policies
rep("| R1. Q1: the accountants' role doesn't have the permission today. Q2: unclear whether \"all permissions\" counts. | Cases 1, 3, 4, and 5, and M. Weber's answers to Q1 and Q2 |",
    f"| R1: the finance role has the permission ({Q1}). Q2: unclear whether \"all permissions\" counts. | Cases 1, 3, 4, and 5, and M. Weber's answer to Q2 |")

# How we will know
rep("They check its invoice numbers against the invoice list for that month in the console, using the month boundaries Q3 sets.",
    "They check its invoice numbers against the invoice list for that month in the console, with the month starting and ending at midnight Berlin time (R3). The technical lead first confirms which time zone the list's date filter uses.")

# Facts and sources
rep("(stated in a comment or document, not verified; technical lead confirms) → Q3", "(stated in a comment or document, not verified; technical lead confirms) → R3, R4")
rep("No role lists `finance:export`. `config/roles.yaml` (verified in the configuration) → Q1, Q2",
    "No role lists `finance:export`. `config/roles.yaml` (verified in the configuration) → R1, Q2")
rep("The finance role is held by the two accountants. `config/roles.yaml` (stated in a comment, not verified; technical lead confirms) → Q1",
    "The finance role is held by the two accountants. `config/roles.yaml` (stated in a comment, not verified; technical lead confirms) → R1")
rep("- Not found: which time zone the invoice list's issue-date filter uses. Also not found: how many invoices fall in a different month in Berlin time than in UTC, which can be counted from the stored issue times. → Q3",
    "- Not found: which time zone the invoice list's issue-date filter uses. → How we will know it worked")

# Terms
rep("The system records the moment of issue in UTC, so the date depends on the time zone used (Q3).",
    "The system records the moment of issue in UTC. The file shows the date in Berlin time (R4).")

# Decision log
s = s.rstrip("\n") + "\n\n## Decision log\n" \
    "- Q1 (Export permission for the accountants): (a) give the export permission to the finance role. M. Weber, 2026-10-20, email.\n" \
    "- Q3 (Month boundaries): (a) Berlin time decides both the month and the issue date shown. Lena Vogel (product owner), 2026-10-21, review meeting.\n"
open(p, "w", encoding="utf-8").write(s)
print("ok")
