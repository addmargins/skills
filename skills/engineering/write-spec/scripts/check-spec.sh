#!/bin/sh
# check-spec.sh: check a spec.md against the format rules of references/spec-template.md.
# Usage: check-spec.sh <spec.md> [<intent.md>]
# The intent file defaults to the spec's "Intent:" line, and a superseded spec to its
# "Supersedes:" line, both resolved next to the spec. Prints one "file:line: problem"
# per finding. Exits 0 when clean, 1 on findings, 2 on a usage error.
# It checks form only. Whether the content is decided and complete is the fresh reader's job.
set -eu

usage='usage: check-spec.sh <spec.md> [<intent.md>]'
spec=${1:?$usage}
[ -f "$spec" ] || { echo "check-spec: no such file: $spec" >&2; exit 2; }
dir=$(dirname "$spec")
template="$(dirname "$0")/../references/spec-template.md"
[ -f "$template" ] || { echo "check-spec: template not found: $template" >&2; exit 2; }

field() { sed -n "s/^$1:[[:space:]]*//p" "$spec" | head -n 1; }

intent=${2:-}
if [ -z "$intent" ]; then
  name=$(field Intent)
  [ -n "$name" ] && intent="$dir/$name"
fi
if [ -z "$intent" ] || [ ! -f "$intent" ]; then
  echo "$spec:1: Intent: line missing, or intent file not found: ${intent:-none}"
  exit 1
fi

old=/dev/null has_old=0
name=$(field Supersedes)
if [ -n "$name" ]; then
  if [ -f "$dir/$name" ]; then old="$dir/$name" has_old=1
  else echo "$spec:1: superseded spec not found: $dir/$name"; exit 1
  fi
fi

# The Open questions note, taken from the template so the two cannot drift apart.
note=$(awk '/^## Open questions/ { on = 1; next } on && NF { print; exit }' "$template")

# Vague words, not allowed outside Open questions and quoted text.
banned='gracefully|appropriately|as needed|as appropriate|if possible|if needed|quickly|intuitive|seamless|user-friendly|robust|etc.|and/or|TBD|적절히|가능하면|필요시|빠르게|원활하게'

sections='Summary|Requirements|Changes to existing behavior|Constraints|Policy conflicts|Out of scope|From the intent|Open questions'
required='Summary|Requirements|Changes to existing behavior|From the intent|Open questions'
# Sections that say "None." when they list nothing, and only then.
say_none='Changes to existing behavior|Open questions'

awk -v SPEC="$spec" -v BANNED="$banned" -v NOTE="$note" -v HAS_OLD="$has_old" \
    -v SECTIONS="$sections" -v REQUIRED="$required" -v SAY_NONE="$say_none" '
