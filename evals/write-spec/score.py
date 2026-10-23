#!/usr/bin/env python3
"""Script-graded checks for write-spec test runs (Python 3, standard library only).

Usage:
  python3 -I score.py ids     <spec.md>
  python3 -I score.py 3parts  <spec.md>
  python3 -I score.py leak    <spec.md>
  python3 -I score.py paths   <spec.md> <repo_dir>
  python3 -I score.py draft   <run.jsonl> <spec_rel_path>
  python3 -I score.py readers <run.jsonl>

Each check prints one JSON object to stdout:
  {"check": <name>, "pass": <bool>, "details": [<dict>, ...]}
Exit status is 0 when the check ran (whatever the verdict), 2 on bad usage.

ids      details: one item per sub-check (defined_once, mentions_defined,
         reviewers_match_open, status_counts), then a "stats" item
         (counts per class, blocking share, rules, lines, bytes).
3parts   details: one item per open question: labels found and problems.
leak     details: one item per finding {line, section, kind, text};
         kind is backtick | path | identifier | word | code_block.
paths    details: a "commit" item, then one item per backticked span in
         Facts and sources: ok | missing | skipped (not path-like and absent).
draft    details: one item describing the first top-level Write of the spec;
         the content is saved as draft-<basename> next to the jsonl.
         pass = found and written before the first Agent/Task call (or
         no such call exists).
readers  details: a "summary" item (rounds, calls per round), then one
         item per top-level Agent/Task call. pass = at least one call and
         no reader prompt names a code path.
"""

import json
import os
import re
import subprocess
import sys
from collections import Counter, OrderedDict

# ---------------------------------------------------------------- helpers

W = r"A-Za-z0-9_"
NB = r"(?<![%s])" % W          # ASCII word boundary before (Korean-safe)
NA = r"(?![%s])" % W           # ASCII word boundary after

HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")
FENCE = re.compile(r"^\s*(```|~~~)")
BACKTICK = re.compile(r"(`+)(.+?)\1")
# Q/R mention, optionally a range such as R10–R12 or Q3-5.
ID_MENTION = re.compile(
    NB + r"([QR])(\d+)" + NA + r"(?:\s*[–—-]\s*\1?(\d+)" + NA + r")?")
Q_HEADING = re.compile(r"^####\s+Q(\d+)\.")
R_BULLET = re.compile(r"^\s*[-*]\s+R(\d+)\.")
DECISION_Q = re.compile(r"^\s*[-*]\s+Q(\d+)\s*\(")
FIELD = re.compile(r"^( ?)[-*]\s+\*\*(.+?)\*\*\s*(.*)$")

FACTS_TITLE = re.compile(r"^(facts and sources|사실과 출처)\b", re.I)
OPEN_Q_TITLE = re.compile(r"^(open questions|미결 질문|열린 질문)\b", re.I)
DECISION_TITLE = re.compile(r"^(decision log|결정 기록)\b", re.I)
STATUS_LINE = re.compile(r"^\s*(?:\*\*)?(?:Status|상태)(?:\*\*)?\s*:(.*)$")
INTENT_LINE = re.compile(r"^\s*(?:\*\*)?Intent(?:\*\*)?\s*:")

CODE_DIRS = ("src", "services", "apps", "packages", "lib", "libs", "app",
             "admin", "config", "test", "tests", "scripts", "cmd", "pkg",
             "internal", "migrations", "server", "client", "modules",
             "components")
PATH_PREFIXES = tuple(d + "/" for d in CODE_DIRS
                      if d not in ("server", "client", "modules",
                                   "components")) + (
    "docs/", ".claude/", ".github/")
CODE_EXTS = {"ts", "tsx", "js", "jsx", "mjs", "cjs", "py", "rb", "go", "rs",
             "java", "kt", "kts", "swift", "c", "h", "cc", "cpp", "hpp", "cs",
             "php", "scala", "sql", "sh", "bash", "yaml", "yml", "json",
             "toml", "ini", "xml", "html", "css", "scss", "vue", "svelte",
             "prisma", "graphql", "gql", "proto", "gradle", "env", "lock",
             "cfg", "conf", "tf", "ex", "exs", "erl", "dart", "lua", "pl"}
