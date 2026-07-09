# LR Lights Phantom-Off Hunt — Run Log

Running log of the `lr-lights-phantom-off-source-hunt` scheduled task. Newest entries at the top. Each entry mirrors the summary pushed to the iPhone, with the fuller detail underneath.

---

## 2026-07-08 (Wed)

**iPhone push:** No phantom off today (Wed Jul 8) — both LR offs were internal HA automations: 12:18am bedtime script and 7:23am 'leave home' geofence (both carry a parent_id, so neither is the phantom). No ~5:09pm away-day off; debug logging re-armed, hunt continues.

**Detail:**
- Two off transitions today, both internal HA automations (neither the phantom):
  - **04:18:22 UTC (00:18 EDT, 12:18am)** — the intentional bedtime off (script.shut_down_bedtime's delayed final step). Ambient logger: `was on for 80.5 min | 0 lx | motion off | presence off | manual`. Known/by-design, not the hunt target.
  - **11:23:58 UTC (07:23 EDT)** — `automation.turn_off_the_lights_when_i_leave_home`, triggered at 11:23:57 by person.lara_wiz leaving Wiz Manor (normal workday departure; commute leave-by was 07:21–07:23). It turned off the undercabinet strip + all three LR bulbs + the group in one command; per-bulb spread ~4ms (corner .320 / torchiere .322 / next_to_couch .324), which is the single-group-`turn_off` signature, not an external event. Lights stayed off 56 min, back on 12:19:46 UTC.
- **Backstop:** fired at 11:24:08 UTC (~10s after the 7:23 off) but **execution = failed_conditions** — it short-circuited at condition/0 (`binary_sensor.early_morning` was on at 07:23, mirroring the Ambient Manager), and would independently have failed condition/2 (null user_id AND null parent_id) because the off carried **parent_id=01KX0QGSV80ECK1MHGJEVCDVHC** — exactly the "leave home" automation's own context (user_id=null). So it correctly declined to re-assert; no "LR Lights Backstop" logbook line (the action never ran). The bedtime off's backstop run (04:18:32) also returned failed_conditions, correctly.
- **No HA restart** today (no Core start/stop in the 20h logbook; the only "Home Assistant" search hits are TTS Cloud and an `update.home_assistant_mcp_server_update` entity toggling on 12:27→off 16:04 — an add-on update notice, not a Core restart). Neither off is a restart artifact.
- **No ~5:09pm (21:09 UTC) away-day off.** It is now 19:07 EDT, past the window; the group has been on since 12:19 UTC. Brief corner/torchiere `unavailable` blips at 20:55 and 22:27 UTC are the known Zigbee reachability flap (recover within ~13–51s), not offs.
- **Logging:** no restart, so prior overrides persisted; re-armed homekit/homekit_controller/hue debug defensively to guarantee coverage. (`error_log` source still 404 via MCP; system log carries only WARNING/ERROR, so DEBUG lines remain unreadable this way.)
- **Recommendation:** keep the task running. Both of today's offs are internal/explained (each carries a parent_id), so there is no null-context away-day phantom to capture — the source remains unconfirmed, nothing to disable. Note the 7:23am "leave home" off is the same benign workday-departure automation seen at 7:26am on Jul 7; it is not the hunted ~5:09pm phenomenon.

## 2026-07-07 (Tue)

**iPhone push:** No phantom off Tue Jul 7 — both offs explained (bedtime 11:57pm, leave-home 7:26am), no ~5:09pm off; logging re-armed. New bug: the backstop re-asserted the lights ON 10s after the bedtime off (button-started chain carries no user_id), so LR lights stayed on all night — backstop needs a bedtime exclusion.

**Detail:**
- Two off transitions today, both explained (neither the phantom):
  - **03:56:56 UTC (23:56 EDT, Jul 6 11:56pm)** — the intentional bedtime off. script.shut_down_bedtime ran 03:45:55→03:56:55 (delayed final step ~11 min); the group off landed 0.9s after the script finished — exact match. Ambient logger: `was on for 982.0 min | 0 lx | motion off | presence off | auto`.
  - **11:26:40 UTC (07:26 EDT)** — `automation.turn_off_the_lights_when_i_leave_home`, triggered at 11:26:39 by person.lara_wiz leaving Wiz Manor (normal workday departure). Lights came back on 1.8 min later at 11:28:25 on motion (`presence on`).
- **Backstop — NEW REGRESSION:** for the bedtime off it **passed all conditions and RE-ASSERTED the lights ON at 03:57:06** (trace `finished`; logbook "LR Lights Backstop … user_id=None parent_id=01KWXAXCB3NEYSCJG0R5E6GPWN"). The group then stayed **on all night (11:57pm→7:26am, 449.6 min)**, defeating the bedtime script. Root cause: condition 3 only respects offs that carry a non-null `user_id`, and last night's bedtime chain was started from the physical Hue Tap (no user anywhere in the chain), so `user_id=None` looked "external". On the Jul 5 and Jul 6 nights the same bedtime off carried a user_id (phone/UI-started chain) and was correctly blocked — the user-id gate is unreliable for the bedtime script. The non-null parent_id confirms an internal HA chain, NOT the classic null-parent phantom.
- For the 7:26am off the backstop correctly declined (condition/0: binary_sensor.early_morning was on).
- **No HA restart** in the last 24h (no Core start/stop in the logbook). Neither off is a restart artifact.
- **No ~5:09pm (21:09 UTC) away-day off.** Lights on continuously from 11:28:25 UTC through the window (still on at 23:07 UTC / 7:07pm EDT) — the window passed clean.
- **Logging:** no restart, so prior overrides persisted; re-armed homekit/homekit_controller/hue debug defensively. (`error_log` source still 404 via MCP.)
- **Recommendation:** keep the hunt task running (source still unconfirmed — nothing to disable). Separately, **fix the backstop** so it can't fight the bedtime script — e.g. also require `input_boolean.in_bed` off before re-asserting, or have script.shut_down_bedtime set a short-lived "expected-off" flag the backstop checks.

## 2026-07-06 (Mon)

**iPhone push:** No phantom off today (Mon Jul 6): only the 10:46pm bedtime off and a 7:34am motion auto-off (internal, parent_id set); no ~5:09pm away-day off. Still inconclusive — debug logging re-armed.

**Detail:**
- Two off transitions today, both internal (not the phantom):
  - **02:46:01 UTC (22:46 EDT, Jul 5 10:46pm)** — the intentional bedtime off (script.shut_down_bedtime ran at 02:33:59, delayed final step ~12 min later). Ambient logger: `was on for 947.8 min | 0 lx | motion off | presence off | manual`. Known/by-design, not the hunt target.
  - **11:34:15 UTC (07:34 EDT)** — motion/presence auto-off: `was on for 68.9 min | smoothed 2 lx | motion off | presence off | auto` (2 lx is far below lux_off 45, so motion/presence-clear, not a lux off). Lights came back on 42s later at 11:34:57 on motion (`presence on`).
- **Backstop:** fired for both offs (02:46:11 and 11:34:25 UTC, ~10s after each), both **execution = failed_conditions** — neither treated as external. The 7:34am off carried **parent_id=01KWVKA6AM4P22BRWXGJ0237R2, user_id=null**, a non-null context chain confirming an HA-automation origin, not the classic null-parent phantom. (No "LR Lights Backstop" logbook line either run — the action never ran.)
- **No HA restart** today (no Core start/stop in the logbook over 24h; today's Music Assistant add-on restart + config-entry reload does not touch Core or the logger overrides). Neither off is a restart artifact.
- **No ~5:09pm (21:09 UTC) away-day off.** Lights on continuously since 11:34:57 UTC and still on at 23:07 UTC (7:07pm EDT) — the window passed clean.
- **Logging:** no restart, so prior overrides persisted; re-armed homekit/homekit_controller/hue debug defensively to guarantee coverage. (`error_log` source still 404 via MCP; system log carries only WARNING/ERROR, so DEBUG lines remain unreadable this way.)
- **Recommendation:** keep the task running. No away-day phantom captured today; the source remains unconfirmed — nothing to disable.

## 2026-07-05 (Sun)

**iPhone push:** No phantom off today (Sun Jul 5, you were home all day). Lights on since 6:58am, no ~5:09pm away-day off. Still inconclusive; debug logging re-armed.

**Detail:**
- **No off today.** Zero off transitions in the July 5 ET window. The group turned **on at 10:58:14 UTC (06:58 EDT)** on morning motion (`smoothed 1 lx / raw 1 lx | motion on | presence off | auto`) and has stayed on continuously since (still on at 19:09 EDT). The only nearby off was the intentional bedtime off at **03:58:55 UTC (23:58 EDT, July 4)** — `was on for 58.6 min | 0 lx | motion off | presence off | manual`, i.e. script.shut_down_bedtime's delayed final step, by design and outside today's window. Not the hunt target.
- **Backstop:** one run today, at **03:59:05 UTC** (~10s after the bedtime off), execution = **failed_conditions** — it correctly declined to re-assert (recognized-context bedtime off, not external). No "LR Lights Backstop" logbook line (the action never ran), and no phantom off-event to inspect for user_id/parent_id today.
- **No HA restart** today (empty "Home Assistant" logbook search over 20h; the group was continuously on with no `unavailable` gap; `person.lara_wiz` continuous `home`). No restart-recovery artifact.
- **No ~5:09pm (21:09 UTC) away-day off.** Expected — it is Sunday July 5 and Lara was **home all day** (`person.lara_wiz` = `home` with no state change), so the away-day trigger condition never existed. It is now past 19:09 EDT and the window passed clean.
- **Logging:** no restart, so the prior overrides persisted; re-armed homekit/homekit_controller/hue debug defensively to guarantee coverage. (`error_log` source still 404 via MCP; system log carries only WARNING/ERROR, so DEBUG lines remain unreadable this way.)
- **Recommendation:** keep the task running. No away-day phantom to capture today (Lara home on a Sunday), so the source remains unconfirmed — nothing to disable.

## 2026-07-04 (Sat)

**iPhone push:** No phantom off today (July 4, you were home all day). The 3:50pm LR off was the Ambient Manager's lux auto-off (room hit 48 lx, above the 45 lux-off), confirmed by trace; no ~5:09pm away-day off. Debug logging re-armed.

**Detail:**
- Two off transitions today, both internal/known (neither the phantom):
  - **07:38:38 UTC (03:38 EDT)** — the intentional bedtime off (script.shut_down_bedtime's delayed final step). Ambient logger: `was on for 1662.8 min | 0 lx | motion off | presence on | manual`. Known/by-design.
  - **19:50:51 UTC (15:50 EDT, 3:50pm)** — **Ambient Manager lux auto-off, confirmed by trace.** `automation.living_room_ambient_manager` ran at 19:50:50.245 on a rising lux crossing (`sensor.living_room_illuminance_smoothed` 45→46, i.e. above lux_off 45), took the OFF branch and called `light.turn_off` on the group (transition 1). Ambient logger at the off: `was on for 605.2 min | smoothed 48 lx / raw 51 lx | motion off | presence on | auto`. Per-bulb spread ~1s (torchiere 19:50:50.570 vs corner/next_to_couch 19:50:51.586/.588) — the sequential-command signature, not the 4ms-simultaneous phantom.
- **Backstop:** fired at 19:51:01 (~10s after) but **execution = failed_conditions** — condition/1 (smoothed lux below lux_on 18) was false at 48 lx, so it correctly declined to re-assert in a bright room. The off-event context id (`01KWQAY1M5KWD7H9RS1X2QX686`) matches the Ambient Manager run's own context exactly, and that run carried **parent_id=01KWQAMWN3WB1NK11QCAP9XZJQ, user_id=null** — a non-null HA-automation origin, not the classic null-parent phantom. (No "LR Lights Backstop" logbook line, since the backstop action never ran.)
- **No HA restart** today (no Core start/stop in the logbook; `person.lara_wiz` continuous `home` since yesterday 23:09 UTC). The 19:50 off is not a restart artifact.
- **No ~5:09pm (21:09 UTC) away-day off.** Expected — it is July 4 (Sat) and Lara was **home all day** and present in the LR when the 3:50pm lux-off fired. A second Ambient Manager lux re-eval ran at 21:15 UTC and left the group off; lights auto-came-on at 22:52 UTC (18:52 EDT) as the room darkened (14 lx). Corner bulb logged its usual separate Zigbee flaps (16:03, 17:37, 19:16, 19:26 UTC unavailable) — the known reachability issue, not the phantom.
- **Logging:** no restart, so prior overrides persisted; re-armed homekit/homekit_controller/hue debug defensively to guarantee coverage. (`error_log` source still 404 via MCP; system log carries only WARNING/ERROR, so DEBUG lines remain unreadable this way.)
- **Recommendation:** keep the task running. Today produced no away-day phantom to capture (Lara home on a holiday), so the source remains unconfirmed — nothing to disable.

## 2026-07-01 (Wed)

**iPhone push:** No phantom off today. LR lights went off at 11:15pm (bedtime script) and 7:31am (motion/lux auto-off, motion+presence clear); no ~5:09pm away-day off. Debug logging re-armed.

**Detail:**
- Two off transitions today, both internal (not the phantom):
  - **03:15:16 UTC (23:15 EDT, 11:15pm)** — the intentional bedtime off. Ambient logger: `was on for 271.3 min | 0 lx | motion off | presence off | manual`. The `manual` tag = a recognized service context (script.shut_down_bedtime's delayed final step). Known/by-design, not the hunt target.
  - **11:31:51 UTC (07:31 EDT, 7:31am)** — motion/presence auto-off: `was on for 92.8 min | smoothed 20 lx | motion off | presence off | auto` (20 lx is below lux_off 45, so this is the motion/presence-clear auto-off, not a lux off). Lights had come back on at 09:59:03 UTC on morning motion.
- **Backstop:** fired for **both** offs (03:15:26 and 11:32:01 UTC, ~10s after each) and both returned **execution = failed_conditions** — the null-context check returned false, so neither was treated as external. The 7:31am off carried **parent_id=01KWEQ65SPQCTHY9RCVPR4KAHH, user_id=null**, i.e. a non-null context chain confirming an HA-automation origin, not the classic null-parent phantom. (No "LR Lights Backstop" logbook line either run, since that line only writes when the external-off condition passes.)
- **No HA restart** today (no Core start/stop in the logbook). An OS update became available at 16:02 UTC — informational, unrelated to any light off.
- **No ~5:09pm (21:09 UTC) away-day off.** It is now past 19:00 EDT and no off landed in that window; the lights have been on since 09:59 UTC apart from the 7:31am motion auto-off.
- **Logging:** no restart, so prior overrides should have persisted; re-armed homekit/homekit_controller/hue debug defensively to guarantee coverage. (`error_log` source still 404 via MCP; system log carries only WARNING/ERROR, so DEBUG lines remain unreadable this way.)
- **Recommendation:** keep the task running. No clean away-day phantom captured at debug level yet, so the source stays unconfirmed — nothing to disable.

## 2026-06-30 (Tue)

**iPhone push:** No phantom today. Both LR offs were internal HA automations (motion auto-off ~7:29a; lux auto-off ~5:18p with someone home, parent_id set). No 5:09pm away-day phantom; debug logging re-armed.

**Detail:**
- Two off transitions today, both internal (not the phantom):
  - **11:29:17 UTC (07:29 EDT)** — motion/presence auto-off (`motion off | presence off`, smoothed 14 lx). Lights came back on 1.8 min later at 11:31:04 on motion. Per-bulb timestamps spread ~1s (torchiere 11:29:15.99 vs others 11:29:17.00), not the 4ms simultaneous phantom signature.
  - **21:18:26 UTC (17:18 EDT)** — lux auto-off: smoothed **48 lx ≥ lux_off 45**, `presence on` (someone home). Per-bulb spread ~1s (corner 21:18:25.30 vs others 21:18:26.32). Trigger context `parent_id=01KWD6BH6TTJGXQZKZVADJBKX4`, user_id null.
- **Backstop:** fired for both offs (11:29:27, 21:18:36) but **execution = failed_conditions** both times — condition/1 (null-context check) returned false, so neither off was treated as external. The 21:18 off carried a **non-null parent_id**, confirming an HA-automation origin, not the classic null-context phantom.
- **No HA restart** today (no Core start/stop in logbook; the 17:04 UTC HA Cloud switch blip is a cloud reconnect, not a Core restart, and is nowhere near either light off).
- **No ~5:09pm (21:09 UTC) away-day off.** The nearest off (21:18) is a legit lux auto-off with presence ON, distinct from the away-day phantom (presence off, 4ms-simultaneous, null parent_id).
- **Logging:** no restart, so prior debug overrides should have stayed active; re-armed homekit/homekit_controller/hue debug defensively to guarantee coverage. (`error_log` source still 404 via MCP; system log carries only WARNING/ERROR, so debug lines remain unreadable this way.)
- **Recommendation:** keep the task running. No clean away-day phantom has been captured at debug level yet, so the source remains unconfirmed — nothing to disable.

## 2026-06-29 (Mon)

**iPhone push:** Inconclusive today: an off hit at 9:18am, but only 33s after an UNEXPECTED HA restart that wiped debug logging (so it wasn't captured, and it carried a non-null parent context unlike the classic phantom off). No 5:09pm off today. Debug logging re-armed.

**Detail:**
- One backstop-flagged external off today, at **13:18:51 UTC (09:18 EDT)**. Backstop re-asserted 10s later; logged `user_id=None parent_id=01KW9RGN9EDRJKGJMV4K5YQ5DZ`.
- It landed **33s after an unexpected HA restart** (HA stopped 13:17:14, started 13:18:18; `automation.alert_ha_unexpected_restart` fired). Whole LR group went `unavailable` 13:17:49→13:18:18. Likely a restart-recovery artifact (HASS Bridge / a HomeKit controller re-asserting cached "off" on reconnect) — not confirmed from a debug line.
- Differs from the classic phantom off: **non-null parent_id** (classic was null) and 9am rather than the ~5:09pm window.
- **No 5:09pm (21:09 UTC) away-day off today.** Lights stayed on from 13:19 onward (End table's 18:05 and 18:32 `unavailable` blips are the known separate Zigbee flap).
- **Logging:** the restart wiped the `logger.set_level` debug overrides, so the 13:18:51 off was not captured at debug level. Re-enabled homekit/homekit_controller/hue debug. (`error_log` source still 404 via MCP; system log carries only WARNING/ERROR.)
- **Recommendation:** keep the task running — inconclusive for the hunt, no clean away-day off captured yet. Worth checking why HA restarted unexpectedly at 13:17 if it recurs.
