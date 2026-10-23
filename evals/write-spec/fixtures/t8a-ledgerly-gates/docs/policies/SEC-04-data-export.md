# SEC-04 Data export

Owner: Security & Compliance (M. Weber) · revised 2026-06-01

1. A file export that contains customer personal data (including customer names) may be performed only by users whose role has the `finance:export` permission.
2. Every such export is logged with: user, time, and the filter or date range used.
3. The system must not store export files on shared storage; files are delivered as a direct download only.
