---
name: clarify-intent
description: Work with the user who has a rough idea to turn it into a short intent document (problem, desired outcome, affected users and systems, scope and constraints, open questions) before any specification or implementation work.
argument-hint: <idea>
disable-model-invocation: true
---

# Clarify Intent

Clarify the intent behind a rough idea through a short conversation with the user who has the idea, and record it in an intent document for later specification work.

The value is in the user's decisions, not the formatting or the number of questions. Surface the gaps a rough idea leaves, and let the user resolve them.

## Principles

- **Record as intent only what the user said or decided.** Don't invent motivations, metrics, stakeholders, constraints, or approvals. Confirm anything you inferred, or leave it out. When the document states something you found in the workspace rather than heard from the user, name its source, such as a file path, next to it.
- **Facts are yours to find.** Read the workspace to learn how things stand today, even mid-conversation, and tell the user what you found and where. Separate what a document claims from what you verified. If you can't check something, say so and ask only about the decision it bears on.
- **Decisions are the user's.** Why, for whom, what counts as success, what is in or out, and what must not happen are for the user to answer. The user can change the direction, depth, or pace of the conversation at any point. If their account contradicts the workspace, show the discrepancy and ask about it. Record an unresolved discrepancy under Open questions.
- **Intent, not implementation.** A way of doing it that the user names, such as their solution, a tool, or a format, is a means, not the outcome. Unless the user has dropped it or said whether they require it, ask whether they do once the desired outcome is settled, as a choice question that names no other means. Don't ask for its reason in the same question. Ask when revising too, even if the earlier document lists a means under scope. Record a means only if the user requires it, as a constraint. The specification writer may replace any other means. Don't design solutions.
- **Challenge, then let the user decide.** If the problem seems already handled, a framing looks off, or a smaller scope might deliver the same outcome, say so and why, and ask for the user's view as a free-form question. Don't offer your alternative in the same turn, so that the user answers from their own reasons. After they answer, you may propose your alternative as a choice question. If they delegate ("you decide"), propose one concrete answer.
- **Leave unknowns open.** If the user doesn't know an answer, record it under Open questions instead of rephrasing until they guess. If the user can't settle the problem or the desired outcome, stop asking about it and go to step 4.

## Ask in rounds

Ask in short rounds shaped by the user's latest answers. Ask a question alone when its answer shapes the rest, as the answers about the problem, the desired outcome, and a challenge do. Once the problem and the desired outcome are settled, most remaining questions don't depend on each other, so ask two or three per round. Ask why it matters now and whether a means is required in the first of these rounds, because the user may end the questions early. A question that builds on an answer you don't have yet, such as a reason question, waits for the next round. Number each question, and make each one ask one thing.

A round fails like this: "1. What goes wrong with court booking today? 2. How many members does it affect?" The second assumes the problem falls on members. If the answer to the first is that front-desk staff spend hours fixing double bookings, the second asks about the wrong people.

Each question takes one of four forms.

**Free-form question.** Use it for the problem, the outcome, and a vague word. For a vague word, ask for a concrete example, a specific group, or a before and after. Give no options. A motivation that you suggest and the user only picks is yours, not theirs. It fails like this: "How do members book courts today, and what does it cost them?" That is two questions in one.

**Choice question.** Use it to choose between alternatives, such as a scope line, a tension, or your proposal. Write the question, then two to four lettered options, one per line. Explain the trade-offs that matter. You may recommend one option, and say why. Tell the user once per round that they can answer in their own words instead of picking an option. It fails like this: "Should late cancellations count as no-shows, be ignored, or stay open?" The options are hidden inside a sentence, and nothing says what each one costs.

**Constraint question.** Ask what the change must not do or break. Give two or three plain examples that fit this idea, inside the question and not as options. Draw them from kinds such as information that must not be exposed, existing behavior that must keep working, a policy, a regulation, or a compatibility rule. Then say that "none" is a valid answer. Don't ask for reasons in the same question. It fails like this: "Anything else I should know?" It gives the user nothing to think about, so it invites a reflexive "no".

