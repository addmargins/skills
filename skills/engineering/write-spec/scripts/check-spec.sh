#!/bin/sh
# check-spec.sh <spec.md>: check what a reader of spec.md alone cannot.
# - Every R, A, C, Q and S id mentioned is defined once, and "R<n> (Name)", "A<n> (Name)", "C<n> (Name)" or
#   "S<n> (Name)" uses its current name; S ids are defined under Sources, and "(current behavior, …)" cites one.
# - Outside the header, Sources, fenced blocks, URLs and the intent's quoted words, no file path or code name
#   (camelCase, snake_case, or a backticked identifier) appears: non-engineers read that prose.
# - Each requirement has a scenario; each constraint has Type:, Source: and Owner:, no "Reason: not stated", and
#   is not of Type policy or law: those go under What this work touches.
# - No Roles line, role heading under What this work touches, constraint Owner:, or question's "Who answers" line
#   says "not named" or "unnamed": each gives a role, by its responsibility.
# - Under What this work touches, each A item sits under a "### <role>" heading and has the template's lines:
#   Today:, After:, Affects: naming an R, one or more Policy text: lines, and Confirm in: naming a Q that is under
#   "Decide before building" and whose "Who answers" names the item's role (its words before any "," or "(").
#   A Policy text: line either cites the document as S<n> and quotes its clause in double quotes, word for word
#   (checked, after whitespace is collapsed, against the S line's file when it can be found from the workspace
#   root), or is "No policy document for this area found in the workspace." (in a spec not in English, a
#   translation of it: no quote, S id, digit or "n/a", and not mostly that sentence's English words). When the
#   intent is not in English, the section's note is not the template's English one.
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
# - Sources is the last section, and its list sits in the template's engineer appendix: a "<details><summary>"
#   line first, its summary the template's word for word or, when the intent is not in English, a translation of
#   all of it ("<who>: <what> (<who may skip>)"), then a blank line, the S lines, and "</details>".
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

