# Wake Up Calendar Events: What the House Reads

**Calendar:** `calendar.master_calendar`
**Written:** 2026-08-23
**Applies to:** every event you want the morning automations to act on
**Consumers:** 7 automations

---

## The One Rule That Breaks Things

**The event summary must contain the two words `wake up`, separated by exactly one space.**

The match is case-insensitive and it is a substring, so anything before or after is fine. What is not fine is changing the phrase itself.

| Summary | Works | Note |
|---|---|---|
| `Wake up` | yes | the standard |
| `Wake up late shift` | yes | free text after is fine |
| `Wake up - early call` | yes | punctuation after is fine |
| `Early wake up` | yes | text before is fine |
| `WAKE UP` / `wake up` | yes | case does not matter |
| `Wake-up` | **NO** | hyphen instead of space |
| `Wakeup` | **NO** | no space |
| `Wake  up` | **NO** | two spaces |

**What a failed summary costs you**
Not one automation. Six of the seven check the summary, so a hyphen silently cancels the alarm, the AC pre-warm, the WFH flag, the alarm-armed marker, the failsafe, and the commute announcement. The day just quietly does nothing. Nothing errors and nothing notifies.

Verified 2026-08-23 by rendering all ten variants above through Home Assistant's own template engine.

---

## Description: `wfh` or `office`

**The description must contain one of those two words.** Case does not matter, and it is a substring match, so `Office day` and `wfh, dentist at 2` both work.

| Description contains | Result |
|---|---|
| `wfh` | `input_boolean.wfh_today` ON |
| `office` | flag OFF |
| both | **WFH wins** |
| neither, or blank | flag stays OFF, and **you get a phone notification** naming the event |

**Why WFH wins when both appear**
Your script prepopulates `office`. If you edit by appending rather than replacing, you end up with both words. The `wfh` test runs first, so your hand edit beats the script's default. That ordering is deliberate.

**The notification is new as of 2026-08-23.** Before that, a description matching neither word silently left the flag at yesterday's value. Now it tells you.

---

## Start Time Is Your Wake Target

Three automations fire *before* the start time. Set the start to when you want to be awake, not when you want things to begin.

| Fires at | Automation | What it does |
|---|---|---|
| start minus 30 min | Bedroom AC Gradual Warm | begins raising the bedroom off its overnight setpoint |
| start minus 20 min | Sonos Wake Alarm | starts the Lofi ramp at 3% volume |
| start minus 20 min | Wake Trigger: Mark Alarm Armed | stamps the sleep-metrics helper |
| start exactly | Sonos Wake Alarm Speaker Failsafe | checks the Sonos is actually playing, sounds a backup if not |
| start exactly | Set WFH Today Flag | reads the description, sets the flag |

---

## End Time Is Your Leave Target

Two automations key off the *end* of the event, not the start. This is easy to forget.

| Fires at | Automation | What it does |
|---|---|---|
| end minus 60 min | Commute: Morning announcer | speaks drive time from Waze |
| end minus 13 min | Heat the car | pre-heats or pre-cools, only in weather extremes |

**So the end time is not decorative.** Shortening the event moves both of these earlier.

---

## Worked Example: Your Current Weekday Event

Start `06:00`, end `07:25`, description `office`.

| Time | What happens |
|---|---|
| 05:30 | bedroom AC starts warming |
| 05:40 | Lofi wake music begins its ramp; alarm-armed marker stamped |
| 06:00 | failsafe verifies the Sonos is playing; WFH flag set to off |
| 06:25 | commute drive time announced |
| 07:12 | car heated, if the weather is extreme enough |

---

## Gates That Can Cancel The Whole Thing

Even a perfectly formed event does nothing if one of these is wrong. Listed because a silent no-op is easy to misread as a broken automation.

| Gate | Effect |
|---|---|
| `binary_sensor.workday` off | **No alarm, no AC pre-warm, no car heating.** Weekends and PTO days are off. |
| `calendar.vacation` on | Mutes the alarm, the commute announcement, and the AC pre-warm |
| `input_boolean.in_bed` off | **No alarm.** The 03:30 fallback forces it on for workdays, so this mostly self-heals |
| Start time outside 04:50 to 08:20 | The alarm's own window is 04:30 to 08:00 measured at start minus 20, so a start outside that range skips it |
| Not home | Cancels the car heating only |

**The big one**
The wake alarm is **workday-only**. Putting a Wake up event on a Saturday will not sound an alarm. For a weekend or one-off alarm use `Manual Bedroom Alarm (One-Off)` with `input_datetime.manual_alarm_time` instead.

---

## Location Field

Only one automation reads it. Commute: Morning announcer checks `location` **or** `description` for the word `office`, so putting the office address in `location` satisfies that one.

**But Heat the car reads the description only.** Keep `office` in the description regardless of what is in the location field, or the car will not get heated.

---

## Halloween

The Sonos Wake Alarm scans that day's events for any summary containing `halloween`. If one exists, it plays Sonos favourite `FV:2/58` instead of the usual Lofi `FV:2/57`. No change to the wake event needed, just a separate Halloween event on the same day.

---

## Quick Checklist

Before saving a wake event:

1. Summary contains `wake up`, one space, no hyphen
2. Description contains `wfh` or `office`
3. Start time is when you want to be awake
4. End time is roughly when you leave
5. If it is not a workday, the alarm will not fire, so use the manual alarm instead

---

## Related

`_reports/automation-clash-audit-2026-08-23.md` covers how the exact-equality bug on the summary field was found, and why five of six consumers already used the substring test while one did not.