EXT_SEG = re.compile(r"\.[A-Za-z][A-Za-z0-9]{0,7}$")
PATH_TOKEN = re.compile(r"[A-Za-z0-9_./~@+-]*/[A-Za-z0-9_./~@+-]*")
CAMEL = re.compile(NB + r"[a-z][a-z0-9]*[A-Z][A-Za-z0-9]*" + NA)
SNAKE = re.compile(NB + r"[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)+" + NA)
CAMEL_OK = {"iPhone", "iPad", "iPod", "iOS", "iPadOS", "macOS", "watchOS",
            "tvOS", "visionOS", "eBay", "iCloud", "iTunes", "kWh", "mAh",
            "kB", "mL", "dB", "pH", "eSIM", "eID"}
LEAK_WORDS = [
    ("write-spec", re.compile(r"write-spec", re.I)),
    ("SKILL", re.compile(r"SKILL")),
    ("fresh reader", re.compile(r"fresh[\s-]+reader", re.I)),
    ("workspace", re.compile(NB + r"workspace" + NA, re.I)),
]


def emit(check, ok, details):
    out = json.dumps({"check": check, "pass": bool(ok), "details": details},
                     ensure_ascii=False, indent=1)
    sys.stdout.buffer.write(out.encode("utf-8") + b"\n")


def read_spec(path):
    with open(path, "rb") as f:
        raw = f.read()
    text = raw.decode("utf-8")
    return raw, text.splitlines()


def annotate(lines):
    """Per line: (lineno, text, in_fence, h2 title, heading level or 0)."""
    out, in_fence, h2 = [], False, ""
    for i, line in enumerate(lines, 1):
        if FENCE.match(line):
            out.append((i, line, True, h2, 0))
            in_fence = not in_fence
            continue
        level = 0
        if not in_fence:
            m = HEADING.match(line)
            if m:
                level = len(m.group(1))
                if level == 2:
                    h2 = m.group(2).strip()
        out.append((i, line, in_fence, h2, level))
    return out


def section_lines(ann, title_re):
    """Lines belonging to the first ## section whose title matches."""
    return [a for a in ann if a[3] and title_re.match(a[3])]


def id_mentions(line):
    """Yield (kind, number) for every Q/R mention, expanding ranges."""
    for m in ID_MENTION.finditer(line):
        kind, a = m.group(1), int(m.group(2))
        b = int(m.group(3)) if m.group(3) else a
        if b < a or b - a > 50:
            b = a
        for n in range(a, b + 1):
            yield kind, n


def fmt(ids):
    return ["%s%d" % k for k in sorted(ids, key=lambda k: (k[0], k[1]))]


def looks_like_path(tok):
    """A path for the leak check: has / and a .ext, or a code-dir prefix."""
    if "/" not in tok:
        return False
    if any(EXT_SEG.search(seg) for seg in tok.split("/") if seg):
        return True
    t = tok[2:] if tok.startswith("./") else tok.lstrip("/")
    return t.startswith(PATH_PREFIXES) and len(t.split("/", 1)[1]) > 0


def clean_token(tok):
    return tok.rstrip(".,;:)!?'\"").lstrip("(\"'")


# ---------------------------------------------------------------- ids

