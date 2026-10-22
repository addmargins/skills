# addmargins skills

Claude Code skills by addmargins.

## Install

Run these in Claude Code:

```
/plugin marketplace add addmargins/skills
/plugin install addmargins@addmargins
```

Or from your shell:

```bash
claude plugin marketplace add addmargins/skills
claude plugin install addmargins@addmargins
```

## Update

Auto-update is off by default for marketplaces outside Anthropic's own. To turn it on, run `/plugin`, open the **Marketplaces** tab, select `addmargins`, and choose **Enable auto-update**.

To update manually:

```bash
claude plugin marketplace update addmargins
claude plugin update addmargins@addmargins
```

Restart Claude Code to apply an update.

## Skills

| Skill | What it does |
|---|---|
| `/clarify-intent <idea>` (or `/addmargins:clarify-intent` if another command takes the short name) | Turns a rough idea into a short intent document (problem, desired outcome, affected users and systems, scope and constraints, open questions) before any specification or implementation work. |
| `/write-spec <intent document>` (or `/addmargins:write-spec`) | Turns an accepted intent document into a spec that the originator, policy owners, engineers, and technical lead can all review: what to build, which design and policy constraints it must follow, and an open question for each undecided behavior or constraint, addressed to its owner. Saved as `docs/specs/NNNN-<slug>.md` beside the intent. |

## Repository structure

- `skills/engineering/<skill>/SKILL.md`: the skill definitions.
- `.claude-plugin/marketplace.json`: makes this repo a Claude Code plugin marketplace with one plugin, `addmargins`.

## Adding a skill

1. Create `skills/engineering/<name>/SKILL.md` and set `name: <name>` in its frontmatter, matching the directory name.
2. Run `claude plugin validate --strict .`. To check that the skill loads, add your local clone as a marketplace (`claude plugin marketplace add .`), install the plugin, and run `claude plugin details addmargins@addmargins`.
3. Push to `main`. Users get the change on their next update; no version bump is needed, because Claude Code tracks the commit.

## License

MIT
