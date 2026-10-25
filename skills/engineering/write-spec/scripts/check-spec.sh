#!/bin/sh
# check-spec.sh <spec.md>: check what a reader of spec.md alone cannot.
# - Every R, C and Q id mentioned is defined once, and "R<n> (Name)" or "C<n> (Name)" uses its current name.
# - From the intent quotes each outcome and open question of the file on the "Intent:" line.
# - Open questions starts with one of the template's notes (English or Korean), word for word.
# - The "Status:" line gives the number of open questions the section lists.
# - A Q id in the Decision log counts as defined, and is not also still open.
# - Changes to existing behavior and Open questions are present and say "None." exactly when they list nothing.
# - A revision keeps each R and C name of the file on its "Supersedes:" line on the same id.
# - "(decided in conversation)" is used only with a "Decided in conversation:" line.
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
function is_def(   s) {   # sets ID and NM when this line defines an R, C or Q
  if (sec == "Decision log") return 0
  if ($0 !~ /^### R[0-9]+\. / && $0 !~ /^- [CQ][0-9]+\. /) return 0
  s = $0; sub(/^(### |- )/, "", s); ID = s; sub(/\..*/, "", ID); NM = s
  sub(/^R[0-9]+\. ([^:]*: )?/, "", NM); if (ID ~ /^C/) { sub(/^C[0-9]+\. /, "", NM); sub(/:.*/, "", NM) }
  if (ID ~ /^Q/) NM = ""
  return 1
}
{ sub(/\r$/, "") }
FNR == 1 { for (f = 1; f < ARGC && ARGV[f] != FILENAME; f++) ; }
f == 1 { if (/^## /) on = /^## Open questions/; else if (/^- /) on = 0; else if (on && NF && !/^</) note[$0] = 1; next }
f == 2 && /^## / { isec = $0; next }
f == 2 { if ((isec == "## Desired outcome" || isec == "## Open questions") && NF && !/^[ \t]/ && !/^</) {
           s = $0; sub(/^[ \t]*(- )?/, "", s); sub(/[ \t.]*$/, "", s); if (s != "None") want[++n_want] = s; n_out += isec ~ /outcome/ }
         next }
f == 3 { if (is_def() && NM != "") old[NM] = ID; next }

/^```/ { fence = !fence; next }
fence { next }
/^## / { sec = substr($0, 4); seen[sec] = FNR; due = (sec == "Open questions"); next }
due && NF { due = 0; if ($0 in note) next; report(FNR, "Open questions must start with the template'"'"'s note, word for word") }
/^- / { items[sec]++ }
/^None\.[ \t]*$/ { none[sec] = FNR }
sec == "" && /^Decided in conversation:[ \t]*[^ \t]/ { conv = 1 }
sec == "" && /^Status:/ { status = $0; status_line = FNR }
sec == "Decision log" && match($0, /^- Q[0-9]+/) { id = substr($0, 3, RLENGTH - 2)
  if (id in name) report(FNR, id " is in the Decision log but is also defined elsewhere"); name[id] = ""; line[id] = FNR }
index($0, "(decided in conversation)") && !conv_line { conv_line = FNR }
/^- (Outcome|Question) "/ { s = $0; sub(/^- [A-Za-z]+ "/, "", s); ledger = ledger "\n" s }
is_def() { if (ID in name) report(FNR, ID " is defined twice"); name[ID] = NM; line[ID] = FNR; n_open += sec == "Open questions" && ID ~ /^Q/ }
{ s = " " $0
  while (match(s, /[^A-Za-z0-9_][RCQ][0-9]+/)) {
    id = substr(s, RSTART + 1, RLENGTH - 1); s = substr(s, RSTART + RLENGTH)
    if (s ~ /^[A-Za-z0-9_]/) continue
    ref[++n_ref] = id; ref_line[n_ref] = FNR; ref_nm[n_ref] = ""
    if (id !~ /^Q/ && match(s, /^ \([^)]*\)/)) ref_nm[n_ref] = substr(s, 3, RLENGTH - 3)
  } }

END {
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
  if (conv_line && !conv) report(conv_line, "(decided in conversation) is used, but there is no \"Decided in conversation:\" line")
  if (!n_out) report(1, "found no \"## Desired outcome\" items in the intent; check its headings")
  for (i = 1; i <= n_want; i++) if (!index(ledger, "\n" want[i]))
    report(1, "From the intent: no Outcome or Question line quoting \"" want[i] "\"")
  for (id in name) if ((name[id] in old) && old[name[id]] != id)
    report(line[id], id " has the name of " old[name[id]] " in the superseded spec; keep the old id")
  exit bad
}' "$template" "$intent" "$old" "$spec"