def check_ids(spec):
    raw, lines = read_spec(spec)
    ann = annotate(lines)
    defs = Counter()
    def_lines = {}
    open_ids, classes, outside_open = [], OrderedDict(), []
    cur_class = None
    for n, line, fence, h2, level in ann:
        if fence:
            continue
        in_open = bool(h2) and OPEN_Q_TITLE.match(h2)
        if in_open and level == 3:
            cur_class = HEADING.match(line).group(2).strip()
            classes.setdefault(cur_class, 0)
        m = Q_HEADING.match(line)
        if m:
            k = ("Q", int(m.group(1)))
            defs[k] += 1
            def_lines.setdefault(k, []).append(n)
            if in_open:
                open_ids.append(k)
                key = cur_class if cur_class is not None else "(no class)"
                classes[key] = classes.get(key, 0) + 1
            else:
                outside_open.append(fmt([k])[0])
        m = R_BULLET.match(line)
        if m:
            k = ("R", int(m.group(1)))
            defs[k] += 1
            def_lines.setdefault(k, []).append(n)
        if h2 and DECISION_TITLE.match(h2):
            m = DECISION_Q.match(line)
            if m:
                k = ("Q", int(m.group(1)))
                defs[k] += 1
                def_lines.setdefault(k, []).append(n)

    details = []
    dups = {fmt([k])[0]: def_lines[k] for k, c in defs.items() if c > 1}
    details.append({"name": "defined_once", "pass": not dups,
                    "duplicates": dups})

    undefined = OrderedDict()
    for n, line, fence, h2, level in ann:
        for k in id_mentions(line):
            if k not in defs:
                undefined.setdefault(fmt([k])[0], []).append(n)
    details.append({"name": "mentions_defined", "pass": not undefined,
                    "undefined": undefined})

    # Reviewers table: first ## section before Open questions with a table.
    table_ids, table_section = set(), None
    order = []
    for n, line, fence, h2, level in ann:
        if h2 and (not order or order[-1] != h2):
            order.append(h2)
    for title in order:
        if OPEN_Q_TITLE.match(title):
            break
        sec = [a for a in ann if a[3] == title and not a[2]]
        is_row = [a[1].lstrip().startswith("|") for a in sec]
        if any(is_row):
            table_section = title
            start = is_row.index(True)
            for a, row in zip(sec[start:], is_row[start:]):
                if not row:
                    break  # first contiguous table only
                table_ids.update(k for k in id_mentions(a[1]) if k[0] == "Q")
            break
    open_set = set(open_ids)
    missing = fmt(open_set - table_ids)
    extra = fmt(table_ids - open_set)
    ok_rev = table_section is not None and not missing and not extra
    details.append({"name": "reviewers_match_open", "pass": ok_rev,
                    "table_section": table_section,
                    "open_not_in_table": missing,
                    "in_table_not_open": extra})

    status_line = next((a[1] for a in ann if STATUS_LINE.match(a[1])), None)
    first_class = next(iter(classes.values()), 0) if classes else 0
    actual = [len(open_ids), first_class]
    if status_line is None:
        ok_status, nums, note = False, [], "no Status line"
    else:
        body = re.sub(r"\d{4}-\d{2}-\d{2}", "",
                      STATUS_LINE.match(status_line).group(1))
        nums = [int(x) for x in re.findall(r"\d+", body)][:2]
        if len(nums) == 2:
            ok_status, note = nums == actual, ""
        elif "Accepted" in status_line and first_class == 0:
            ok_status, note = True, "Accepted with no counts; nothing blocks"
        else:
            ok_status, note = False, "Status line has no two counts"
    details.append({"name": "status_counts", "pass": ok_status,
                    "status_line": status_line, "status_numbers": nums,
                    "actual_open_and_first_class": actual, "note": note})

    total = len(open_ids)
    details.append({
        "name": "stats",
        "open_questions": total,
        "per_class": classes,
        "first_class": next(iter(classes), None),
        "blocking_share": round(first_class / total, 3) if total else None,
        "q_headings_outside_open_questions": outside_open,
        "decision_log_entries": sum(1 for a in ann if a[3]
                                    and DECISION_TITLE.match(a[3])
                                    and DECISION_Q.match(a[1])),
        "rules": len({k for k in defs if k[0] == "R"}),
        "lines": len(lines),
        "bytes": len(raw),
    })
    ok = all(d.get("pass", True) for d in details)
    emit("ids", ok, details)


# ---------------------------------------------------------------- 3parts

def question_blocks(ann):
    """Yield (qid, [(lineno, text)]) for each #### Qn. in Open questions."""
    cur, buf = None, []
    for n, line, fence, h2, level in ann:
        if level and not fence:
            if cur:
                yield cur, buf
                cur, buf = None, []
            m = Q_HEADING.match(line)
            if m and h2 and OPEN_Q_TITLE.match(h2):
                cur = "Q" + m.group(1)
            continue
        if cur:
            buf.append((n, line))
    if cur:
        yield cur, buf


