# Fresh readers

Give each prompt below to its own subagent, with the paths filled in. Give each one only the files its prompt names: not this conversation, not your notes, and nothing else from the workspace. Run them at the same time. Each returns a list and edits nothing.

Fill in names and roles from the spec's Reviewers table. When the intent names no originator, the originator reader plays "the author of this intent". For the policy reader, pass the full text of every policy document you read, including those you found not applicable.

## Rounds

- A first draft's first round runs all three readers. Skip the policy reader only when you found no policy, privacy, security, compliance, or legal document at all, and say so.
- Wait for every reader in a round to return before you judge any finding.
- After you apply findings, check the edited file again (SKILL.md step 6, checks 1–4), then run the next round: a new implementer, plus each reader whose part changed. The originator's part is the Summary, Scope, How we will know it worked, and questions addressed to the originator or product owner. The policy reader's part is the Rules, Cases, Policies, and questions addressed to a policy owner. Stop after a round that yields nothing you apply, or after three rounds.
- On a revision that changes rules or cases, run at least one round: the implementer, plus the policy reader when a policy owner answered, and the originator when scope or an outcome changed.

## Judging findings

- If a source settles it, write or fix the rule, with the source.
- If no source settles it, add an open question, but only if it passes the check in SKILL.md step 4. Readers raise padding too.
- If nobody outside engineering would notice, list it under Left to engineering.
- If the spec already settles it, dismiss it. If the reader missed it because it was hard to find, move or rewrite it.

Note each finding and how it ended, for the report. Never resolve a finding by choosing behavior, or with a hedge such as "not yet confirmed" or "if this turns out to be X, ask Y". Each finding ends as a sourced rule, a question, a fact with a named confirmer, or a dismissal with its reason.

- A finding that needs a decision with a different owner or different consequences from an existing question becomes its own question. Widen an existing question only when the same owner decides it among the same options. A line such as "X must also be decided" inside a question, with no options of its own, is a new question.
- When a finding becomes a question, change every other sentence that already settles the point so it names the question instead.
- A case row you add gets a result only when the rules it cites compute it.
- When the policy reader says a row settles how a policy's words are read, give the row's result under each reading and name the question, or quote the words that allow only one reading.
- When the originator reader reports something dropped or narrowed, restore the intent's wording or ask the originator.

## Implementer

You will build what this specification describes. You have only this file. You can't ask anyone, and you can't read the intent, the policies, or the code it cites.

Read the spec at `<spec path>`. List every point where, to build it, you would have to decide on your own:

- how the product behaves in some situation,
- what a person sees or is told,
- a number, limit, date, or condition,
- or how to apply a policy.

For each point, quote the sentence or name the step, rule, or case it comes from, and say what you would have to decide. Leave out choices that nobody outside engineering would notice, such as code structure or storage. Leave out points the spec already marks as open questions, unless the question is missing something you would need. If there are none, write "none".

## Originator

You are `<name>`, `<role>`. You wrote the intent document that this specification answers. You don't read code. You have two files and nothing else: your intent at `<intent path>` and the spec at `<spec path>`.

1. List every item in your intent, such as the problem, a desired outcome, a scope line, a constraint, or an open question, that the spec drops, narrows, or changes without asking you. Include any option you named that is missing from the spec's questions.
2. List every sentence outside the facts-and-sources section that you can't understand, or can't check, without help from an engineer. Quote it and say what is in the way.
3. For each open question addressed to you, say whether you could answer it from the question alone. If not, say what is missing.
4. Say whether you could tell, within a minute of opening the spec, which parts you need to review.

## Policy reader

You review this specification for the people who own the company's policies. You don't read code. You have the spec at `<spec path>` and these policy documents: `<policy paths>`. Nothing else.

1. List each policy clause the spec quotes or cites wrongly, and each clause that applies to this work but that the spec doesn't mention.
2. List each conflict between two policies, or between a policy and the spec, that the spec doesn't raise as an open question.
3. List each place where the spec, including a worked example, settles how a policy's words are read when they could be read another way.
4. List each applicable clause that has no case and no named review to check it.
5. For each open question addressed to a policy owner, say whether that owner could answer it from the question alone. If not, say what is missing.
