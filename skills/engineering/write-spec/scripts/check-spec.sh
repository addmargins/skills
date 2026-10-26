#!/bin/sh
# check-spec.sh <spec.md>: check what a reader of spec.md alone cannot.
# - Every R, C, Q and S id mentioned is defined once, and "R<n> (Name)", "C<n> (Name)" or "S<n> (Name)" uses its
#   current name; S ids are defined under Sources, and "(current behavior, …)" cites one.
# - Outside the header, Sources, fenced blocks, URLs and the intent's quoted words, no file path or code name
#   (camelCase, snake_case, or a backticked identifier) appears: non-engineers read that prose.
# - Each requirement has a scenario; each constraint has Type:, Source: and Owner:, and no "Reason: not stated".
# - No Roles or Conflicts line, constraint Owner:, or question's "Who answers" line says "not named" or
#   "unnamed": each gives a role, by its responsibility.
# - From the intent quotes each outcome and open question of the file on the "Intent:" line.
# - Open questions starts with the template's note word for word, or with a translation of it (a paragraph
#   that is not mostly the note's English words and names the labels the note quotes, as the questions do).
#   When the intent is not in English (over 30% of its letters, outside headings and backticks, are Hangul, CJK,
#   kana, Greek, Cyrillic, Hebrew or Arabic), the note and the question labels must not be the English ones.
# - Open questions has "### Decide before building" then "### Can wait for planning", each listing questions or
#   saying "None.", and no question outside them.
# - Each open question has the template's labeled lines, in order: the template's labels under the English
#   note, otherwise the same translated labels on every question.
# - The "Status:" line gives the number of questions under each tier, in that order.
# - No "(decided by …)" marker cites an open question.
# - Changes to existing behavior is present and says "None." exactly when it lists nothing.
# - A revision keeps each R and C name of the file on its "Supersedes:" line on the same id (R and C apart).
# - A Sources line whose path names a policy file ends with a "Clauses:" record (step 3): each entry names a C, R or
#   Q item or says "n/a", each Q it names is under "Decide before building", and, when the file can be found from
#   the workspace root, every numbered clause in it ("2.3", "제4조", or a top-level "1.") is listed.
# Prints "file:line: problem" per finding. Exits 0 when clean, 1 on findings, 2 on a usage error.
set -eu
spec=${1:?usage: check-spec.sh <spec.md>}
[ -f "$spec" ] || { echo "check-spec: no such file: $spec" >&2; exit 2; }
dir=$(dirname "$spec") template=$(dirname "$0")/../references/spec-template.md
[ -f "$template" ] || { echo "check-spec: template not found: $template" >&2; exit 2; }
field() { awk -v k="$1:" '{ sub(/\r$/, "") } index($0, k) == 1 { sub(/^[^:]*:[ \t]*/, ""); print; exit }' "$spec"; }

name=$(field Intent) intent=
for f in "$dir/../intents/$name" "$dir/$name"; do   # never the spec itself, which may share its file name
  [ -n "$name" ] && [ -f "$f" ] && [ "$f" != "$dir/${spec##*/}" ] && { intent=$f; break; }; done
[ -n "$intent" ] || { echo "$spec:1: Intent: line missing, or intent file not found: ${name:-none}"; exit 1; }
name=$(field Supersedes) old=/dev/null
[ -z "$name" ] || old=$dir/$name
[ -z "$name" ] || [ -f "$old" ] || { echo "$spec:1: superseded spec not found: $old"; exit 1; }
letters() { LC_ALL=C sed -e '/^#/d' -e 's/`[^`]*`//g' "$intent" | LC_ALL=C tr -cd "$1" | wc -c; }
foreign=$(letters '\316-\333\343-\355') latin=$(letters 'A-Za-z')
foreign=$(( foreign * 10 > (foreign + latin) * 3 ))   # 1 when the intent is not in English