def norm_label(label):
    return label.strip().rstrip(":：?？ ").strip()


def check_3parts(spec):
    _, lines = read_spec(spec)
    ann = annotate(lines)
    details, ok = [], True
    for qid, block in question_blocks(ann):
        fields = []  # [label, content parts]
        for n, line in block:
            m = FIELD.match(line)
            if m:
                content = re.sub(r"^[:：]\s*", "", m.group(3)).strip()
                fields.append([m.group(2), [content] if content else [], n])
            elif fields and line.strip():
                fields[-1][1].append(line.strip())
        labels = [norm_label(f[0]) for f in fields]
        problems = []
        if len(fields) < 3:
            problems.append("only %d bold-labelled fields" % len(fields))
        for i, f in enumerate(fields[:3]):
            if not f[1]:
                problems.append("part %d (%s) is empty" % (i + 1, labels[i]))
        if len(fields) < 4:
            problems.append("no 4th field (Holds back / 막는 것)")
        elif not re.match(r"^(holds back|막는 것)", labels[3], re.I):
            problems.append("4th field is '%s', not Holds back / 막는 것"
                            % labels[3])
        if len(fields) < 5 or not re.match(r"^(answer|답변)", labels[-1],
                                            re.I):
            problems.append("last field is '%s', not Answer / 답변"
                            % (labels[-1] if labels else ""))
        item = {"id": qid, "pass": not problems, "labels": labels,
                "problems": problems}
        if len(fields) >= 4 and not fields[3][1]:
            item["holds_back_empty"] = True
        details.append(item)
        ok = ok and not problems
    if not details:
        details.append({"note": "no open questions found"})
    emit("3parts", ok, details)


# ---------------------------------------------------------------- leak

def check_leak(spec):
    _, lines = read_spec(spec)
    ann = annotate(lines)
    found = []

    def add(n, h2, kind, text):
        found.append({"line": n, "section": h2, "kind": kind, "text": text})

    for n, line, fence, h2, level in ann:
        if INTENT_LINE.match(line):
            continue
        for word, rx in LEAK_WORDS:
            for m in rx.finditer(line):
                add(n, h2, "word", m.group(0))
        if h2 and FACTS_TITLE.match(h2):
            continue
        if fence:
            if FENCE.match(line) and not (found and found[-1]["kind"]
                                          == "code_block"
                                          and found[-1].get("open")):
                add(n, h2, "code_block", line.strip())
                found[-1]["open"] = True
            elif FENCE.match(line):
                found[-1].pop("open", None)
            continue
        masked = line
        for m in BACKTICK.finditer(line):
            add(n, h2, "backtick", m.group(2))
            masked = masked[:m.start()] + " " * (m.end() - m.start()) \
                + masked[m.end():]
        for m in PATH_TOKEN.finditer(masked):
            if m.start() > 0 and masked[m.start() - 1] == ":":
                continue  # URL such as https://...
            tok = clean_token(m.group(0))
            if "://" in tok:
                continue
            if looks_like_path(tok):
                add(n, h2, "path", tok)
                masked = masked[:m.start()] + " " * (m.end() - m.start()) \
                    + masked[m.end():]
        for rx in (CAMEL, SNAKE):
            for m in rx.finditer(masked):
                if m.group(0) not in CAMEL_OK:
                    add(n, h2, "identifier", m.group(0))
    for f in found:
        f.pop("open", None)
    found.sort(key=lambda f: f["line"])
    emit("leak", not found, found)


# ---------------------------------------------------------------- paths

LINE_SUFFIX = re.compile(r"(?:#L\d+(?:-L?\d+)?|(?::\d+(?:[-–]\d+)?)+)$")


def git(repo, *args):
    return subprocess.run(["git", "-C", repo] + list(args),
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                          universal_newlines=True)


