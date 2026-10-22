# Open questions

An open question is how an undecided item reaches the person who can decide it. Its owner often reads nothing but the question and the rules it names, so write each one to be answerable from the spec alone. A question that can be answered only by reading code has failed, however accurate it is.

## When to write one

Write a question wherever someone working only from the spec would have to decide, on their own, a product behavior or a constraint that nobody has decided. Typical sources:

- an open question carried from the intent;
- a policy clause whose words two careful readers would apply differently;
- two policies, or a policy and the intent, that can't both hold;
- a fact, such as a contract limit, that makes the desired outcome impossible for some cases;
- a threshold whose relevance depends on a real figure the workspace lacks;
- a reader's finding that the sources don't settle.

Don't write one when the workspace already answers it. State the answer as a rule or a fact, with its source, so a reader can still correct it. Don't write one for a choice nobody outside engineering would notice; list it under Left to engineering.

Ask one thing per question. Two decisions with different owners or different consequences are two questions, even when they concern the same screen.

## Fields

Write the field labels in the spec's language. In a Korean spec, use the requester's own wording for the three parts: 무엇이 불명확한가? / 그 답에 따라 무엇이 달라지는가? / 무엇을 확인하거나 결정하면 해결되는가?

- **Short name.** The heading: `Q<n>. <a few words naming the decision>`. Other sections refer to the question by this ID and name.
- **What is unclear.** Name the specific gap, and quote or cite the words that leave it open. State in plain words the fact or rule it depends on, with its ID and short name, so the question reads without the rest of the spec. "The policy is unclear" is not a gap. "LEG-2026-14 §2 counts a step as an action that moves the customer to the next screen, and doesn't say whether the button that opens the cancel flow is one" is.
- **What changes depending on the answer.** Be concrete: who is affected, what they see or receive, which amounts change, which rules and cases change, and what else the answer forces. This field is what lets a non-engineer judge how much the question matters.
- **What would resolve it.** Say who must confirm or decide what, and in what form: a yes or no, a choice among the options, a number, a rule, or a document. If a fact must be confirmed first, say who confirms it.
- **Who answers.** A role and a name, taken from the policy's owner line, the intent, or the workspace. Product behavior and scope go to the product owner. What a policy requires, and how its words are read, go to that policy's owner. A conflict between two policies goes to both owners, routed by the product owner. Whether the spec solves the problem goes to the originator. If you can't find an owner, write "the product owner assigns one". Never guess a name.
- **Holds back.** The rules, cases, and steps that can't be built until this is answered, by ID and short name.
- **Options.** Only when the possible answers can be listed: two to four, each with a line on what it means for the people affected and for the policies. Never drop an option the intent itself names; state its consequence instead. If a source rules an option out, say so under what changes.
- **Recommendation (the writer's, not a decision).** Optional. Give one only when a source supports it. Name that source and what you may not know. Never recommend on a conflict between policies, on how a policy's words are read, or on a business target, such as a number, that no source informs. Your recommendation would decide those in practice.
- **From.** Where the question came from, in words a reviewer knows: an open question in the intent, a conflict between two named policies, a fact about the existing system, or a review of the draft.
- **Answer.** Leave it empty for the owner: answer, who, date. On revision, check that the answer came from every owner the question names before applying it.

## Classes

Put each question under one class heading.

- **Blocks planning.** The answer changes what gets built: the steps of a flow, who can use it, how amounts are calculated, what data is kept, or what a policy requires. Every conflict between policies is here. Planning would otherwise have to guess.
- **Needed before release.** The answer changes a value, a label, what a notice says, or another detail that planning can leave as a slot. Customers must not see the change until it is answered.
- **Doesn't block.** The answer doesn't change what gets built now, such as a success target, or a concern outside the scope that the product owner should know about.

When you can't tell which applies, choose Blocks planning. Holding up planning costs a day; a guess built into the product costs a release. The spec can be accepted, and planning can start, only when nothing under Blocks planning is open.

## How questions fail

- "Need to check the refund policy with finance." It has none of the three parts, so the owner doesn't know what to answer or why it matters.
- "Should late cancellations count as no-shows, be ignored, or stay open?" The options are hidden in a sentence, and nothing says what each one costs.
- "Should `E_PARTIAL_CANCEL_EXPIRED` fall back to a bank transfer?" Only an engineer can read it, and it decides the fallback in the course of asking.
- "Who answers: Finance / Legal." The policies name people. A question addressed to no one in particular waits for everyone and is answered by no one.
- A recommendation on whether the marketing policy or the legal policy wins. That is the owners' call, and a recommendation would decide it in practice.
- "What should happen after 180 days, and who approves large refunds?" Two decisions with different owners, so one gets answered and the other gets lost.
- A worked example that computes every refund under one reading of "a partial month counts as a month". The question was never asked, and the example answered it.

## Example

#### Q3. Late cancellations
- **What is unclear:** The intent says members who "don't show up" lose booking rights for a week (R6 (no-show penalty)). It doesn't say whether cancelling less than an hour before the slot counts as not showing up.
- **What changes depending on the answer:** About one in five cancellations happen in the last hour, according to the booking log. If they count, those members lose a week of booking, and the slot can still be resold. If they don't, the penalty applies only to members who never cancel, and late cancellations go unpenalized. Cases 4 and 5 change.
- **What would resolve it:** The front desk lead chooses one of the options below.
- **Who answers:** Front desk lead (Kim, per the intent).
- **Holds back:** R6 (no-show penalty), cases 4 and 5.
- **Options:** (a) A late cancellation counts as a no-show. It is strict, and members are told before they cancel. (b) It doesn't count. It is lenient, and late cancellations go unpenalized. (c) It counts only when the slot isn't rebooked. It is fairer, but members can't know at cancel time whether they'll be penalized.
- **From:** An open question in the intent.
- **Answer:**