**Reason question.** Ask it when the user states a decision, constraint, or required means without its reason, and a reader would need the reason to apply the item to cases its words don't cover. Quote the item in the user's words, then ask what would go wrong without it. Don't suggest a reason. Ask once per item. If the user only restates the item, record it as stated. It fails like this: "Is weekends-only because the front desk isn't staffed then?" The reason is yours, and the user only has to say yes.

## Workflow

### 1. Start from the idea

Take the idea from the invocation arguments or the user's message. If there is none, ask for it in one sentence and wait.

Once you have the idea, and before you ask about it, list each `docs/intents/` in the workspace and read only the intent documents whose file names or titles relate to the idea. If a document is marked `Superseded by:`, read the one it names instead. Read the parts of the workspace the idea touches.

Restate the idea in a sentence or two, adding nothing the user didn't say. Then check two things that change what the conversation is about, one at a time, in this order.

- If an existing intent document covers this idea, show it and ask which of these applies, as a choice question:

  a. It still holds. Stop without writing a file.  
  b. It needs revising. Ask only about what changed or what it left open, and link the two documents (step 5).  
  c. It is a different idea.

- If the user's own words name outcomes that could each be delivered and judged on their own, ask which one this document is about, as a choice question. List the others as out of scope, as candidates for their own intent documents. Keep them together only if none is useful without the others.

Then go to step 2. If the input leaves no gaps, run the checks at the end of step 2, then go to step 3.

### 2. Discuss the idea

These are topics to clarify, not a script to follow in order. Start with the problem, then follow what the user's answers make important.

- **Problem**: what is wrong or missing today, and why it matters now. If the idea arrives as a solution, first ask what problem it solves. If the impact is unclear, ask how people cope today and what the problem costs them, as separate questions. The problem is settled once what is wrong or missing is clear. Ask why it matters now once the outcome is settled, as a free-form question, unless the user already named a deadline or what prompted the change. Name kinds of answer, such as a deadline or an event that prompted it, but not a candidate reason, which the user would only have to confirm. Calling it urgent or important doesn't answer it, so ask once for a deadline or an event behind it. If the user still can't say, record why it matters now under Open questions.
- **Desired outcome**: what is observably different once this is done. Ask what the user would see that tells them it worked. Don't demand a metric, but don't accept a wish either. "Booking should be less of a hassle" names a feeling, not an outcome, so the intent is still unclear. Ask what would be different, naming kinds of change such as a step members no longer take or a mistake that stops happening, not a candidate answer. The outcome is settled only when a reader who never saw this conversation could tell whether it happened. When revising, ask about the new outcome alone, and whether the earlier one still holds in a later round.
- **Affected users and systems**: who is affected, and which parts of the system or workflow the problem lives in today. Ask who is affected as a free-form question once the problem is known. Find the systems in the workspace and tell the user what you found instead of asking. Don't list systems that only a means the user doesn't require would touch.
- **Scope**: what is in, and what is explicitly out.
- **Constraints**: what the change must not do, and what must stay as it is. Ask the constraint question once, unless the user has already covered constraints. A constraint mentioned in passing doesn't cover the rest, and a scope question doesn't surface them.

Don't ask about what the input, earlier answers, or the workspace already settle. Don't ask about details a specification can settle, such as behavior in particular cases or how to build it.

If a related intent document or a separately deliverable outcome comes up only now, ask the matching question from step 1 before you continue.

Before you go to step 3, check the answers against each other and against the workspace. Does the outcome follow from solving the problem? Can it be reached within the scope and constraints? Does anything out of scope remove what an affected user needs? Does anything contradict what you found? Ask about each tension, and settle any proposal still pending.

### 3. Restate the intent in your own words

