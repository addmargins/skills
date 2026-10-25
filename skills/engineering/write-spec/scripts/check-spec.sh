#!/bin/sh
# check-spec.sh <spec.md>: check what a reader of spec.md alone cannot.
# - Every R, C, Q and S id mentioned is defined once, and "R<n> (Name)", "C<n> (Name)" or "S<n> (Name)" uses its
#   current name; S ids are defined under Sources, and "(current behavior, …)" cites one.
# - Outside the header, Sources, fenced blocks, URLs and the intent's quoted words, no file path or code name
#   (camelCase, snake_case, or a backticked identifier) appears: non-engineers read that prose.
# - Each requirement has a scenario; each constraint has Kind:, Source: and Owner:, and no "Reason: not stated".
# - No Reviewers or Conflicts line, constraint Owner:, or question's "Who answers" line says "not named" or
#   "unnamed": each gives a role, by its responsibility.
# - From the intent quotes each outcome and open question of the file on the "Intent:" line.
# - Open questions starts with the template's note word for word, or with a translation of it (a paragraph
#   that is not mostly the note's English words and names the labels the note quotes, as the questions do).
# - Each open question has the template's labeled lines, in order, the last ("Until decided") optional: the
#   template's labels under the English note, otherwise the same translated labels on every question. A question
#   without "Until decided" is named in Requirements, Changes, Constraints, Conflicts or Out of scope.
# - The "Status:" line gives the number of open questions the section lists.
# - A Q id in the Decision log is closed: it is not also still open, and outside the Decision log it is named only
#   in "(decided by …, Q<n>)" markers, which name only closed questions.
# - Changes to existing behavior and Open questions are present and say "None." exactly when they list nothing.
# - A revision keeps each R and C name of the file on its "Supersedes:" line on the same id.
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

