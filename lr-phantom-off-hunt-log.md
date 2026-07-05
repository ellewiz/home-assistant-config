# LR Lights Phantom-Off Hunt — Run Log

Running log of the `lr-lights-phantom-off-source-hunt` scheduled task. Newest entries at the top. Each entry mirrors the summary pushed to the iPhone, with the fuller detail underneath.

---

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
