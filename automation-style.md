# Wiz Manor — Automation House Style

House conventions for authoring Home Assistant automations and scripts in this config.
Derived from the existing `automations.yaml`. When writing or editing an automation,
follow these so new work matches what's already here. Examples cite real automations.

---

## 1. Schema: use the modern (plural) keys

Write new automations in the current HA schema, not the legacy one:

- Top level: `triggers:`, `conditions:`, `actions:` (plural).
- Inside items: `trigger:`, `condition:`, `action:` (e.g. `trigger: state`, `action: light.turn_on`, `condition: numeric_state`).
- Do NOT use the legacy `platform:` / `service:` keys in new work. Older automations still use them; leave them unless you're already rewriting that automation.

Reference: "Living Room — Ambient Manager" and "Living room lights on - Morning" use the modern style.

## 2. Naming (`alias:`)

- Title Case, descriptive, human-readable.
- **Namespace prefix with a colon** for families of automations: `Oura: Capture bedroom temp at bedtime`, `Commute: Morning announcer with Waze (v2)`, `Alert: HA Unexpected Restart`, `Health Tags: Daily Reset at 4am`.
- **Room/area prefix uses an em dash**: `Living Room — Ambient Manager (Lux On/Off)`, `Pollen Alert Level — Daily Reset`, `Backup — When core update available`. This em-dash-in-aliases is an established house convention — keep it (it does not apply to chat prose, only to automation names).
- **Version suffix** for iterated automations: `(v2)`. When an automation is materially rewritten, bump the version in the alias.
- Emoji prefix is used for a few high-signal alerts (`🦅 Eagles Score - Flash Green`, pollen alerts). Use sparingly, only where it aids scanning.

## 3. IDs

- Newer automations use **descriptive snake_case IDs** (`oura_capture_bedroom_temp_bedtime`) or **date-prefixed** (`20260416_workday_tomorrow_refresh`). Prefer descriptive snake_case for new hand-written automations.
- Legacy numeric timestamp IDs (`'1635902622080'`) exist from the UI editor — don't renumber them, just leave them.

## 4. `description:` is for rationale and TODOs — write it

Non-trivial automations carry a real description that explains WHY and records future plans, not just what. This is a strong house convention. Examples:

- Pollen Spike Alert documents the whole tier-tracker design and why it uses `moderate` not `medium`.
- Power Outage / Restoration Alert is labelled `v1:` and notes "When voltage sensor is added, rewrite to v2 with brownout/sag detection."

For anything with branching or state-tracking, write a description covering the logic, edge cases handled, and any planned next version.

## 5. Mode

- Default `mode: single`. Use it unless there's a reason not to.
- `mode: restart` for automations that should restart on re-trigger (fade/escalation loops, wait-based sequences).
- Add `max_exceeded: silent` on high-frequency triggers to keep the log quiet (see Pollen Spike Alert).

## 6. Branching pattern: trigger IDs + `choose`

The dominant multi-branch pattern is: give each trigger an `id:`, then branch in actions with `choose:` where each branch leads with `- condition: trigger\n  id: <trigger_id>`. Combine with additional state conditions per branch. See "Living Room — Ambient Manager" (lux_below_on / lux_above_off / early_morning_ended).

## 7. Self-documenting step aliases

Use `alias:` on individual action/sequence steps to narrate multi-phase logic, e.g. the Sonos Wake Alarm uses `Phase 1 — Set initial low volume`, `Phase 2 — Alarm escalation loop`, `Phase 3 — Gentle light fade-in once up`. Do this for any sequence longer than a few steps.

## 8. Gating conditions (apply these by default)

- **`calendar.vacation` state `off`** — gate any personal/house comfort automation that shouldn't fire while away (TV sound, wind-down announcements, wake alarm, pollen alerts). `calendar.vacation` means "away from the house for an extended period," used to mute personal automations for a house/dog-sitter — it is NOT empty-house occupancy theater. Add this condition to new personal automations unless they must run while away (e.g. security, fridge alert, power outage).
- **`input_boolean.in_bed`**, **`group.morning`**, **`input_boolean.workday_tomorrow`**, **`binary_sensor.early_morning`** — common state gates for sleep/wake/work context.
- Presence: trigger on `person.lara_wiz` zone events. Light/comfort automations key off **human** presence, never the dog. Johnny (the dog) has his own automations; don't let dog motion drive human-comfort lighting.

## 9. Lighting conventions

- **Lux hysteresis:** separate ON and OFF thresholds via helpers (`input_number.living_room_lux_on` / `_off`, `input_number.bedroom_lux_on` / `_off threshold`), with `for:` debounce durations on the numeric_state triggers (e.g. `for: 00:01:00` to turn on, longer to turn off). Never use a single threshold for on/off.
- Always include a `transition:` in light service data (e.g. `transition: 5` on, `transition: 1` off).
- Respect Adaptive Lighting: toggle `switch.adaptive_lighting_sleep_mode_*` rather than fighting it.
- Occupancy-hold: motion `to: 'on'` → turn on → `wait_for_trigger` motion `to: 'off'` with a `timeout:` and `continue_on_timeout: true` → turn off. See "Shut off Johnny's light".

## 10. Notifications

- Push to **`notify.mobile_app_iphone`** with `data: { title:, message: }`.
- Title = short label, often emoji-prefixed by severity (`🚨` very high, `⚠️` high, `🌿`/info). Message = one or two sentences, with live values via Jinja: `{{ states('sensor.total_pollen_index') }}`.
- **Anti-spam / re-alert guard:** for tiered alerts, track the highest tier reached with an `input_number.*_alert_level_reached` and only fire when crossing into a higher tier; reset it on a daily-reset automation. Don't emit repeat notifications for the same condition. (Pollen Spike Alert + "Pollen Alert Level — Daily Reset" are the reference implementation.)

## 11. Spoken announcements

Use `script.sonos_say` with `restore: true`, `ungroup: true`, an explicit `player:` (e.g. `media_player.living_room_arc`), `message:`, and a `volume:` (~0.6). Used for wind-down and commute announcements.

## 12. Templates (Jinja)

- Filter out `unknown` / `unavailable` explicitly in both triggers (`not_from` / `not_to`) and template conditions before acting on a state.
- Use defensive map lookups: `{% set levels = {...} %}` then `levels.get(new, 0)`.
- Normalize with `| lower` / `| title` when mapping or displaying states.

## 13. Workflow / safety

- Edit config through the File Editor / VS Code add-on or git, **not over the Samba share** while HA holds the file open (that leaves `.smbdelete*` artifacts and can log a transient duplicate-unique-id error).
- After editing automations, run `ha_check_config` before reloading/restarting.
- Reload automations (or Reload Command Line / YAML) rather than full-restarting HA when possible.
- New device-backed automations: prefer entity_id targets over raw `device_id:` where an entity exists, for readability (some legacy ones use device_id + illuminance device conditions; that's fine to leave).
- **Scripts load from a `scripts/` directory (`!include_dir_merge_named scripts`), NOT `scripts.yaml`.** The `ha_config_set_script` API tool writes to `scripts.yaml`, which nothing includes here — the write validates and reads back fine, but no entity ever appears, silently. Bit this project twice (2026-08-10, 2026-08-12). To add or edit a script: write `scripts/<script_id>.yaml` directly (script_id as the top-level key, one file per script) and run `ha_call_service("script","reload")`; verify with `ha_get_state("script.<id>")`, not just the config-read tool. Full writeup: `reference_ha_config_include_layout.md` in project memory.