awk -v SPEC="$spec" '
function report(l, m) { print SPEC ":" l ": " m; bad = 1 }
function english_share(t,   a, n, i, w, hit) {   # share of the words of t that are words of the template note
  if (!n_ew) { w = tolower(note); gsub(/[^a-z]+/, " ", w); n_ew = split(w, a, " "); for (i = 1; i <= n_ew; i++) ew[a[i]] = 1 }
  n = split(t, a, " "); for (i = 1; i <= n; i++) { w = a[i]; gsub(/[.,;:!?"()]/, "", w); hit += w ~ /^[A-Za-z]+$/ && (tolower(w) in ew) }
  return n ? hit / n : 0
}
function endq(   k, want) {   # checks the labeled lines of the open question just read
  if (cq == "") return
  if (nf == ntl - 1) nound[cq] = cq_line
  if (nf != ntl && nf != ntl - 1) report(cq_line, cq " has " nf " labeled lines; it needs " ntl - 1 " or " ntl ", as in the template")
  else for (k = 1; k <= nf; k++) {
    if (!eng && !(k in fl)) { fl[k] = lab[k]; if (tr != "" && index(note, "\"" tl[k] "\"") && !index(tr, lab[k]))
      report(cq_line, "the Open questions note does not name \"" lab[k] "\", the label " cq " uses for \"" tl[k] "\"") }
    want = eng ? tl[k] : fl[k]
    if (lab[k] != want) { report(cq_line, cq ": line " k " is labeled \"" lab[k] "\"; expected \"" want "\""); break }
  }
  cq = ""
}
function is_def(   s) {   # sets ID and NM when this line defines an R, C, Q or S
  if (sec == "Decision log") return 0
  if ($0 !~ /^### R[0-9]+\. / && $0 !~ /^- [CQ][0-9]+\. / && !(sec == "Sources" && $0 ~ /^- S[0-9]+\. /)) return 0
  s = $0; sub(/^(### |- )/, "", s); ID = s; sub(/\..*/, "", ID); NM = s
  sub(/^R[0-9]+\. ([^:]*: )?/, "", NM); if (ID ~ /^[CS]/) { sub(/^[CS][0-9]+\. /, "", NM); sub(/:.*/, "", NM) }
  if (ID ~ /^Q/) NM = ""
  return 1
}
{ sub(/\r$/, "") }
FNR == 1 { for (f = 1; f < ARGC && ARGV[f] != FILENAME; f++) ; }
f == 1 { if (/^## /) { tsec = $0; next }
         if (tsec != "## Open questions" || !NF || /^</) next
         if (/^- /) inq = 1
         else if (inq && match($0, /^[ \t]+- [^:]+:/)) { s = substr($0, 1, RLENGTH - 1); sub(/^[ \t]+- /, "", s); tl[++ntl] = s }
         else if (!inq && note == "") note = $0
         next }
f == 2 && /^## / { isec = $0; next }
f == 2 { if ((isec == "## Desired outcome" || isec == "## Open questions") && NF && !/^[ \t]/ && !/^</) {
           s = $0; sub(/^[ \t]*(- )?/, "", s); sub(/[ \t.]*$/, "", s); if (s != "None") want[++n_want] = s; n_out += isec ~ /outcome/ }
         next }
f == 3 { if (is_def() && NM != "") old[NM] = ID; next }
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
function end_r() { if (cr != "" && !scn) report(cr_line, cr " has no scenario: add a case under it"); cr = "" }

/^```/ { fence = !fence; next }
fence { next }
/^## / { endq(); end_r(); sec = substr($0, 4); seen[sec] = FNR; due = (sec == "Open questions"); next }
sec == "Requirements" && /^- / { scn = 1 }
sec != "" && sec != "Sources" { s = $0; if (/^- (Outcome|Question) "/) gsub(/"[^"]*"/, "", s)
  if ((w = code_name(s)) != "") report(FNR, "\"" w "\" is a file or code name: say it in plain words and cite S<n> (Name); names go under Sources")
  s = $0; while (match(s, /\(current behavior, [^)]*/)) { if (substr(s, RSTART, RLENGTH) !~ /, S[0-9]+/) report(FNR, "a (current behavior, …) marker must cite S<n> (Name) from Sources"); s = substr(s, RSTART + RLENGTH) } }
sec == "Constraints" && /^- C[0-9]+\. / { for (k = split("Kind:|Source:|Owner:", cf, "|"); k; k--) if (!index($0, cf[k])) report(FNR, "constraint has no \"" cf[k] "\"")
  if ($0 ~ /Reason:[ \t]*(not stated|none|n\/a|unknown)/) report(FNR, "omit Reason when the source states none")
  if (p = index($0, "Owner:")) no_role(FNR, substr($0, p)) }
(sec == "Reviewers" || sec == "Conflicts") && /^- / { no_role(FNR, $0) }
due && NF { due = 0
  if ($0 == note) { eng = 1; next }
  if ($0 !~ /^(- |[ \t]|None\.)/ && english_share($0) <= 0.5) { tr = $0; next }
  report(FNR, "Open questions must start with the template'"'"'s note, word for word, or its faithful translation") }
cq != "" && /^[ \t]+- / { s = $0; sub(/^[ \t]+- /, "", s); p = index(s, ":"); w = index(s, "\357\274\232")   # ASCII or full-width colon
  if (w && (!p || w < p)) { p = w; w = 3 } else w = 1
  lab[++nf] = p ? substr(s, 1, p - 1) : ""
  if (!p) report(FNR, cq " has a line with no label: start it with the label and a colon, as in the template")
  else if (substr(s, p + w) ~ /^[ \t]*$/) report(FNR, cq " has an empty \"" lab[nf] "\" line")
  else if (tl[nf] == "Who answers") no_role(FNR, substr(s, p + w)) }
/^- / { items[sec]++ }
/^None\.[ \t]*$/ { none[sec] = FNR }
sec == "" && /^Status:/ { status = $0; status_line = FNR }
sec == "Decision log" && match($0, /^- Q[0-9]+/) { id = substr($0, 3, RLENGTH - 2)
  if (id in name) report(FNR, id " is in the Decision log but is also defined elsewhere"); name[id] = ""; line[id] = FNR; closed[id] = 1 }
/^- (Outcome|Question) "/ { s = $0; sub(/^- [A-Za-z]+ "/, "", s); ledger = ledger "\n" s }
is_def() { if (ID in name) report(FNR, ID " is defined twice"); name[ID] = NM; line[ID] = FNR
  if (ID ~ /^R/) { end_r(); cr = ID; cr_line = FNR; scn = 0 }
  if (ID ~ /^Q/) open_q[ID] = 1
  if (sec == "Open questions" && ID ~ /^Q/) { n_open++; endq(); cq = ID; cq_line = FNR; nf = 0 } }
{ s = " " $0
  while (match(s, /[^A-Za-z0-9_][RCQS][0-9]+/)) {
    id = substr(s, RSTART + 1, RLENGTH - 1); s = substr(s, RSTART + RLENGTH)
    if (s ~ /^[A-Za-z0-9_]/) continue
    ref[++n_ref] = id; ref_line[n_ref] = FNR; ref_nm[n_ref] = ""
    if (id !~ /^Q/ && match(s, /^ \([^)]*\)/)) ref_nm[n_ref] = substr(s, 3, RLENGTH - 3)
  } }
sec != "Decision log" { s = " " $0; m = ""   # Q ids inside "(decided by …)" markers, and outside them
  while (match(s, /\(decided by [^()]*\)/)) { m = m " " substr(s, RSTART, RLENGTH); s = substr(s, 1, RSTART - 1) " " substr(s, RSTART + RLENGTH) }
  while (match(s, /[^A-Za-z0-9_]Q[0-9]+/)) { id = substr(s, RSTART + 1, RLENGTH - 1); s = substr(s, RSTART + RLENGTH)
    if (s !~ /^[A-Za-z0-9_]/) { qref[++n_q] = id; qref_line[n_q] = FNR
      if (sec ~ /^(Requirements|Changes to existing behavior|Constraints|Conflicts|Out of scope)$/) held[id] = 1 } }
  while (match(m, /[^A-Za-z0-9_]Q[0-9]+/)) { id = substr(m, RSTART + 1, RLENGTH - 1); m = substr(m, RSTART + RLENGTH)
    if (m !~ /^[A-Za-z0-9_]/) { mref[++n_m] = id; mref_line[n_m] = FNR } } }

END { endq(); end_r()
  for (i = 1; i <= n_ref; i++) { id = ref[i]
    if (!(id in name)) { if (!(id in told)) report(ref_line[i], id " is referenced but not defined"); told[id] = 1 }
    else if (ref_nm[i] != "" && ref_nm[i] != name[id])
      report(ref_line[i], id " is cited as \"" ref_nm[i] "\" but is named \"" name[id] "\"")
  }
  split("Changes to existing behavior|Open questions", must, "|")
  for (i = 1; i <= 2; i++) { s = must[i]
    if (!(s in seen)) report(1, "no \"## " s "\" section")
    else if (!items[s] && !(s in none)) report(seen[s], "\"" s "\" lists nothing: write \"None.\" under it")
    else if (items[s] && (s in none)) report(none[s], "\"" s "\" says \"None.\" but also lists items")
  }
  if (!status_line) report(1, "no \"Status:\" line")
  else if (!match(status, /[0-9]+/)) report(status_line, "Status: gives no number of open questions")
  else if (substr(status, RSTART, RLENGTH) + 0 != n_open)
    report(status_line, "Status: says " substr(status, RSTART, RLENGTH) " open questions, but Open questions lists " n_open)
  for (i = 1; i <= n_q; i++) if ((qref[i] in closed) && !(qref[i] in open_q))
    report(qref_line[i], qref[i] " is closed in the Decision log; write its answer here instead of naming it, or cite it as (decided by <role>, " qref[i] ")")
  for (i = 1; i <= n_m; i++) if ((mref[i] in open_q) && !(mref[i] in closed))
    report(mref_line[i], mref[i] " is still open, so a (decided by …) marker cannot cite it")
  for (id in nound) if (!(id in held))
    report(nound[id], id " has no \"Until decided\" line, so name it where its case is left out, as in \"… waits for " id "\"")
  if (!n_out) report(1, "found no \"## Desired outcome\" items in the intent; check its headings")
  for (i = 1; i <= n_want; i++) if (!index(ledger, "\n" want[i]))
    report(1, "From the intent: no Outcome or Question line quoting \"" want[i] "\"")
  for (id in name) if (id !~ /^S/ && (name[id] in old) && old[name[id]] != id)
    report(line[id], id " has the name of " old[name[id]] " in the superseded spec; keep the old id")
  exit bad
}' "$template" "$intent" "$old" "$spec"
