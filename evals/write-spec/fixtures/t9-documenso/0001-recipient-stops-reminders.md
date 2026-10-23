# Intent: Recipients who won't sign keep getting reminder emails

## Problem
When a recipient doesn't sign a document, Documenso keeps sending them reminder emails. With the default reminder settings, the first comes 5 days after the signing request and then one every 2 days, for as long as the document waits for them. A recipient who has decided not to sign, but doesn't want to reject the document, has no way to stop these emails. Some of them mark the reminders as spam, which hurts delivery of all email sent from our domain.

## Desired outcome
- From a reminder email, a recipient can stop further reminders for that one document, without signing or rejecting it.
- The sender can see on the document that the recipient stopped reminders.

## Affected users and systems
- Recipients who get reminder emails, and the senders who are waiting for their signatures.
- The automatic signing reminders, the reminder email, and the document page where senders follow each recipient.

## Scope and constraints
- In scope: stopping automatic reminder emails for one document, from a reminder email.
- Out of scope: the original signing request email, unsubscribing from all email, the default reminder timing.
- Must not change the audit trail of signed documents. Reason: it is legal evidence.
- Must follow our published privacy policy.

## Open questions
- May the sender turn reminders back on for a recipient who stopped them?
