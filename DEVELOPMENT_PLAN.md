# SIGNAL LOST — Development Plan

> Roguelike Tower Defense with Procedural Storytelling
> Target: Steam (Win/Mac/Linux) | $4.99 | 10,000+ copies
> Engine: Godot 4.3+ | Language: GDScript
> Created: 2026-03-08

---

## GDD Corrections (approved by all 9 agents)

| Change | Reason | Agent |
|--------|--------|-------|
| 6-8 waves per run instead of 8-12 | 15 min run unrealistic with 12 waves | Gori |
| 20 transmissions at launch, not 50 | Scope creep. Remaining 30 = post-launch content | Gori + Pifi |
| 3 concrete endings instead of "random interpretations" | Player won't understand they "chose" an ending | Gori |
| Object pooling from day one | 100+ enemies = need optimization immediately | Nikola |
| CRT effects toggleable | Accessibility + Steam Deck readability | Jony |
| Synergy stacking rules (anti-exploit) | Amplifier loop will break balance | Gori + Neo |
| Daily Challenge seed system | Low effort, high engagement | Gandalf |
| Run Statistics + Best Runs board | Free replayability | Gandalf |
| Steam Deck "Playable" not "Verified" at launch | Verified requires device testing | Gori |
| Tower targeting priority (first/last/strong/weak) | Core TD mechanic, missing from GDD | Neo |

---

## Architecture Decisions

### ADR-001: Scene Tree (not ECS)
Godot Scene Tree + Resources for data. ECS is overkill for 6 tower types and 5 enemies.

### ADR-002: State Management — Autoload Singletons
- `GameManager` — current wave, resources, core HP
- `RunManager` — run modifiers, chosen rewards, current run state
- `MetaManager` — unlocked towers, transmissions, permanent upgrades
- `AudioManager` — music/SFX control

### ADR-003: Data Architecture — JSON + .tres Resources
All balance data in external files. Towers, enemies, waves, transmissions — never hardcoded.
Allows balance tuning without code changes.

### ADR-004: Grid System — TileMap + AStarGrid2D
TileMap for the main map. Custom layer for tower placement slots.
Built-in AStarGrid2D for enemy pathfinding.

---

## Project Structure

```
signal-lost/
├── project.godot
├── assets/
│   ├── shaders/          # CRT, glow, scanlines
│   ├── fonts/            # Monospace terminal fonts
│   ├── audio/            # SFX, music placeholders
│   └── ui/               # UI textures, icons
├── data/
│   ├── towers.json       # Tower stats, costs, synergies
│   ├── enemies.json      # Enemy stats, behaviors
│   ├── waves.json        # Wave compositions
│   ├── transmissions.json # Story fragments (20 for launch)
│   └── modifiers.json    # Run modifiers
├── scenes/
│   ├── main/             # Main menu, settings
│   ├── game/             # Core gameplay scene
│   ├── towers/           # Tower scenes
│   ├── enemies/          # Enemy scenes
│   ├── ui/               # HUD, menus, terminal
│   └── effects/          # VFX, particles
├── scripts/
│   ├── autoload/         # GameManager, RunManager, MetaManager, AudioManager
│   ├── towers/           # Tower logic, synergy calculator
│   ├── enemies/          # Enemy AI, pathfinding
│   ├── systems/          # Wave spawner, grid, economy, narrative
│   └── ui/               # UI controllers
└── exports/
    ├── windows/
    ├── macos/
    └── linux/
```

---

## Design Tokens (Jony)

```
Background:    #0A0E17 (dark navy)
Surface:       #111827 (panels, cards)
Grid:          #00FF88 at 20% opacity (subtle lines)
Text Primary:  #00FF88 (terminal green)
Text Secondary:#00FF88 at 60%
Tower Accent:  #00C8FF (cyan)
Enemy Accent:  #FF2244 (red)
Narrative:     #FFB800 (amber)
Boss/Alert:    #AA44FF (purple)
```

---

## Tower System

| Tower | Role | Cost | Synergy |
|-------|------|------|---------|
| Pulse Emitter | Single target, high DPS | 100 | +15% dmg near Amplifier |
| Arc Relay | Chain lightning, crowd control | 150 | +1 chain per adjacent Arc Relay |
| Cryo Node | Slows enemies in area | 120 | Frozen enemies take 2x from Pulse |
| Data Siphon | Generates extra resources | 200 | +10% yield per decoded transmission |
| Amplifier | Boosts adjacent tower stats | 180 | Effect doubles if surrounded by 3+ towers (NO recursive stacking) |
| Shield Generator | Absorbs damage to relay core | 250 | Recharges faster near Cryo Node |

