#!/bin/sh
# run.sh: regression tests for skills/engineering/write-spec/scripts/check-spec.sh, under whatever awk is on PATH.
# The samples in docs/specs/ must pass. Each variant is a sample with exact replacements, and must fail with the
# finding it was built for; each ok-variant must still pass. Exits 1 when any test fails.
cd "$(dirname "$0")" || exit 2
check=../../skills/engineering/write-spec/scripts/check-spec.sh
tmp=docs/tmp.$$
rm -rf "$tmp"; mkdir "$tmp" || exit 2; trap 'rm -rf "$tmp"' EXIT INT TERM
cp docs/specs/*.md "$tmp"/
fail=0 n=0

# variant <name> <sample> <old> <new> [<old> <new> ...]: write $tmp/<name>.md, each old text replaced exactly once
variant() {
  out=$tmp/$1.md; cp "docs/specs/$2.md" "$out"; shift 2
  while [ $# -ge 2 ]; do
    OLD_S=$1 NEW_S=$2 awk 'BEGIN { o = ENVIRON["OLD_S"]; r = ENVIRON["NEW_S"] } { t = t $0 "\n" }
      END { i = index(t, o); if (!i || index(substr(t, i + 1), o)) exit 1; printf "%s", substr(t, 1, i - 1) r substr(t, i + length(o)) }' \
      "$out" > "$out.new" || { echo "FAIL could not build $out: no single match for: $1"; fail=1; }
    mv "$out.new" "$out"; shift 2
  done
}
# fails <name> <text the output must contain> <sample> <old> <new> ...
fails() {
  name=$1 want=$2; shift 2; variant "$name" "$@"; n=$((n + 1))
  if got=$(sh "$check" "$tmp/$name.md"); then echo "FAIL $name: passed, but should report: $want"; fail=1
  else case $got in *"$want"*) ;; *) echo "FAIL $name: wrong finding; wanted: $want"; echo "$got"; fail=1 ;; esac; fi
}
# passes <name> <sample> <old> <new> ...
passes() {
  name=$1; shift; variant "$name" "$@"; n=$((n + 1))
  got=$(sh "$check" "$tmp/$name.md") || { echo "FAIL $name: should pass"; echo "$got"; fail=1; }
}

for s in sample-en sample-ko sample-en-v2; do n=$((n + 1))
  got=$(sh "$check" "$tmp/$s.md") || { echo "FAIL $s: should pass"; echo "$got"; fail=1; }; done

fails undefined-id 'Q9 is referenced but not defined' sample-en 'carried as Q4.' 'carried as Q9.'
fails defined-twice 'Q4 is defined twice' sample-en '- Q5. Wording after a move' '- Q4. Wording after a move'
fails decided-by-open-q 'Q4 is an open question, so a (decided by' sample-en \
  'without paying a second deposit.' 'without paying a second deposit (decided by the originator, Q4).'
fails no-scenario 'R2 has no scenario' sample-en \
  '- Given a 2026-11-10 10:00 appointment, when the patient moves it to the same doctor' 'Given a 2026-11-10 10:00 appointment, when the patient moves it to the same doctor'
fails intent-outcome-missing 'no Outcome or Question line quoting "A cancellation refunds' sample-en \
  '- Outcome "A cancellation refunds the amount' 'The intent says "A refund gives the amount'
fails intent-question-missing 'no Outcome or Question line quoting "앱에서 예약을 변경할 때' sample-ko \
  '- Question "앱에서 예약을 변경할 때 담당 의사도 바꿀 수 있게 할지 정하지 않았다": carried as Q5.' ''
fails supersede-renumbered 'R4 has the name of R2 in the superseded spec' sample-en-v2 \
  '### R2. Patient: Move within the branch' '### R4. Patient: Move within the branch'
fails tier-heading-missing 'no "### Can wait for planning" heading' sample-en '### Can wait for planning' ''
fails area-question-tier2 'A2 is confirmed in Q5, which is not under "Decide before building"' sample-en \
  '  - Confirm in: Q2.' '  - Confirm in: Q5.'
fails status-count 'Status: says 3 under "Decide before building", but it lists 4' sample-en \
  'Status: 4 to decide' 'Status: 3 to decide'
fails quote-not-verbatim 'A1: the text quoted from S3 is not word for word' sample-en 'gets 50% back' 'gets half back'
fails quote-stops-at-colon 'A2: the quote from S4 stops before the list' sample-en \
  '“A cancellation text must give: the branch and the time of the appointment; the amount refunded, if any.”' '“A cancellation text must give:”'
fails quote-stops-before-list-ko 'A1: the quote from S5 stops before the list' sample-ko \
  '다음과 같이 환불한다. 1. 진료 1일 전까지 취소한 경우: 예약금 전액 2. 제1호의 기한이 지난 뒤 진료 예정 시각 3시간 전까지 취소한 경우: 예약금의 50% 3. 진료 예정 시각 3시간 전이 지난 뒤 취소한 경우: 환불하지 않는다."' '다음과 같이 환불한다."'
fails quote-file-missing 'A1: not verified: S3' sample-en 'policies/POL-FIN-007-en.md' 'policies/POL-FIN-007-old.md'
fails quote-path-with-spaces 'A1: not verified: S3' sample-en 'policies/POL-FIN-007-en.md' '`policies/Deposit policy copy.md`'
fails quote-path-is-folder 'A1: not verified: S3' sample-en 'policies/POL-FIN-007-en.md' 'policies'
fails quote-not-verbatim-ko 'A3: the text quoted from S6 is not word for word' sample-ko '48시간이 지나기 전에는' '이틀이 지나기 전에는'
fails code-label 'WELLBEING" is a file or code name' sample-en 'with no staff input. The amount' 'with no staff input, as for WELLBEING claims. The amount'
fails code-camel-case 'cancelBooking" is a file or code name' sample-ko '취소 문자는 지금처럼' 'cancelBooking의 취소 문자는 지금처럼'
fails code-path 'docs/policies/" is a file or code name' sample-en '- Moving to another branch or department (intent).' '- Moving to another branch or department (intent, docs/policies/).'
fails boundary-under '"under £100" puts a case on one side of 100, which Q4 asks' sample-en \
  'whether a move may switch to another doctor in the same department.' 'whether a deposit of exactly £100 is refunded by the app.' \
  'with no staff input. The amount for each cancellation time' 'with no staff input when the deposit is under £100. The amount for each cancellation time'
fails boundary-within-threshold '"within the threshold" puts a case on one side of the threshold, which Q4 asks' sample-en \
  'whether a move may switch to another doctor in the same department.' 'whether a deposit exactly at the refund threshold is refunded by the app.' \
  'After: see R1 (Cancel in the app).' 'After: deposits within the threshold are refunded, see R1 (Cancel in the app).'
fails boundary-ko '"100,000원 이하" puts a case on one side of 100000, which Q5 asks' sample-ko \
  '변경할 때 같은 진료과의 다른 의사를 고를 수 있는지' '예약금이 정확히 100,000원일 때 앱에서 환불하는지' \
  '확정하면 예약금 정책에 따른 환불액이' '예약금이 100,000원 이하이면 확정할 때 예약금 정책에 따른 환불액이'
passes ok-boundary-intent-and-question sample-en \
  'whether a move may switch to another doctor in the same department.' 'whether a patient may cancel exactly 3 hours before, or only under 3 hours before.'
passes ok-product-names sample-en 'cancel their own appointment in the app' 'cancel their own appointment in the iPhone or Android app, built on Node.js for macOS,'
passes ok-list-quoted-by-item sample-en \
  '2.1: “A cancellation text must give: the branch and the time of the appointment; the amount refunded, if any.”' \
  '2.1: “A cancellation text must give:”
  - Policy text: Patient notice rules (S4), 2.1(a): “the branch and the time of the appointment;”
  - Policy text: Patient notice rules (S4), 2.1(b): “the amount refunded, if any.”'
passes ok-quotes-split sample-en \
  '4.2: "A later cancellation up to 3 hours before gets 50% back."' '4.2: "A later cancellation" … "gets 50% back."'

[ $fail = 0 ] && echo "ok: $n tests passed"
exit $fail