Go to this step when two things hold. You can state the problem and a settled desired outcome from what the user said, or from the earlier intent document they chose to revise. Every other topic in step 2 is answered, deliberately left open, or found not to apply, and you have asked the constraint question, why it matters now, and whether each means the user named is required, except where the user already answered. If the user asks to end the questions or to just write it before agreeing to a restatement, go to step 4 instead, even when that same reply answers everything that was left.

In a turn of its own, write in two or three sentences of your own what problem the user is trying to solve and what outcome they want. Use neither their phrasing nor the wording you would put in the document, because a misreading shows up only in your own words. Keep numbers, names, and conditions as the user gave them. Add nothing they didn't say. When revising an earlier document, restate the intent as revised, and say in a line what changed. Don't show the document. End with one question: whether you understood them correctly.

It fails like this: the outcome without the problem, the user's sentences repeated back, a section-by-section summary, or a second question after the first.

When the user agrees, go to step 5. A reply such as "mostly, but…" or "yes, and one more thing" is a correction. Apply clear corrections, and ask about any remaining gap or conflict that would change the intent. Once those are settled, restate again if your understanding of the problem or the desired outcome changed. Otherwise, say in a line what changed and go to step 5. If the user asks to stop or to just write it, go to step 4.

### 4. If the conversation stops early

Come here when the user wants to end the questions or to just write it before they agree with your restatement in step 3, including during step 2, or when the user can't settle the problem or the desired outcome. If the user wants to drop the idea instead, stop without writing a file. If you can't tell which they mean, ask.

- If the user settled the problem and the desired outcome, run the checks at the end of step 2 without asking. Then write the document as in step 5 in your next message, with any corrections the user gave. Don't ask whether you understood them first. Put each tension, each proposal of yours the user hasn't accepted, and everything else unaddressed under Open questions. A means you didn't get to ask about goes there too, not in scope. If the user didn't answer whether an existing intent document covers the idea, name that document under Open questions instead of filling in `Supersedes`. If you haven't restated the intent yet, restate it in the same message, after saving, and invite corrections to the document without asking a question.
- Otherwise, don't write a file, even if the user asked to just write it: without both, there is no intent for a specification to start from. Say in a line or two what is settled, what is still unclear, and what would settle it, then stop.

### 5. Write the document

Use the headings of [references/intent-template.md](references/intent-template.md) in that order. Omit a section only when it would be empty. Leave out the `Supersedes` line unless the document revises an earlier one.

- Write for a reader who never saw this conversation. Keep connecting prose short. Keep numbers, thresholds, conditions, ordering, defaults, and "must not" statements exactly as the user gave them, not as you restated them.
- State decisions plainly, with the user's reasons where given. Say each thing once, in the section the template gives it. When the user answered "none", as to the constraint question, record that answer instead of leaving it out.
- Name the title after the problem or the outcome, not a means. Write the in-scope item as what the change covers, not a means, and record a means the user requires as a constraint. Leave out a means the user said they don't require, and any alternative they named with it.

Before saving, check each statement: the user said or decided it, or it names its workspace source. Move anything else to Open questions, or remove it.

Save it like this:

- Use the workspace's `docs/intents/`. If there are several, use the one closest to the parts of the workspace the idea touches. If there is none, create `docs/intents/` at the workspace root. Save a document that revises an earlier one in the earlier one's directory.
- Name the file `NNNN-<slug>.md`. `NNNN` is one more than the highest number prefix in the directory, zero-padded to four digits, starting at `0001`. `<slug>` is a short kebab-case English name for what the title names, as in `0003-double-bookings.md`.
- Don't modify or overwrite intent documents written before this conversation, with one exception. When the new document revises an earlier one, fill in the template's `Supersedes` line. In the earlier file, add a `Superseded by: <new file name>` line as its own paragraph right after the title.
- If you can't write the file, say so and give the document in chat.

After saving, tell the user the file path and any open questions that must be resolved before specification work. Do not write the specification.