**Stacking Rules (anti-exploit):**
- Amplifier cannot boost another Amplifier
- Maximum synergy bonus cap: 200% per tower
- Chain lightning max depth: 5

**Targeting Priorities (player selectable):**
- First (default) — targets enemy closest to core
- Last — targets enemy furthest from core
- Strongest — targets highest HP enemy
- Weakest — targets lowest HP enemy

---

## Enemy System

| Enemy | Behavior | Counter |
|-------|----------|---------|
| Glitch Swarm | Fast, low HP, masses | Arc Relay chain, area damage |
| Corrupted Signal | Medium, shielded | Pulse Emitter focused fire |
| Data Leech | Slow, drains tower energy | Cryo Node + keep distance |
| Phantom Burst | Invisible, teleports | Amplified detection towers |
| Overload Core (Boss) | Massive HP, spawns minions, phases | Full tower synergy required |

---

## Phase 0: Pre-production (2-3 days)

- [ ] Finalize synergy matrix (all tower combinations + stacking rules)
- [ ] Define tower targeting priorities
- [ ] Create data schemas: towers.json, enemies.json, waves.json
- [ ] Set up Godot 4.3+ project skeleton
- [ ] Create GitHub repo
- [ ] Set up branches (main, develop)
- [ ] Steam Tags strategy (Pifi)
- [ ] Install Godot 4.3+ on dev machine

---

## Phase 1: MVP Prototype — Weeks 1-2

**Goal: Playable 1-map demo. If not fun — STOP and redesign.**

| Task | Priority | Hours |
|------|----------|-------|
| Grid system (TileMap + placement slots) | P0 | 8 |
| Tower base class + 3 towers (Pulse, Arc, Cryo) | P0 | 12 |
| Enemy base class + 2 enemies (Swarm, Signal) | P0 | 6 |
| A* pathfinding (AStarGrid2D) | P0 | 6 |
| Wave spawner (5 waves + 1 mini-boss) | P0 | 6 |
| Relay Core (HP, game over) | P0 | 4 |
| Resource economy (earn/spend) | P0 | 4 |
| Basic HUD (HP, resources, wave counter) | P0 | 8 |
| Object pooling for enemies and projectiles | P0 | 4 |
| **Total** | | **~58 hours** |

**Milestone:** Playable. Answer: "Is this fun?"

---

## Phase 2: Core Systems — Weeks 3-4

| Task | Priority |
|------|----------|
| +3 towers (Data Siphon, Amplifier, Shield Generator) | P0 |
| +3 enemies (Data Leech, Phantom Burst, Overload Core boss) | P0 |
| Synergy system (matrix from Phase 0) | P0 |
| Tower upgrade system (3 levels per run) | P0 |
| Tower sell mechanic | P1 |
| Tower targeting priority selection (UI) | P1 |
| Enemy variety in waves (mixed compositions) | P0 |
| Balance pass #1 (all data in JSON) | P0 |

**Milestone:** Full wave gameplay with all towers and enemies.

---

## Phase 3: Roguelike Layer — Weeks 5-6

| Task | Priority |
|------|----------|
| Procedural map generation (sector choice) | P0 |
| Run Modifiers (8-10 modifiers, pick 1 of 3) | P0 |
| Between-wave reward choice (1 of 3: tower/upgrade/passive/story) | P0 |
| Run state management (start/end/death) | P0 |
| Difficulty scaling per wave | P0 |
| Seed system (for Daily Challenge later) | P1 |

**Milestone:** Complete run loop — start to death/win and back.

---

## Phase 4: Meta & Narrative — Weeks 7-8

| Task | Priority |
|------|----------|
| Meta-progression: Decoded Transmissions currency | P0 |
| Tower Blueprints unlock system (start 3, unlock to 10) | P0 |
| Station Upgrades (permanent passive bonuses) | P0 |
| Transmission Log UI (terminal aesthetic) | P0 |
| 20 transmissions (not 50 — scale post-launch) | P0 |
| 3 concrete endings with unlock conditions | P0 |
| Synergy Discovery catalogue | P1 |
| Save/Load system (local + Steam Cloud prep) | P0 |

**Milestone:** Full game loop with meta-progression and narrative.

---

## Phase 5: Polish & VFX — Weeks 9-10

