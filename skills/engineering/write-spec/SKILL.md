---
name: write-spec
description: Turn an accepted intent document into a specification that its originator, policy owners, engineers, and technical lead can all review. The spec states what to build and which design and policy constraints the work must follow. It leaves every product behavior or constraint that nobody has decided as an open question, addressed to the person who owns it. Use after clarify-intent and before any implementation plan.
argument-hint: <intent document>
disable-model-invocation: true
---

# Write Spec

Turn an accepted intent document into a specification (spec): what must be built, and which design and policy constraints the work must follow. Four kinds of reviewer read it: the originator who wrote the intent, the policy owners, the engineers, and the technical lead. Most of them don't read code. Each must be able to check their own part without asking an engineer what a sentence means. Engineers plan against the spec once a person accepts it.

Hold the spec to one test. Would someone working only from this spec have to decide, on their own, a product behavior or a constraint that nobody has decided yet? Each place where the answer is yes becomes an open question addressed to the person who can answer it. The value is in the decisions the spec exposes and routes to the right people, not in its length.

## Principles

- **Settle nothing that isn't settled.** A statement becomes a rule, a step, or a case result only when a source settles it. The sources are the intent, a policy clause whose words allow one reading, an answer recorded from the person who owns the question, or a derivation (step 4). Anything you inferred is a recommendation, however obvious it seems, and a recommendation lives only inside an open question. Readers treat everything outside the open questions as decided. So a default you pick reaches the code, and its owner never learns it was theirs to decide.
- **Facts are yours to find.** How the system behaves today, what a policy says, how many steps a flow takes, and what data exists are facts. Read the workspace for them instead of asking anyone. Separate what you verified from what a document or a code comment claims. A fact you could read only in a comment stays marked as claimed, however confident you are, and names who will confirm it.
- **Decisions belong to their owners.** The product owner decides product behavior and scope, and the originator says whether the spec solves their problem. Each policy owner decides what their policy requires, including how its words are read. A conflict between two policies belongs to both owners, and the product owner routes it. To tell a decision from a technical choice, ask whether a customer, a staff member, a policy owner, or the originator would notice which option was chosen. If they would and no source settles it, it is an open question.
- **What, not how.** The spec states observable behavior, the rules it must follow, and how reviewers will check it. Module structure, schemas, API shapes, file changes, and test layout belong to the implementation plan. Engineers write that plan after the spec is accepted. A limit of an existing system that changes what people experience is a constraint, so state it in plain words. A partner club's booking system that accepts changes only up to 24 hours ahead is one. List the choices you leave to engineers on purpose, so reviewers don't mistake them for gaps. The copy and layout of screens that customers see, or that a policy regulates, are not engineering choices. If nobody is named to design them, ask the product owner.
- **Write for the least technical reviewer.** A policy owner must be able to judge each rule and answer each question without reading code. Say each thing once, in the section the template gives it, and refer to it elsewhere by its ID.

## Workflow

### 1. Find the intent

Take the intent document from the invocation arguments. If there is none, list each `docs/intents/` in the workspace and ask which document to use, as a choice question with one option per intent: its path and title. Leave out an intent marked `Superseded by:`, or label it as superseded. A choice question is the question, then lettered options, one per line, each with what it means, and a line saying the user may answer in their own words. If the document is marked `Superseded by:`, use the one it names, and say so. If the intent you use has a `Supersedes:` line and the intent it replaces already has a spec, write a new spec and follow the superseding rule in [references/revising.md](references/revising.md).

Then check these, in this order:

- **Is there something to specify?** If the intent states no problem, or no desired outcome a reader could check, stop without writing a file. Say what is missing and suggest the `clarify-intent` skill. Every rule traces back to the outcome, so a spec built on a guessed outcome traces to nothing. Write a spec for any other thin intent: its gaps become open questions.
- **Does a spec for it already exist?** Look for a file of the same name in the `docs/specs/` beside the intent's `docs/intents/`. If one exists, revise it as [references/revising.md](references/revising.md) describes, unless the user asks for a new one.
- **Is it one piece of work?** If the intent holds outcomes that could each be delivered on their own, ask which one this spec covers, unless none is useful without the others. If no one can answer now, make the split the first open question that blocks planning, addressed to the originator.

Ask nothing else before saving. Most open questions in a spec belong to people who aren't in this conversation, such as a policy owner or the technical lead. An answer the user gives on their behalf is a guess that looks like a decision. A question asked before its options and consequences are written out also gets answered cold. If the user states a decision that is theirs to make anyway, record it with their name and the date.

