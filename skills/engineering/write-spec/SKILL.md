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
- **What, not how.** The spec states observable behavior, the rules it must follow, and how reviewers will check it. Module structure, schemas, API shapes, file changes, and test layout belong to the implementation plan. Engineers write that plan after the spec is accepted. A limit of an existing system that changes what people experience is a constraint, so state it in plain words. A partner club's booking system that accepts changes only up to 24 hours ahead is one. List the choices you leave to engineers on purpose, so reviewers don't mistake them for gaps. Screen copy and layout are not engineering choices: customers see them, and policies may regulate them.
- **Write for the least technical reviewer.** A policy owner must be able to judge each rule and answer each question without reading code. Say each thing once, in the section the template gives it. Elsewhere, refer to it by ID and short name.

## Workflow

### 1. Find the intent

Take the intent document from the invocation arguments. If there is none, list each `docs/intents/` in the workspace and ask which document to use, as a choice question. If the document is marked `Superseded by:`, use the one it names, and say so.

Then check these, in this order:

- **Is there something to specify?** If the intent states no problem, or no desired outcome a reader could check, stop without writing a file. Say what is missing and suggest the `clarify-intent` skill. Every rule traces back to the outcome, so a spec built on a guessed outcome traces to nothing. Write a spec for any other thin intent: its gaps become open questions.
- **Does a spec for it already exist?** Look for a file of the same name in the `docs/specs/` beside the intent's `docs/intents/`. If one exists, revise it (step 8) unless the user asks for a new one.
- **Is it one piece of work?** If the intent holds outcomes that could each be delivered and judged on their own, ask which one this spec covers, as a choice question. List the others under Scope as candidates for their own specs. Keep them together if none is useful without the others. If no one can answer now, write one spec for the intent as written. Make the split the first open question that blocks planning, addressed to the originator.

Ask nothing else before saving. Most open questions in a spec belong to people who aren't in this conversation, such as a policy owner or the technical lead. An answer the user gives on their behalf is a guess that looks like a decision. A question asked before its options and consequences are written out also gets answered cold. If the user states a decision that is theirs to make anyway, record it with their name and the date.

### 2. Read the ground

Read the whole intent and list every item in it: the problem, each desired outcome, each affected group and system, each scope line, each constraint with its reason, and each open question. Step 6 checks that each one landed somewhere.

Then read everything that constrains the behavior it asks for. Note each fact with its source as you go.

- **Policies.** Read every policy document in the workspace, such as those in `docs/policies/`. Also read `CLAUDE.md` or `AGENTS.md` and any workspace skill that states rules for brand, security, privacy, compliance, or UX. Read each candidate in full, not only the ones the intent cites, because a skipped clause is a missed constraint. Note each policy's owner, as the document names them, and its dates.
- **Earlier specs.** Search `docs/specs/` for specs that touch the same policies or systems. An owner's answer in an earlier spec's Decision log can settle a question here, as long as the policy hasn't been revised since. Cite it.
- **The systems the intent names.** Read the code and documents behind them, and the paths the new behavior will run through. Look for what happens today, what data exists, the contracts of outside services, and the existing paths the change must keep. You are reading for facts and limits, not to design the change. For each fact, note whether you verified it in code or read it in a comment or document. Also note what you searched for and didn't find. Record the commit you read (`git rev-parse --short HEAD`), or the date if the workspace isn't a git repository.
- **Numbers.** Count what can be counted: steps in a flow, people affected, thresholds, days until a deadline. When a number matters and you can't find it, note how it could be measured.

### 3. Walk the change and sweep for undecided points

Walk the main path as the person who uses it: what they see, what they do, what happens next. Then walk it as each staff role and each system that records or pays something. At every step, ask whether someone building this would have to decide behavior or a constraint here.

Most gaps hide in the same places. Check each one:

- **Who qualifies.** Check also whether the system can tell those people apart, such as a guest, a member of a partner club, or a staff account.
- **Boundaries.** Whether a limit is inclusive, how a number rounds, whether counting starts at day 0 or day 1, month ends, and time zones.
- **What came before.** Renewals, earlier periods, earlier partial actions, and prices that changed since purchase.
- **Timing and state.** When the change takes effect, what state things are in meanwhile, and whether the person can undo it.
- **Repeats.** A second press, a second attempt after a failure, or two paths acting on the same thing.
- **Failures.** An outside service refuses, a limit is reached, or an approval never comes. No failure may leave money or data in a state nobody sees.
- **What people are told.** Before they commit, while something waits, and after.
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
- **The plain words of the intent or a policy already answer it.** State the answer as a rule with its source instead. This doesn't apply to questions carried over from the intent, which step 3 keeps open until their named person confirms them.
- **It concerns something this change doesn't build or touch.** If it matters, give it one line under Scope, at the edges.