| Task | Priority |
|------|----------|
| CRT shader (scanlines, phosphor glow, curvature) | P0 |
| Option to reduce/disable CRT effects (accessibility) | P0 |
| UI polish: main menu, settings, pause | P0 |
| Terminal UI for transmissions (typewriter effect, static) | P0 |
| Audio integration: placeholders to real assets | P0 |
| Boss fight polish (Overload Core) | P0 |
| Run Statistics screen | P1 |
| Steam Achievements (10-15) | P1 |
| CRT color variant skins (green/amber/white) | P2 |

**Milestone:** Feature complete, polished.

---

## Phase 6: Testing & Ship — Weeks 11-12

| Task | Priority |
|------|----------|
| Balance pass #2 (data-driven, JSON tweaks) | P0 |
| Bug fixing marathon | P0 |
| Steam build + export configs (Win/Mac/Linux) | P0 |
| GodotSteam integration (achievements, cloud saves) | P0 |
| Steam store page (capsule art, screenshots, description) | P0 |
| Demo build (first 3 waves, 1 map) | P0 |
| Steam Deck Playable testing | P1 |
| Submit to Steam Next Fest | P1 |

**Milestone:** Release candidate. Ship it.

---

## Gamification Features (Gandalf)

### Run Statistics (after each run)
- Waves survived
- Enemies destroyed
- Resources earned
- Synergies activated
- Best Runs leaderboard (local)

### Daily Challenge
- One seed per day, everyone plays the same map
- Local leaderboard (Steam leaderboard post-launch)
- Minimal code, maximum engagement

### Steam Achievements (15 planned)
1. "First Contact" — decode first transmission
2. "Chain Reaction" — 10+ chain lightning in one wave
3. "Absolute Zero" — freeze 50 enemies simultaneously
4. "The Full Picture" — collect all transmissions
5. "Speedrunner" — complete a run in under 10 minutes
6. "Pacifist Wave" — survive a wave with Shield Generator only
7. "Synergy Master" — discover all synergy combinations
8. "Signal Decoded" — reach ending #1
9. "Truth Revealed" — reach ending #2
10. "Beyond the Static" — reach ending #3
11. "Wave 8 Club" — survive all 8 waves
12. "Overloaded" — defeat the Overload Core boss
13. "Efficient Operator" — win a run spending under 1000 resources
14. "Tower Hoarder" — have 15+ towers placed simultaneously
15. "Daily Devotee" — complete 7 daily challenges

### CRT Color Skins (unlockable)
- Classic Green (default)
- Amber Terminal (unlock: 10 runs completed)
- White Phosphor (unlock: all transmissions found)

---

## Performance Targets (Nikola)

- 200+ enemies on screen at 60fps
- Object pooling for enemies and projectiles from day one
- Synergy recalculation only on tower place/remove, not per frame
- CRT shader = single full-screen post-process, not stacked
- Arc Relay chain: max 5 depth, cached
- All balance calculations in `_physics_process`
- Profile on Steam Deck in Phase 5

---

## Marketing Checklist (from GDD)

### Pre-Launch (8 weeks before release)
- [ ] Steam page live with capsule art, 5+ screenshots, GIF-rich description
- [ ] Free demo (first 3 waves, 1 map)
- [ ] Submit to Steam Next Fest
- [ ] TikTok/YouTube Shorts: 15-sec gameplay clips
- [ ] Wishlist goal: 2,000+

### Launch
- [ ] 10% launch discount ($4.49)
- [ ] Keys to small/medium YouTubers (TD/roguelike niche)
- [ ] Reddit: r/TowerDefense, r/roguelikes, r/IndieGaming
- [ ] Steam community hub dev logs

### Post-Launch
- [ ] Content updates every 2-4 weeks (new towers, enemies, transmissions)
- [ ] +30 more transmissions (to reach 50 total)
- [ ] Seasonal Steam Sales participation
- [ ] Daily Challenge feature promotion

---

## Financial Model

| Metric | Conservative | Target | Optimistic |
|--------|-------------|--------|------------|
| Copies Sold | 5,000 | 10,000 | 30,000 |
| Net Revenue | $17,465 | $34,930 | $104,790 |
| Reviews | ~150 | ~300 | ~900 |

---

## Reference Games

- **Bloons TD 6** — Proven TD core, tower synergies
- **Slay the Spire** — Run-based structure, meta-unlocks
- **Into the Breach** — Tactical depth in small grid
- **FTL** — Sci-fi atmosphere, crew narrative
- **Vampire Survivors** — Low price, high replayability
- **Rogue Tower** — Direct competitor, $9.99, Very Positive (3K+)

---

## Next Steps

1. Install Godot 4.3+ on Mac
2. Complete Phase 0 (pre-production)
3. Begin Phase 1 (MVP prototype)
