# LR Lights Phantom-Off Hunt — Run Log

Running log of the `lr-lights-phantom-off-source-hunt` scheduled task. Newest entries at the top. Each entry mirrors the summary pushed to the iPhone, with the fuller detail underneath.

---

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