Reviewers answer a short list of real questions. Padding hides the questions that matter among ones that don't.

A rule nobody stated may appear only as a derivation. It must follow from its sources with no other reasonable reading, and no open question could change it. Write the reasoning in its source, as in "derived from R2 (one booking per court per hour): a second booking for the same court and hour is refused". If you have to argue for it, it is a recommendation. A gap that puts money, personal data, or a legal obligation at risk becomes a question that blocks planning, never a rule you add.

### 5. Write the spec

Use the headings of [references/spec-template.md](references/spec-template.md) in that order, and follow its notes. Omit a section only when it would be empty. Open questions always stays, with "None" under an empty class, so that readers know the test was applied.

**Language.** Write the body in the intent's language, because its originator and reviewers must read it and answer in it. Section headings and header labels follow the paired intent. If the intent uses the English headings of clarify-intent's template, use the template's English headings. If its headings are in its own language, use the translations the template gives. Field labels and table headers are always in the body's language, and the three parts of an open question use the wording the template gives. Keep IDs, policy IDs, file paths, quoted policy text, and the `Supersedes:` and `Superseded by:` lines as they are.

- **What the user experiences.** Number the main path, one action per step, as the person sees it, and give each step its source. Where an open question splits the path, show both branches and name the question. Never present one side of an open conflict as the design. A reviewer who doesn't read code checks this path against the intent, and counts what a policy counts.
- **Rules.** Number them R1, R2, and so on across the whole spec, grouped by stage of the path. Give each a short name, one sentence plus at most one qualifier, and its source at the end. A rule that an open question holds back names that question.
- **Cases.** Use one table, with a row for each situation that changes the outcome, including boundaries, repeats, and failures. Give each row concrete dates and amounts, and what the person sees and what happens, computed from the rules. If the result isn't decided, say so and name the question. List the rule and question IDs each row rests on. Mark invented values as examples. Mark each row that depends on how a policy's words are read. Whether a threshold ever applies may depend on a real figure the workspace lacks, such as the actual price. Then ask for the figure in an open question rather than only illustrating it. The plan turns these rows into tests.
- **Open questions.** Write each one as [references/open-questions.md](references/open-questions.md) describes, under the class that fits: blocks planning, needed before release, or doesn't block.
- **Policies.** Give each applicable clause one row: what it requires here, where the spec stands (the rules that meet it, or the question it raises), and how it will be checked. The check is the cases that test it, or a named owner's review before release. A clause with neither is a gap: add a case, a review, or a question.
- **Reviewers.** Give each person one row: the originator and product owner from the intent, the owner each applicable policy names, the technical lead, and the engineers. Name people only as a source names them. List each person's questions by ID and short name. Each claimed fact that a rule or question rests on needs a confirmer: the technical lead, or "the product owner assigns one" when no technical lead is named. This table is the only index of the questions, so keep it in step with them.
- **How we will know it worked.** Map each desired outcome in the intent to the rules that serve it, a check that someone other than you can perform, and the baseline and target. If the target is undecided, name the question that sets it.
- **Facts and sources.** Keep one list of every workspace fact the spec relies on. Give each its file and whether you verified it or read it in a comment or document. The technical lead confirms this list. Elsewhere, state a fact in plain words, and only where it drives a rule or question.

Write for a reader who knows the business and not the code:

- Name who does what: the member, the front desk, the finance team, the service.
- Use one word for each thing. When a policy defines a word, use its definition. Define a word a non-engineer might not know where it first appears, and list it under Terms.
- Keep numbers, thresholds, dates, conditions, and "must not" statements exactly as the source gives them. Write dates as YYYY-MM-DD.
- Keep code names, error codes, and file paths out of every section except Facts and sources.
- Each section mentions a rule or question the first time with its ID and short name, as in "Q3 (late cancellations)". A row of bare IDs means nothing to a reviewer.
- Don't use this skill's own words, such as "workspace" or "fresh reader", in the spec. Say what they mean in the reader's words.

It fails like this: "R7. `cancelBooking()` calls `refundFee()` when `hoursBefore >= 24`." A policy owner can't check it, and it decides how to build the refund. Write instead: "R7. **Free cancellation:** A member who cancels 24 hours or more before the slot gets the booking fee back. (BOOK-02 §4)"

### 6. Check it

Save the draft at the path in step 7, then check it in this order.

