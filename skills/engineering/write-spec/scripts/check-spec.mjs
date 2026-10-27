#!/usr/bin/env node
// check-spec.mjs <spec.md>: facts a reader of spec.md alone cannot check. Each id is defined once and each reference
// resolves, a revision keeps its ids, a "decided by" marker appears only in a revision, names the spec it supersedes,
// and cites no open question, each requirement has a scenario, From the intent covers the intent, tiers and Status:
// counts add up, each area is confirmed in a question to decide before building, quotes match their files, and prose
// outside Sources has no backticks or workspace paths. A pass means only that. Prints "file:line: problem".
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const TIERS = ["Decide before building", "Can wait for planning"];
const AREAS = "What this work touches";
const ID = /(?<![A-Za-z0-9_])[RACQS][0-9]+(?![A-Za-z0-9_])/g;
const POLICY = /^[ \t]+- Policy text:/;
const LEDGER = /^- (Outcome|Question) "/;
const EXT = /\.[A-Za-z0-9]+$/;
const TEXT = /\.(md|markdown|txt|text|rst|adoc|html?)$/;
const TWO = "Status: must give two numbers: questions to decide before building, then those that can wait for planning";
const CITE = "cite the quoted document as S<n> (Name), listed under Sources with its file";
const HAND = "check the quote by hand and say so in your final message";
const EXACT = "quote the clause exactly, never a summary; quote separate parts separately";
const LIST = "quote the list too, here or in the next quote";
const DROP = "for a value a policy sets, drop the value and name the area's question";
const PLAIN = "name it in plain words, and keep the code name under Sources";

process.on("uncaughtException", (e) => {
	console.error(`check-spec: internal error: ${e.message}`);
	process.exit(2);
});
const file = process.argv[2];
if (!file) {
	console.error("Usage: node check-spec.mjs <spec.md>");
	process.exit(2);
}
const isFile = (f) => fs.statSync(f, { throwIfNoEntry: false })?.isFile() ?? false;
if (!isFile(file)) {
	console.error(`check-spec: no such file: ${file}`);
	process.exit(2);
}

const problems = [];
const fail = (line, message) => problems.push(`${file}:${line}: ${message}`);
const readLines = (f) => fs.readFileSync(f, "utf8").split("\n").map((l) => l.replace(/\r$/, ""));
const trimEnd = (t) => t.replace(/[ \t]+$/, "");
// curly quotes, bold, list markers, and whitespace do not count
const squeeze = (t) => t.replace(/[“”]/g, '"').replace(/[‘’]/g, "'").replaceAll("**", "").split(/[ \t\r]+/)
	.filter((w) => w && !/^([-*+]|•|\([0-9a-z]{1,4}\)|[a-z]\))$/.test(w)).join(" ");
// the id and name this line defines, if any: "### R1. Actor: Name", "- C1. Name: ...", "- Q1.", "- A1.", "- S1."
const def = (text, sec) => {
	const m = text.match(/^(### |- )([RACQS][0-9]+)\. (.*)$/);
	const kind = m?.[2][0];
	if (!m || (m[1] === "### ") !== (kind === "R")) return null;
	if ((kind === "S" && sec !== "Sources") || (kind === "A" && sec !== AREAS)) return null;
	const name = kind === "R" ? m[3].replace(/^[^:]*: /, "") : kind === "C" ? m[3].replace(/:.*/, "") : m[3];
	return { id: m[2], name: trimEnd(name) };
};
// a line without the text it quotes from a policy or the intent
const unquoted = (t) => POLICY.test(t) ? t.replace(/".*/, "") : LEDGER.test(t) ? t.replace(/"[^"]*"/g, "") : t;
// a marker from its "(" to the matching ")", else to the end of the line
const marker = (t, at) => {
	let depth = 0;
	for (let i = at; i < t.length; i++) {
		depth += t[i] === "(" ? 1 : t[i] === ")" ? -1 : 0;
		if (!depth) return t.slice(at, i + 1);
	}
	return t.slice(at);
};
// the file an S line names: in backticks, else the first word with / or .ext
const firstPath = (t) => {
	const tick = t.match(/`([^`]+)`/);
	if (tick) return tick[1];
	const words = t.split(/[ \t]+/).map((w) => w.replace(/^[(`"]+|[.,;:)`"]+$/g, ""));
	return words.find((w) => w.includes("/") || /\.[a-z]+$/.test(w)) ?? "";
};

const lines = readLines(file);
const field = (k) => {
	const line = lines.find((l) => l.startsWith(`${k}:`)) ?? "";
	return trimEnd(line.replace(/^[^:]*:[ \t]*/, "").replaceAll("`", ""));
};
const dir = path.dirname(file);
const roots = [`${dir}/../..`, `${dir}/..`, dir, "."];
const findFile = (p) => {
	if (p.startsWith("/")) return isFile(p) ? p : "";
	return (p && roots.map((r) => `${r}/${p}`).find(isFile)) || "";
};
const texts = new Map();
const fileText = (f) => {
	if (!texts.has(f)) texts.set(f, squeeze(fs.readFileSync(f, "utf8").split("\n").join(" ")));
	return texts.get(f);
};

