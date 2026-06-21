# Runbook: Replacing an existing Hue bulb (incl. swapping to a non-Hue brand)

Procedure for swapping a physical bulb that Home Assistant already knows about, while
keeping every automation, dashboard, scene, light group, and energy sensor working with
zero config edits. Written from the 2026-06-16 living-room corner swap (old ~11yr Hue
color bulb → Innr RB 285 C color A19), but applies to any Hue-bridge bulb swap.

The core trick: **reclaim the old entity_id** instead of find/replacing references.

---

## 0. Before you start
- Know the old entity's IDs (e.g. `light.living_room_corner`, `sensor.corner_zigbee_connectivity`,
  and any Powercalc sensors like `sensor.corner_lamp_power` / `sensor.corner_lamp_energy`).
- Know which area and Hue room the bulb belongs to.
- A quick `ha_deep_search("<old_object_id>", search_types=["automation","script","helper","dashboard"])`
  shows direct references. Note: light-group membership and Hue bridge-side scenes won't show
  up there, but the entity_id reclaim covers them anyway.

## 1. Physically pair the new bulb (Hue app)
- Screw in the new bulb. **Turn the fixture off then on** to put the bulb in pairing mode
  (this is the step that's easy to miss).
- In the Hue app, add the light and **assign it to the correct Hue room** (e.g. Living Room).
  This matters: Hue's color scenes (`scene.living_room_*`) and the Hue room group only include
  bulbs that are in the room. HA area assignment is separate and does NOT do this.

## 2. See how it landed in HA
- The old device gets removed when you swap it, which **frees up the old entity_id**.
- The new bulb shows up as an auto-named entity, e.g. `light.extended_color_light_1`
  (device named like "Corner light"). Find it with
  `ha_get_device(integration="hue", manufacturer="<innr|signify|...>")`.

## 3. Reclaim the old entity_id (the key step)
Rename the new entity back to the old ID so all references just keep working:

```
ha_set_entity(
  "light.extended_color_light_1",
  new_entity_id="light.living_room_corner",
  name="Corner lamp",
  area_id="living_room",
  new_device_name="Corner",
)
```
Also rename the connectivity sensor for tidiness:
```
ha_set_entity("sensor.extended_color_light_1_zigbee_connectivity",
              new_entity_id="sensor.corner_zigbee_connectivity")
```
Result: every automation, dashboard, light group, and scene that referenced the old
entity_id now drives the new bulb — no find/replace needed.

## 4. Fix the orphaned Powercalc sensors
When the old device left, its discovery-based power/energy sensors
(`sensor.<name>_power` / `_energy`) disappeared, but the Powercalc **config entry survives
orphaned**. Reload it to regenerate the sensors against the reclaimed entity_id:
- Find the entry: `ha_get_integration(domain="powercalc")` → note the entry_id whose title
  matches the bulb (e.g. "Corner lamp").
- Reload: `ha_call_service("homeassistant", "reload_config_entry", data={"entry_id": "<id>"})`
- Verify: `ha_search_entities("<name>_power")` → the sensors are back. The energy total
  carries over (no history gap).

## 5. Retune the Powercalc power profile (UI only — not available via the API/MCP)
After a reload the entry stays pinned to the **old bulb's** library profile (e.g. the swap
left it on `signify / LCT001`, the original Hue color bulb). To match the new bulb:
- HA → **Settings → Devices & Services → Powercalc** → search the entry → click its **gear**
  (Configure) → **Library options** → Next → set **manufacturer** and **model** to the new
  bulb → Next → Finish.
- Pick the model by spec (lumens/base). The Innr A19 806lm color = **RB 285 C**; the 1200lm
  version is RB 287 C. The Hue bridge only reports a generic "Extended color light," so match
  by the box, not by what HA shows.
- Verify: `sensor.<name>_power` reads a value with `calculation_mode: lut`.
- This flow is **not reachable from the Home Assistant MCP tools** — it has to be done in the
  browser/UI (Claude can drive it via the in-browser tools if asked).

## 6. Clean up bulb-specific monitoring
- Reset any per-bulb dropout counters/datetimes (e.g.
  `counter.<name>_unavailable_count` via `counter.reset`) so they read clean on the new bulb.
- Retire bulb-specific watchdog/logger automations once the new bulb proves stable; the
  fleet-wide watchdog already covers it.

## 7. Final verification
- `ha_deep_search` / dashboard load: no references to a missing entity.
- The next `ha-daily-maintenance` Repair sweep should show no "references sensors that don't
  exist" warning for this bulb.
- Confirm in the Hue app the bulb responds and follows a scene.

---

### Quick gotchas
- **Turn the fixture off/on** to start Hue pairing.
- **Hue room membership** (bridge-side) is separate from HA area — set it or scenes skip the bulb.
- **Reclaim the entity_id**; don't find/replace references.
- **Reload the Powercalc entry** to regenerate orphaned power/energy sensors.
- **Powercalc profile retune is UI-only** — match the model by the box's lumens/base.
