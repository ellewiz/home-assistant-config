# LR Lights Phantom-Off Hunt — Run Log

Running log of the `lr-lights-phantom-off-source-hunt` scheduled task. Newest entries at the top. Each entry mirrors the summary pushed to the iPhone, with the fuller detail underneath.

---

## 2026-07-11 (Sat)

**iPhone push:** No LR off at all today (Sat Jul 11) — lights on since 6:57am and you were home through the 5:09pm window, so no away-day test. No restart; logging re-armed, hunt continues.

**Detail:**
- **No off today.** Zero off transitions in the July 11 ET window. The group was off at midnight (last night's intentional bedtime off landed 03:41 UTC / 11:41pm EDT Jul 10, outside today's window), turned **on at 10:57:35 UTC (06:57 EDT)** and has stayed on continuously since (still on at 19:08 EDT).
- **Backstop:** zero runs in today's window. Its most recent run was 03:41:13 UTC (11:41pm EDT Jul 10, the bedtime off), execution = failed_conditions — correctly declined. No off-event today to inspect for user_id/parent_id.
- **No HA restart** today. The only "Home Assistant" logbook hit is `update.home_assistant_core_update` flipping on at 21:22 UTC (a new Core release became available — informational, not a restart). No Core start/stop; group and person tracker continuous.
- **No ~5:09pm (21:09 UTC) away-day off, and the window was NOT a live test.** `person.lara_wiz` was **home continuously all day** (Saturday, no state changes), so the away-day trigger condition never existed. The lights were on straight through the window.
- **Logging:** no restart, so prior overrides persisted; re-armed homekit/homekit_controller/hue debug defensively (logger.set_level succeeded). `error_log` still 404s via MCP, so DEBUG lines remain unreadable that way.
- **Recommendation:** keep the task running. Quiet 11th consecutive monitored day with no phantom, but today (like most recent days) was not a live away-day test. Still pending from Jul 9: Lara's Home app check for whether the Hue bridge itself is HomeKit-paired (Home Settings → Hubs & Bridges) — that answer closes or opens the last Hue-side door. Note: a Core update is now pending (flagged 21:22 UTC); when it's installed, that restart WILL wipe the debug overrides — the next run after any update must re-arm.

## 2026-07-10 (Fri)

**iPhone push:** No phantom off today (Fri Jul 10). Both LR offs (8:27am, 10:50am) were your own leave-home departures: lights cut ~1s after your phone left home, each carried a parent_id and the backstop declined. You were home through the 5:09pm window, so no away-day test today; logging re-armed.

