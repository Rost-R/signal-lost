# SIGNAL LOST — Development Plan

> Roguelike Tower Defense with Procedural Storytelling
> Target: Steam (Win/Mac/Linux) | $4.99 | 10,000+ copies
> Engine: Godot 4.6.1 | Language: GDScript
> Created: 2026-03-08

---

## GDD Corrections (approved by all 9 agents)

| Change | Reason | Agent |
|--------|--------|-------|
| 10 waves per run (9 regular + 1 boss) | GDD v2 spec, balanced for 22-28 min runs | GDD v2 |
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
Godot Scene Tree + Resources for data. ECS is overkill for 6 tower types and 8 enemies.

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

| Tower | Role | Cost | Power | Synergy |
|-------|------|------|-------|---------|
| Pulse Emitter | Single target, high DPS | 50 | 1 | 2x dmg to frozen enemies; +20% near Scrambler |
| Arc Relay | Chain lightning, crowd control | 70 | 1 | +1 chain per adjacent Arc Relay (max +3) |
| Cryo Node | Slows/freezes enemies in area | 60 | 1 | Adjacent Prism Beam gets +30% damage |
| Scrambler Dish | Debuff: reduces armor/resistance | 75 | 1 | Adjacent Pulse Emitter gets +20% damage |
| Prism Beam | Linear piercing beam (hits all in line) | 90 | 2 | +30% damage when adjacent to Cryo Node |
| Salvage Matrix | Economy: bonus scrap + passive income | 80 | 1 | Enables greedy high-cost builds |

**Economy:**
- Starting Scrap: 140
- Power Cap: 8 (towers consume 1-2 power each)
- Sell Refund: 70%
- Tower Upgrades: 3 levels per tower

**Targeting Priorities (player selectable):**
- First (default) — targets enemy closest to core
- Last — targets enemy furthest from core
- Strongest — targets highest HP enemy
- Weakest — targets lowest HP enemy

---

## Enemy System

| Enemy | Tier | Behavior | Counter |
|-------|------|----------|---------|
| Glitch Swarm | Common | Fast, low HP, masses | Arc Relay chain, AoE |
| Corrupted Carrier | Common | Slow tank, high armor | Sustained DPS, Scrambler debuff |
| Mirror Fragment | Common | Splits into 2 copies on death | Avoid overkill, AoE cleanup |
| Null Shield | Common | Front shield absorbs 50% per hit | Scrambler debuff disables shield |
| Phase Leech | Elite | Teleports forward along path | Layered defense, not linear |
| Parasite Packet | Elite | Heals nearby enemies every 2s | Priority target, focus fire |
| **The Choir** | Boss | Spawns echo units (max 4) | Multi-lane response, sustained DPS |
| **Black Relay** | Boss | EMP disables nearby towers for 3s | Backup builds, tower spacing |

**Elite Modifiers (applied in later waves):**
- Encrypted — 50% freeze resistance, 30% slow resistance
- Overclocked — 1.5x speed
- Ghosted — 40% reduced targeting probability

**Waves:** 9 regular + 1 boss = 10 per run

---

## Phase 0: Pre-production (2-3 days) — COMPLETE

- [x] Finalize synergy matrix (all tower combinations + stacking rules)
- [x] Define tower targeting priorities
- [x] Create data schemas: towers.json, enemies.json, waves.json
- [x] Set up Godot 4.6.1 project skeleton
- [x] Create GitHub repo
- [x] Set up branches (main, develop)
- [ ] Steam Tags strategy (Pifi)
- [x] Install Godot 4.6.1 on dev machine

---

## Phase 1: MVP Prototype — Weeks 1-2

**Goal: Playable 1-map demo. If not fun — STOP and redesign.**

| Task | Priority | Status |
|------|----------|--------|
| Grid system (TileMap + placement slots) | P0 | DONE |
| Tower base class + 3 towers (Pulse, Arc, Cryo) | P0 | DONE |
| Enemy base class + 2 enemies (Swarm, Carrier) | P0 | DONE |
| A* pathfinding (AStarGrid2D) | P0 | DONE |
| Wave spawner (10 waves) | P0 | DONE |
| Relay Core (HP, game over) | P0 | DONE |
| Scrap economy (earn/spend) | P0 | DONE |
| Basic HUD (HP, scrap, power, wave counter) | P0 | DONE |
| Object pooling for enemies and projectiles | P0 | DONE |

**Milestone:** Playable. COMPLETE.

---

