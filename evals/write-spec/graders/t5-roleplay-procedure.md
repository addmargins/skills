<!--
T5 stakeholder role-play. One fresh agent per role-player, with no code and no conversation history.
Give each one, in this order:
  1. A persona card: <NAME>, <ROLE> (the policy they own, or originator), and 3-4 private stances to answer from.
     plan.md T5 lists the round-6 people and example stances; the round-6 cards themselves were not kept.
  2. <TOP_FILE>: the spec from its start through the Reviewers table.
  3. <SPEC_FILE>: the full spec. Originators also get <INTENT_FILE>.
  4. <OUT_FILE>: where to write stages A and B.
  5. The procedure below, unchanged.
A judge then grades T5 assertions 1-6 over all outputs, with the policies and intents at hand (plan.md T5).
-->

# Role-play procedure (T5)

You are a real stakeholder reviewing a specification. You are not an engineer, and you have never seen code. Stay in character, and answer only from what the files you are given say plus your private stances. Don't use outside knowledge of how software is built.

Work in two stages, in order. Write everything to your output file.

## Stage A: find your part (one minute)
Open only the TOP file, which runs from the spec's start through the Reviewers table. From it alone, write:
- A1. The question IDs you must answer or confirm, exactly as you understand them from the table.
- A2. The other sections or rows you must review.
- A3. Could you tell this within a minute? (yes/no, with what slowed you down)

## Stage B: do your part
Now open the FULL spec (and the intent, if you are given one).
- B1. For each question addressed to you, wherever you find it in the full spec (including ones you missed in Stage A), give:
  - the ID and short name;
  - your answer, using your private stances where they apply, or "I can't answer; I need X";
  - whether you could answer it from the question text alone (yes, or what was missing);
  - whether your answer maps to exactly one listed option, or is a concrete value someone could apply without asking you again.
- B2. Quote every sentence outside the facts-and-sources section that you couldn't understand, or couldn't check, without an engineer. Say what was in the way.
- B3. List any rule in your domain that settles something you were never asked about. For a policy owner, that includes a rule or worked example that applies a reading of your policy's words you wouldn't necessarily agree with.
- B4. (Originators only) List any item from your intent that the spec dropped, narrowed, or changed without asking you.
- B5. In two sentences: would you sign off on your part as written? What would you need first?
