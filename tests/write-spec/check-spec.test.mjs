// Regression tests for skills/engineering/write-spec/scripts/check-spec.mjs. The samples in docs/specs/ must pass.
// Each variant is a sample with exact replacements, and must fail with the finding it was built for, or still pass.
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { cpSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { after, before, test } from "node:test";

const here = import.meta.dirname;
const checker = join(here, "../../skills/engineering/write-spec/scripts/check-spec.mjs");
let tmp;
before(() => {
	tmp = mkdtempSync(join(tmpdir(), "check-spec-test-"));
	cpSync(join(here, "docs"), join(tmp, "docs"), { recursive: true });
	cpSync(join(here, "policies"), join(tmp, "policies"), { recursive: true });
});
after(() => rmSync(tmp, { recursive: true, force: true }));

const run = (...args) => spawnSync(process.execPath, [checker, ...args], { cwd: tmp, encoding: "utf8" });
// write docs/specs/<name>.md: the sample with each old text, which must occur exactly once, replaced
const variant = (name, sample, ...pairs) => {
	let text = readFileSync(join(tmp, "docs/specs", `${sample}.md`), "utf8");
	for (let i = 0; i < pairs.length; i += 2) {
		const at = text.indexOf(pairs[i]);
		const again = text.indexOf(pairs[i], at + 1);
		if (at === -1 || again !== -1) throw new Error(`no single match in ${sample} for: ${pairs[i]}`);
		text = text.slice(0, at) + pairs[i + 1] + text.slice(at + pairs[i].length);
	}
	writeFileSync(join(tmp, "docs/specs", `${name}.md`), text);
	return `docs/specs/${name}.md`;
};
const fails = (name, want, sample, ...pairs) =>
	test(name, () => {
		const result = run(variant(name, sample, ...pairs));
		assert.equal(result.status, 1, `passed, but should report: ${want}`);
		assert.ok(result.stdout.includes(want), `wanted: ${want}\ngot: ${result.stdout}`);
	});
const passes = (name, sample, ...pairs) =>
	test(name, () => {
		const result = run(variant(name, sample, ...pairs));
		assert.equal(result.status, 0, result.stdout);
	});

for (const sample of ["sample-en", "sample-ko", "sample-en-v2"]) {
	test(sample, () => {
		const result = run(`docs/specs/${sample}.md`);
		assert.equal(result.status, 0, result.stdout);
		assert.equal(result.stdout, "");
	});
}

test("usage-no-arg", () => {
	const result = run();
	assert.equal(result.status, 2);
	assert.ok(result.stderr.includes("Usage: node check-spec.mjs <spec.md>"));
});
test("no-such-file", () => {
	const result = run("docs/specs/missing.md");
	assert.equal(result.status, 2);
	assert.ok(result.stderr.includes("check-spec: no such file: docs/specs/missing.md"));
});

fails("undefined-id", "Q9 is referenced but not defined", "sample-en", "carried as Q4.", "carried as Q9.");
fails("defined-twice", "Q4 is defined twice", "sample-en",
	"- Q5. Wording after a move", "- Q4. Wording after a move");
const booked = "the new time and branch are booked";
fails("decided-by-open-q", "Q4 is an open question, so a (decided by", "sample-en-v2",
	booked, `${booked} (decided by the originator, sample-en.md Q4)`);
fails("decided-by-no-supersedes", "may cite only the spec this one supersedes, and this spec supersedes none",
	"sample-en", "without paying a second deposit.",
	"without paying a second deposit (decided by the finance team lead, S3 (Deposit policy) 4.2).");
fails("decided-by-other-file", "may cite only the spec this one supersedes (sample-en.md)", "sample-en-v2",
	booked, `${booked} (decided by the finance team lead, S3 (Deposit policy) 4.2)`);
passes("ok-decided-by-supersedes", "sample-en-v2", booked, `${booked} (decided by the originator, sample-en.md R2)`);
fails("no-scenario", "R2 has no scenario", "sample-en",
	"- Given a 2026-11-10 10:00 appointment, when the patient moves it to the same doctor",
	"Given a 2026-11-10 10:00 appointment, when the patient moves it to the same doctor");
fails("intent-outcome-missing", 'no Outcome or Question line quoting "A cancellation refunds', "sample-en",
	'- Outcome "A cancellation refunds the amount', 'The intent says "A refund gives the amount');
fails("intent-question-missing", 'no Outcome or Question line quoting "앱에서 예약을 변경할 때', "sample-ko",
	'- Question "앱에서 예약을 변경할 때 담당 의사도 바꿀 수 있게 할지 정하지 않았다": carried as Q5.', "");
fails("intent-missing", "Intent: line missing, or its file not found", "sample-en",
	"Intent: 0002-app-cancellation-en.md", "Intent: 0009-gone.md");
fails("supersedes-missing", "superseded spec not found next to this one: sample-old.md", "sample-en-v2",
	"Supersedes: sample-en.md", "Supersedes: sample-old.md");
fails("supersede-renumbered", "R4 has the name of R2 in the superseded spec", "sample-en-v2",
	"### R2. Patient: Move within the branch", "### R4. Patient: Move within the branch");
fails("tier-heading-missing", 'no "### Can wait for planning" heading', "sample-en",
	"### Can wait for planning", "");
fails("q-no-tier", "Q1 is under no tier", "sample-en", "### Decide before building", "### Decide first");
fails("confirm-in-no-question", "A2's Confirm in: names no question", "sample-en",
	"  - Confirm in: Q2.\n", "");
fails("area-confirm-not-q", "A2's Confirm in: names no question", "sample-en",
	"  - Confirm in: Q2.", "  - Confirm in: R1 (Cancel in the app).");
fails("area-question-tier2", 'A2 is confirmed in Q5, which is not under "Decide before building"', "sample-en",
	"  - Confirm in: Q2.", "  - Confirm in: Q5.");
fails("status-missing", 'no "Status:" line', "sample-en", "Status: 4 to decide", "State: 4 to decide");
fails("status-not-two-numbers", "Status: must give two numbers", "sample-en",
	"Status: 4 to decide before building, 1 that", "Status: 4 to decide before building, one that");
fails("status-count", 'Status: says 3 under "Decide before building", but it lists 4', "sample-en",
	"Status: 4 to decide", "Status: 3 to decide");
fails("quote-not-verbatim", "A1: the text quoted from S3 is not word for word", "sample-en",
	"gets 50% back", "gets half back");
fails("quote-unclosed", "A1: a quote has no closing quote mark", "sample-en",
	'gets nothing back."', "gets nothing back.");
fails("quote-no-source-id", "A1: not verified: cite the quoted document as S<n> (Name)", "sample-en",
	"Deposit policy (S3), 4.3:", "Deposit policy, 4.3:");
fails("quote-stops-at-colon", "A2: the quote from S4 stops before the list", "sample-en",
	"“A cancellation text must give: the branch and the time of the appointment; the amount refunded, if any.”",
	"“A cancellation text must give:”");
fails("quote-file-missing", "A1: not verified: S3", "sample-en",
	"policies/POL-FIN-007-en.md", "policies/POL-FIN-007-old.md");
fails("quote-path-with-spaces", "A1: not verified: S3", "sample-en",
	"policies/POL-FIN-007-en.md", "`policies/Deposit policy copy.md`");
fails("quote-path-is-folder", "A1: not verified: S3", "sample-en", "policies/POL-FIN-007-en.md", "policies");
test("quote-not-text-file", () => {
	writeFileSync(join(tmp, "policies/POL-FIN-007-en.pdf"), "");
	const result = run(variant("quote-not-text-file", "sample-en",
		"policies/POL-FIN-007-en.md", "policies/POL-FIN-007-en.pdf"));
	assert.equal(result.status, 1);
	assert.ok(result.stdout.includes("A1: not verified: policies/POL-FIN-007-en.pdf is not a text file"),
		result.stdout);
});
fails("quote-not-verbatim-ko", "A3: the text quoted from S6 is not word for word", "sample-ko",
	"48시간이 지나기 전에는", "이틀이 지나기 전에는");
passes("ok-list-quoted-by-item", "sample-en",
	"2.1: “A cancellation text must give: the branch and the time of the appointment; the amount refunded, if any.”",
	`2.1: “A cancellation text must give:”
  - Policy text: Patient notice rules (S4), 2.1(a): “the branch and the time of the appointment;”
  - Policy text: Patient notice rules (S4), 2.1(b): “the amount refunded, if any.”`);
passes("ok-quotes-split", "sample-en",
	'4.2: "A later cancellation up to 3 hours before gets 50% back."', '4.2: "A later cancellation" … "gets 50% back."');