const intentName = field("Intent");
const intent = intentName && [
	`${dir}/../intents/${path.basename(intentName)}`,
	`${dir}/${intentName}`,
	`${dir}/../../${intentName}`,
].find((f) => isFile(f) && path.resolve(f) !== path.resolve(file));
const want = [];
let isec = "";
for (const l of intent ? readLines(intent) : []) {
	if (l.startsWith("## ")) isec = trimEnd(l);
	else if ((isec === "## Desired outcome" || isec === "## Open questions") && l.startsWith("- ")) {
		const s = squeeze(l.slice(2)).replace(/[ \t.]+$/, "");
		if (s !== "None") want.push(s);
	}
}
const oldName = field("Supersedes");
const old = oldName && isFile(`${dir}/${oldName}`) ? `${dir}/${oldName}` : "";
const oldIds = new Map();
for (const d of old ? readLines(old).map((l) => def(l, "")) : []) {
	if (d && "RC".includes(d.id[0])) oldIds.set(d.id[0] + d.name, d.id);
}

let fence = false, sec = "", tier = 0, area = "", req = null, status = null, ledger = "";
const defs = new Map(), qTier = new Map(), tierCount = [0, 0, 0], hasTier = [];
const areas = [], areaLine = new Map(), confirm = new Map(), quotes = [];
const sources = new Map(), refs = [], decidedBy = [], prose = [];
const endReq = () => {
	if (req && !req.scenario) fail(req.n, `${req.id} has no scenario: add a case under it`);
	req = null;
};
lines.forEach((text, i) => {
	const n = i + 1;
	if (text.startsWith("```")) {
		fence = !fence;
		return;
	}
	if (fence) return;
	if (text.startsWith("## ")) {
		endReq();
		sec = trimEnd(text.slice(3));
		area = "";
		return;
	}
	if (sec === "" && text.startsWith("Status:")) status = { n, text };
	if (sec === "Open questions" && text.startsWith("### ")) {
		tier = TIERS.indexOf(trimEnd(text.slice(4))) + 1;
		hasTier[tier] = true;
		return;
	}
	if (sec === "Requirements" && text.startsWith("- ") && req) req.scenario = true;
	if (sec === AREAS && /^(### |- )/.test(text)) area = "";
	const a = sec === AREAS && text.match(/^- (A[0-9]+)\. /);
	if (a) {
		area = a[1];
		areas.push(area);
		areaLine.set(area, n);
	}
	if (area && /^[ \t]+- Confirm in:/.test(text)) {
		confirm.set(area, { n, q: text.match(/(?<=[^A-Za-z0-9_])Q[0-9]+/)?.[0] });
	}
	if (area && POLICY.test(text)) quotes.push({ n, id: area, text });
	const s = sec === "Sources" && text.match(/^- (S[0-9]+)\. /);
	if (s) sources.set(s[1], firstPath(text.slice(2)));
	if (LEDGER.test(text)) ledger += `\n${squeeze(text.replace(/^- [A-Za-z]+ "/, ""))}`;
	const d = def(text, sec);
	if (d) {
		if (defs.has(d.id)) fail(n, `${d.id} is defined twice`);
		defs.set(d.id, { n, name: d.name });
	}
	if (d?.id[0] === "R") {
		endReq();
		req = { id: d.id, n, scenario: false };
	}
	if (d?.id[0] === "Q") {
		qTier.set(d.id, tier);
		tierCount[tier]++;
		if (!tier) fail(n, `${d.id} is under no tier: put it under "### ${TIERS[0]}" or "### ${TIERS[1]}"`);
	}
	// quoted text is not a reference
	for (const m of unquoted(text).matchAll(ID)) refs.push({ n, id: m[0] });
	if (sec !== "Sources" && !/^(Intent|Supersedes):/.test(text)) prose.push({ n, text: unquoted(text.replace(/[“”]/g, '"')) });
	for (const m of text.matchAll(/\(decided by\b/gi)) decidedBy.push({ n, text: marker(text, m.index) });
});
endReq();

if (!intent) fail(1, "Intent: line missing, or its file not found in ../intents/ or next to the spec");
if (oldName && !old) fail(1, `superseded spec not found next to this one: ${oldName}`);
const told = new Set();
for (const r of refs) {
	if (defs.has(r.id) || told.has(r.id)) continue;
	told.add(r.id);
	fail(r.n, `${r.id} is referenced but not defined`);
}
for (const { n, text } of decidedBy) {
	for (const q of text.matchAll(/(?<![A-Za-z0-9_])Q[0-9]+/g)) {
		if (qTier.has(q[0])) fail(n, `${q[0]} is an open question, so a (decided by …) marker cannot cite it`);
	}
	if (!oldName) {
		fail(n, `(decided by …) may cite only the spec this one supersedes, and this spec supersedes none; ${DROP}`);
	} else if (!text.includes(path.basename(oldName))) {
		fail(n, `(decided by …) may cite only the spec this one supersedes (${oldName}); ${DROP}`);
	}
}
for (const w of want) if (!ledger.includes(w)) fail(1, `From the intent: no Outcome or Question line quoting "${w}"`);
for (const [id, d] of defs) {
	const was = oldIds.get(id[0] + d.name);
	if (was && was !== id) fail(d.n, `${id} has the name of ${was} in the superseded spec; keep the old id`);
}
TIERS.forEach((t, i) => {
	if (!hasTier[i + 1]) {
		fail(1, `Open questions has no "### ${t}" heading; write "None." under it if it has no questions`);
	}
});
for (const id of areas) {
	const c = confirm.get(id);
	if (!c?.q) {
		const n = c?.n ?? areaLine.get(id);
		fail(n, `${id}'s Confirm in: names no question: give the Q<n> that asks its role to confirm it`);
	} else if (qTier.has(c.q) && qTier.get(c.q) !== 1) {
		fail(c.n, `${id} is confirmed in ${c.q}, which is not under "${TIERS[0]}"`);
	}
}
const counts = status?.text.match(/[0-9]+/g)?.map(Number) ?? [];
if (!status) fail(1, 'no "Status:" line');
else if (counts.length !== 2) {
	fail(status.n, TWO);
} else {
	TIERS.forEach((t, i) => {
		const listed = tierCount[i + 1];
		if (counts[i] !== listed) fail(status.n, `Status: says ${counts[i]} under "${t}", but it lists ${listed}`);
	});
}

// each quoted part of a Policy text: line is word for word in its S file; a quote cut at a colon goes on in the next
let stop = null;
const listCut = () => {
	if (stop) {
		const { n, id, sid } = stop;
		fail(n, `${id}: the quote from ${sid} stops before the list it leads into: ${LIST}`);
	}
	stop = null;
};
const checkQuotes = ({ n, id, text }) => {
	const parts = text.replace(/[“”]/g, '"').split('"');
	if (parts.length < 2) return;
	if (parts.length % 2 === 0) return fail(n, `${id}: a quote has no closing quote mark`);
	const sid = parts[0].match(/(?<![A-Za-z0-9_])S[0-9]+/)?.[0];
	if (!sid) return fail(n, `${id}: not verified: ${CITE}`);
	const p = sources.get(sid) ?? "";
	const f = findFile(p);
	const missing = p ? `${p} was not found` : "is not named under Sources";
	if (!f) return fail(n, `${id}: not verified: ${sid}'s file ${missing}; ${HAND}`);
	if (EXT.test(p) && !TEXT.test(p)) return fail(n, `${id}: not verified: ${p} is not a text file; ${HAND}`);
	const ft = fileText(f);
	for (let i = 1; i < parts.length - 1; i += 2) {
		const q = squeeze(parts[i]);
		if (!q) continue;
		const k = ft.indexOf(q);
		if (k === -1) {
			fail(n, `${id}: the text quoted from ${sid} is not word for word in ${p}: ${EXACT}`);
			continue;
		}
		if (stop) {
			const t = ft.slice(stop.at).replace(/^ ?:? ?/, "");
			const goesOn = t.startsWith(q) || t.replace(/^[0-9]+[.)] /, "").startsWith(q);
			if (stop.id !== id || stop.f !== f || !goesOn) listCut();
			stop = null;
		}
		const end = k + q.length;
		if (q.endsWith(":") || /^ ?:/.test(ft.slice(end, end + 2))) stop = { n, id, sid, f, at: end };
	}
};
quotes.forEach(checkQuotes);
listCut();

// code names in prose: a backtick span, or a path in the workspace
for (const { n, text } of prose) {
	const seen = new Set();
	for (const m of text.matchAll(/`([^`]+)`/g)) {
		if (!seen.has(m[1])) fail(n, `\`${m[1]}\` is in backticks, which mark code: ${PLAIN}`);
		seen.add(m[1]);
	}
	const rest = text.replace(/`[^`]+`/g, " ");
	for (const w of rest.match(/[\w.\/-]*[\w\/]/g) ?? []) {
		if (seen.has(w) || !/[A-Za-z]/.test(w) || !w.includes("/") || !roots.some((r) => fs.existsSync(`${r}/${w}`))) continue;
		seen.add(w);
		fail(n, `${w} is a path in the workspace: cite it as S<n> (Name), with the path under Sources`);
	}
}

for (const p of problems) console.log(p);
process.exit(problems.length ? 1 : 0);
