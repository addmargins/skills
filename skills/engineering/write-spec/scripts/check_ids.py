"""Check the rule and question IDs in a spec written with the write-spec template.

Usage: python3 check_ids.py <spec.md>

Prints one line per problem and exits with status 1 if there is any. Otherwise
prints the counts, to compare with the spec's Status line. The checks rely on the
template's structure and markers, not on the spec's language.
"""

import re
import sys

ID = re.compile(r"(?<![A-Za-z0-9_\-./])([RQ]\d+)(?![0-9])")
RULE_DEF = re.compile(r"^[ \t]*-[ \t]+\**(R\d+)\.", re.M)
OPEN_Q_DEF = re.compile(r"^(#{3,4})[ \t]+(Q\d+)\.", re.M)
LOGGED_Q_DEF = re.compile(r"^[ \t]*-[ \t]+(Q\d+)[ \t]*\(", re.M)
FIELD = re.compile(r"^[ \t]*-[ \t]+\*\*", re.M)
MIN_FIELDS = 7  # unclear, what changes, what resolves, who answers, holds back, from, answer


def blank_code(text):
    """Replace code spans and fenced blocks with spaces, keeping offsets and lines."""
    def blank(match):
        return re.sub(r"[^\n]", " ", match.group(0))
    text = re.sub(r"^```.*?^```", blank, text, flags=re.M | re.S)
    return re.sub(r"`[^`\n]*`", blank, text)


def split_sections(text):
    """Return (start, end, title) for each '## ' section."""
    starts = [m.start() for m in re.finditer(r"^## ", text, re.M)]
    bounds = starts + [len(text)]
    return [
        (s, bounds[i + 1], text[s + 3:text.index("\n", s) if "\n" in text[s:] else len(text)].strip())
        for i, s in enumerate(starts)
    ]


def main(path):
    raw = open(path, encoding="utf-8").read()
    text = blank_code(raw)
    problems = []

    rule_defs = [(m.group(1), m.start(1)) for m in RULE_DEF.finditer(text)]
    open_defs = [(m.group(2), m.start(2), len(m.group(1))) for m in OPEN_Q_DEF.finditer(text)]
    logged_defs = [(m.group(1), m.start(1)) for m in LOGGED_Q_DEF.finditer(text)]
    def_positions = {pos for _, pos in rule_defs} | {pos for _, pos, _ in open_defs} | {pos for _, pos in logged_defs}

    defined = {"R": [i for i, _ in rule_defs], "Q": [i for i, _, _ in open_defs] + [i for i, _ in logged_defs]}
    mentions = [(m.group(1), m.start(1)) for m in ID.finditer(text)]

    for kind, ids in defined.items():
        for dup in sorted({i for i in ids if ids.count(i) > 1}, key=lambda s: int(s[1:])):
            problems.append(f"{dup} is defined more than once")
        for ref in sorted({i for i, _ in mentions if i[0] == kind} - set(ids), key=lambda s: int(s[1:])):
            problems.append(f"{ref} is mentioned but never defined")

    sections = split_sections(text)
    open_ids = [i for i, _, _ in open_defs]

    # Open questions: grouped under three class headings, each with its fields.
    blocking = []
    if open_defs:
        q_section = next(s for s in sections if s[0] <= open_defs[0][1] < s[1])
        body = text[q_section[0]:q_section[1]]
        classes = [m.start() + q_section[0] for m in re.finditer(r"^###[ \t]+(?!Q\d+\.)", body, re.M)]
        if len(classes) != 3 or any(level != 4 for _, _, level in open_defs):
            problems.append(
                "open questions should sit under exactly three class headings (### ) as #### Q<n>. headings"
            )
        elif len(classes) == 3:
            blocking = [i for i, pos, _ in open_defs if classes[0] < pos < classes[1]]
        heading_starts = sorted(m.start() for m in re.finditer(r"^#{1,4}[ \t]", text, re.M))
        for qid, pos, _ in open_defs:
            end = next((h for h in heading_starts if h > pos), len(text))
            fields = len(FIELD.findall(text[pos:end]))
            if fields < MIN_FIELDS:
                problems.append(f"{qid} has {fields} fields; it needs at least {MIN_FIELDS}, including an empty answer line")

    # Routing: the Reviewers table is the first section with a table, and the only index.
    first_q = open_defs[0][1] if open_defs else len(text)
    reviewers = next((s for s in sections if s[0] < first_q and re.search(r"^\|", text[s[0]:s[1]], re.M)), None)
    if reviewers is None and open_ids:
        problems.append("no Reviewers table found before the open questions")
    elif reviewers is not None:
        routed = {i for i, pos in mentions if i[0] == "Q" and reviewers[0] <= pos < reviewers[1]}
        for qid in open_ids:
            if qid not in routed:
                problems.append(f"{qid} is open but the Reviewers table doesn't route it to anyone")
        for qid in sorted(routed - set(open_ids), key=lambda s: int(s[1:])):
            problems.append(f"{qid} is in the Reviewers table but isn't an open question")

    # Short names: the first mention of an ID in each section carries its name, as in "Q3 (name)".
    for start, end, title in sections:
        seen = set()
        for ident, pos in mentions:
            if not start <= pos < end or pos in def_positions or ident in seen:
                continue
            seen.add(ident)
            after = text[pos + len(ident):pos + len(ident) + 3]
            if not re.match(r"[ \t]?\(", after):
                line = text.count("\n", 0, pos) + 1
                problems.append(f"line {line}: first mention of {ident} in '{title}' has no short name, as in '{ident} (name)'")

    for line in problems:
        print(line)
    if problems:
        return 1
    print(
        f"OK: {len(open_ids)} open questions ({len(blocking)} block planning), "
        f"{len(logged_defs)} answered, {len(rule_defs)} rules"
    )
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__.strip())
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
