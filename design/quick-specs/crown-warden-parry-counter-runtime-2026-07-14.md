# Quick Design Spec: Crown Warden Parry Counter Runtime

## Problem

Story146 delivered a playable Crown Warden encounter, but its incoming attack
path still applies normal damage while Cinderpaw is visibly parrying. The Boss4
config also carries `1.5x` parry damage and `enter_stun=true`, contradicting the
approved Boss rule in `design/gdd/boss-config.md`: a parried Boss takes `5.0x`
damage and does not enter STUN.

## Bounded Outcome

1. A real Crown Warden hit arriving during Cinderpaw's 18-frame parry window is
   consumed by `CombatComponent.resolve_parry_result()` and deals no player HP
   damage.
2. The arena resolves the successful Boss outcome through
   `BossConfigComponent`, using the current weapon's effective base damage and
   the configured `5.0x` multiplier.
3. Crown Warden receives the counter damage once for that attack contact and
   does not receive STUN. Its active attack chain is not interrupted by a fake
   generic stun state.
4. PERFECT uses the existing generated parry flash/spark assets and cat-eye-gold
   current-frame afterimage. Existing parry SFX are routed through AudioSystem.
5. Missed parries and non-enemy/environmental damage keep the existing damage
   path. This slice does not add a second parry state owner.

## Ownership

- `PlayerController`: recognizes a real enemy hit while both visible and Core
  parry states are active, asks CombatComponent to classify it, and starts the
  existing counter animation surface.
- `CrownWardenArena`: consumes the resolved signal, queries BossConfigComponent,
  applies one Boss-specific counter, and forwards presentation/audio metadata.
- `BossConfigComponent`: remains the data-driven source for multiplier and STUN
  policy. No EventBus or new Autoload is added.

## Acceptance Probe

With Cinderpaw and Crown Warden in real hurtbox/hitbox overlap, enter PERFECT
parry immediately before `talon_dive` becomes active. Player HP stays `100`, a
level-1 Cat Claw counter deals `10 * 5.0 = 50`, Boss HP becomes `110`, STUN is
absent, the same contact cannot counter twice, and the existing gold afterimage
is visible in a clean Godot MCP capture.

## Out Of Scope

- Retuning parry windows, ability cooldowns, weapon base damage or Boss HP.
- Adding a Crown Warden-specific sprite set, new VFX texture or new SFX.
- Applying generic enemy STUN across every encounter.
- Reworking Crown Warden attack patterns, phases, reward or scene flow.