**Detail:**
- Three off transitions in the 24h window, all internal or known (none the phantom):
  - **03:05:26 UTC (23:05 EDT, Jul 9 11:05pm):** the intentional bedtime off (script.shut_down_bedtime's delayed final step). Ambient logger: `was on for 839.8 min | smoothed 0 lx / raw 0 lx | motion off | presence off | manual`. Overnight, by design, not the hunt target.
  - **12:27:34 UTC (08:27 EDT):** leave-home departure off. `person.lara_wiz` went `not_home` at 12:27:33 UTC (1s before the off) and tracked away from Wiz Manor on a short errand (back `home` 12:42:14 UTC / 08:42 EDT). Ambient logger: `was on for 143.5 min | smoothed 19 lx / raw 19 lx | motion off | presence off | auto`. Group came back on 12:35:53 UTC (8.3 min later).
  - **14:50:53 UTC (10:50 EDT):** second leave-home departure off. `person.lara_wiz` went `not_home` at 14:50:52 UTC (1s before the off), away on a second short errand (back `home` 15:13:23 UTC / 11:13 EDT). Ambient logger: `was on for 135.0 min | smoothed 10 lx / raw 12 lx | motion off | presence off | auto`. Group came back on 15:17:52 UTC (27 min later) and has stayed on since.
- **Backstop:** fired ~10s after each off (03:05:36, 12:27:44, 14:51:03 UTC), all three **execution = failed_conditions** (none treated as external):
  - 12:27:44 run: off-event context **parent_id=01KX5ZYNZWHBH12GR65Q8YVGW4, user_id=null**; short-circuited at the lux gate (condition/1: 19 lx not below lux_on 18) before reaching the null-context check.
  - 14:51:03 run: off-event context **parent_id=01KX6853Q5P9VGSK33G9HJRG8C, user_id=null**; passed condition/0 and condition/1 (10 lx below 18, dark room) then correctly failed condition/2 (requires null user_id AND null parent_id) because the parent_id was non-null.
  - Both non-null parent_id values confirm an internal HA-automation origin (the leave-home departure chain), not the classic null-parent phantom. No "LR Lights Backstop" logbook line on any run (the re-assert action never executed).
- **No HA restart** today. Logbook "Home Assistant" search over 24h shows only `tts.home_assistant_cloud` (00:30) and `update.home_assistant_mcp_server_update` toggling (off 02:09, on 21:26 UTC, an add-on update notice), with no Core start/stop. The LR group and person tracker were continuous. Neither off is a restart artifact.
- **No ~5:09pm (21:09 UTC) away-day off, and the window was NOT a live test.** The group has been on continuously since 15:17:52 UTC through now (23:08 UTC / 19:08 EDT). More important, `person.lara_wiz` was **home continuously from 15:13 UTC (11:13 EDT) onward**, so home during the 5:09pm window. Today's only away periods were the two short morning errands (08:27 to 08:42 and 10:50 to 11:13 EDT), neither in the hunted window.
- **Logging:** no restart, so the prior debug overrides persisted; re-armed homekit/homekit_controller/hue debug defensively (logger.set_level succeeded) to guarantee coverage. The `error_log` source still 404s via MCP, so DEBUG lines remain unreadable that way.
- **Recommendation:** keep the task running. Both of today's offs are internal leave-home departures carrying a non-null parent_id, so there was no null-context away-day phantom to capture, and the 5:09pm window was not a live away-day test (Lara home). The source stays unconfirmed; nothing to disable.

## 2026-07-09 (Thu)

**iPhone push:** No phantom off today — the 9:03am off was your own leave-home automation (late shift), and no 5:09pm off occurred. Debug logging re-armed; hunt continues.

**Detail:**
- Two off transitions today, both internal HA automations (neither the phantom):
  - **03:55:52 UTC (23:55 EDT, Jul 8 11:55pm)** — the intentional bedtime off (script.shut_down_bedtime's delayed final step). Known/by-design, not the hunt target.
  - **13:03:24 UTC (09:03 EDT)** — `automation.turn_off_the_lights_when_i_leave_home`, triggered by person.lara_wiz leaving Wiz Manor (late-shift departure, consistent with the 07:45 late-shift announcer). Logbook context confirms it directly. Ambient logger: `was on for 139.5 min | smoothed 8 lx / raw 7 lx | motion off | presence on | auto`. Per-bulb: corner 13:03:23.045, then torchiere/next_to_couch 13:03:24.055/.058 (~2ms apart) — sequential-command signature, not the 4ms-simultaneous phantom. Lights came back **on 2.3 min later at 13:05:41** via `automation.living_room_lights_on_morning` (Hue motion — after departure, so presumably Johnny) and stayed on all day.
- **Backstop:** fired at 13:03:34 UTC (~10s after) but **execution = failed_conditions** — conditions 0 and 1 passed, condition/2 (null user_id AND null parent_id) correctly failed: the off carried **parent_id=01KX3FKJ3A22G695B1W2H3S93F, user_id=null** — the leave-home automation's own context chain. The Jul 7 tightening is working as intended. No "LR Lights Backstop" logbook line (action never ran). The bedtime off's backstop run (03:56:02) also correctly returned failed_conditions.
- **No HA restart** today (no Core start/stop in the 24h logbook; only TTS Cloud entries and an MCP-server add-on update notice at 21:35 UTC). Neither off is a restart artifact.
- **No ~5:09pm (21:09 UTC) off, but the away-day window was NOT live** — CORRECTION (Lara flagged this; original entry wrongly claimed she was away at 5:09pm based on a "late shift" inference, without checking presence). `person.lara_wiz` history: left home 13:03 UTC (9:03am), at Work 16:07–17:42 UTC (12:07–1:42pm), **home 18:18–22:59 UTC (2:18pm–6:59pm)** — so she was HOME at 5:09pm and today is NOT evidence the phantom has stopped (same non-test category as Jul 4/Jul 5). The group has been on continuously since 13:05 UTC regardless.
- **Logging:** no restart, so prior overrides persisted; re-armed homekit/homekit_controller/hue debug defensively. (`error_log` source still 404 via MCP; DEBUG lines remain unreadable this way.)
- **Recommendation:** keep the task running — no phantom captured, and today was not a live away-day test (Lara home at 5:09pm), so the source remains unconfirmed and nothing can be disabled. Future runs: verify away/home from `person.lara_wiz` history, never infer it from shift type.

**Late-evening addendum — Hue bridge API audit (interactive session with Lara):**
- Lara ruled out Apple Shortcuts (none touch Hue) and reported the Hue app Automations tab has looked empty on prior checks. So we went past the app UI and audited the bridge itself over its local API (via her Mac; HA's key from `.storage/core.config_entries`; bridge 192.168.1.153, v2; note port 443 initially refused one connection, then worked — HTTP 80 fine throughout).
- **Bridge-side automations: EXONERATED.** v1 `/schedules` = empty. Hue Labs resourcelink container present but zero installed formulas. v1 `/rules` = 4 geofence→presence-flag rules from 2017/2021, `timestriggered: 0` (never fired once), and they only write a presence sensor, never lights; the underlying Geofence sensors are fossils (stuck `presence: true`, lastupdated May 2021). v2 `/behavior_instance` = exactly ONE behavior: a "Timer" (20 min → recall recipe), targeting room **Bedroom** (703c8731), currently stopped — cannot be the LR off.
- **Whitelist audit: no rogue clients.** ~70 API keys dating to 2014 (IFTTT, Yonomi, sleepcycle, DPHue, HueSunset, Huemote, party apps, etc.) — ALL dead, none used since 2022 at the latest, most 2016-2018. Only two keys used since June 27 2026: `home-assistant#wiz-manor` (constant, expected) and the current `Hue#iPhone` key (created Jun 7, **last used Jun 27 00:16 UTC** — dormant since).
- **Where this leaves the hunt:** the classic away-day ~5:09pm phantom has NOT recurred in 9 consecutive monitored days (Jun 29 → Jul 9). Any Hue-API-borne off would now have to come via HA's key or her phone's key (both accounted for). Remaining channels for the historical offs: (1) a HomeKit write via the HASS Bridge (arrives through HA's own key/context machinery; invisible to the whitelist), (2) her own Hue app/cloud session during the active window (key WAS active then, dormant since), (3) a direct HomeKit (HAP) pairing of the Hue bridge itself — keyless and whitelist-invisible, but only exists if the bridge is paired as an accessory in Apple Home. **Morning check for Lara: does the Home app show the Philips Hue Bridge itself as a paired bridge (Home Settings → Hubs & Bridges)?** If not, door 3 closes too.
- Working theory: whatever it was stopped around Jun 27-28 (coincides with the app's last use and the bedtime-script solve). If the bridge is not HomeKit-paired and nothing recurs, this may only ever be explainable historically, not catchable live. Side observation (not the phantom): the morning-lights automation re-lit the LR on motion at 9:05am after Lara had left, and the lights then burned all day in an empty house; if that recurs, consider gating `automation.living_room_lights_on_morning` on someone being home.

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