### 2. Read the ground

Read the whole intent and list every item in it: the problem, each desired outcome, each affected group and system, each scope line, each constraint with its reason, and each open question. Step 6 checks that each one landed somewhere.

Then read everything that constrains the behavior it asks for. Note each fact with its source as you go.

- **Policies.** Read every policy document in the workspace, such as those in `docs/policies/`. If there is no such folder, search file and folder names, documentation sites included, for policy, privacy, security, compliance, legal, and terms. `CLAUDE.md`, `AGENTS.md`, and other contributor guides are engineering conventions. Cite one only where it states a product, privacy, security, or compliance requirement, and never treat a skill as a policy. Read each candidate in full, not only the ones the intent cites, because a skipped clause is a missed constraint. Note each policy's owner, as the document names them.
- **The systems the intent names.** Read the code and documents behind them, and the paths the new behavior will run through. Look for what happens today, what data exists, the contracts of outside services, and the existing paths the change must keep. You are reading for facts and limits, not to design the change. For each fact, note whether you verified it in code or read it in a comment or document. Also note what you searched for and didn't find, and how a number that matters but is missing could be measured. Record the commit you read (`git rev-parse --short HEAD`), or the date if the workspace isn't a git repository.

### 3. Walk the change and sweep for undecided points

Walk the main path as the person who uses it: what they see, what they do, what happens next. Then walk it as each staff role and each system that records or pays something. At every step, ask whether someone building this would have to decide behavior or a constraint here.

Most gaps hide in the same places. Check each one:

- **Who qualifies.** Check also whether the system can tell those people apart, such as a guest, a member of a partner club, or a staff account. Also check accounts in a state the intent sends down another path, such as a dispute. When a policy limits who may do something, whom the system would let in, including through a broad grant, is a fact; whether the policy lets them in is a question for its owner.
- **Boundaries.** Whether a limit is inclusive, how a number rounds, whether counting starts at day 0 or day 1, month ends, and time zones.
- **What came before.** Renewals, earlier periods, earlier partial actions or refunds on the same payment, and prices that changed since purchase. For every amount, say at which moment each input is taken.
- **Values from other records.** Whether a name, status, or price shows as it is now or as it was at the event, and what shows when it is missing.
- **Timing and state.** When the change takes effect, what happens to anything already scheduled, such as the next charge or renewal, what state things are in meanwhile, and whether each person who can trigger the change can undo it.
- **Repeats.** A second press, a second attempt after a failure, or two paths acting on the same thing.
- **Failures.** An outside service refuses, a limit is reached, or an approval never comes. No failure may leave money or data in a state nobody sees.
- **What people are told.** Before they commit, while something waits, and after.
- **Records the change creates.** What is kept, for how long, and who can see it.
- **The edges of scope.** People or channels the scope excludes who will still reach the new behavior, or whom a policy still covers.

Then look for conflicts: between two policies, between a policy and the intent, and between the intent or a policy and a fact about the existing system. For each one, check whether some behavior satisfies both sides. If one does, state the constraint and show that it can be met. If none does, or if meeting both depends on how an owner reads their policy, write an open question for the owners on both sides, routed by the product owner. Show the count, the arithmetic, or the screen-by-screen walk that proves the conflict. Don't choose which side wins, and don't soften either side to make them fit.

A policy clause's words may allow two readings that change an outcome. When they do, state as a rule only what both readings share, and ask the policy owner about the difference. A worked example computed under one reading settles the question just as a rule would.

Carry every open question in the intent forward. When a source seems to answer one, quote it, and still ask the person the intent named to confirm. Confirming then takes a yes or a no. Keep every option the intent itself names, even one you think conflicts with something, and state its consequence instead.

It fails like this: the spec restates each booking-policy clause as a rule, but never asks what happens to a member who cancels a partner-club court two hours before the slot. By then the partner club's system no longer accepts changes. Every rule has a source, and the builder still decides the two-hour behavior alone.

### 4. Sort each undecided point

- **A fact you can find.** Go back to the workspace. Don't ask anyone.
- **A choice nobody outside engineering would notice**, such as code structure, storage, or retry timing. List it under Left to engineering, with the rules it must respect.
- **Anything else.** Write it as an open question for its owner (step 5).

Before you write a question, check that its answer would change something a reviewer would accept or reject. Leave it out in these cases:

- **Every option already meets the rules and checks the reviewers set, and nobody outside engineering has a reason to prefer one.** List the choice under Left to engineering, together with the check that bounds it. An example is "any image format for the stored receipt photo, as long as finance can open it at full size (case 3)".
- **The plain words of the intent or a policy already answer it**, with no other reasonable reading of the words or of the things they apply to. State the answer as a rule with its source instead. An answer that rests on a term the workspace doesn't define, such as what a "no-show" means, still needs the question. This doesn't apply to questions carried over from the intent, which step 3 keeps open until their named person confirms them.
- **Its answer doesn't change what this spec builds.** That covers something this change doesn't build or touch, an obligation on people outside the scope, and a success target. Give it one line where it belongs, naming who should settle it: under Scope, at the edges, or in How we will know it worked. Two kinds stay questions, under Needed before release, even when this change doesn't build them: a question carried over from the intent, and a point that could defeat the intent or put money, personal data, or a legal obligation at risk.
- **It arises only if an unconfirmed fact turns out a certain way, and no source suggests it does.** State the fact as not yet confirmed, with its confirmer.

Reviewers answer a short list of real questions. Padding hides the questions that matter among ones that don't.

A rule nobody stated may appear only as a derivation. It must follow from its sources with no other reasonable reading, and no open question could change it. Write the reasoning in its source, as in "derived from R2: a second booking for the same court and hour is refused". If you have to argue for it, it is a recommendation. A derivation can show that something is needed, but it can't approve it. When meeting a rule needs someone's consent, such as granting a permission that a policy controls or an exception to a policy, ask that person as a question that blocks planning. A gap that puts money, personal data, or a legal obligation at risk becomes a question that blocks planning, never a rule you add.

### 5. Write the spec

Use the headings of [references/spec-template.md](references/spec-template.md) in that order. Omit a section only when it would be empty. Open questions always stays, with "None" under an empty class, so that readers know the test was applied.

**Language.** Write the body, field labels, and table headers in the intent's language, because its originator and reviewers must read the spec and answer in that language. Keep the template's section headings and header lines in English. A Korean spec uses the labels the template lists, and the three parts of an open question keep the requester's exact wording. Keep IDs, policy IDs, file paths, and quoted policy text as they are.

- **Summary.** Write it in your own words, not the intent's. The originator reviews this paragraph, and a misreading shows up only in your own words. Keep numbers, names, and dates as the intent gives them.
- **What the user experiences.** Number the main path, one action per step, as the person sees it, and give each step its source. Where an open question splits the path, show both branches and name the question. Never present one side of an open conflict as the design. A reviewer who doesn't read code checks this path against the intent, and counts what a policy counts.
- **Rules.** Number them R1, R2, and so on across the whole spec, grouped by stage of the path. Give each a short name, one sentence plus at most one qualifier, and its source at the end. A rule taken from an intent constraint keeps the intent's reason. A rule that an open question holds back names that question.
- **Cases.** Use one table, with a row for each situation that changes the outcome, including boundaries, repeats, and failures. Give each row concrete dates and amounts, and what the person sees and what happens, computed from the rules. Mark invented values as examples. When the result depends on an open question or on how a policy's words are read, give the result under each option or reading and name the question, or say it isn't decided. If whether a threshold ever applies depends on a real figure the workspace lacks, such as the actual price, ask for the figure rather than only illustrating it. The plan turns these rows into tests.
- **Open questions.** Write each one as [references/open-questions.md](references/open-questions.md) describes, under its class: blocks planning, or needed before release.
- **Policies.** Give each applicable clause one row: what it requires here, where the spec stands (the rules that meet it, or the question it raises), and how it will be checked. The check is the cases that test it, or a named owner's review before release. A clause with neither is a gap: add a case, a review, or a question. When no policy applies, write the section as one line.
- **Reviewers.** Give each person one row: the originator and product owner from the intent, the owner each applicable policy names, the technical lead, and the engineers. Name people only as a source names them. List each person's questions, and every other line in the spec that asks them to decide, confirm, or review something, by section. Each claimed fact that a rule or question rests on needs a confirmer: the technical lead, or "the product owner assigns one" when no technical lead is named. This table is the only index of the questions, so keep it in step with them.
- **How we will know it worked.** Map each desired outcome in the intent to a check that someone other than you can perform, with its baseline and target. Say who sets a target that is still open.
- **Facts and sources.** Start with the commit or date you read. Keep one list of every workspace fact the spec relies on. Give each its full path from the repository root and whether you verified it or read it in a comment or document. The technical lead confirms this list. Elsewhere, state a fact in plain words, and only where it drives a rule or question.
- **Terms.** List only words a policy defines and words with tempting synonyms. Define what a thing is, not what it does. Never define a word a policy uses without defining it; if its meaning changes an outcome, ask the policy owner.