awk -v SPEC="$spec" -v FOREIGN="$foreign" -v NOTFOUND="No policy document for this area found in the workspace." -v ROOTS="$dir/../..|$dir/..|$dir|." '
function report(l, m) { print SPEC ":" l ": " m; bad = 1 }
function english_share(t, ref,   a, n, i, w, hit) {   # share of the words of t that are English words of ref
  if (!(ref in ew_done)) { ew_done[ref] = 1; w = tolower(ref); gsub(/[^a-z]+/, " ", w); n = split(w, a, " "); for (i = 1; i <= n; i++) ew[ref, a[i]] = 1 }
  n = split(t, a, " "); for (i = 1; i <= n; i++) { w = a[i]; gsub(/[.,;:!?"()]/, "", w); hit += w ~ /^[A-Za-z]+$/ && ((ref, tolower(w)) in ew) }
  return n ? hit / n : 0
}
function endq(   k, want) {   # checks the labeled lines of the open question just read
  if (cq == "") return
  if (nf != ntl) report(cq_line, cq " has " nf " labeled lines; it needs " ntl ", as in the template")
  else for (k = 1; k <= nf; k++) {
    if (!eng && !(k in fl)) { fl[k] = lab[k]; if (tr != "" && index(note, "\"" tl[k] "\"") && !index(tr, lab[k]))
      report(cq_line, "the Open questions note does not name \"" lab[k] "\", the label " cq " uses for \"" tl[k] "\"")
      if (FOREIGN && lab[k] == tl[k]) report(cq_line, "\"" tl[k] "\" is the English label, but the intent is not in English: translate it, as step 5 says") }
    want = eng ? tl[k] : fl[k]
    if (lab[k] != want) { report(cq_line, cq ": line " k " is labeled \"" lab[k] "\"; expected \"" want "\""); break }
  }
  cq = ""
}
function is_def(   s) {   # sets ID and NM when this line defines an R, A, C, Q or S
  if ($0 !~ /^### R[0-9]+\. / && $0 !~ /^- [CQ][0-9]+\. / && !(sec == "Sources" && $0 ~ /^- S[0-9]+\. /) \
    && !(sec == "What this work touches" && $0 ~ /^- A[0-9]+\. /)) return 0
  s = $0; sub(/^(### |- )/, "", s); ID = s; sub(/\..*/, "", ID); NM = s
  sub(/^[RA][0-9]+\. ([^:]*: )?/, "", NM); sub(/[ \t]+$/, "", NM); if (ID ~ /^[CS]/) { sub(/^[CS][0-9]+\. /, "", NM); sub(/:.*/, "", NM) }
  if (ID ~ /^Q/) NM = ""
  return 1
}
{ sub(/\r$/, "") }
FNR == 1 { for (f = 1; f < ARGC && ARGV[f] != FILENAME; f++) ; }
f == 1 { if (/^## /) { tsec = $0; next }
         if (tsec == "## What this work touches" && anote == "" && NF && !/^[<#-]/) anote = $0
         if (tsec == "## Sources" && /^<details><summary>.*<\/summary>[ \t]*$/) { tsum = $0; sub(/^<details><summary>/, "", tsum); sub(/<\/summary>[ \t]*$/, "", tsum) }
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
function check_summary(l, s) {   # the summary of the Sources appendix
  if (s == tsum) { if (FOREIGN) report(l, "the intent is not in English: translate the Sources summary, as step 5 says"); return }
  if (!FOREIGN) report(l, "the Sources summary must be the template'"'"'s, word for word: \"" tsum "\"")
  else if (s !~ /(:|\357\274\232).+(\(|\357\274\210).+(\)|\357\274\211)[ \t]*$/ || english_share(s, note) > 0.5)
    report(l, "the Sources summary must translate all of the template'"'"'s: who it is for, what it lists, and, in parentheses, that other readers can skip it")
}
function squeeze(t) { gsub(/[ \t\r\n]+/, " ", t); gsub(/\*\*/, "", t); sub(/^ /, "", t); sub(/ $/, "", t); return t }
function file_text(f,   l, t) { if (f in ftext) return ftext[f]; t = ""; while ((getline l < f) > 0) t = t " " l; close(f); return ftext[f] = squeeze(t) }
function find_file(path,   a, k, f, l) {   # path found from the workspace root, or ""
  if (path == "") return ""
  if (path ~ /^\//) return ((getline l < path) > 0) ? path : ""
  f = ""; for (k = split(ROOTS, a, "|"); k; k--) if ((getline l < (a[k] "/" path)) > 0) { close(a[k] "/" path); f = a[k] "/" path }
  return f
}
function check_policy_text(l, id, v,   t, i, j, q, sid, f) {   # one "Policy text:" line of area id
  t = v; gsub(/\342\200\234|\342\200\235/, "\"", t)
  if ((i = index(t, "\"")) > 0) { q = substr(t, i + 1); j = 0; while (match(substr(q, j + 1), /"/)) j += RSTART
    if (!j) { report(l, id ": the quoted clause has no closing quote mark"); return }
    q = squeeze(substr(q, 1, j - 1)); sid = ""
    if (match(substr(t, 1, i - 1), /(^|[^A-Za-z0-9_])S[0-9]+/)) { sid = substr(t, RSTART, RLENGTH); sub(/^[^S]/, "", sid) }
    if (sid == "") { report(l, id ": cite the document the clause is quoted from as S<n> (Name), listed under Sources with its file"); return }
    if ((f = find_file(s_path[sid])) != "" && !index(file_text(f), q))
      report(l, id ": the text quoted from " sid " is not word for word in " s_path[sid] ": quote the clause exactly, never a summary")
    return }
  if (tolower(t) ~ /^no policy document for this area found in the workspace/) {
    if (FOREIGN) report(l, id ": the intent is not in English: translate \"" NOTFOUND "\" into its language"); return }
  if (!FOREIGN || t ~ /[0-9]/ || t ~ /(^|[^A-Za-z0-9_])S[0-9]+/ || tolower(t) ~ /n\/a|not appl|no polic(y|ies) appl|해당 ?없|적용(되지 ?않|하지 ?않|대상 ?아)/ || english_share(t, NOTFOUND) > 0.5)
    report(l, id ": a Policy text: line quotes a clause, with its S<n> and in quote marks, or says \"" NOTFOUND "\"" (FOREIGN ? " in the intent'"'"'s language" : "") ", never that none applies")
}
function end_r() { if (cr != "" && !scn) report(cr_line, cr " has no scenario: add a case under it"); cr = "" }

/^```/ { fence = !fence; next }
fence { next }
/^## / { endq(); end_r(); ca = role = ""; if (sec == "Sources") report(FNR, "\"" $0 "\" comes after Sources: keep Sources the last section")
  sec = substr($0, 4); seen[sec] = FNR; due = (sec == "Open questions"); next }
sec == "Open questions" && /^### / { endq(); s = substr($0, 5); sub(/[ \t]+$/, "", s)
  if (due) report(FNR, "Open questions must start with the template'"'"'s note, word for word, or its faithful translation"); due = 0
  if (s == "Decide before building" && !tier) tier = 1
  else if (s == "Can wait for planning" && tier < 2) tier = 2
  else { report(FNR, "\"" $0 "\": Open questions has only \"### Decide before building\" then \"### Can wait for planning\""); next }
  tline[tier] = FNR; next }
sec == "Open questions" && tier && /^- / { titems[tier]++ }
sec == "Open questions" && tier && /^None\.[ \t]*$/ { tnone[tier] = FNR }
sec == "Requirements" && /^- / { scn = 1 }
sec != "" && sec != "Sources" { s = $0; if (/^- (Outcome|Question) "/) gsub(/"[^"]*"/, "", s); if (/^[ \t]+- Policy text:/) sub(/".*/, "", s)
  if ((w = code_name(s)) != "") report(FNR, "\"" w "\" is a file or code name: say it in plain words and cite S<n> (Name); names go under Sources")
  s = $0; while (match(s, /\(current behavior, [^)]*/)) { if (substr(s, RSTART, RLENGTH) !~ /, S[0-9]+/) report(FNR, "a (current behavior, …) marker must cite S<n> (Name) from Sources"); s = substr(s, RSTART + RLENGTH) } }
sec == "Constraints" && /^- C[0-9]+\. / { for (k = split("Type:|Source:|Owner:", cf, "|"); k; k--) if (!index($0, cf[k])) report(FNR, "constraint has no \"" cf[k] "\"")
  if ($0 ~ /Reason:[ \t]*(not stated|none|n\/a|unknown)/) report(FNR, "omit Reason when the source states none")
  if (tolower($0) ~ /type:[ \t]*(policy|law|legal|regulation|정책|법)/) report(FNR, "a policy or law is not a constraint: put the area it governs under What this work touches, " \
    "quoting the clause, for its role to confirm (step 3)")
  if (p = index($0, "Owner:")) no_role(FNR, substr($0, p)) }
sec == "Roles" && /^- / { no_role(FNR, $0) }
sec == "What this work touches" && !role && !ca && NF && !/^[#-]/ && FOREIGN && $0 == anote {
  report(FNR, "the intent is not in English: translate the What this work touches note, as step 5 says") }
sec == "What this work touches" && /^### / { role = substr($0, 5); sub(/[ \t]+$/, "", role); no_role(FNR, role); ca = ""; next }
sec == "What this work touches" && /^- A[0-9]+\. / { ca = substr($0, 3); sub(/\..*/, "", ca); a_id[++n_a] = ca; a_line[ca] = FNR; a_role[ca] = role }
sec == "What this work touches" && /^- / && !/^- A[0-9]+\. / { ca = "" }
sec == "What this work touches" && ca != "" && /^[ \t]+- / { s = $0; sub(/^[ \t]+- /, "", s); p = index(s, ":"); k = p ? substr(s, 1, p - 1) : ""; v = substr(s, p + 1); sub(/^[ \t]+/, "", v)
  if (k !~ /^(Today|After|Affects|Policy text|Confirm in)$/) { report(FNR, ca " has a line labeled \"" k "\": use the template'"'"'s Today:, After:, Affects:, Policy text: and Confirm in:"); next }
  a_has[ca, k]++; if (v ~ /^[ \t]*$/) report(FNR, ca " has an empty \"" k "\" line")
  if (k == "Affects" && v !~ /(^|[^A-Za-z0-9_])R[0-9]+/) report(FNR, ca "'"'"'s Affects: names no requirement: give each R<n> (Short name) the area changes")
  if (k == "Confirm in") { a_q[ca] = ""; if (match(v, /(^|[^A-Za-z0-9_])Q[0-9]+/)) { a_q[ca] = substr(v, RSTART, RLENGTH); sub(/^[^Q]/, "", a_q[ca]) } a_qline[ca] = FNR }
  if (k == "Policy text") { pt_a[++n_pt] = ca; pt_line[n_pt] = FNR; pt_v[n_pt] = v } }
due && NF { due = 0
  if ($0 == note) { eng = 1
    if (FOREIGN) report(FNR, "the intent is not in English: translate the Open questions note and the question labels into its language")
    next }
  if ($0 !~ /^(- |[ \t]|None\.)/ && english_share($0, note) <= 0.5) { tr = $0; next }
  report(FNR, "Open questions must start with the template'"'"'s note, word for word, or its faithful translation") }
cq != "" && /^[ \t]+- / { s = $0; sub(/^[ \t]+- /, "", s); p = index(s, ":"); w = index(s, "\357\274\232")   # ASCII or full-width colon
  if (w && (!p || w < p)) { p = w; w = 3 } else w = 1
  lab[++nf] = p ? substr(s, 1, p - 1) : ""
  if (!p) report(FNR, cq " has a line with no label: start it with the label and a colon, as in the template")
  else if (substr(s, p + w) ~ /^[ \t]*$/) report(FNR, cq " has an empty \"" lab[nf] "\" line")
  else if (tl[nf] == "Who answers") { no_role(FNR, substr(s, p + w)); qwho[cq] = substr(s, p + w) } }
sec == "Sources" && /^- S[0-9]+\. / { s = $0; sub(/^- /, "", s); id = s; sub(/\..*/, "", id); s_path[id] = first_path(s) }
sec == "Sources" && !src_open && !src_told && NF { if (/^<details><summary>.*<\/summary>[ \t]*$/) {
    src_open = FNR; s = $0; sub(/^<details><summary>/, "", s); sub(/<\/summary>[ \t]*$/, "", s); check_summary(FNR, s); next }
  report(FNR, "Sources must start with the template'"'"'s line \"<details><summary>" tsum "</summary>\" (translated in a spec not in English), then a blank line, the S lines, and \"</details>\": the list is an appendix for engineers"); src_told = 1 }
sec == "Sources" && src_open == FNR - 1 && NF { report(FNR, "leave a blank line after the <summary> line, or the list inside it is not rendered as a list") }
sec == "Sources" && src_open && /^<\/details>[ \t]*$/ { src_close = FNR }
sec == "Sources" && src_close && /^- S[0-9]+\. / { report(FNR, "this S line is after </details>: keep every S line inside the engineer appendix") }
/^- / { items[sec]++ }
/^None\.[ \t]*$/ { none[sec] = FNR }
sec == "" && /^Status:/ { status = $0; status_line = FNR }
/^- (Outcome|Question) "/ { s = $0; sub(/^- [A-Za-z]+ "/, "", s); ledger = ledger "\n" s }
is_def() { if (ID in name) report(FNR, ID " is defined twice"); name[ID] = NM; line[ID] = FNR
  if (ID ~ /^R/) { end_r(); cr = ID; cr_line = FNR; scn = 0 }
  if (ID ~ /^Q/) open_q[ID] = 1
  if (sec == "Open questions" && ID ~ /^Q/) { endq(); cq = ID; cq_line = FNR; nf = 0; n_tier[tier]++; qtier[ID] = tier
    if (!tier) report(FNR, ID " is under no tier: put it under \"### Decide before building\" or \"### Can wait for planning\"") } }
{ s = " " $0; if (/^[ \t]+- Policy text:/) sub(/".*/, "", s)
  while (match(s, /[^A-Za-z0-9_][RACQS][0-9]+/)) {
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
  if ("Sources" in seen && !src_told) { if (!src_open) report(seen["Sources"], "Sources must wrap its list in the template'"'"'s <details><summary>" tsum "</summary> … </details> block")
    else if (!src_close) report(src_open, "close the engineer appendix with a \"</details>\" line after the last S line") }
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
  for (i = 1; i <= n_a; i++) { id = a_id[i]
    if (a_role[id] == "") report(a_line[id], id " is under no role heading: put it under \"### <the role that confirms its rules>\", as in the template")
    for (k = split("Today|After|Affects|Policy text|Confirm in", cf, "|"); k; k--) if (!((id, cf[k]) in a_has)) report(a_line[id], id " has no \"" cf[k] ":\" line")
    q = a_q[id]; if (!((id, "Confirm in") in a_has)) continue
    if (q == "") report(a_qline[id], id "'"'"'s Confirm in: names no question: give the Q<n> that asks its role to confirm it")
    else if (!(q in qtier)) continue
    else if (qtier[q] != 1) report(a_qline[id], id " is confirmed in " q ", which is not under \"Decide before building\": an area'"'"'s question is answered before building starts")
    else if (a_role[id] != "") { r = tolower(a_role[id]); sub(/[,(\357].*/, "", r); sub(/[ \t]+$/, "", r)
      if (!index(tolower(qwho[q]), r)) report(a_qline[id], q "'"'"'s Who answers does not name " id "'"'"'s role, \"" a_role[id] "\": the role under which an area sits answers its question") } }
  for (i = 1; i <= n_pt; i++) check_policy_text(pt_line[i], pt_a[i], pt_v[i])
  for (id in name) if (id ~ /^[RC]/ && ((k = substr(id, 1, 1) SUBSEP name[id]) in old) && old[k] != id)
    report(line[id], id " has the name of " old[k] " in the superseded spec; keep the old id")
  exit bad
}' "$template" "$intent" "$old" "$spec"
