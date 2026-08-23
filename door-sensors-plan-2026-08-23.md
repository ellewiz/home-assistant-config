# Door Sensors — Buy List and Build Plan (2026-08-23)

Status: **hardware not yet purchased.** Build starts when sensors arrive and pair.

## 1. Buy list

| Item | Qty | Unit | Where |
|---|---|---|---|
| SONOFF SNZB-04PR2 Zigbee contact sensor | 2 | ~$13.90 | sonoff.tech direct, Amazon US, or eBay (~$12.99) |

Total: roughly $28.

**Why the PR2 over the SNZB-04P.** Slimmer body sits better on a door frame,
magnet mounts horizontal or vertical, and it takes 2x AAA instead of a CR2477
coin cell. The 04P's 5-year coin-cell life is the better spec on paper but the
wrong tradeoff for two sensors: AAA is in the drawer, CR2477 is not.

**Rejected options.**

- Third Reality contact 2-pack — cheaper, but no track record with the brand
  here, and no Sonoff-family ZHA quirk to fall back on.
- Aqara Door & Window Sensor P2 (~$30) — Thread/Matter. Would ride the ZBT-1,
  but that stick is Thread-only and unproven in this setup, at double the price.

**ZHA note.** Both Sonoff variants pair on ZHA. Tamper detection needs a custom
quirk on ZHA (Zigbee2MQTT gets it out of the box). Neither job here uses tamper,
so this does not matter.

## 2. ConBee context — NO ACTION NEEDED (corrected Aug 23)

The ZHA mesh currently holds the ConBee II plus four devices, all end devices:

- LUMI button (`lumi.remote.b1acn01`, office)
- SONOFF SNZB-01M (kitchen, med button)
- SONOFF SNZB-06P (living room presence)
- SONOFF SNZB-02WD (bathroom)

**There are no Zigbee routers in the ZHA mesh.** The Hue bulbs are on the Hue
bridge, a separate network, and relay nothing. Both new sensors will therefore
talk directly to the ConBee II.

The ConBee has a USB flapping history from May 28 to Jun 1 2026. **This was
initially written up here as a prerequisite. It is not.** Corrected Aug 23:

- She has had a USB extension cable on the ConBee since before that episode, so
  the cable was never the missing fix. Nothing to buy.
- The flapping is not currently happening. Over the full 10-day recorder window,
  ZHA went `unavailable` exactly twice — Aug 22 13:16:43 for 41s and Aug 23
  12:45:10 for 7s — both at Core restarts. Supervisor logs agree.
- What stopped it is unknown. Possibly the Jun 2 reboot; that was a correlation,
  not a diagnosis.
- Open hypothesis: the flapping window overlaps the SIGBUS crash window, and
  SIGBUS recurred Aug 22. A host going soft can produce both. Watch it there
  rather than as a separate cable problem.

**Only remaining action, and it is optional:** the ConBee is hanging near the
floor beside the printer and power bricks. Raising it into open air buys range,
which matters when two new sensors are joining with no routers to relay.

Once both door sensors are live they become the best coordinator-drop detector
in the house: a ConBee drop shows as BOTH going unavailable in the same second,
versus one dropping which means only that sensor.

See: `reference_conbee_usb_flapping` memory note.

### Host hardware, for reference

Home Assistant Blue (ODROID-N2+). A Nortek HUSBZB-1 is plugged directly into it
and serves the single Z-Wave node; ZHA runs on the ConBee II on the extension.

## 3. Build A — Johnny's in-bed mode (office door)

**Replaces:** the ZHA button press trigger on `automation.good_night_johnny`.

The real gain is not the trigger, it is that a contact sensor gives *state*
where the button gives an *event*. Nothing in HA currently knows whether Johnny
is in bed right now.

**Confirmed with Lara:** the office door already gets closed at his bedtime, so
this is a swap, not a new habit.

### New template binary sensor

`binary_sensor.johnny_in_bed` = office door closed AND
`binary_sensor.late_night_together` is on.

### Rewires

| Existing | Change |
|---|---|
| `automation.good_night_johnny` | Trigger becomes office door `on -> off` (closed). Keep the `late_night_together` condition. Action unchanged: Sonos Move, favorite `FV:2/47`, "Soothing Music for Dogs". |
| `automation.log_good_night_johnny_button_press` | Retrigger off the door instead of the button. |
| `counter.good_night_johnny_presses` | Now counts door-close bedtimes. Consider renaming. |
| `counter.good_night_johnny_presses_vacation` | Same. |
| `input_datetime.good_night_johnny_last_press` | Same. Consider renaming to `_last_bedtime`. |

### Freed hardware

The LUMI button (`c8bb0b9a688e58d28beaf2e26ee12b21`, ieee
`00:15:8d:00:07:f5:ed:24`) comes free. No rush to rebind — there are already
8 unbound Hue buttons per the Aug 2026 automation audit.

## 4. Build B — Bedroom door left open alert

**Motivation is not energy.** It is keeping Johnny out of the bedroom, because
the floor risk is sock and underwear ingestion. This is why there is no AC gate.

### Spec

- Trigger: bedroom door open **for 2 minutes**.
- Conditions: none. Fires regardless of AC state, season, or presence.
- Action: push to `notify.mobile_app_iphone` (`data:`, not `service_data:`;
  Jomo allowlist applies).
- **No critical/silent-bypass escalation.** Lara sleeps with the door closed, so
  the overnight case is not expected. If it does drift open at 3am the alert
  still fires, but as a normal push she will see in the morning.
- Repeat suppression: single fire per open event.

### Non-software fix (do this too)

The door swings open easily on its own. A door closer or fresh weatherstrip on
the latch side fixes the cause for a few dollars. The sensor is then the backup
that catches it when the physical fix fails, rather than the only line of
defense. An after-the-fact alert does not help much when the failure mode is a
dog eating a sock.

## 5. Build conventions

Follow `automation-style.md`: naming, `(vN)` version suffix in the alias,
`calendar.vacation` gating where relevant, notification conventions, and
`color_temp_kelvin` (never `kelvin:`) if any lighting gets touched.

`ha_config_set_script` silently fails on this instance — write scripts by file,
verify by reading back.

## 6. Open items

- [x] Order 2x SNZB-04PR2 — ordered, arriving Wednesday Aug 26
- [x] ~~USB extension for the ConBee II~~ — already installed, no action
- [ ] Optional: raise the ConBee off the floor, away from the printer
- [ ] Confirm both doors are within direct range of the coordinator after pairing
- [ ] Decide on renaming the `*_presses` counters and `*_last_press` datetime
- [ ] Physical door closer / weatherstrip for the bedroom door

## Sources

- [SmartHomeScene — SNZB-04PR2 review](https://smarthomescene.com/reviews/sonoff-snzb-04pr2-zigbee-door-sensor-review/)
- [ITEAD — SNZB-04P product page](https://itead.cc/product/sonoff-zigbee-door-window-sensor-snzb-04p/)
- [CNX Software — SNZB-04P review](https://www.cnx-software.com/2024/04/29/review-sonoff-snzb-06p-zigbee-human-presence-snzb-04pdoor-window-sensor/)
- [Aqara — Door & Window Sensor P2](https://www.aqara.com/us/product/door-and-window-sensor-p2/)
- [Amazon — Third Reality contact sensor 2-pack](https://www.amazon.com/THIRDREALITY-Contact-Security-Automation-Required/dp/B09XCWRHCT)
