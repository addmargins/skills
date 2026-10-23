# Spec: Accountants download each month's invoice list as one file that opens ready in Excel

Intent: [0003-monthly-invoice-export.md](../intents/0003-monthly-invoice-export.md)
Status: Draft · 9 open questions, 6 block planning
Verified against: b79f2e7, 2026-10-19

## Summary
At every month-end close, the two in-house accountants spend about a working day typing invoices one at a time from the admin console into their spreadsheet, because the console has no way to export them. This spec adds a download to the console's invoices page: an accountant picks one calendar month and gets one file that opens in their Excel as it is, listing every invoice issued that month with eight columns and no card or bank details. The new external auditor wants this list as a file from January 2027. Planning can't start until Security & Compliance decides whether the accountants get the export permission that policy SEC-04 requires and that their role lacks today (Q1, export permission for the accountants), and whether admins count as holding it (Q2, admins and the export permission). The product owner must also decide which time zone sets where a month starts and ends (Q3, month boundaries), when the payment status is read (Q4, payment status timing), and which customer name is shown (Q5, which customer name), and the originator must confirm what file the auditor needs (Q6, the auditor's file needs).

## Scope
- In: Exporting the invoices of one chosen calendar month from the admin console's invoices page, as one file an accountant downloads (intent).
- Out: Scheduled or emailed exports, credit notes, and other reports (intent).
- Unchanged: The intent names no existing behavior to protect. Exporting reads invoices and changes none of them.
- At the edges:
  - After the download, the accountants save the file and send it to the external auditor themselves, so the file leaves the company. SEC-04 §3 governs what "the system" stores, not what people do with a file. M. Weber (Security & Compliance) should say whether any rule covers sending it outside the company.
  - Credit notes are out of scope, but the invoice record has no field that marks an entry as a credit note. The technical lead confirms that credit notes aren't kept among invoices, so none can appear in the file.
  - The auditor gets the file only from the accountants and has no access to the console (intent).

## Reviewers
| Role | Who | What to check | Questions to answer or confirm |
|---|---|---|---|
| Originator | Not named in the intent | Does this spec solve the problem the intent describes? Was anything dropped or narrowed? | Q6 (the auditor's file needs) |
| Product owner | Not named in the intent or elsewhere in the repository. Whoever accepts this spec names one. | Scope and product behavior. Routes each policy conflict to its owners. | Q3 (month boundaries), Q4 (payment status timing), Q5 (which customer name), Q7 (voided invoices), Q8 (a month that hasn't ended), Q9 (headings and wording) |
| Policy owner: SEC-04 | Security & Compliance (M. Weber) | The SEC-04 rows under Policies | Q1 (export permission for the accountants), Q2 (admins and the export permission) |
| Technical lead | Not named; the product owner assigns one | Facts and sources, Left to engineering | Confirm the facts behind Q1 (who holds the finance role), Q2 (who holds the admin role, and how "all permissions" works today), Q3 (issue times stored in UTC, the invoice list's time zone, how many 2026 invoices fall in a different month in Berlin time than in UTC), Q4 (no history of status changes), Q5 (whether the name on each invoice is kept), Q7 (what "void" means), R7 (all amounts stored in cents), and that credit notes aren't kept among invoices |
| Engineers | Not named | Can the work be planned without deciding product behavior? | None |

## What the accountant experiences
1. The accountant opens the invoices page in the admin console. (Intent, affected systems)
2. They choose one calendar month, for example January 2027. (Intent, in scope; R2) Whether they can choose the current month is open: Q8 (a month that hasn't ended).
3. They start the export. Only a user whose role has the export permission can do this. (R1) Whether the accountants' role gets that permission is open: Q1 (export permission for the accountants).
4. The system logs the export with who they are, the time, and the month. If it can't record the log entry, they get no file. (R10, R11)
5. Their browser downloads one file. (R9)
6. They open the file in their own Excel and change nothing: one row for each invoice issued in that month, with eight columns. (R3, R4, R8) Still open: which invoices issued around midnight belong to the month, Q3 (month boundaries); whether voided invoices are in it, Q7 (voided invoices); when the payment status is read, Q4 (payment status timing); and which customer name is shown, Q5 (which customer name).
7. They send the file to the external auditor themselves, outside the system. (Intent, affected users; see Scope, at the edges)

## Open questions

### Blocks planning
#### Q1. Export permission for the accountants
- **What is unclear:** SEC-04 §1 says a file export that contains customer names "may be performed only by users whose role has the `finance:export` permission", and the intent requires customer names in the file. The accountants' role ("finance") doesn't have that permission today. It can only read invoices, mark invoices paid, and read customers. No role in the admin console lists the permission by name. Who may hold it is Security & Compliance's decision, because SEC-04 controls it.
- **What changes depending on the answer:** Without the permission, no accountant can export, and the intent's first outcome can't be met. If the whole finance role gets it, everyone with that role can download every customer name for any month. A note in the roles file says only the two accountants have that role, and the technical lead confirms this. If it goes only to the two accountants by name, no one else who later gets the finance role can export. R1 and cases 1 and 4 change.
- **What would resolve it:** M. Weber (Security & Compliance, owner of SEC-04) chooses one of the options below. Before that, the technical lead confirms who holds the finance role today.
- **Holds back:** R1 for the accountants, cases 1 and 4, and steps 3 to 6 of the walkthrough.
- **Options:** (a) Give the export permission to the finance role. Everyone with that role can export. (b) Give it only to the two accountants, by name. Anyone else in the finance role can't export. (c) Don't give it. No accountant can export, and the product owner has to take the intent back to its originator.
- **Answer:**

#### Q2. Admins and the export permission
- **What is unclear:** The admin role doesn't list its permissions. It is set to "all permissions". SEC-04 §1 allows the export only to users whose role "has the `finance:export` permission", and doesn't say whether a role with all permissions counts as having it. The repository doesn't record who holds the admin role, or how the console applies "all permissions" today.
- **What changes depending on the answer:** If it counts, everyone with the admin role can download every customer name for any month, and the export log (R10) is the only record of it. If it doesn't count, admins can't export unless they are given the permission by name, and the export check treats "all permissions" differently from how it works elsewhere in the console. Case 5 changes.
- **What would resolve it:** M. Weber says yes or no: does a role with "all permissions" have the `finance:export` permission under SEC-04 §1? Before that, the technical lead reports who holds the admin role and how "all permissions" is applied today.
- **Holds back:** R1 for admins, case 5.
- **Options:** (a) Yes. Admins can export. (b) No. Admins can't export unless given the permission by name.
- **Answer:** (b) No · M. Weber · 2026-10-22

#### Q3. Month boundaries
- **What is unclear:** The intent asks for "every invoice issued in that month" and each invoice's "issue date". It doesn't say which time zone decides where a month starts and ends. The system records the moment each invoice is issued in UTC. A code comment and the README say so, but it wasn't checked. The company is in Berlin, one hour ahead of UTC in winter and two hours ahead in summer. The repository doesn't record which time zone the invoice list's issue-date filter uses.
- **What changes depending on the answer:** An invoice issued in the first hour of a month in Berlin time (first two hours in summer) is still in the previous month in UTC. Example: an invoice issued 2027-02-01 at 00:30 Berlin time was issued 2027-01-31 at 23:30 UTC. In Berlin time it goes in the February file with issue date 2027-02-01. In UTC it goes in the January file with issue date 2027-01-31. That decides which month the invoice counts toward and which file the auditor finds it in. If the file and the invoice list's date filter use different time zones, accountants who check the file against the list for the same month will see different invoices. R3, R4 (issue date), cases 6 and 7, and the first check under How we will know change.
- **What would resolve it:** The product owner chooses one of the options below, after asking the accountants which dates their books use. Before that, the technical lead reports which time zone the invoice list's date filter uses, confirms that issue times are stored in UTC, and counts how many invoices issued in 2026 fall in a different month in Berlin time than in UTC. That count shows how many invoices the answer moves.
- **Holds back:** R3 (where the month starts and ends), R4 (issue date), cases 6 and 7.
- **Options:** (a) Berlin time decides both the month and the issue date shown. (b) UTC decides both. (c) The file uses whatever the invoice list's date filter uses, so the file and the list always agree. This needs the technical lead's report first.
- **Answer:** (a) Berlin time · Lena Vogel · 2026-10-22

#### Q4. Payment status timing
- **What is unclear:** The intent asks for each invoice's "payment status" but not as of when. The invoice record holds only the current status. It has no date of payment and no history of status changes. That was checked in the record's definition, and no history was found anywhere else in the repository. The accountants close a month after it ends, so a status can change between the end of the month and the download, and between two downloads.
- **What changes depending on the answer:** Example: an invoice issued 2027-01-20 is paid on 2027-02-04. If January is exported on 2027-02-03 and again on 2027-02-05, the status is read at download under options (a) and (b), so the first file shows "open" and the second shows "paid". The accountants then have two different files for the same month, and the auditor may get either one. Under option (c), both files show "open". Option (c) also needs data the system doesn't keep today. Case 12 changes.
- **What would resolve it:** The product owner chooses one of the options below, after asking the accountants what the auditor expects the status column to mean. The technical lead confirms that no history of status changes is kept anywhere.
- **Holds back:** R4 (payment status), case 12.
- **Options:** (a) The status at the moment of download, with nothing else shown. This is the simplest option, but two files for the same month can differ and nothing shows which is newer. (b) The status at the moment of download, and the file states when it was produced. Readers can tell the versions apart. (c) The status at the end of the chosen month. Every download of a month is the same, but the system must start recording when each status changes, and months before that record starts can't be produced this way.
- **Answer:**

#### Q5. Which customer name
- **What is unclear:** The intent asks for "customer name". The invoice record holds only a reference to the customer, not a name. That was checked in the record's definition. The name therefore comes from the customer's own record, which isn't in the repository. If a customer's name changes after an invoice is issued, the file could show the name the customer has now, or the name the invoice was issued to.
- **What changes depending on the answer:** Example: an invoice is issued on 2027-01-12 to "Alpha Bau GmbH", which is renamed "Alpha Bau AG" on 2027-03-01. If January is exported on 2027-03-05, option (a) shows "Alpha Bau AG" and option (b) shows "Alpha Bau GmbH". Under (a), the auditor finds a different name in the file than on the invoice. Option (b) works only if the name on each invoice is kept somewhere. If it isn't, the system must start keeping it, and earlier invoices can only show the current name. Case 13 changes.
- **What would resolve it:** The product owner chooses one of the options below, after asking the accountants. Before that, the technical lead confirms whether the name on each invoice, as issued, is kept anywhere.
- **Holds back:** R4 (customer name), case 13.
- **Options:** (a) The customer's current name. (b) The name the invoice was issued to.
- **Answer:**

#### Q6. The auditor's file needs
- **What is unclear:** The intent says the new external auditor "wants the full monthly invoice list as a file" from January 2027, and that the file must open in the accountants' Excel without reformatting. It doesn't say whether the auditor needs a particular kind of file, for example an Excel workbook or a plain comma-separated text file for the auditor's own software.
- **What changes depending on the answer:** If the auditor needs a particular kind of file, engineers build that kind, and it must still open in the accountants' Excel without changes (R8). If the auditor accepts any file that opens in Excel, engineers may choose the kind (see Left to engineering). Switching kinds after building means rework close to January 2027. The auditor's answer may also inform Q4 (payment status timing) and Q7 (voided invoices).
- **What would resolve it:** The originator asks the auditor and reports either the kind of file required or "any file that opens in Excel".
- **Holds back:** The kind of file (Left to engineering), and cases 9 to 11, which test it.
- **Options:** (a) Any file that opens in the accountants' Excel without changes. (b) A particular kind of file that the auditor names.
- **Answer:**

### Needed before release
#### Q7. Voided invoices
- **What is unclear:** An invoice can have the status "void". The intent asks for "every invoice issued in that month", and the repository doesn't say what "void" means. It could be an invoice that was issued and later cancelled, or one that was never sent. So it is unclear whether voided invoices belong in the file.
- **What changes depending on the answer:** Example: an invoice issued 2027-01-10 is voided on 2027-01-12. If voided invoices are included, the invoice numbers in the file run without gaps (if voided invoices keep their numbers), but the column totals include voided amounts unless the accountants filter them out. If they are left out, the totals cover only valid invoices, but the auditor sees gaps in the invoice numbers. R3 and case 14 change.
- **What would resolve it:** The technical lead confirms what "void" means in the system. The product owner then chooses one of the options below, after asking the accountants what the auditor expects.
- **Holds back:** R3 for voided invoices, case 14.
- **Options:** (a) Include voided invoices, with status "void" and their amounts as recorded. (b) Leave them out.
- **Answer:** (a) include voided invoices · Jonas Krüger (accountant) · 2026-10-22

#### Q8. A month that hasn't ended
- **What is unclear:** The intent lets an accountant choose "one calendar month". It doesn't say whether that can be the current month, which hasn't ended yet.
- **What changes depending on the answer:** Example: on 2027-01-20 an accountant chooses January 2027. If that is allowed, the file lists only the invoices issued up to that moment, and it could reach the auditor as if it were the full list. If it isn't allowed, a month can be chosen only after it ends, in the time zone that Q3 (month boundaries) settles. R2 and case 15 change.
- **What would resolve it:** The product owner chooses one of the options below.
- **Holds back:** R2 (whether the current month can be chosen), case 15.
- **Options:** (a) Any month, including the current one. The file lists the invoices issued so far. (b) Only months that have ended. The current month becomes available once it is over.
- **Recommendation (the writer's, not a decision):** (b). The intent's first outcome is a file that lists "every invoice issued in that month", and the auditor wants "the full monthly invoice list". A file for a month that hasn't ended can be neither. I don't know whether the accountants start close work before a month ends.
- **Answer:**

#### Q9. Headings and wording
- **What is unclear:** The intent names the eight things each row shows. It doesn't give the column headings, their order or language, the words used for the four statuses (open, paid, overdue, void), or the file's name. The accountants and the auditor read all of these. The admin console shows amounts in German format, and the intent is written in English.
- **What changes depending on the answer:** These choices decide the language the accountants and the auditor read the file in. They also decide whether the accountants can paste rows straight into their current spreadsheet or must rearrange columns first, which bears on the intent's third outcome (no more re-keying). R4 is affected. No case changes.
- **What would resolve it:** The product owner, after asking the accountants, gives a list: the eight headings in order, the four status words, and the file name.
- **Holds back:** The headings, status words, and file name. Planning can leave these as blanks to fill in.
- **Options:** (a) English headings and status words, in the order the intent lists them. (b) German headings and status words. (c) The headings and column order of the accountants' current spreadsheet.
- **Answer:**

## Rules
### Who can export
- R1. **Only holders of the export permission:** Only a user whose role has the export permission can export the file, by any route, because the file contains customer names. Whether the accountants and admins hold the permission is open: Q1 and Q2. (SEC-04 §1; intent, desired outcome 1)

### Choosing the month
- R2. **One calendar month per file:** On the invoices page of the admin console, the user chooses one calendar month, with no limit on how far back, and gets one file for it. Whether the current month can be chosen is open: Q8. (Intent, in scope and desired outcome 1, which set no limit on the month)
- R3. **Every invoice of that month:** The file lists every invoice issued in the chosen month, however many there are and whatever filters are set on the invoice list at the time. Where a month starts and ends is open (Q3), and so is whether voided invoices count (Q7). (Derived from intent, desired outcome 1: "every invoice issued in that month")

### What the file contains
- R4. **Eight columns:** Each row is one invoice and shows its invoice number, issue date, customer name, net amount, VAT amount, gross amount, currency, and payment status. The issue date waits on Q3, the customer name on Q5, the payment status on Q4, and the headings and wording on Q9. (Intent, desired outcome 1)
- R5. **No card or bank details:** The file contains no card or bank account details, because the file leaves the company and the auditor doesn't need them. (Intent, constraints)
- R6. **Amounts and currency as on the invoice:** Each amount is the amount recorded on the invoice, in the invoice's own currency, and nothing is recalculated or converted into another currency. (Derived from intent, desired outcome 1, which lists each invoice's amounts with its own currency)
- R7. **Amounts in currency units:** Amounts appear as numbers in units of the currency, with two decimal places (1.234,56 €, not 123456 cents). (Derived from intent, desired outcome 2, and the stored amounts being in cents: an amount in cents would have to be divided by 100 before use)
- R8. **Opens without changes:** Opened in an accountant's own Excel, every column shows correctly with no change: issue dates as dates, amounts as numbers that can be added up, and every name and invoice number exactly as recorded, including umlauts and names that start with "=". (Intent, desired outcome 2)

### Handing over the file
- R9. **Direct download only:** The file reaches the user only as a download in their browser. The system doesn't email it, send it on a schedule, or put it on shared storage such as a network drive. (SEC-04 §3; intent, out of scope)
- R10. **Every export logged:** Each export is logged with the user, the time, and the month chosen. (SEC-04 §2)
- R11. **No file without a log entry:** If the log entry can't be recorded, no file is handed over. (Derived from SEC-04 §2: a file handed over without a log entry would be an export that isn't logged)

## Cases
| # | Situation | What the person sees and what happens | Basis |
|---|---|---|---|
| 1 | On 2027-02-03 an accountant whose role has the export permission chooses January 2027. 312 invoices were issued in January (example), more than the 50 the invoice list shows per page. | One file downloads with 312 rows, one per invoice, each with the eight columns. The log records the accountant, the time, and January 2027. | R1, R2, R3, R4, R9, R10 |
| 2 | As case 1, but the invoice list on screen is filtered to status "paid" and to one customer. | The file still holds all 312 January invoices. | R3 |
| 3 | A support staff member (support role) tries to export. | They can't start an export, from the invoices page or by any other route. No file. | R1 |
| 4 | One of the accountants tries to export with the finance role as it is today, without the export permission. | They can't export, as in case 3, unless Q1 gives them the permission. | R1, Q1 |
| 5 | A user with the admin role ("all permissions") tries to export. | Not decided: Q2. | R1, Q2 |
| 6 | An invoice issued 2027-02-01 at 00:30 Berlin time, which is 2027-01-31 at 23:30 UTC (example). | Not decided whether it is in the January or the February file, or whether its issue date shows 2027-01-31 or 2027-02-01: Q3. | R3, R4, Q3 |
| 7 | An invoice issued 2027-07-01 at 01:30 Berlin summer time, which is 2027-06-30 at 23:30 UTC (example). | Not decided whether it is in the June or the July file, or which issue date it shows: Q3. | R3, R4, Q3 |
| 8 | An invoice issued 2027-01-15 at 10:00 Berlin time, which is 09:00 UTC (example). | In the January file with issue date 2027-01-15, whatever Q3 decides. | R3, R4 |
| 9 | A euro invoice: net 1.234,56 €, VAT 234,57 €, gross 1.469,13 € (example). | The row shows 1234.56, 234.57, and 1469.13 as numbers, in Excel's own number style, and currency EUR. Excel can add them up without any change. | R6, R7, R8 |
| 10 | A Swiss franc invoice in the same month: net 500,00 CHF, VAT 40,50 CHF, gross 540,50 CHF (example). | The row shows 500.00, 40.50, and 540.50 and currency CHF. Nothing is converted to euros. | R6, R7 |
| 11 | Customers named "Müller & Söhne GmbH" and "=Plus Consulting" (examples). | Both names appear exactly as written, as text. Excel doesn't treat "=Plus Consulting" as a formula. | R8 |
| 12 | An invoice issued 2027-01-20 and paid 2027-02-04 (example). January is exported on 2027-02-03 and again on 2027-02-05. | Not decided: Q4. If the status is read at download, the first file shows "open" and the second "paid". If it is read at the end of the month, both show "open". | R4, Q4 |
| 13 | An invoice issued 2027-01-12 to "Alpha Bau GmbH". The customer is renamed "Alpha Bau AG" on 2027-03-01, and January is exported on 2027-03-05 (example). | Not decided which name the row shows: Q5. | R4, Q5 |
| 14 | An invoice issued 2027-01-10 and voided 2027-01-12 (example). | Not decided whether it is in the January file: Q7. | R3, Q7 |
| 15 | On 2027-01-20 an accountant chooses January 2027, which hasn't ended. | Not decided: Q8. | R2, Q8 |
| 16 | January 2027 is exported twice, by the same accountant or by both. | Two files and two log entries. The files are the same unless an invoice changed in between (see Q4 and Q5). | R10 |
| 17 | The log entry can't be recorded when an accountant starts an export. | No file is handed over, and nothing reaches the accountant's computer. | R11 |
| 18 | The download breaks off after the log entry was recorded. | The log shows the export. The accountant starts again, and that records a second entry. | R10, R11 |
| 19 | Any exported file is inspected column by column. | It has the eight columns of R4 and no card or bank account details. | R4, R5 |
| 20 | After an export, someone looks for a copy of the file kept by the system. | There is no copy on any shared storage. The technical lead checks this before release. | R9 |

- What can't be undone: A downloaded file can't be recalled. Once an accountant sends it to the auditor, the customer names in it have left the company. That is why SEC-04 §1 limits who can export (R1) and why the intent keeps card and bank details out (R5).

## Policies
| Policy and clause (owner) | What it requires here | Where this spec stands | How it will be checked |
|---|---|---|---|
| SEC-04 §1 (Security & Compliance, M. Weber) | The file contains customer names, so only users whose role has the export permission may export it. | R1. Q1: the accountants' role doesn't have the permission today. Q2: unclear whether "all permissions" counts. | Cases 1, 3, 4, and 5, and M. Weber's answers to Q1 and Q2 |
| SEC-04 §2 (Security & Compliance, M. Weber) | Every export is logged with the user, the time, and the filter or date range, which here is the month chosen. | R10, R11 | Cases 1, 16, 17, and 18, and M. Weber reviews a sample log entry before release |
| SEC-04 §3 (Security & Compliance, M. Weber) | The system doesn't store export files on shared storage, and files go out only as a direct download. | R9, and the limit on how the file is produced under Left to engineering | Case 20, and M. Weber reviews before release |

Read and not applicable: None. SEC-04 is the only policy in the repository, and the repository has no other written rules for brand, security, privacy, or compliance.

## How we will know it worked
| Desired outcome (intent) | How someone other than the writer checks it | Baseline → target |
|---|---|---|
| An accountant can download one file per calendar month that lists every invoice issued in that month, with the eight columns | After release, an accountant exports the first month that has ended. They check its invoice numbers against the invoice list for that month in the console, using the month boundaries Q3 sets. The product owner arranges this. | No export today → one file per month that holds every invoice of the month with the eight columns |
| The file opens in the accountants' Excel without any reformatting | On their own computer, an accountant opens the file, adds up the gross amounts for one currency, and sorts by issue date, all without changing anything first (cases 9 to 11) | Not possible today → no change needed |
| Month-end close no longer includes re-keying invoices by hand | After the first month-end close that uses the export, the product owner asks both accountants how many invoices they typed in by hand | About one working day per close → no invoices typed by hand |

The originator confirms the first month for which the auditor expects a file (the intent says "from January 2027"). That sets the latest release date.

## Left to engineering
- The kind of file, unless Q6 settles it, as long as cases 9 to 11 pass on an accountant's own computer (R8).
- How the month is chosen on the invoices page and how the export is started (R2).
- Whether users without the export permission see the export control greyed out or don't see it at all, as long as they can't export (R1, case 3).
- How the file is produced, as long as it never goes on shared storage and reaches the user only as a download (R9). Producing it without writing it to any storage meets every reading of SEC-04 §3. If the plan needs to write it anywhere, even briefly, ask M. Weber first.
- Where and how the export log is kept, as long as each entry holds the user, the time, and the month, and M. Weber accepts it in the review before release (R10, R11).
- How the user is told that an export failed, as long as they can tell that no file was produced (case 17).
- What the user gets for a month with no invoices, as long as they can tell the month had none.
- The order of the rows.

## Facts and sources
- The invoice record holds the invoice number, the moment of issue, a reference to the customer, the net, VAT, and gross amounts, the currency (EUR, CHF, or USD), and the status (open, paid, overdue, or void). `services/billing/invoice.ts` (verified in code)
- The invoice record holds no customer name, no card or bank account details, no date of payment, no due date, and no history of status changes. `services/billing/invoice.ts` (verified in code; whether any of these is kept elsewhere wasn't found; technical lead confirms)
- The moment of issue is stored in UTC. `services/billing/invoice.ts`, `README.md` (stated in a comment or document, not verified; technical lead confirms) → Q3
- The net amount is stored in cents. No unit is given for the VAT and gross amounts. `services/billing/invoice.ts` (stated in a comment, not verified; technical lead confirms that all three are in cents) → R7
- Invoice numbers look like "LG-2026-001234". `services/billing/invoice.ts` (stated in a comment, not verified)
- The company, Ledgerly GmbH, is in Berlin. `README.md` (stated in a document, not verified)
- The invoice list filters by status, customer, and issue-date range, shows 50 invoices per page, and shows amounts in German format (1.234,56 €). `admin/src/pages/invoices/index.tsx` (stated in a comment, not verified; the page's code isn't in the repository; technical lead confirms)
- Roles: support can read invoices and customers. Finance can read invoices, mark invoices paid, and read customers. Admin is set to `"*"` (all permissions). No role lists `finance:export`. `config/roles.yaml` (verified in the configuration) → Q1, Q2
- The finance role is held by the two accountants. `config/roles.yaml` (stated in a comment, not verified; technical lead confirms) → Q1
- Not found: code that checks permissions, so how `"*"` is applied today is unknown. Also not found: who holds the admin role. → Q2
- Not found: any existing export or export log (searched the repository for "export" and "log"). → R10
- Not found: the customer record, where customer names come from, and whether the name on each invoice as issued is kept. → Q5
- Not found: which time zone the invoice list's issue-date filter uses. Also not found: how many invoices fall in a different month in Berlin time than in UTC, which can be counted from the stored issue times. → Q3
- Not found: where credit notes are kept. The invoice record has no field that marks a credit note. → Scope, at the edges
- Not found: the accountants' Excel version and regional settings. The check for R8 runs on an accountant's own computer, so these needn't be looked up first.
- Not found: what kind of file the auditor needs. → Q6

## Terms
- **Export:** The monthly invoice file produced and handed to the user as a download. SEC-04 calls this a "file export".
- **Export permission:** The permission SEC-04 §1 names `finance:export`. A user may export only if their role has it.
- **Role:** A named set of permissions in the admin console, such as support, finance, or admin.
- **Customer personal data:** As SEC-04 §1 uses it, it includes customer names.
- **Accountant:** One of the finance team's two in-house accountants (intent).
- **Issue date:** The date an invoice was issued. The system records the moment of issue in UTC, so the date depends on the time zone used (Q3).
- **UTC:** The world reference time. Berlin is one hour ahead of it in winter and two hours ahead in summer.
- **Payment status:** The status recorded on the invoice: open, paid, overdue, or void.