def check_paths(spec, repo):
    _, lines = read_spec(spec)
    ann = annotate(lines)
    facts = section_lines(ann, FACTS_TITLE)
    r = git(repo, "rev-list", "--max-parents=0", "HEAD")
    roots = r.stdout.split()
    if r.returncode != 0 or not roots:
        emit("paths", False, [{"error": "no root commit",
                               "stderr": r.stderr.strip()}])
        return
    commit = roots[-1]
    details = [{"commit": commit, "roots": roots,
                "facts_section_found": bool(facts)}]
    spans = OrderedDict()
    for n, line, fence, h2, level in facts:
        for m in BACKTICK.finditer(line):
            spans.setdefault(m.group(2).strip(), []).append(n)
    repo_abs = os.path.abspath(repo).rstrip("/") + "/"
    ok = bool(facts)
    for rawspan, where in spans.items():
        p = LINE_SUFFIX.sub("", rawspan)
        if p.startswith(repo_abs):
            p = p[len(repo_abs):]
        while p.startswith("./"):
            p = p[2:]
        p = p.rstrip("/")
        pathlike = (("/" in rawspan or bool(EXT_SEG.search(p)))
                    and not re.search(r"[\s\"'*]", rawspan))
        exists = bool(p) and git(repo, "cat-file", "-e",
                                 "%s:%s" % (commit, p)).returncode == 0
        status = "ok" if exists else ("missing" if pathlike else "skipped")
        if status == "missing":
            ok = False
        details.append({"span": rawspan, "path": p, "status": status,
                        "lines": where})
    emit("paths", ok, details)


# ---------------------------------------------------------------- transcripts

def load_events(path):
    events, bad = [], 0
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                ev = json.loads(line)
            except ValueError:
                bad += 1
                continue
            if isinstance(ev, dict):
                events.append(ev)
    return events, bad


def session_id(events):
    for ev in events:
        if ev.get("type") == "system" and ev.get("subtype") == "init" \
                and ev.get("session_id"):
            return ev["session_id"]
    for ev in events:
        if ev.get("type") == "result" and ev.get("session_id"):
            return ev["session_id"]
    return None


def tool_uses(events):
    """All tool_use items in order: dicts with top, msg, item. Deduped."""
    seen, out = set(), []
    for i, ev in enumerate(events):
        if ev.get("type") != "assistant":
            continue
        msg = ev.get("message") or {}
        content = msg.get("content")
        if not isinstance(content, list):
            continue
        for c in content:
            if not isinstance(c, dict) or c.get("type") != "tool_use":
                continue
            tid = c.get("id")
            if tid and tid in seen:
                continue
            seen.add(tid)
            out.append({"top": not ev.get("parent_tool_use_id"),
                        "msg": msg.get("id") or ev.get("uuid") or i,
                        "item": c})
    return out


def is_agent(item):
    return item.get("name") in ("Agent", "Task")


def check_draft(jsonl, rel):
    events, bad = load_events(jsonl)
    rel = rel.replace("\\", "/")
    while rel.startswith("./"):
        rel = rel[2:]
    calls = tool_uses(events)
    top = [c for c in calls if c["top"]]
    first_agent = next((i for i, c in enumerate(top)
                        if is_agent(c["item"])), None)
    def to_spec(c):
        fp = str((c["item"].get("input") or {}).get("file_path", ""))
        fp = fp.replace("\\", "/")
        return fp == rel or fp.endswith("/" + rel)

    hit = next((c for c in top if c["item"].get("name") == "Write"
                and to_spec(c)), None)
    sub_writes = sum(1 for c in calls if not c["top"] and to_spec(c)
                     and c["item"].get("name") in ("Write", "Edit",
                                                   "MultiEdit"))
    base = {"session_id": session_id(events), "bad_lines": bad,
            "top_level_tool_calls": len(top),
            "first_agent_index": first_agent,
            "subagent_writes_to_spec": sub_writes}
    if hit is None:
        base.update({"found": False})
        emit("draft", False, [base])
        return
    content = str(hit["item"]["input"].get("content", ""))
    out = os.path.join(os.path.dirname(os.path.abspath(jsonl)),
                       "draft-" + os.path.basename(rel))
    with open(out, "w", encoding="utf-8") as f:
        f.write(content)
    idx = next((i for i, c in enumerate(top) if c is hit), None)
    rel_idx = (idx - first_agent) if (idx is not None
                                      and first_agent is not None) else None
    base.update({
        "found": True,
        "saved": out,
        "file_path": hit["item"]["input"].get("file_path"),
        "tool_call_index": idx,
        "index_relative_to_first_agent": rel_idx,
        "before_first_agent": (rel_idx < 0) if rel_idx is not None else None,
        "bytes": len(content.encode("utf-8")),
        "lines": len(content.splitlines()),
    })
    ok = rel_idx is None or rel_idx < 0
    emit("draft", ok, [base])


