// Regression tests for skills/engineering/write-spec/scripts/check-spec.mjs. The sample in docs/specs/ must pass.
// Each variant is the sample with exact replacements, and must fail with the finding it was built for, or still pass.
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

test("sample-en", () => {
	const result = run("docs/specs/sample-en.md");
	assert.equal(result.status, 0, result.stdout);
	assert.equal(result.stdout, "");
});

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

fails("undefined-id", "Q9 is referenced but not defined", "sample-en", "carried as Q3.", "carried as Q9.");
fails("defined-twice", "Q3 is defined twice", "sample-en",
	"- Q4. Wording after a move", "- Q3. Wording after a move");
const intentLine = "Intent: 0002-app-cancellation-en.md";
const rev = (old = "sample-en.md") => [intentLine, `${intentLine}\n\nSupersedes: ${old}`];
const booked = "without paying a second deposit.";
fails("decided-by-open-q", "Q3 is an open question, so a (decided by", "sample-en", ...rev(),
	booked, "without paying a second deposit (decided by the originator, sample-en.md Q3).");
fails("decided-by-no-supersedes", "may cite only the spec this one supersedes, and this spec supersedes none",
	"sample-en", "without paying a second deposit.",
	"without paying a second deposit (decided by the finance team lead, S2 (Deposit policy) 4.2).");
fails("decided-by-other-file", "may cite only the spec this one supersedes (sample-en.md)", "sample-en", ...rev(),
	booked, "without paying a second deposit (decided by the finance team lead, S2 (Deposit policy) 4.2).");
passes("ok-decided-by-supersedes", "sample-en", ...rev(), booked, "without paying a second deposit (decided by the originator, sample-en.md R2).");
fails("no-scenario", "R2 has no scenario", "sample-en",
	"- Given a 2026-11-10 10:00 appointment, when the patient moves it to the same doctor",
	"Given a 2026-11-10 10:00 appointment, when the patient moves it to the same doctor");
fails("intent-question-missing", 'no Outcome or Question line quoting "Whether a patient who moves', "sample-en",
	'- Question "Whether a patient who moves an appointment may also change the doctor": carried as Q3.', "");
fails("intent-missing", "Intent: line missing, or its file not found", "sample-en",
	"Intent: 0002-app-cancellation-en.md", "Intent: 0009-gone.md");
fails("supersedes-missing", "superseded spec not found next to this one: sample-old.md", "sample-en", ...rev("sample-old.md"));
fails("supersede-renumbered", "R4 has the name of R2 in the superseded spec", "sample-en", ...rev(),
	"### R2. Patient: Move within the branch", "### R4. Patient: Move within the branch");
fails("tier-heading-missing", 'no "### Can wait for planning" heading', "sample-en",
	"### Can wait for planning", "");
fails("q-no-tier", "Q1 is under no tier", "sample-en", "### Decide before building", "### Decide first");
fails("confirm-in-no-question", "A2's Confirm in: names no question", "sample-en",
	"  - Confirm in: Q2.\n", "");
fails("area-confirm-not-q", "A2's Confirm in: names no question", "sample-en",
	"  - Confirm in: Q2.", "  - Confirm in: R1 (Cancel in the app).");
fails("area-question-tier2", 'A2 is confirmed in Q4, which is not under "Decide before building"', "sample-en",
	"  - Confirm in: Q2.", "  - Confirm in: Q4.");
fails("status-missing", 'no "Status:" line', "sample-en", "Status: 3 to decide", "State: 3 to decide");
fails("status-not-two-numbers", "Status: must give two numbers", "sample-en",
	"Status: 3 to decide before building, 1 that", "Status: 3 to decide before building, one that");
fails("status-count", 'Status: says 2 under "Decide before building", but it lists 3', "sample-en",
	"Status: 3 to decide", "Status: 2 to decide");
fails("quote-not-verbatim", "A1: the text quoted from S2 is not word for word", "sample-en",
	"gets 50% back", "gets half back");
fails("quote-unclosed", "A1: a quote has no closing quote mark", "sample-en",
	'gets nothing back."', "gets nothing back.");
fails("quote-no-source-id", "A1: not verified: cite the quoted document as S<n> (Name)", "sample-en",
	"Deposit policy (S2), 4.3:", "Deposit policy, 4.3:");
fails("quote-stops-at-colon", "A2: the quote from S3 stops before the list", "sample-en",
	"“A cancellation text must give: the branch and the time of the appointment; the amount refunded, if any.”",
	"“A cancellation text must give:”");
fails("quote-file-missing", "A1: not verified: S2's file policies/POL-FIN-007-old.md was not found", "sample-en",
	"policies/POL-FIN-007-en.md", "policies/POL-FIN-007-old.md");
test("quote-not-text-file", () => {
	writeFileSync(join(tmp, "policies/POL-FIN-007-en.pdf"), "");
	const result = run(variant("quote-not-text-file", "sample-en",
		"policies/POL-FIN-007-en.md", "policies/POL-FIN-007-en.pdf"));
	assert.equal(result.status, 1);
	assert.ok(result.stdout.includes("A1: not verified: policies/POL-FIN-007-en.pdf is not a text file"),
		result.stdout);
});
passes("ok-list-quoted-by-item", "sample-en",
	"2.1: “A cancellation text must give: the branch and the time of the appointment; the amount refunded, if any.”",
	`2.1: “A cancellation text must give:”
  - Policy text: Patient notice rules (S3), 2.1(a): “the branch and the time of the appointment;”
  - Policy text: Patient notice rules (S3), 2.1(b): “the amount refunded, if any.”`);
passes("ok-area-no-policy-found", "sample-en",
	"Policy text: Patient notice rules (S3), 2.1: “A cancellation text must give: the branch and the time of the appointment; the amount refunded, if any.”",
	"Policy text: No policy document for this area found in the workspace.");
passes("ok-quotes-split", "sample-en",
	'4.2: "A later cancellation up to 3 hours before gets 50% back."', '4.2: "A later cancellation" … "gets 50% back."');
const cancelText = "The cancellation text names the branch and time, as today";
fails("code-backtick", "`cancelBooking` is in backticks, which mark code", "sample-en",
	"then the app does not cancel it", "then `cancelBooking` does not cancel it");
fails("code-path", "policies/POL-NTC-003-en.md is a path in the workspace", "sample-en",
	`${cancelText} (current behavior, S1 (Booking cancellation)).`, `${cancelText} (policies/POL-NTC-003-en.md).`);