awk -v SPEC="$spec" -v FOREIGN="$foreign" -v ROOTS="$dir/../..|$dir/..|$dir|." '
function report(l, m) { print SPEC ":" l ": " m; bad = 1 }
function english_share(t,   a, n, i, w, hit) {   # share of the words of t that are words of the template note
  if (!n_ew) { w = tolower(note); gsub(/[^a-z]+/, " ", w); n_ew = split(w, a, " "); for (i = 1; i <= n_ew; i++) ew[a[i]] = 1 }
  n = split(t, a, " "); for (i = 1; i <= n; i++) { w = a[i]; gsub(/[.,;:!?"()]/, "", w); hit += w ~ /^[A-Za-z]+$/ && (tolower(w) in ew) }
  return n ? hit / n : 0
}
function endq(   k, want) {   # checks the labeled lines of the open question just read
  if (cq == "") return
  if (nf != ntl) report(cq_line, cq " has " nf " labeled lines; it needs " ntl ", as in the template")
  else for (k = 1; k <= nf; k++) {
    if (!eng && !(k in fl)) { fl[k] = lab[k]; if (tr != "" && index(note, "\"" tl[k] "\"") && !index(tr, lab[k]))
      report(cq_line, "the Open questions note does not name \"" lab[k] "\", the label " cq " uses for \"" tl[k] "\"")
      if (FOREIGN && lab[k] == tl[k]) report(cq_line, "\"" tl[k] "\" is the English label, but the intent is not in English: translate it, as step 4 says") }
    want = eng ? tl[k] : fl[k]
    if (lab[k] != want) { report(cq_line, cq ": line " k " is labeled \"" lab[k] "\"; expected \"" want "\""); break }
  }
  cq = ""
}
function is_def(   s) {   # sets ID and NM when this line defines an R, C, Q or S
  if ($0 !~ /^### R[0-9]+\. / && $0 !~ /^- [CQ][0-9]+\. / && !(sec == "Sources" && $0 ~ /^- S[0-9]+\. /)) return 0
  s = $0; sub(/^(### |- )/, "", s); ID = s; sub(/\..*/, "", ID); NM = s
  sub(/^R[0-9]+\. ([^:]*: )?/, "", NM); if (ID ~ /^[CS]/) { sub(/^[CS][0-9]+\. /, "", NM); sub(/:.*/, "", NM) }
  if (ID ~ /^Q/) NM = ""
  return 1
}
{ sub(/\r$/, "") }
FNR == 1 { for (f = 1; f < ARGC && ARGV[f] != FILENAME; f++) ; }
f == 1 { if (/^## /) { tsec = $0; next }
         if (tsec != "## Open questions" || !NF || /^</ || /^#/ || tdone) next
         if (/^- /) { if (inq) { tdone = 1; next } inq = 1 }
         else if (inq && match($0, /^[ \t]+- [^:]+:/)) { s = substr($0, 1, RLENGTH - 1); sub(/^[ \t]+- /, "", s); tl[++ntl] = s }
         else if (!inq && note == "") note = $0
         next }
f == 2 && /^## / { isec = $0; next }
f == 2 { if ((isec == "## Desired outcome" || isec == "## Open questions") && NF && !/^[ \t]/ && !/^</) {
           s = $0; sub(/^[ \t]*(- )?/, "", s); sub(/[ \t.]*$/, "", s); if (s != "None") want[++n_want] = s; n_out += isec ~ /outcome/ }
         next }
f == 3 { if (is_def() && NM != "") old[substr(ID, 1, 1), NM] = ID; next }
function code_name(t,   a, n, i, w) {   # the first file path or code name in t, or ""
  gsub(/https?:\/\/[^ \t)>]+/, "", t)
  n = split(t, a, /[ \t]+/)
  for (i = 1; i <= n; i++) { w = a[i]
    if (w ~ /[A-Za-z0-9_-]\/[A-Za-z0-9_.\/-]*\.[A-Za-z]/ || w ~ /[A-Za-z0-9]_[A-Za-z0-9]/ || w ~ /(^|[^A-Za-z0-9])[a-z][a-z0-9]*[A-Z][a-z]/ \
      || w ~ /(^|[^A-Za-z0-9_.\/-])[A-Za-z0-9_-]+\.(ts|tsx|js|jsx|mjs|py|go|rb|java|kt|cs|php|sql|json|yaml|yml|toml|sh|md|rs|swift|vue)([^A-Za-z0-9]|$)/ \
      || w ~ /`[^`]*([a-z]\.[a-z]|\(\))[^`]*`/) { gsub(/^[^A-Za-z0-9_`]+|[^A-Za-z0-9_`]+$/, "", w); return w } }
  return ""
}
function no_role(l, t) { if (tolower(t) ~ /not named|unnamed/)
  report(l, "\"not named\" is not a role: name the role by its responsibility, such as \"owner of <policy>\" or \"whoever decides <product>'"'"'s behavior\"") }
function first_path(t,   a, n, i, w) {   # the first file path in t, or ""
  n = split(t, a, /[ \t]+/)
  for (i = 1; i <= n; i++) { w = a[i]; gsub(/^[(`"]+|[.,;:)`"]+$/, "", w); if (w ~ /\// || w ~ /\.md$/) return w }
  return ""
}
function listed(r, L,   i, n, b, a) {   # whether clause number L appears in r as a whole number
  n = length(L)
  while ((i = index(r, L)) > 0) { b = i > 1 ? substr(r, i - 1, 1) : ""; a = substr(r, i + n, 2)
    if (b !~ /[A-Za-z0-9.]/ && a !~ /^[0-9]/ && a !~ /^\.[0-9]/) return 1
    r = substr(r, i + n) }
  return 0
}
function read_clauses(f,   l, t, na, nk, nn, A, K, N, i) {   # sets LB[1..NL] to the numbered clauses of file f
  na = nk = nn = NL = 0
  while ((getline l < f) > 0) { sub(/\r$/, "", l)
    if (match(l, /^[ \t>*-]*[0-9]+\.[0-9]+(\.[0-9]+)*[ \t.)*]/)) { t = substr(l, RSTART, RLENGTH); gsub(/^[ \t>*-]+|[ \t.)*]+$/, "", t); A[++na] = t }
    else if (l ~ /^#/ && match(l, /제[0-9]+조/)) K[++nk] = substr(l, RSTART, RLENGTH)
    else if (match(l, /^(\*\*)?[0-9]+\.(\*\*)?[ \t]/)) { t = substr(l, RSTART, RLENGTH); gsub(/[^0-9]/, "", t); N[++nn] = t } }
  close(f)
  if (na) for (i = 1; i <= na; i++) LB[++NL] = A[i]
  else if (nk) for (i = 1; i <= nk; i++) LB[++NL] = K[i]
  else for (i = 1; i <= nn; i++) LB[++NL] = N[i]
}
function end_r() { if (cr != "" && !scn) report(cr_line, cr " has no scenario: add a case under it"); cr = "" }

/^```/ { fence = !fence; next }
fence { next }
/^## / { endq(); end_r(); sec = substr($0, 4); seen[sec] = FNR; due = (sec == "Open questions"); next }
sec == "Open questions" && /^### / { endq(); s = substr($0, 5); sub(/[ \t]+$/, "", s)
  if (due) report(FNR, "Open questions must start with the template'"'"'s note, word for word, or its faithful translation"); due = 0
  if (s == "Decide before building" && !tier) tier = 1
  else if (s == "Can wait for planning" && tier < 2) tier = 2
  else { report(FNR, "\"" $0 "\": Open questions has only \"### Decide before building\" then \"### Can wait for planning\""); next }
  tline[tier] = FNR; next }
sec == "Open questions" && tier && /^- / { titems[tier]++ }
sec == "Open questions" && tier && /^None\.[ \t]*$/ { tnone[tier] = FNR }
sec == "Requirements" && /^- / { scn = 1 }
sec != "" && sec != "Sources" { s = $0; if (/^- (Outcome|Question) "/) gsub(/"[^"]*"/, "", s)
  if ((w = code_name(s)) != "") report(FNR, "\"" w "\" is a file or code name: say it in plain words and cite S<n> (Name); names go under Sources")
  s = $0; while (match(s, /\(current behavior, [^)]*/)) { if (substr(s, RSTART, RLENGTH) !~ /, S[0-9]+/) report(FNR, "a (current behavior, …) marker must cite S<n> (Name) from Sources"); s = substr(s, RSTART + RLENGTH) } }
sec == "Constraints" && /^- C[0-9]+\. / { for (k = split("Type:|Source:|Owner:", cf, "|"); k; k--) if (!index($0, cf[k])) report(FNR, "constraint has no \"" cf[k] "\"")
  if ($0 ~ /Reason:[ \t]*(not stated|none|n\/a|unknown)/) report(FNR, "omit Reason when the source states none")
  if (p = index($0, "Owner:")) no_role(FNR, substr($0, p)) }
(sec == "Roles" || sec == "Conflicts") && /^- / { no_role(FNR, $0) }
due && NF { due = 0
  if ($0 == note) { eng = 1
    if (FOREIGN) report(FNR, "the intent is not in English: translate the Open questions note and the question labels into its language")
    next }
  if ($0 !~ /^(- |[ \t]|None\.)/ && english_share($0) <= 0.5) { tr = $0; next }
  report(FNR, "Open questions must start with the template'"'"'s note, word for word, or its faithful translation") }
cq != "" && /^[ \t]+- / { s = $0; sub(/^[ \t]+- /, "", s); p = index(s, ":"); w = index(s, "\357\274\232")   # ASCII or full-width colon
  if (w && (!p || w < p)) { p = w; w = 3 } else w = 1
  lab[++nf] = p ? substr(s, 1, p - 1) : ""
  if (!p) report(FNR, cq " has a line with no label: start it with the label and a colon, as in the template")
  else if (substr(s, p + w) ~ /^[ \t]*$/) report(FNR, cq " has an empty \"" lab[nf] "\" line")
  else if (tl[nf] == "Who answers") no_role(FNR, substr(s, p + w)) }
sec == "Sources" && /^- S[0-9]+\. / { s = $0; sub(/^- /, "", s); id = s; sub(/\..*/, "", id)
  if (p = index($0, "Clauses:")) { cl_id[++ncl] = id; cl_line[ncl] = FNR; cl_rec[ncl] = substr($0, p + 8); cl_path[ncl] = first_path(substr($0, 1, p - 1))
    n = split(cl_rec[ncl], a, ";"); for (k = 1; k <= n; k++) if (a[k] ~ /[^ \t.]/ && a[k] !~ /(^|[^A-Za-z0-9_])[RCQ][0-9]+/ && tolower(a[k]) !~ /n\/a/)
      report(FNR, id " Clauses: \"" a[k] "\" names no C, R or Q item and does not say \"n/a: <why>\"") }
  else if (tolower(first_path($0)) ~ /polic/) report(FNR, id " is a policy: end its line with the Clauses record the template shows, one entry per numbered clause") }
/^- / { items[sec]++ }
/^None\.[ \t]*$/ { none[sec] = FNR }
sec == "" && /^Status:/ { status = $0; status_line = FNR }
/^- (Outcome|Question) "/ { s = $0; sub(/^- [A-Za-z]+ "/, "", s); ledger = ledger "\n" s }
is_def() { if (ID in name) report(FNR, ID " is defined twice"); name[ID] = NM; line[ID] = FNR
  if (ID ~ /^R/) { end_r(); cr = ID; cr_line = FNR; scn = 0 }
  if (ID ~ /^Q/) open_q[ID] = 1
  if (sec == "Open questions" && ID ~ /^Q/) { endq(); cq = ID; cq_line = FNR; nf = 0; n_tier[tier]++; qtier[ID] = tier
    if (!tier) report(FNR, ID " is under no tier: put it under \"### Decide before building\" or \"### Can wait for planning\"") } }
{ s = " " $0
  while (match(s, /[^A-Za-z0-9_][RCQS][0-9]+/)) {
    id = substr(s, RSTART + 1, RLENGTH - 1); s = substr(s, RSTART + RLENGTH)
    if (s ~ /^[A-Za-z0-9_]/) continue
    ref[++n_ref] = id; ref_line[n_ref] = FNR; ref_nm[n_ref] = ""
    if (id !~ /^Q/ && match(s, /^ \([^)]*\)/)) ref_nm[n_ref] = substr(s, 3, RLENGTH - 3)
  } }
{ s = " " $0; m = ""   # Q ids inside "(decided by …)" markers
  while (match(s, /\(decided by [^()]*\)/)) { m = m " " substr(s, RSTART, RLENGTH); s = substr(s, 1, RSTART - 1) " " substr(s, RSTART + RLENGTH) }
  while (match(m, /[^A-Za-z0-9_]Q[0-9]+/)) { id = substr(m, RSTART + 1, RLENGTH - 1); m = substr(m, RSTART + RLENGTH)
    if (m !~ /^[A-Za-z0-9_]/) { mref[++n_m] = id; mref_line[n_m] = FNR } } }

END { endq(); end_r()
  for (i = 1; i <= n_ref; i++) { id = ref[i]
    if (!(id in name)) { if (!(id in told)) report(ref_line[i], id " is referenced but not defined"); told[id] = 1 }
    else if (ref_nm[i] != "" && ref_nm[i] != name[id])
      report(ref_line[i], id " is cited as \"" ref_nm[i] "\" but is named \"" name[id] "\"")
  }
  s = "Changes to existing behavior"
  if (!(s in seen)) report(1, "no \"## " s "\" section")
  else if (!items[s] && !(s in none)) report(seen[s], "\"" s "\" lists nothing: write \"None.\" under it")
  else if (items[s] && (s in none)) report(none[s], "\"" s "\" says \"None.\" but also lists items")
  split("Decide before building|Can wait for planning", tn, "|")
  if (!("Open questions" in seen)) report(1, "no \"## Open questions\" section")
  else for (i = 1; i <= 2; i++)
    if (!(i in tline)) report(seen["Open questions"], "Open questions has no \"### " tn[i] "\" heading")
    else if (!titems[i] && !(i in tnone)) report(tline[i], "\"" tn[i] "\" lists nothing: write \"None.\" under it")
    else if (titems[i] && (i in tnone)) report(tnone[i], "\"" tn[i] "\" says \"None.\" but also lists questions")
  s = status; n = 0
  while (match(s, /[0-9]+/)) { cnt[++n] = substr(s, RSTART, RLENGTH) + 0; s = substr(s, RSTART + RLENGTH) }
  if (!status_line) report(1, "no \"Status:\" line")
  else if (n != 2) report(status_line, "Status: must give two numbers: questions to decide before building, then those that can wait for planning")
  else for (i = 1; i <= 2; i++) if (cnt[i] != n_tier[i] + 0)
    report(status_line, "Status: says " cnt[i] " under \"" tn[i] "\", but it lists " n_tier[i] + 0)
  for (i = 1; i <= n_m; i++) if (mref[i] in open_q)
    report(mref_line[i], mref[i] " is an open question, so a (decided by …) marker cannot cite it")
  if (!n_out) report(1, "found no \"## Desired outcome\" items in the intent; check its headings")
  for (i = 1; i <= n_want; i++) if (!index(ledger, "\n" want[i]))
    report(1, "From the intent: no Outcome or Question line quoting \"" want[i] "\"")
  for (i = 1; i <= ncl; i++) { s = " " cl_rec[i]
    while (match(s, /[^A-Za-z0-9_]Q[0-9]+/)) { id = substr(s, RSTART + 1, RLENGTH - 1); s = substr(s, RSTART + RLENGTH)
      if (s !~ /^[0-9]/ && (id in qtier) && qtier[id] != 1) report(cl_line[i], cl_id[i] " Clauses: " id " is a clause'"'"'s reading or conflict, so it goes under \"Decide before building\"") }
    f = ""; if (cl_path[i] ~ /^\//) f = cl_path[i]
    else if (cl_path[i] != "") for (k = split(ROOTS, a, "|"); k; k--) if ((getline s < (a[k] "/" cl_path[i])) > 0) { close(a[k] "/" cl_path[i]); f = a[k] "/" cl_path[i] }
    if (f == "") continue
    split("", LB); read_clauses(f); m = ""; split("", told_cl)
    for (k = 1; k <= NL; k++) if (!(LB[k] in told_cl) && !listed(cl_rec[i], LB[k])) { m = m (m == "" ? "" : ", ") LB[k]; told_cl[LB[k]] = 1 }
    if (m != "") report(cl_line[i], cl_id[i] " Clauses: does not list " m " of " cl_path[i] ": record every numbered clause, as step 3 says") }
  for (id in name) if (id ~ /^[RC]/ && ((k = substr(id, 1, 1) SUBSEP name[id]) in old) && old[k] != id)
    report(line[id], id " has the name of " old[k] " in the superseded spec; keep the old id")
  exit bad
}' "$template" "$intent" "$old" "$spec"
