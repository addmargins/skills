#!/bin/sh
# check-spec.sh <spec.md>: mechanical facts a reader of spec.md alone cannot check, each with one fix: ids and
# references resolve, quotes match their files, From the intent covers the intent, a revision keeps its ids, the
# counts add up, each requirement has a scenario, prose names no code, and no line outside Open questions and Sources
# puts on one side ("under £100", "within the threshold", "100 이하") a value a question asks at its boundary ("exactly").
# Passing means only that, never that the spec is good. Prints "file:line: problem" per finding, "not verified" for
# a quote it could not check. Exits 0 when clean, 1 on findings, 2 on a usage error.
set -eu
spec=${1:?usage: check-spec.sh <spec.md>}
[ -f "$spec" ] || { echo "check-spec: no such file: $spec" >&2; exit 2; }
dir=$(dirname "$spec")
field() { awk -v k="$1:" '{ sub(/\r$/, "") } index($0, k) == 1 { sub(/^[^:]*:[ \t]*/, ""); gsub(/`/, ""); sub(/[ \t]+$/, ""); print; exit }' "$spec"; }
name=$(field Intent) intent=/dev/null
for f in "$dir/../intents/${name##*/}" "$dir/$name" "$dir/../../$name"; do   # never the spec itself
  [ -n "$name" ] && [ -f "$f" ] && [ "$f" != "$dir/${spec##*/}" ] && { intent=$f; break; }; done
name=$(field Supersedes) old=/dev/null
[ -z "$name" ] || [ ! -f "$dir/$name" ] || old=$dir/$name

awk -v SPEC="$spec" -v INTENT="$intent" -v OLD="$old" -v SUP="$name" -v ROOTS="$dir/../..|$dir/..|$dir|." '
function report(l, m) { print SPEC ":" l ": " m; bad = 1 }
function squeeze(t,   a, n, i, o) {   # curly quotes, bold, list markers and whitespace do not count
  gsub(/“|”/, "\"", t); gsub(/‘|’/, "'"'"'", t); gsub(/\*\*/, "", t); n = split(t, a, /[ \t\r]+/); o = ""
  for (i = 1; i <= n; i++) if (a[i] != "" && a[i] !~ /^([-*+]|•|\([0-9a-z][0-9a-z]?[0-9a-z]?[0-9a-z]?\)|[a-z]\))$/) o = o (o == "" ? "" : " ") a[i]; return o }
