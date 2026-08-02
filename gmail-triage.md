# Gmail Triage

## Why this exists

MailSynth (a third-party inbox-organizing service) was cancelled on 2026-07-30.
It had been doing two jobs:

1. **Auto-labeling** incoming mail into the label taxonomy below.
2. **Daily digests** summarizing what came in.

Both stopped the moment the subscription ended. This doc covers replacing
that with (a) native Gmail filters for anything deterministic, and (b) a
recurring Claude triage pass for anything that needs judgment.

## Existing label taxonomy (inherited from MailSynth)

| Label | Apparent purpose |
|---|---|
| Read Later | Low-priority, non-actionable |
| Older / Older than 3 months ago | Age-based archive tiers |
| Car / Honda | Vehicle-related |
| Finance | Financial mail |
| Alerts | Security/account notices (Apple ID, Google account, subscription renewals) |
| Misc | Catch-all |
| Moved | Marker for "already processed out of inbox" |
| Action Needed | High-priority, requires a response/decision |
| Medium | Mid-priority tier |
| 🗑️ Review-Delete | Staged for deletion |
| Food / Wine / Shopping / Receipts / Tax receipts / Passwords | Self-explanatory |
| f/forwards, f/attachment(/pdf,/image,/office doc), f/not to me, f/social networks | Structural filters (attachment type, forwarded, not-to-me, social) |
| Flagged by Guardio | Set by the Guardio browser extension, not Gmail — leave alone |

New label added: **Real Estate** (for the `+realestate` alias — see below).

## Part 1 — Native Gmail filters (set these up manually)

There's no API for creating Gmail filters (only labels/search/apply-label), so
these need to be entered by hand at **Gmail → Settings → Filters and Blocked
Addresses → Create a new filter**. Only deterministic, sender-based rules
belong here — anything requiring judgment about importance goes to Part 2
instead.

### 1. Real estate alias → own label, out of the inbox
- **Search:** `to:(lwizinski+realestate@gmail.com)`
- **Action:** Apply label "Real Estate", Skip Inbox (Archive it)
- Covers Zillow saved-home alerts, LandSearch updates, and anything else sent
  to that alias.

### 2. Known low-quality marketing → Review-Delete
- **Search:** `from:(uphubroad.work)`
- **Action:** Apply label "🗑️ Review-Delete", Skip Inbox
- `update@uphubroad.work` ("home insurance quotes") came back **suspicious**
  on a threat-intelligence check — not confirmed malicious, but not worth
  inbox space. Add other one-off marketing domains here as they show up.

### 3. Account/security alerts → Alerts
- **Search:** `from:(id.apple.com) OR from:(email.apple.com) OR from:(accounts.google.com)`
- **Action:** Apply label "Alerts" (leave in Inbox — these can be
  time-sensitive, e.g. password-reset or account-recovery notices)

Everything else that used to get auto-sorted by MailSynth — priority calls
like "Action Needed" vs. "Medium," or judgment calls like political
fundraising blasts — can't be expressed as a sender/subject rule. That's what
Part 2 is for.

## Part 2 — Going-forward triage (replaces the daily digest)

Recommended: a recurring Claude Routine (e.g. daily) that:
1. Searches `in:inbox has:nouserlabels newer_than:1d` (mail that arrived and
   wasn't caught by a filter above).
2. Applies judgment to sort it into the existing label taxonomy
   (Action Needed / Medium / Read Later / Misc / etc.), the same way MailSynth did.
3. Sends a short digest of anything landing in "Action Needed."

This hasn't been activated yet — say the word and I'll set up the schedule.
