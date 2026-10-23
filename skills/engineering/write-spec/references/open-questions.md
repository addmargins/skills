# Open questions

An open question is how an undecided item reaches the person who can decide it. Its owner often reads nothing but the question, so write each one to be answerable on its own. A question that can be answered only by reading code has failed, however accurate it is.

## When to write one

Write a question wherever someone working only from the spec would have to decide, on their own, a product behavior or a constraint that nobody has decided, and it passes the check in SKILL.md step 4. Typical sources:

- an open question carried from the intent;
- a policy clause whose words two careful readers would apply differently;
- two policies, or a policy and the intent, that can't both hold;
- a fact, such as a contract limit, that makes the desired outcome impossible for some cases;
- a threshold whose relevance depends on a real figure the workspace lacks.

Ask one thing per question. Two decisions with different owners or different consequences are two questions, even when they concern the same screen.

## Fields

- **Short name.** The heading: `Q<n>. <a few words naming the decision>`.
- **What is unclear.** Name the specific gap, and quote or cite the words that leave it open. Say in plain words what any rule it cites requires, so the question reads without the rest of the spec. Say "carried from the intent" when it is. "The policy is unclear" is not a gap. "BOOK-02 §2 takes booking rights from members who 'don't show up', and doesn't say whether arriving 15 minutes late counts" is.
- **What changes depending on the answer.** Be concrete: who is affected, what they see or receive, which amounts change, which rules and cases change, and what else the answer forces. This field is what lets a non-engineer judge how much the question matters.
- **What would resolve it.** Say who must decide or confirm what, by role and by the name a source gives, and in what form: a yes or no, a choice among the options, a number, or a rule. Product behavior and scope go to the product owner. What a policy requires, and how its words are read, go to that policy's owner. A conflict between two policies goes to both owners, routed by the product owner. If a fact must be confirmed first, say who confirms it; a fact about how a named team works today is confirmed by that team. Also ask, to confirm, each policy owner whose clause an option would break or use up, and the originator when an option narrows a desired outcome. If no product owner is named, address product questions to the originator, as input until one is named. If no source names any owner, write "the product owner assigns one". Never guess a name.
- **Holds back.** The rules, cases, and steps that can't be built until this is answered.
- **Options.** Only when the possible answers can be listed: two to four, each with a line on what it means for the people affected and for the policies. Never drop an option the intent itself names; state its consequence instead.
- **Recommendation (the writer's, not a decision).** Optional. Give one only when a source supports it. Name that source and what you may not know. Never recommend on a conflict between policies, on how a policy's words are read, or on a business target that no source informs. Your recommendation would decide those in practice.
- **Answer.** Leave it empty for the owner: answer, who, date.

## Classes

Put each question under one class heading.

- **Blocks planning.** The answer changes what gets built: the steps of a flow, who can use it, how amounts are calculated, what data is kept, or what a policy requires. Every conflict between policies goes here, and so does every consent a rule needs. Planning would otherwise have to guess.
- **Needed before release.** The answer changes a value, a label, what a notice says, or another detail that planning can leave as a slot. A question carried from the intent whose answer changes nothing built also goes here. Customers must not see the change until it is answered.

To tell them apart, ask whether planning could build the flow with the answer as a slot to fill in, such as a value, a wording, a label, or "nothing". If so, the question is Needed before release. So is a request for a real figure that only replaces example values. How rarely a situation occurs never sets the class. When you still can't tell whether an answer changes a flow, who qualifies, an amount, the data kept, or what a policy requires, choose Blocks planning. Holding up planning costs a day; a guess built into the product costs a release. The spec can be accepted, and planning can start, only when nothing under Blocks planning is open.

## How questions fail

- "Need to check the cancellation policy with the front desk." It has none of the three parts, so the owner doesn't know what to answer or why it matters.
- "Should late cancellations count as no-shows, be ignored, or stay open?" The options are hidden in a sentence, and nothing says what each one costs.
- "Should `E_SLOT_LOCKED` fall back to the waiting list?" Only an engineer can read it, and it decides the fallback in the course of asking.
- A worked example that computes every fee under one reading of "a partial hour counts as an hour". The question was never asked, and the example answered it.

## Example

#### Q3. Late cancellations
- **What is unclear:** The intent says members who "don't show up" lose booking rights for a week. It doesn't say whether cancelling less than an hour before the slot counts as not showing up. Carried from the intent.
- **What changes depending on the answer:** About one in five cancellations happen in the last hour, according to the booking log. If they count, those members lose a week of booking, and the slot can still be resold. If they don't, the penalty applies only to members who never cancel. R6 and cases 4 and 5 change.
- **What would resolve it:** The front desk lead (Kim, per the intent) chooses one of the options below.
- **Holds back:** R6, cases 4 and 5.
- **Options:** (a) A late cancellation counts as a no-show. It is strict, and members are told before they cancel. (b) It doesn't count. It is lenient, and late cancellations go unpenalized. (c) It counts only when the slot isn't rebooked. It is fairer, but members can't know at cancel time whether they'll be penalized.
- **Answer:**