1. Run `python3 <this skill's directory>/scripts/check_ids.py <spec file>` and fix every line it prints. It checks four things. Each rule and question is defined once. Each one mentioned exists and carries its short name the first time a section mentions it. Each open question has its fields. Each open question appears in the Reviewers table. When it finds nothing, it prints the counts, so compare them with the Status line.
2. Check what a script can't:
   - Every item you listed from the intent in step 2 appears in the spec, in Scope, a rule, a case, an open question, How we will know it worked, or Facts and sources. Nothing was dropped or narrowed.
   - Every rule, step, and case result has a source or names an open question. No rule contains your recommendation.
   - No open question could change a derived rule. If one could, mark the rule with that question, or move the rule into the question.
   - Every applicable policy clause has a check.
   - Each fact still matches the workspace. Recheck them as the technical lead would.
3. Give the saved file to fresh readers, as [references/fresh-readers.md](references/fresh-readers.md) describes. You have read the intent, the policies, and the code, so you fill gaps without seeing them. The test is about a reader who has only the spec. Run three subagents at once, each with only what its reviewer would have. The implementer gets only the spec. The originator gets the spec and the intent. The policy reader gets the spec and every policy text. Judge each finding yourself:
   - If a source settles it, write or fix the rule, with the source.
   - If no source settles it, add an open question.
   - If nobody outside engineering would notice, list it under Left to engineering.
   - If the spec already settles it, dismiss it. If the reader missed it because it was hard to find, move or rewrite it.

   Never resolve a finding by choosing behavior. Then run another round with new subagents: the implementer, plus any reader whose part changed. Stop after a round that yields nothing you apply, or after three rounds. Report what the last round raised that you didn't apply. No reviewer has seen the draft yet, so you may renumber while you apply findings. If subagents aren't available, do each reader's pass yourself, and read only the saved file for the implementer pass. Say in your report that the check was a self-review.

### 7. Save and report

Save the spec beside the intent: for `<dir>/docs/intents/NNNN-<slug>.md`, write `<dir>/docs/specs/NNNN-<slug>.md`. Create `docs/specs/` if it doesn't exist. The shared file name pairs the two, so neither needs a link added. Don't modify the intent, the policies, or earlier specs. If you can't write the file, say so and give the spec in chat.

Set the status to Draft. Then tell the user, in a few lines:

- The file path, the number of open questions, and how many block planning.
- The questions that block planning, grouped by who answers them, each by ID and short name.
- Each conflict between policies, or between a policy and the intent, in one line. The product owner settles these with the policy owners before engineers plan.
- What the fresh readers changed, in a line.

Then offer to go through the open questions the user owns, one per turn. Ask each as a choice question built from that question's options, in the form clarify-intent uses. Apply each answer as step 8 describes. Don't write the implementation plan.

### 8. Revise when answers come in

Come here when a spec for the intent already exists and something has changed. Someone may have answered questions in this conversation, on the answer lines in the file, or in review comments the user points to. Or the intent may have changed.

- **Only the owners close a question.** Take an answer as decided only when every owner the question names has given it. For a conflict between policies, that means both policy owners. Put a partial answer, or anyone else's answer, under the question as input, and leave the question open. When the user relays someone's answer, record both names.
- **Apply it everywhere it lands.** Write the answer into the rules, steps, and cases it settles, with the source "Q3 answer, <name>, <date>". Remove the question from Open questions and from the Reviewers table. Add a line to the Decision log: the question's ID and short name, the answer, who decided, the date, and where it was given. Don't copy the rule there.
- **Keep IDs stable.** Never renumber, and never reuse a removed ID, so that reviews and plans that cite R9 still point at the same rule. New items take the next unused number.
- **Look for what the answer opens.** An answer often raises a new question, or makes a new derivation possible. Sweep the affected parts again (step 3), and run step 6 again on what changed. If you read the workspace again, update `Verified against`.
- **Send intent changes back.** If an answer changes the problem, the desired outcome, or the scope, don't absorb it. Add an open question saying the intent needs revising with clarify-intent.
- **Suggest recording policy readings.** When an answer settles how a policy's words are read, suggest that its owner write that reading into the policy, so the next spec doesn't have to ask again. Never edit a policy yourself.
- **Status.** Set `Accepted (<name>, <date>)` only when two things hold: the product owner, or whoever the workspace names as accepting specs, says so, and no open question blocks planning. If they ask to accept while such questions are open, list those questions with their owners and keep the status Draft. Planning starts at acceptance. A later change to an accepted spec sets it back to Draft. If a plan already cites the spec, tell the user which IDs changed meaning.
- **Write a new spec for a superseding intent.** When a new intent supersedes this one, write a new spec for it with a `Supersedes:` line. In the old spec, add `Superseded by: <new file name>` as its own paragraph right after the title, and change nothing else.