PROMPT_PATH = re.compile(r"(?<![A-Za-z0-9_./~@+-])[A-Za-z0-9_./~@+-]*/"
                         r"[A-Za-z0-9_./~@+-]*")


def prompt_paths(text):
    out = []
    for m in PROMPT_PATH.finditer(text):
        if m.start() > 0 and text[m.start() - 1] == ":":
            continue  # URL
        tok = clean_token(m.group(0))
        if "/" not in tok or "://" in tok:
            continue
        last = tok.rstrip("/").rsplit("/", 1)[-1]
        if (EXT_SEG.search(last) or tok.startswith(("/", "./", "../", "~/"))
                or tok.startswith(PATH_PREFIXES)):
            if tok not in out:
                out.append(tok)
    return out


def is_code_path(p):
    segs = [s for s in p.split("/") if s]
    if "docs" in segs:
        return False
    m = EXT_SEG.search(segs[-1]) if segs else None
    if m:
        return m.group(0)[1:].lower() in CODE_EXTS
    return any(s in CODE_DIRS for s in segs)


def check_readers(jsonl):
    events, bad = load_events(jsonl)
    top = [c for c in tool_uses(events) if c["top"]]
    rounds, cur, last_msg, round_open = [], None, None, False
    details_calls = []
    for idx, c in enumerate(top):
        it = c["item"]
        if not is_agent(it):
            round_open = False
            continue
        if not (round_open or (cur is not None and c["msg"] == last_msg)):
            cur = []
            rounds.append(cur)
        round_open, last_msg = True, c["msg"]
        cur.append(idx)
        inp = it.get("input") or {}
        prompt = str(inp.get("prompt", ""))
        paths = prompt_paths(prompt)
        code = [p for p in paths if is_code_path(p)]
        details_calls.append({
            "kind": "call",
            "round": len(rounds),
            "tool_call_index": idx,
            "tool": it.get("name"),
            "description": inp.get("description"),
            "subagent_type": inp.get("subagent_type"),
            "prompt_len": len(prompt),
            "paths": paths,
            "mentions_intents": "docs/intents/" in prompt,
            "mentions_policies": "docs/policies/" in prompt,
            "mentions_code": bool(code),
            "code_paths": code,
        })
    summary = {"kind": "summary", "session_id": session_id(events),
               "bad_lines": bad, "calls": len(details_calls),
               "rounds": len(rounds),
               "calls_per_round": [len(r) for r in rounds]}
    ok = bool(details_calls) and not any(d["mentions_code"]
                                         for d in details_calls)
    emit("readers", ok, [summary] + details_calls)


# ---------------------------------------------------------------- main

CHECKS = {
    "ids": (check_ids, 1),
    "3parts": (check_3parts, 1),
    "leak": (check_leak, 1),
    "paths": (check_paths, 2),
    "draft": (check_draft, 2),
    "readers": (check_readers, 1),
}


def main(argv):
    if len(argv) < 2 or argv[1] not in CHECKS \
            or len(argv) - 2 != CHECKS[argv[1]][1]:
        sys.stderr.write(__doc__.split("\n\n")[1] + "\n")
        return 2
    fn, _ = CHECKS[argv[1]]
    fn(*argv[2:])
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