Write for a reader who knows the business and not the code:

- Name who does what: the member, the front desk, the service. Use one word for each thing. When a policy defines a word, use its definition. Define a word a non-engineer might not know where it first appears.
- Keep numbers, thresholds, dates, conditions, and "must not" statements exactly as the source gives them. Write dates as YYYY-MM-DD.
- Outside Facts and sources, name screens and buttons by the labels people see, never by code names, error codes, file names, or paths. Don't say where a fact was read, such as the code, a comment, or the repository. Mark a fact nobody has confirmed as "(not yet confirmed; <confirmer> checks)", and a record you couldn't find as "no record of X was found; <confirmer> checks".
- Cite the intent only for words it contains, and cite IDs one by one, never as a range.
- Give a rule or question its short name where a reader meets its ID with the thing out of view: in the Summary, the walkthrough, and the Reviewers table, as in "Q3 (late cancellations)". Inside an open question, say in plain words what a cited rule requires. Elsewhere, the bare ID is enough.
- Don't use this skill's own words, such as "workspace" or "fresh reader", in the spec. Say what they mean in the reader's words.

It fails like this: "R7. `cancelBooking()` calls `refundFee()` when `hoursBefore >= 24`." A policy owner can't check it, and it decides how to build the refund. Write instead: "R7. **Free cancellation:** A member who cancels 24 hours or more before the slot gets the booking fee back. (BOOK-02 §4)"

### 6. Check it

Save the draft at the path in step 7, then check it in this order.

1. Every rule and question ID you cite is defined exactly once. Search the file for each name and role: every line that asks that person to decide, confirm, or review something is in their Reviewers row, and every person asked has a row. The counts in the Status line match.
2. Every item you listed from the intent in step 2 appears in the spec, in Scope, a rule, a case, an open question, How we will know it worked, or Facts and sources. Nothing was dropped or narrowed.
3. Every rule, step, and case result has a source or names an open question. No rule contains your recommendation, and no open question could change a derived rule. If one could, mark the rule with that question, or move the rule into the question. Anything marked as not decided outside Open questions names a question.
4. Every applicable policy clause has a check, and each fact still matches the workspace. Outside Facts and sources, no code name, error code, file name, or path appears, and no sentence says where a fact was read.
5. **Round 1.** Give the saved file to fresh readers and judge their findings, as [references/fresh-readers.md](references/fresh-readers.md) describes. You have read the intent, the policies, and the code, so you fill gaps without seeing them. The test is about a reader who has only the spec.
6. **Round 2.** If you applied any round-1 finding, run checks 1–4 on the edited file, then give it to a new implementer reader, plus any reader whose part changed. Judge those findings the same way. The text you wrote to apply findings is the only text no reader has seen, and new gaps appear there. If round 2 led to changes, run a third round the same way; a report that says a further round would cover something means that round is owed. After the third round, change no rule, step, or case result: make each finding you would still apply an open question, and run checks 1–4. Don't report until the last round has run, and say in your report how many rounds ran.

   On a first draft, before any reviewer has seen it, you may renumber while you apply findings. Once a spec has been saved for reviewers, never renumber.

   If subagents aren't available, make one pass yourself. Reread only the saved file as the implementer, and recheck every calculated case against the policy text for words that read two ways. Add only findings that pass the step 4 check, and say in your report that no fresh reader ran.

### 7. Save and report

Save the spec beside the intent: for `<dir>/docs/intents/NNNN-<slug>.md`, write `<dir>/docs/specs/NNNN-<slug>.md`. Create `docs/specs/` if it doesn't exist. The shared file name pairs the two, so neither needs a link added. Don't modify the intent, the policies, or earlier specs, except for the `Superseded by:` line that the superseding rule adds to a replaced spec.

Set the status to Draft. Then tell the user, in a few lines:

- The file path, the number of open questions, and how many block planning.
- The questions that block planning, grouped by who answers them, each by ID and short name.
- Each conflict between policies, or between a policy and the intent, in one line. The product owner settles these with the policy owners before engineers plan.
- What the fresh readers changed, and every finding you didn't apply, from any round, each in one line with the reason. Report a finding as applied only if the file now settles it or asks it.

Then offer to go through the open questions the user owns, one per turn, and ask which are theirs if they haven't said. Ask each as a choice question (step 1) built from that question's options. Apply each answer as [references/revising.md](references/revising.md) describes. Don't write the implementation plan.