## Phase 2: Core Systems — Weeks 3-4

| Task | Priority | Status |
|------|----------|--------|
| +3 towers (Scrambler Dish, Prism Beam, Salvage Matrix) | P0 | DONE |
| +4 enemies (Corrupted Carrier, Mirror Fragment, Null Shield, Phase Leech) | P0 | DONE |
| +1 enemy (Parasite Packet — healer) | P0 | DONE |
| +2 bosses (The Choir, Black Relay) | P0 | DONE |
| Debuff system (Scrambler → enemy armor reduction) | P0 | DONE |
| Scrap + Power economy (replaces old "resources") | P0 | DONE |
| Tower upgrade system (3 levels per run) | P0 | DONE |
| Tower sell mechanic (70% refund) | P0 | DONE |
| Tower targeting priority selection (UI) | P1 | DONE |
| 10-wave compositions (9 regular + 1 boss) | P0 | DONE |
| Balance pass #1 (all data in JSON) | P0 | DONE |

**Milestone:** Full wave gameplay with all towers and enemies. COMPLETE.

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
| Tower Blueprints unlock system (start 3, unlock to 6) | P0 |
| Station Upgrades (permanent passive bonuses) | P0 |
| Transmission Log UI (terminal aesthetic) | P0 |
| 20 transmissions (not 50 — scale post-launch) | P0 |
| 3 concrete endings with unlock conditions | P0 |
| Synergy Discovery catalogue | P1 |
| Save/Load system (local + Steam Cloud prep) | P0 |

**Milestone:** Full game loop with meta-progression and narrative.

---

## Phase 5: Art & Visual Assets — Weeks 9-10

> **All code complete. Now replace _draw() placeholders with real art (AI-generated via Midjourney/DALL-E/Stable Diffusion).**

| Task | Priority |
|------|----------|
| Art style guide (CRT terminal aesthetic, color palette, reference board) | P0 |
| Tower sprites (6 types x 3 upgrade levels = 18 sprites) | P0 |
| Enemy sprites (8 types + death/hit animations) | P0 |
| Grid tileset (floor, walls, paths, spawn points, core) | P0 |
| Map backgrounds (3-4 sector variants) | P0 |
| VFX sprites (projectiles, explosions, freeze, lightning, shields) | P0 |
| UI icons (tower icons, resource icons, wave indicators, upgrades) | P0 |
| Main menu background + game logo | P0 |
| UI frames and panels (terminal aesthetic) | P0 |
| Integration: replace _draw() with Sprite2D/AnimatedSprite2D | P0 |
| Sprite atlas packing (performance) | P1 |

**Milestone:** Game looks like a real product, not programmer art.

---

## Phase 6: Polish & VFX — Weeks 11-12

| Task | Priority |
|------|----------|
| CRT shader (scanlines, phosphor glow, curvature) | P0 |
| Option to reduce/disable CRT effects (accessibility) | P0 |
| UI polish: main menu, settings, pause | P0 |
| Terminal UI for transmissions (typewriter effect, static) | P0 |
| Audio integration: placeholders to real assets | P0 |
| Boss fight polish (The Choir, Black Relay) | P0 |
| Run Statistics screen | P1 |
| Steam Achievements (10-15) | P1 |
| CRT color variant skins (green/amber/white) | P2 |

**Milestone:** Feature complete, polished.

---

## Phase 7: Testing & Ship — Weeks 13-14

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
6. "Scrap Hoarder" — win a run with 3+ Salvage Matrices
7. "Synergy Master" — discover all synergy combinations
8. "Signal Decoded" — reach ending #1
9. "Truth Revealed" — reach ending #2
10. "Beyond the Static" — reach ending #3
11. "Wave 10 Club" — survive all 10 waves
12. "Silenced the Choir" — defeat The Choir boss
13. "Efficient Operator" — win a run spending under 1000 scrap
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
- Arc Relay chain: max 5 depth (base 3 + up to 3 from adjacent relays)
- Prism Beam: uses dot/cross product math for line intersection (no raycasting overhead)
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

1. ~~Install Godot 4.3+ on Mac~~ DONE (Godot 4.6.1)
2. ~~Complete Phase 0 (pre-production)~~ DONE
3. ~~Begin Phase 1 (MVP prototype)~~ DONE
4. ~~Complete Phase 2 (Core Systems + GDD v2 alignment)~~ DONE
5. Begin Phase 3 (Roguelike Layer) — reward choices, transmissions, signal charge, run modifiers
