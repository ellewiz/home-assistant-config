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

Label added but not currently used: **Real Estate** — an existing filter
already routes the `+realestate` alias to "Claude searches" instead; keeping
that as-is (see below).

## Part 1 — Native Gmail filters (set these up manually)

There's no API for creating Gmail filters (only labels/search/apply-label), so
these need to be entered by hand at **Gmail → Settings → Filters and Blocked
Addresses → Create a new filter**. Only deterministic, sender-based rules
belong here — anything requiring judgment about importance goes to Part 2
instead.

### 1. Real estate alias → ~~own label~~ — skipped, already handled
- An existing filter already routes `to:(lwizinski+realestate@gmail.com)` to
  "Claude searches." Leaving it alone rather than creating a competing
  "Real Estate" filter.

### 2. Known low-quality marketing → Review-Delete — done
- **Search:** `from:(uphubroad.work)`
- **Action:** Apply label "🗑️ Review-Delete", Skip Inbox
- `update@uphubroad.work` ("home insurance quotes") came back **suspicious**
  on a threat-intelligence check. Already manually marked as spam; filter
  added to catch future mail from the same domain automatically.

### 3. Account/security alerts → Alerts — still to do
- **Search:** `from:(id.apple.com) OR from:(email.apple.com) OR from:(accounts.google.com)`
- **Action:** Apply label "Alerts" (leave in Inbox — these can be
  time-sensitive, e.g. password-reset or account-recovery notices)

Everything else that used to get auto-sorted by MailSynth — priority calls
like "Action Needed" vs. "Medium," or judgment calls like political
fundraising blasts — can't be expressed as a sender/subject rule. That's what
Part 2 is for.

## Part 2 — Going-forward triage (replaces the daily digest)

Active: a "Gmail Daily Triage" Routine runs daily at 8am ET. It:
1. Searches `in:inbox has:nouserlabels newer_than:2d` (mail that arrived and
   wasn't caught by a filter above).
2. Applies judgment to sort it into the existing label taxonomy
   (Action Needed / Medium / Read Later / Misc / etc.), the same way MailSynth did.
3. Reports back with a short digest of anything landing in "Action Needed" or
   anything that looked like phishing/a scam.

It's bound to this Claude session (fires as a new turn here each morning)
rather than a fresh session, since this org doesn't currently support
granting Gmail connector access to fresh-session Routines.

## Part 3 — Backlog cleanup (2026-08-02 session)

The "🗑️ Review-Delete" label had ballooned to ~7,800 messages. Worked through
identifying what's safe to bulk-delete via Gmail's own "select all matching /
Trash" UI (no bulk-delete API available here). Segmentation used:

- **Safe to bulk-trash:** `label:"🗑️ Review-Delete" -is:starred -label:Finance -label:Passwords -label:"Tax receipts" -has:attachment`
- **Hold back for manual review:** starred threads (6), Finance-labeled (~200+,
  includes real subscription records), Passwords-labeled (~200+, mostly stale
  Apple ID reset notices), anything with attachments (real receipts — vet
  invoices, Paddle payment receipts, TSA PreCheck renewal), Tax receipts (1).

Additional bulk-delete queries used for other big buckets (Shopping, Older
than 3 months, general newsletter cleanup via "unsubscribe" keyword) — same
exclusion pattern each time.

**Confirmed scams, reported to threat intel:** a "homeowner stimulus/mortgage
relief" scam cluster on throwaway domains — `yourconcpway.cyou`,
`zenbflowlink.cyou`, `gorainarmweb.rest` — plus a "debt relief/refinance"
cluster of five `.xyz` domains (`scalemetricproleaddevelop.xyz`,
`onlineprivacytoday.xyz`, `marketselectgroupbasiscommand.xyz`,
`worthcorefirmbeaconshield.xyz`, `stakerefinedportalsignalvertex.xyz`). All 8
reported via Malwarebytes ScamGuard. Catch-all search for these senders:

```
{from:yourconcpway.cyou from:zenbflowlink.cyou from:gorainarmweb.rest from:scalemetricproleaddevelop.xyz from:onlineprivacytoday.xyz from:marketselectgroupbasiscommand.xyz from:worthcorefirmbeaconshield.xyz from:stakerefinedportalsignalvertex.xyz}
```

### Filter candidates identified but not yet added

| Filter | Search | Action |
|---|---|---|
| Political fundraising blasts | `from:(shared1.ccsend.com) OR from:(moody.senate.gov) OR from:(cbcpac.org)` | Label Review-Delete, skip inbox — confirm intent first, this is a content judgment call rather than a clear spam/vendor domain |
| Recurring retail/beauty marketing | `from:(ursamajorvt.com) OR from:(zulily.com) OR from:(pinchme.com) OR from:(hello.us.mercari.com)` | Label Shopping, skip inbox |
| Car-dealer lead-gen spam | `from:(alstspecials.com) OR from:(edealerhub.com) OR from:(truecarmail.com)` | Label Review-Delete, skip inbox — third-party marketing platforms, not real dealership/manufacturer mail |
| Today's reported scam senders | the 8-domain query above | Label Review-Delete or Spam, skip inbox |