function norm(s) { s = tolower(s); sub(/^[ \t]+/, "", s); sub(/[ \t.]+$/, "", s); return s }
function report(line, msg) { print SPEC ":" line ": " msg; bad = 1 }
function strip_quotes(s) {                   # quoted words are the source'"'"'s, not the writer'"'"'s
  while (match(s, /"[^"]*"/)) s = substr(s, 1, RSTART - 1) substr(s, RSTART + RLENGTH)
  return s
}
function is_word_char(c) { return c ~ /[A-Za-z0-9_]/ }
function check_banned(s, line,   n, i, w, t, p) {
  t = tolower(strip_quotes(s)); n = split(BANNED, words, "|")
  for (i = 1; i <= n; i++) {
    w = tolower(words[i]); p = index(t, w)
    if (!p) continue
    # English words match whole words; Korean ones take particles, so they match anywhere.
    if (w ~ /^[a-z]/ && (is_word_char(substr(t, p - 1, 1)) || is_word_char(substr(t, p + length(w), 1)))) continue
    report(line, "vague word \"" words[i] "\": say the value, state, or next action instead")
  }
}
function marked(s) {
  return index(s, "(decided by") || index(s, "(decided in conversation)") ||
    s ~ /\(required by C[0-9]+ \(/ || s ~ /\(see [RC][0-9]+ \(/
}
function item_id(   s) { s = $2; sub(/\.$/, "", s); return s }
function close_item() {                      # checks for the R or Q that just ended
  if (cur_r != "") {
    if (!r_sothat) report(r_line, cur_r ": no \"So that:\" line")
    if (!r_given)  report(r_line, cur_r ": no Given/when/then scenario")
  }
  if (cur_q != "") {
    if (!q_dep)   report(q_line, cur_q ": no \"Depends on the answer:\" line")
    if (!q_res)   report(q_line, cur_q ": no \"To resolve:\" line")
    if (!q_until) report(q_line, cur_q ": no \"Until decided:\" line")
  }
  cur_r = cur_q = ""
}

FNR == 1 { pass++; if (pass == 2 && !HAS_OLD) pass = 3 }

# Pass 1: the intent. Collect its text, outcomes, and open questions.
pass == 1 {
  intent_text = intent_text " " tolower($0)
  if ($0 ~ /^## /) { isec = $0; next }
  if ($0 ~ /^[ \t]*$/ || $0 ~ /^</) next
  item = $0; sub(/^[ \t]*-[ \t]*/, "", item)
  if (isec == "## Desired outcome") outcome[++n_out] = item
  if (isec == "## Open questions")  question[++n_q] = item
  next
}

# Pass 2: the superseded spec. Collect its requirement names.
pass == 2 {
  if ($0 ~ /^### R[0-9]+\. /) {
    nm = $0; sub(/^### R[0-9]+\. [^:]*: /, "", nm); id = $2; sub(/\.$/, "", id)
    old_name[id] = nm; old_line[nm] = id
  }
  next
}

# Pass 3: the spec.
FNR == 1 && $0 !~ /^# Spec: / { report(1, "first line is not \"# Spec: <Title>\"") }

/^```/ { fence = !fence; next }
fence { next }

/^## / {
  close_item()
  sec = substr($0, 4); seen_sec[sec] = 1; sec_line[sec] = FNR; note_due = (sec == "Open questions")
  n = split(SECTIONS, order, "|"); pos = 0
  for (i = 1; i <= n; i++) if (order[i] == sec) pos = i
  if (!pos) report(FNR, "unknown section \"" sec "\"")
  else if (pos < last_pos) report(FNR, "section \"" sec "\" is out of template order")
  else last_pos = pos
  next
}

note_due && NF {
  note_due = 0
  if ($0 != NOTE) report(FNR, "Open questions must start with the template'"'"'s note, word for word")
  next
}

/^### R[0-9]+\. / {
  close_item()
  cur_r = item_id(); r_line = FNR; r_sothat = r_given = 0
  if ($0 !~ /^### R[0-9]+\. [^:]+: ./) report(FNR, cur_r ": heading is not \"R<n>. <Actor>: <short name>\"")
  if (cur_r in r_name) report(FNR, cur_r " is defined twice")
  nm = $0; sub(/^### R[0-9]+\. [^:]*: /, "", nm); r_name[cur_r] = nm
  next
}

sec == "Constraints" && /^- C[0-9]+\. / {
  id = item_id()
  if (id in c_name) report(FNR, id " is defined twice")
  nm = $0; sub(/^- C[0-9]+\. /, "", nm); sub(/:.*/, "", nm); c_name[id] = nm
  if ($0 !~ /^- C[0-9]+\. [^:]+: ./) report(FNR, id ": no \"<Short name>:\" before the rule")
  if (index($0, "Source:") == 0) report(FNR, id ": no \"Source:\"")
  if (index($0, "Owner:") == 0)  report(FNR, id ": no \"Owner:\"")
  if (index($0, "Reason:") == 0) report(FNR, id ": no \"Reason:\"")
}

sec == "Open questions" && /^- Q[0-9]+\. / {
  close_item()
  cur_q = item_id(); q_line = FNR; q_dep = q_res = q_until = 0
  if (cur_q in q_seen) report(FNR, cur_q " is defined twice")
  q_seen[cur_q] = 1
}
cur_q != "" && /^[ \t]+- Depends on the answer:/ {
  q_dep = 1
  if ($0 !~ /[RC][0-9]+/) report(FNR, cur_q ": \"Depends on the answer\" names no R or C item")
}
cur_q != "" && /^[ \t]+- To resolve:/ { q_res = 1 }
cur_q != "" && /^[ \t]+- Until decided:/ {
  q_until = 1
  if ($0 !~ /do not build R[0-9]+/ && index($0, "accepted by") == 0)
    report(FNR, cur_q ": \"Until decided\" is neither \"do not build R<n>\" nor a value \"accepted by <decider>, <where>\"")
}

# The short marker refers to the "Decided in conversation:" line, which names who and when.
sec == "" && /^Decided in conversation:[ \t]*[^ \t]/ { has_conv = 1 }
index($0, "(decided in conversation)") && !conv_line { conv_line = FNR }

cur_r != "" && $0 !~ /^So that:/ && $0 !~ /^- / && !marked($0) {
  # A number in a rule sentence comes from the intent, or says who decided it, the constraint
  # that requires it, or the item it follows from.
  rest = $0
  while (match(rest, /[0-9]+([.:][0-9]+)?/)) {
    num = substr(rest, RSTART, RLENGTH); rest = substr(rest, RSTART + RLENGTH)
    if (index(intent_text, num) == 0)
      report(FNR, cur_r ": " num " is not in the intent; add (decided in conversation), (decided by <name>, <role>, <where>), or (required by C<n> (Short name)), or make it an open question")
  }
}
cur_r != "" && /^So that:/   { r_sothat = 1 }
cur_r != "" && /^- Given /   { r_given = 1 }

sec == "From the intent" && match($0, /"[^"]*"/) {
  ledger[norm(substr($0, RSTART + 1, RLENGTH - 2))] = 1
}

sec != "" && /^- / { n_items[sec]++ }
sec != "" && /^None\.[ \t]*$/ { none_line[sec] = FNR }

sec != "Open questions" && sec != "From the intent" { check_banned($0, FNR) }

{
  # Collect references and resolve them at the end, since a reference may come first.
  rest = $0
  while (match(rest, /[RC][0-9]+ \([^)]*\)/)) {
    ref = substr(rest, RSTART, RLENGTH); rest = substr(rest, RSTART + RLENGTH)
    rid = ref; sub(/ .*/, "", rid); rnm = ref; sub(/^[^(]*\(/, "", rnm); sub(/\)$/, "", rnm)
    refs[++n_ref] = rid; ref_nm[n_ref] = rnm; ref_line[n_ref] = FNR
  }
  rest = $0
  while (match(rest, /(see|carried as) Q[0-9]+/)) {
    ref = substr(rest, RSTART, RLENGTH); rest = substr(rest, RSTART + RLENGTH)
    sub(/.* /, "", ref); refs[++n_ref] = ref; ref_nm[n_ref] = ""; ref_line[n_ref] = FNR
  }
}

END {
  close_item()
  if (conv_line && !has_conv)
    report(conv_line, "(decided in conversation) is used, but there is no \"Decided in conversation: <name>, <role>, <date>\" line")
  n = split(REQUIRED, req, "|")
  for (i = 1; i <= n; i++) if (!(req[i] in seen_sec)) report(1, "no \"## " req[i] "\" section")
  n = split(SAY_NONE, empty, "|")
  for (i = 1; i <= n; i++) {
    s = empty[i]
    if (!(s in seen_sec)) continue
    if (!n_items[s] && !(s in none_line)) report(sec_line[s], "\"" s "\" lists nothing: write \"None.\" under it")
    if (n_items[s] && (s in none_line)) report(none_line[s], "\"" s "\" says \"None.\" but also lists items")
  }

  for (i = 1; i <= n_ref; i++) {
    rid = refs[i]; k = substr(rid, 1, 1)
    if (k == "R") { ok = rid in r_name; cur = r_name[rid] }
    else if (k == "C") { ok = rid in c_name; cur = c_name[rid] }
    else { ok = rid in q_seen; cur = "" }
    if (!ok) report(ref_line[i], rid " is referenced but not defined")
    else if (ref_nm[i] != "" && ref_nm[i] != cur)
      report(ref_line[i], rid " is cited as \"" ref_nm[i] "\" but is named \"" cur "\"")
  }

  for (i = 1; i <= n_out; i++) if (!(norm(outcome[i]) in ledger))
    report(1, "From the intent: no line quoting the intent outcome \"" outcome[i] "\"")
  for (i = 1; i <= n_q; i++) if (!(norm(question[i]) in ledger))
    report(1, "From the intent: no line quoting the intent question \"" question[i] "\"")

  # A revision keeps the ids it inherits: no renamed id, no name moved to a new id.
  for (id in old_name) if ((id in r_name) && r_name[id] != old_name[id])
    report(1, id " was \"" old_name[id] "\" in the superseded spec; give a changed requirement a new id")
  for (id in r_name) if ((r_name[id] in old_line) && old_line[r_name[id]] != id)
    report(1, id " reuses the name of " old_line[r_name[id]] " from the superseded spec; keep the old id")
  exit bad
}
' "$intent" "$old" "$spec"
