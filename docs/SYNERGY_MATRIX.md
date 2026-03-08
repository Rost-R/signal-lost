# Tower Synergy Matrix — Signal Lost

## Quick Reference Table

| Tower A | Tower B | Synergy Effect | Stacking |
|---------|---------|---------------|----------|
| Pulse Emitter | Amplifier (adjacent) | +15% Pulse damage | Yes, capped at 200% |
| Pulse Emitter | Cryo Node (frozen target) | 2x damage to frozen enemies | No stack (binary) |
| Arc Relay | Arc Relay (adjacent) | +1 chain jump per adjacent Arc | Max +3 bonus chains |
| Cryo Node | Pulse Emitter (frozen) | Enables Pulse 2x damage bonus | N/A (debuff) |
| Cryo Node | Shield Generator (adjacent) | Shield recharges 50% faster | No stack (binary) |
| Data Siphon | Transmissions decoded | +10% yield per transmission | Max +100% bonus |
| Amplifier | Any non-Amplifier (adjacent) | +20/30/45% damage, +10/15/20% speed, +10/15/20% range | Per level |
| Amplifier | 3+ adjacent non-Amplifiers | Amplifier effect doubles | No stack (binary) |
| Shield Generator | Cryo Node (adjacent) | Recharge rate x1.5 | No stack (binary) |

## Anti-Exploit Rules

1. **Amplifier CANNOT buff another Amplifier** — prevents infinite scaling loops
2. **Maximum synergy bonus cap: 200%** — no tower can exceed 3x its base stats from synergies
3. **Chain lightning max depth: 5** — Arc Relay chains stop at 5 targets regardless of bonuses
4. **Binary synergies don't stack** — having 2 Cryo Nodes adjacent to a Shield Generator doesn't give 2x the recharge bonus
5. **Conditional synergies check once** — frozen target bonus is checked at time of hit, not continuously

## Synergy Discovery IDs

These are logged in MetaManager when first triggered:

| Synergy ID | Trigger |
|------------|---------|
| `syn_pulse_amplified` | Pulse Emitter fires while adjacent to Amplifier |
| `syn_pulse_frozen` | Pulse Emitter hits a frozen enemy |
| `syn_arc_chain` | Arc Relay chains to extra target from adjacent Arc |
| `syn_cryo_pulse` | Cryo Node freezes an enemy that gets hit by Pulse |
| `syn_siphon_transmission` | Data Siphon earns bonus from decoded transmission |
| `syn_amplifier_surrounded` | Amplifier activates doubled effect |
| `syn_shield_cryo` | Shield Generator recharges faster near Cryo Node |

## Planned Synergies (Post-Launch)

- Arc Relay + Cryo Node: Chain lightning spreads freeze effect
- Data Siphon + Amplifier: Generates bonus data from amplified kills
- Shield Generator + Amplifier: Shield gains damage reflection