function is_def(   s) {   # sets ID and NM when this line defines an R, A, C, Q or S
  if ($0 !~ /^### R[0-9]+\. / && $0 !~ /^- [CQ][0-9]+\. / && !(sec == "Sources" && $0 ~ /^- S[0-9]+\. /) \
    && !(sec == "What this work touches" && $0 ~ /^- A[0-9]+\. /)) return 0
  s = $0; sub(/^(### |- )/, "", s); ID = s; sub(/\..*/, "", ID); NM = s; sub(/^[RACQS][0-9]+\. /, "", NM)
  if (ID ~ /^R/) sub(/^[^:]*: /, "", NM); if (ID ~ /^C/) sub(/:.*/, "", NM); sub(/[ \t]+$/, "", NM); return 1 }
function code_name(t,   a, n, i, w) {   # the first file path or code name in t, or ""
  gsub(/https?:\/\/[^ \t)>]+/, "", t); n = split(t, a, /[ \t]+/)
  for (i = 1; i <= n; i++) { w = a[i]
    if (w ~ /`[^`]+`/ || w ~ /[A-Za-z0-9_-]\/[A-Za-z0-9_.\/-]*\.[A-Za-z]/ || w ~ /[a-z][a-z0-9_-]*\/[a-z0-9_-]+\// \
      || w ~ /[A-Za-z]_[A-Za-z]/ || w ~ /(^|[^A-Za-z0-9])[a-z][a-z0-9]+[A-Z][a-z]/ \
      || (w ~ /[A-Za-z0-9_-]\.(ts|tsx|js|jsx|mjs|py|go|rb|java|kt|cs|php|sql|json|yaml|yml|toml|sh|md|rs|swift|vue)([^A-Za-z0-9]|$)/ && w !~ /^[^A-Za-z]*[A-Z][a-z]+\.js/)) {
      gsub(/^[^A-Za-z0-9_`]+|[^A-Za-z0-9_`\/]+$/, "", w); return w } }
  gsub(/“|”/, "\"", t); gsub(/"[^"]*"/, "", t); n = split(t, a, /[ \t]+/)   # a code label, outside quoted words
  for (i = 1; i <= n; i++) { w = a[i]; gsub(/^[^A-Za-z0-9_]+|[^A-Za-z0-9_]+$/, "", w); if (w ~ /^[A-Z][A-Z][A-Z][A-Z][A-Z][A-Z][A-Z]+$/) return w } return "" }
function first_path(t,   a, n, i, w) {   # the file an S line names: in backticks, else the first word with / or .ext
  if (match(t, /`[^`]+`/) > 0) return substr(t, RSTART + 1, RLENGTH - 2)
  n = split(t, a, /[ \t]+/)
  for (i = 1; i <= n; i++) { w = a[i]; gsub(/^[(`"]+|[.,;:)`"]+$/, "", w); if (w ~ /\// || w ~ /\.[a-z][a-z]*$/) return w } return "" }
function find_file(p,   a, k, f) {   # p found from the workspace root, or ""
  if (p ~ /^\//) return is_file(p) ? p : ""
  for (k = 1; k <= split(ROOTS, a, "|"); k++) if (p != "" && is_file(f = a[k] "/" p)) return f; return "" }
function is_file(f,   a, n, i, q, o) { q = sprintf("%c", 39); n = split(f, a, q); o = a[1]; for (i = 2; i <= n; i++) o = o q "\\" q q a[i]
  return system("test -f " q o q) == 0 }
function file_text(f,   l, t, prev) {   # the file squeezed; lstop[f, i]: where a line that leads into a list ends
  if (f in ftext) return ftext[f]
  t = prev = ""; while ((getline l < f) > 0) {
    if (l ~ /^[ \t]*([-*+|]|[0-9]+[.)]|\(?[a-z0-9]\))[ \t]/) { if (prev != "") lstop[f, ++n_lstop[f]] = length(squeeze(t)) + 1; prev = "" }
    else if (l !~ /^[ \t]*$/) prev = (l ~ /^#/) ? "" : l
    t = t " " l }
  close(f); return ftext[f] = squeeze(t) }
function check_quotes(l, id, v,   a, n, i, sid, p, f, q, k, ft, t, e, j, stop) {   # each quoted part of one Policy text: line
  gsub(/“|”/, "\"", v); n = split(v, a, "\""); if (n < 2) return
  if (n % 2 == 0) { report(l, id ": a quote has no closing quote mark"); return }
  sid = ""; if (match(a[1], /(^|[^A-Za-z0-9_])S[0-9]+/) > 0) { sid = substr(a[1], RSTART, RLENGTH); sub(/^[^S]/, "", sid) }
  if (sid == "") { report(l, id ": not verified: cite the quoted document as S<n> (Name), listed under Sources with its file"); return }
  p = s_path[sid]; f = find_file(p)
  if (f == "") { report(l, id ": not verified: " sid "'"'"'s file " (p == "" ? "is not named under Sources" : p " was not found") "; check the quote by hand and say so in your final message"); return }
  if (p ~ /\.[A-Za-z0-9]+$/ && p !~ /\.(md|markdown|txt|text|rst|adoc|html?)$/) { report(l, id ": not verified: " p " is not a text file; check the quote by hand and say so in your final message"); return }
  ft = file_text(f)
  for (i = 2; i < n; i += 2) { q = squeeze(a[i]); if (q == "") continue
    if (!(k = index(ft, q))) { report(l, id ": the text quoted from " sid " is not word for word in " p ": quote the clause exactly, never a summary; quote separate parts separately"); continue }
    if (stop_id != "") { t = substr(ft, stop_at); sub(/^ ?:? ?/, "", t); e = t; sub(/^[0-9]+[.)] /, "", e)   # goes on with the list
      if (stop_id != id || stop_f != f || (index(t, q) != 1 && index(e, q) != 1)) list_cut(); stop_id = "" }
    e = k + length(q); stop = q ~ /:$/ || substr(ft, e, 2) ~ /^ ?:/
    for (j = 1; j <= n_lstop[f]; j++) if (lstop[f, j] == e) stop = 1
    if (stop) { stop_id = id; stop_f = f; stop_at = e; stop_line = l; stop_sid = sid } } }
function list_cut() { if (stop_id != "") report(stop_line, stop_id ": the quote from " stop_sid " stops before the list it leads into: quote the list too, here or in the next quote"); stop_id = "" }
function norm(v) { gsub(/,/, "", v); sub(/\.0+$/, "", v); return v }
function side_scan(t, u,   m, v) {   # each phrase putting a case on one side of a value; not words of the intent, nor "falls under"
  while (match(t, /(^|[^a-z])(under|below|over|above|within|up to|at least|at most|less than|more than|exceed(s|ed|ing)?|meets?)( (the|a|an|its) [a-z-]+( [a-z-]+)?( of)?)?[: ]+[^ 0-9a-z(]?[^ 0-9a-z(]?[^ 0-9a-z(]?[0-9][0-9,]*(\.[0-9]+)?/)) {
    m = substr(t, RSTART, RLENGTH); t = substr(t, RSTART + RLENGTH); sub(/^[^a-z]/, "", m); v = m; sub(/^[^0-9]*/, "", v); side(m, norm(v)) }
  t = u; while (match(t, /[0-9][0-9,]*(\.[0-9]+)?[^ 0-9]*( [^ 0-9]+)? ?(or more|or less|이상|이하|미만|초과|이내)/)) {
    m = substr(t, RSTART, RLENGTH); t = substr(t, RSTART + RLENGTH); v = m; sub(/[^0-9.,].*/, "", v); side(m, norm(v)) }
  t = u; while (match(t, /(^|[^a-z])(under|below|over|above|within|up to|exceed(s|ed|ing)?|meets?) (the|a|an|its) ([a-z-]+ )?(threshold|limit)/)) {
    m = substr(t, RSTART, RLENGTH); t = substr(t, RSTART + RLENGTH); sub(/^[^a-z]/, "", m); v = m; sub(/.* /, "", v); side(m, "~" v) }
  t = u; while (match(t, /(기준|한도)[^ 0-9]*( [^ 0-9]+)? ?(이상|이하|미만|초과|이내)/)) {
    m = substr(t, RSTART, RLENGTH); t = substr(t, RSTART + RLENGTH); side(m, m ~ /^기준/ ? "~threshold" : "~limit") } }
function side(m, v) { if (!index(itx, m) && !index(cur, "fall " m) && !index(cur, "falls " m)) { sd_m[++n_sd] = m; sd_v[n_sd] = v; sd_l[n_sd] = FNR } }
function end_r() { if (cr != "" && !scn) report(cr_line, cr " has no scenario: add a case under it"); cr = "" }
{ sub(/\r$/, "") }
FILENAME == OLD { if (/^## /) sec = substr($0, 4); if (is_def() && ID ~ /^[RC]/) old_id[substr(ID, 1, 1), NM] = ID; next }
FILENAME == INTENT { itx = itx " " tolower($0); if (/^## /) { isec = $0; sub(/[ \t]+$/, "", isec); next }
  if ((isec == "## Desired outcome" || isec == "## Open questions") && /^- /) { s = squeeze(substr($0, 3)); sub(/[ \t.]+$/, "", s); if (s != "None") want[++n_want] = s }
  next }
FNR == 1 { sec = "" }
/^```/ { fence = !fence; next }
fence { next }
/^## / { end_r(); sec = substr($0, 4); sub(/[ \t]+$/, "", sec); ca = ""; next }
sec == "" && /^Status:/ { status = $0; status_line = FNR }
sec == "Open questions" && /^### / { s = substr($0, 5); sub(/[ \t]+$/, "", s); tier = (s == "Decide before building") ? 1 : (s == "Can wait for planning") ? 2 : 0
  if (tier) has_tier[tier] = 1; next }
sec == "Requirements" && /^- / { scn = 1 }
sec == "What this work touches" && /^(### |- )/ { ca = "" }
sec == "What this work touches" && /^- A[0-9]+\. / { ca = substr($0, 3); sub(/\..*/, "", ca); a_id[++n_a] = ca; a_line[ca] = FNR }
ca != "" && /^[ \t]+- Confirm in:/ { a_q[ca] = ""; a_qline[ca] = FNR; if (match($0, /[^A-Za-z0-9_]Q[0-9]+/) > 0) a_q[ca] = substr($0, RSTART + 1, RLENGTH - 1) }
ca != "" && /^[ \t]+- Policy text:/ { pt_a[++n_pt] = ca; pt_line[n_pt] = FNR; pt_v[n_pt] = $0 }
sec == "Sources" && /^- S[0-9]+\. / { s = $0; sub(/^- /, "", s); id = s; sub(/\..*/, "", id); s_path[id] = first_path(s) }
/^- (Outcome|Question) "/ { s = $0; sub(/^- [A-Za-z]+ "/, "", s); ledger = ledger "\n" squeeze(s) }
sec != "" && sec != "Sources" { s = $0; if (/^- (Outcome|Question) "/) gsub(/"[^"]*"/, "", s); if (/^[ \t]+- Policy text:/) sub(/".*/, "", s)
  if ((w = code_name(s)) != "") report(FNR, "\"" w "\" is a file or code name: say it in plain words and cite S<n> (Name); names go under Sources")
  if (sec != "Open questions") { cur = tolower(s); gsub(/[racqs][0-9]+ \([^)]*\)/, "", cur); side_scan(cur, cur) } }   # "R3 (Name)": once, where defined
sec == "Open questions" { if (/^- Q[0-9]+\. /) { cq = substr($0, 3); sub(/\..*/, "", cq); qtext[cq] = $0; q_ord[++n_q] = cq }
  else if (cq != "" && /^[ \t]/) qtext[cq] = qtext[cq] " " $0; else cq = "" }
is_def() { if (ID in line) report(FNR, ID " is defined twice"); line[ID] = FNR; name[ID] = NM
  if (ID ~ /^R/) { end_r(); cr = ID; cr_line = FNR; scn = 0 }
  if (ID ~ /^Q/) { qtier[ID] = tier; n_tier[tier]++; if (!tier) report(FNR, ID " is under no tier: put it under \"### Decide before building\" or \"### Can wait for planning\"") } }
{ s = " " $0; if (/^[ \t]+- Policy text:/) sub(/".*/, "", s); if (/^- (Outcome|Question) "/) gsub(/"[^"]*"/, "", s)
  while (match(s, /[^A-Za-z0-9_][RACQS][0-9]+/) > 0) { id = substr(s, RSTART + 1, RLENGTH - 1); s = substr(s, RSTART + RLENGTH)
    if (s !~ /^[A-Za-z0-9_]/) { ref[++n_ref] = id; ref_line[n_ref] = FNR } }
  s = $0; while (match(s, /\(decided by [^()]*\)/) > 0) { m = substr(s, RSTART, RLENGTH); s = substr(s, RSTART + RLENGTH)
    while (match(m, /[^A-Za-z0-9_]Q[0-9]+/) > 0) { mref[++n_m] = substr(m, RSTART + 1, RLENGTH - 1); mref_line[n_m] = FNR; m = substr(m, RSTART + RLENGTH) } } }
END { end_r()
  if (INTENT == "/dev/null") report(1, "Intent: line missing, or its file not found in ../intents/ or next to the spec")
  if (SUP != "" && OLD == "/dev/null") report(1, "superseded spec not found next to this one: " SUP)
  for (i = 1; i <= n_ref; i++) if (!(ref[i] in line) && !(ref[i] in told)) { told[ref[i]] = 1; report(ref_line[i], ref[i] " is referenced but not defined") }
  for (i = 1; i <= n_m; i++) if (mref[i] in qtier) report(mref_line[i], mref[i] " is an open question, so a (decided by …) marker cannot cite it")
  for (i = 1; i <= n_want; i++) if (!index(ledger, want[i])) report(1, "From the intent: no Outcome or Question line quoting \"" want[i] "\"")
  for (id in name) if (id ~ /^[RC]/ && ((k = substr(id, 1, 1) SUBSEP name[id]) in old_id) && old_id[k] != id)
    report(line[id], id " has the name of " old_id[k] " in the superseded spec; keep the old id")
  split("Decide before building|Can wait for planning", tn, "|")
  for (i = 1; i <= 2; i++) if (!(i in has_tier)) report(1, "Open questions has no \"### " tn[i] "\" heading; write \"None.\" under it if it has no questions")
  for (i = 1; i <= n_a; i++) { id = a_id[i]; q = a_q[id]
    if (q == "") report((id in a_qline) ? a_qline[id] : a_line[id], id "'"'"'s Confirm in: names no question: give the Q<n> that asks its role to confirm it")
    else if ((q in qtier) && qtier[q] != 1) report(a_qline[id], id " is confirmed in " q ", which is not under \"Decide before building\"") }
  s = status; n = 0; while (match(s, /[0-9]+/) > 0) { cnt[++n] = substr(s, RSTART, RLENGTH) + 0; s = substr(s, RSTART + RLENGTH) }
  if (!status_line) report(1, "no \"Status:\" line")
  else if (n != 2) report(status_line, "Status: must give two numbers: questions to decide before building, then those that can wait for planning")
  else for (i = 1; i <= 2; i++) if (cnt[i] != n_tier[i] + 0) report(status_line, "Status: says " cnt[i] " under \"" tn[i] "\", but it lists " n_tier[i] + 0)
  for (i = 1; i <= n_q; i++) { q = q_ord[i]; t = u = tolower(qtext[q])   # values asked at a boundary
    while (match(t, /exactly|equals|equal to|at the threshold|boundary|정확히|경계/)) {
      t = substr(t, RSTART); p = match(t, /[;.] |\. *$/); s = p ? substr(t, 1, p) : substr(t, 1, 120); t = substr(t, 2)
      for (k = split("threshold 기준 limit 한도", a, " "); k; k--) if (index(u, a[k]) && !((w = k > 2 ? "~limit" : "~threshold") in bq)) bq[w] = q
      while (match(s, /[^a-z0-9_][0-9][0-9,]*(\.[0-9]+)?/)) { v = norm(substr(s, RSTART + 1, RLENGTH - 1)); s = substr(s, RSTART + RLENGTH)
        if (v + 0 >= 2 && s !~ /^\. / && !(v in bq)) bq[v] = q } } }
  for (i = 1; i <= n_sd; i++) if (((v = sd_v[i]) in bq) && !(sd_l[i] in sd_told)) { q = bq[v]; sd_told[sd_l[i]] = 1
    report(sd_l[i], "\"" sd_m[i] "\" puts a case on one side of " (v ~ /^~/ ? "the " substr(v, 2) : v) ", which " q " asks about: drop the comparison word, give the value as its source does, and leave the case at the boundary to " q) }
  for (i = 1; i <= n_pt; i++) check_quotes(pt_line[i], pt_a[i], pt_v[i]); list_cut()
  exit bad
}' "$old" "$intent" "$spec"
