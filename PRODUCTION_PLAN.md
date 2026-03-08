# SIGNAL LOST — Production Plan

> Solo developer + AI pipeline. Gates + milestones, not calendar.
> Source of truth: `Signal_Lost_GDD_v2_Master.md`
> Current date: 2026-03-08
> Target release: November 2026

---

## Current State Assessment

### DONE (Gate 1 — Proof of Fun: ~80% complete)

| System | Status | Notes |
|--------|--------|-------|
| Grid + pathfinding | DONE | AStarGrid2D, placement slots |
| 6 towers (GDD v2 aligned) | DONE | Pulse, Arc, Cryo, Scrambler, Prism, Salvage |
| 6 enemies + 2 bosses | DONE | All GDD v2 types + The Choir, Black Relay |
| Wave spawner (10 waves) | DONE | 9 regular + 1 boss |
| Economy (Scrap + Power) | DONE | 140 start, cap 8 power |
| HUD (scrap, power, wave, HP) | DONE | Functional placeholder |
| Object pooling | DONE | Enemies reuse |
| Tower upgrades (3 levels) | DONE | Linear, no branches yet |
| Tower sell (70%) | DONE | |
| Targeting priorities | DONE | First/Last/Strong/Weak |
| Debuff system | DONE | Scrambler → armor reduction |
| Synergy framework | PARTIAL | Data defined, runtime partially implemented |

### NOT DONE (required for Gate 1 completion)

| System | Priority | Why needed for Gate 1 |
|--------|----------|----------------------|
| Reward choice (pick 1 of 3) | P0 | Core loop incomplete without it |
| Run win/loss flow | P0 | Can't test "one more run" desire |
| Basic run restart | P0 | Must be able to play again |
| Balance pass on existing content | P0 | Fun test needs tuned numbers |

### NOT DONE (Gate 2+)

| System | Gate |
|--------|------|
| Transmission system (36 texts + effects) | G2 |
| Tower upgrade branches (2 paths x 6 towers) | G2 |
| Signal Charge meter | G2 |
| 4 sector maps | G3 |
| Run modifiers (pick 1 of 3) | G3 |
| Elite modifiers on enemies | G3 |
| Meta progression (Decoded Fragments) | G3 |
| Codex / Dossiers | G3 |
| Hub terminal menu | G3 |
| Difficulty modes (3) | G3 |
| Endings (3+1) | G3 |
| Save/Load | G3 |
| Art (replace _draw()) | G4 |
| Audio (music, SFX, VO) | G4 |
| CRT shader | G4 |
| Steam integration | G5 |
| Achievements (15) | G5 |
| Demo build | G5 |
| Store page assets | G5 |
| Trailer | G5 |

---

## 1. Production Roadmap

---

### GATE 1 — PROOF OF FUN (Weeks 1-2)

**Goal:** Is the core loop fun WITHOUT story, meta, or polish?

**Deliverables:**
- [ ] Reward choice system (pick 1 of 3 after each wave)
- [ ] Run win condition (survive wave 10)
- [ ] Run loss condition (core integrity = 0)
- [ ] Run summary screen (waves survived, enemies killed, scrap earned)
- [ ] Run restart (back to wave 1, fresh state)
- [ ] Balance pass #1 (economy feels tight but fair)
- [ ] Flawless wave bonus (extra scrap for no core damage)

**Definition of Done:**
- [ ] Play 5 complete runs without crashes
- [ ] At least 1 run ends in victory, at least 1 in defeat
- [ ] After losing, the impulse is "one more run" not "whatever"
- [ ] Tower placement decisions feel meaningful
- [ ] Economy feels tight (not too much, not too little)

**Risks:**
| Risk | Mitigation |
|------|------------|
| Core loop isn't fun | Redesign economy/towers BEFORE adding content |
| Waves too easy or too hard | Use JSON tuning, not code changes |
| Reward choices feel empty | Start with tower + upgrade + scrap heal — simple but impactful |

**Do NOT do yet:**
- Art/sprites
- Story/transmissions
- Multiple maps
- Meta progression
- Audio beyond placeholder
- CRT shader
- Steam integration

---

### GATE 2 — VERTICAL SLICE (Weeks 3-6)

**Goal:** One polished sector that looks and plays like a real product. Screenshot-worthy.

**Deliverables:**
- [ ] Transmission system (10 transmissions, text + gameplay effect)
- [ ] Transmission choice UI (pick 1 of 2-3 at story windows)
- [ ] Tower upgrade branches (2 paths per tower = 12 branches)
- [ ] Signal Charge meter (basic implementation)
- [ ] Polished HUD redesign (diegetic terminal look)
- [ ] Art: 6 tower sprites (level 1 only)
- [ ] Art: 6 enemy sprites + 2 boss sprites
- [ ] Art: grid tileset (1 sector: Relay Spine)
- [ ] CRT shader (basic scanlines + glow)
- [ ] 3-5 SFX (tower place, tower shoot, enemy death, core hit, wave start)
- [ ] 1 music track (ambient build phase)
- [ ] First gameplay recording (30-60 sec, trailer material)
- [ ] First 5 screenshots

**Definition of Done:**
- [ ] A non-developer watches 30 sec of gameplay and says "I'd try that"
- [ ] Screenshot looks like a product, not programmer art
- [ ] Transmissions feel like part of the build, not text interruptions
- [ ] Tower upgrade branches create real build diversity

**Risks:**
| Risk | Mitigation |
|------|------------|
| Art style inconsistent | Create ASSET_BIBLE.md FIRST |
| Transmission pacing breaks flow | Max 3 lines + 1 effect. Codex for deep reading |
| Upgrade branches unbalanced | Focus on 2 towers first, copy pattern to rest |

**Do NOT do yet:**
- All 4 sectors
- Meta progression
- Save/load
- Full 36 transmissions
- Steam page
- Multiple difficulty modes

---

### GATE 3 — CONTENT COMPLETE ALPHA (Weeks 7-12)

**Goal:** All 1.0 content in the game. Rough balance, but complete.

**Deliverables:**
- [ ] 4 sectors (Relay Spine, Split Chamber, Orbital Ring, Broken Conduit)
- [ ] 36 transmissions (6 crew x 6 fragments)
- [ ] Truth axes system (CREW_FAULT / CORE_FAULT / SIGNAL_TRUTH)
- [ ] 3 endings + 1 synthesis ending
- [ ] Run modifiers (8-10, pick 1 of 3)
- [ ] Elite modifiers on enemies (Encrypted, Overclocked, Ghosted)
- [ ] Meta progression (Decoded Fragments currency)
- [ ] Hub terminal menu (Start Run, Decode Archive, Upgrade Network, Dossiers, Contracts, Settings, Stats)
- [ ] Tower unlock system (start 3, unlock to 6)
- [ ] Codex / Crew Dossiers
- [ ] Difficulty modes (Standard, Hard Signal, Anomaly Protocol)
- [ ] Save/Load system (local)
- [ ] Art: all tower sprites (all upgrade levels = 18+12 branch variants)
- [ ] Art: map backgrounds (4 sectors)
- [ ] Art: VFX sprites (projectiles, explosions, freeze, lightning)
- [ ] Art: UI frames and panels
- [ ] Audio: 3-4 music tracks (build, wave, boss, hub)
- [ ] Audio: full SFX pass
- [ ] Audio: 6-10 voice lines (transmission samples)
- [ ] Balance pass #2

**Definition of Done:**
- [ ] Can play from hub → select sector → complete run → see ending → return to hub
- [ ] Meta unlocks persist between runs
- [ ] All 36 transmissions reachable across multiple runs
- [ ] All 4 sectors playable with distinct layouts
- [ ] No placeholder art in gameplay (HUD can still be WIP)

**Risks:**
| Risk | Mitigation |
|------|------------|
| Scope explosion (36 transmissions) | Write transmission TEXT first (Claude), gameplay effects second |
| 4 sectors = 4x the work | Sectors share tile system. Variation = node layout, not art |
| Meta balance too grindy or too fast | Target: unlock all towers in 5-8 runs |

**Do NOT do yet:**
- Steam integration
- Achievements
- Demo build
- Trailer final
- Store page
- External testing

---

### GATE 4 — BETA / EXTERNAL TESTING (Weeks 13-16)

**Goal:** External players understand and enjoy the game. Critical UX issues fixed.

**Deliverables:**
- [ ] Steam Playtest build
- [ ] Tutorial/onboarding (implicit, no text wall)
- [ ] Accessibility pass (CRT slider, font size, pause, speed controls)
- [ ] Performance optimization (200+ enemies @ 60fps)
- [ ] Balance pass #3 (data from external testers)
- [ ] Bug fix marathon
- [ ] Crash logging / error reporting
- [ ] Controller support (Steam Deck target)
- [ ] UI polish: all menus final
- [ ] Art: main menu + game logo

**Definition of Done:**
- [ ] 5+ external testers complete full run without asking "what do I do"
- [ ] 60% of testers want to play a second run
- [ ] No critical bugs (crash, softlock, data loss)
- [ ] Performance stable on mid-range hardware
- [ ] Steam Deck: playable at 60fps

**Risks:**
| Risk | Mitigation |
|------|------------|
| Testers confused by transmissions | Add tooltip: "Story fragments change your build" |
| Performance issues with 200+ enemies | Profile early. Object pooling already done |
| Controller UX bad | Design grid navigation early, test on Deck |

---

### GATE 5 — RELEASE PREP (Weeks 17-20)

**Goal:** Ship-ready build. Store page live. Marketing assets done.

**Deliverables:**
- [ ] Steam integration (achievements, cloud saves)
- [ ] 15 achievements
- [ ] Demo build (1 sector, 4-5 waves, 1 transmission branch, cliffhanger)
- [ ] Trailer (60 sec, gameplay-first)
- [ ] Store page (capsule art, screenshots, description, tags)
- [ ] Store page copy (short desc, bullets, about section)
- [ ] Streamer/press key list
- [ ] Launch discount setup (10% = $6.29)
- [ ] Final balance pass
- [ ] Release candidate build
- [ ] Launch comms prep (Reddit, Twitter, Steam community)

**Definition of Done:**
- [ ] Steam page has 5+ screenshots, trailer, demo link
- [ ] Demo stable, ends on cliffhanger that makes player want full game
- [ ] Achievement list covers progression, skill, discovery
- [ ] No known critical bugs
- [ ] Build uploaded to Steam, reviewed, approved

---

## 2. Weekly Backlog

### Current status: Gate 1 is ~80% done. Starting from remaining Gate 1 tasks.

---

### WEEK 1 (Mar 9-15): Complete Gate 1

| Day | Task | Priority | Hours |
|-----|------|----------|-------|
| Mon | Reward choice system — data model + UI | P0 | 4 |
| Mon | Reward choice system — tower/upgrade/scrap types | P0 | 3 |
| Tue | Run win/loss detection + game over screen | P0 | 3 |
| Tue | Run summary screen (stats display) | P0 | 3 |
| Wed | Run restart flow (clean state → wave 1) | P0 | 2 |
| Wed | Flawless wave bonus | P1 | 2 |
| Wed | Wave preview (show incoming enemies before wave) | P1 | 2 |
| Thu | Balance pass — economy tuning (scrap rewards, tower costs) | P0 | 4 |
| Thu | Balance pass — enemy HP/speed scaling | P0 | 3 |
| Fri | Playtest 5 full runs, fix issues | P0 | 4 |
| Fri | Gate 1 checklist evaluation | P0 | 2 |

---

### WEEK 2 (Mar 16-22): Gate 2 Prep + Asset Bible

| Day | Task | Priority | Hours |
|-----|------|----------|-------|
| Mon | Create ASSET_BIBLE.md (palette, shapes, silhouettes, rules) | P0 | 4 |
| Mon | Create NARRATIVE_BIBLE.md (timeline, voices, truth axes) | P0 | 4 |
| Tue | Transmission system — data format (JSON schema) | P0 | 2 |
| Tue | Transmission system — in-game UI (choice panel) | P0 | 4 |
| Wed | Transmission system — gameplay effects engine | P0 | 5 |
| Thu | Write first 10 transmissions (Claude) | P0 | 4 |
| Thu | Hook transmission effects into tower/enemy systems | P0 | 3 |
| Fri | Tower upgrade branches — design all 12 branches | P0 | 4 |
| Fri | Tower upgrade branches — implement for Pulse + Arc | P0 | 3 |

---

### WEEK 3 (Mar 23-29): Upgrade Branches + Signal Charge

| Day | Task | Priority | Hours |
|-----|------|----------|-------|
| Mon | Tower upgrade branches — Cryo + Scrambler | P0 | 4 |
| Mon | Tower upgrade branches — Prism + Salvage | P0 | 4 |
| Tue | Signal Charge meter (basic: fills during combat, spends on resonance) | P1 | 4 |
| Tue | Transmission + Signal Charge integration | P1 | 3 |
| Wed | HUD redesign — layout, diegetic terminal look | P0 | 5 |
| Thu | HUD redesign — implement in game_hud.gd | P0 | 5 |
| Fri | Integration testing: full run with transmissions + branches | P0 | 4 |
| Fri | Bug fixes from testing | P0 | 3 |

---

### WEEK 4 (Mar 30 - Apr 5): Art Pipeline Start

| Day | Task | Priority | Hours |
|-----|------|----------|-------|
| Mon | Art: Midjourney — tower concept exploration (all 6) | P0 | 4 |
| Mon | Art: select direction, clean up best outputs | P0 | 3 |
| Tue | Art: tower sprites level 1 — Pulse, Arc, Cryo | P0 | 5 |
| Wed | Art: tower sprites level 1 — Scrambler, Prism, Salvage | P0 | 5 |
| Thu | Art: enemy sprites — Glitch Swarm, Corrupted Carrier, Mirror Fragment | P0 | 5 |
| Fri | Art: enemy sprites — Null Shield, Phase Leech, Parasite Packet | P0 | 5 |

---

### WEEK 5 (Apr 6-12): Art + Audio + CRT

| Day | Task | Priority | Hours |
|-----|------|----------|-------|
| Mon | Art: boss sprites — The Choir, Black Relay | P0 | 4 |
| Mon | Art: grid tileset — Relay Spine sector | P0 | 3 |
| Tue | Integration: replace _draw() with sprites (towers) | P0 | 5 |
| Wed | Integration: replace _draw() with sprites (enemies) | P0 | 5 |
| Thu | CRT shader — scanlines, phosphor glow, curvature | P0 | 4 |
| Thu | CRT shader — intensity slider (accessibility) | P1 | 2 |
| Fri | Audio: 5 core SFX (Suno/ElevenLabs/manual) | P0 | 3 |
| Fri | Audio: 1 ambient build-phase track | P0 | 3 |

---

### WEEK 6 (Apr 13-19): Gate 2 Completion

| Day | Task | Priority | Hours |
|-----|------|----------|-------|
| Mon | First gameplay recording (30-60 sec) | P0 | 3 |
| Mon | First 5 screenshots (high quality, CRT on) | P0 | 2 |
| Mon | Polish: visual effects (projectiles, explosions) | P0 | 3 |
| Tue | Balance pass on transmissions + upgrade branches | P0 | 5 |
| Wed | Gate 2 playtest: 3 full runs, evaluate | P0 | 4 |
| Wed | Bug fixes | P0 | 3 |
| Thu | Gate 2 checklist evaluation | P0 | 2 |
| Thu | Plan Gate 3 detailed breakdown | P1 | 3 |
| Fri | Buffer / overflow | — | — |

---

### WEEKS 7-8: Sectors + Transmissions Bulk

| Task | Priority |
|------|----------|
| 3 remaining sectors (Split Chamber, Orbital Ring, Broken Conduit) | P0 |
| Sector-specific node layouts (power nodes, hazard nodes, relay nodes) | P0 |
| Write remaining 26 transmissions (Claude batch) | P0 |
| Truth axes accumulation system | P0 |
| Ending triggers + ending screens (3+1) | P0 |
| Run modifiers system (8-10 modifiers) | P0 |
| Run modifier selection UI (pick 1 of 3) | P0 |
| Elite modifiers on enemies (runtime application) | P0 |

---

### WEEKS 9-10: Meta + Hub

| Task | Priority |
|------|----------|
| Hub terminal menu (7 sections) | P0 |
| Meta progression: Decoded Fragments earn + spend | P0 |
| Tower unlock system | P0 |
| Codex / Crew Dossiers data + UI | P0 |
| Contracts system (optional challenges) | P1 |
| Difficulty modes (Standard, Hard Signal, Anomaly Protocol) | P0 |
| Save/Load system (local files) | P0 |

---

### WEEKS 11-12: Art Complete + Audio + Balance

| Task | Priority |
|------|----------|
| All tower sprites (upgrade levels + branches) | P0 |
| Map backgrounds (4 sectors) | P0 |
| VFX sprites complete | P0 |
| UI frames and panels (terminal aesthetic) | P0 |
| 3-4 music tracks (build, wave, boss, hub) | P0 |
| Full SFX pass | P0 |
| Voice lines: 6-10 transmission samples (ElevenLabs) | P1 |
| Balance pass #2 | P0 |
| Gate 3 checklist evaluation | P0 |

---

### WEEKS 13-16: Beta

| Task | Priority |
|------|----------|
| Steam Playtest setup | P0 |
| Tutorial / onboarding (implicit) | P0 |
| Accessibility pass | P0 |
| Performance optimization | P0 |
| Controller support | P0 |
| External testing (5+ testers) | P0 |
| Balance pass #3 (from tester data) | P0 |
| Bug fix marathon | P0 |
| UI polish: all menus final | P0 |
| Main menu + logo art | P0 |
| Gate 4 checklist evaluation | P0 |

---

### WEEKS 17-20: Release Prep

| Task | Priority |
|------|----------|
| Steam integration (achievements, cloud saves) | P0 |
| 15 achievements | P0 |
| Demo build | P0 |
| Trailer (60 sec) | P0 |
| Store page (capsule, screenshots, copy) | P0 |
| Press/streamer key list | P1 |
| Launch discount setup | P0 |
| Final balance pass | P0 |
| RC build | P0 |
| Gate 5 checklist evaluation | P0 |

---

## 3. Godot Project Structure

```
signal-lost/
├── project.godot
├── PRODUCTION_PLAN.md          # This file
├── DEVELOPMENT_PLAN.md         # Legacy plan (reference)
├── ASSET_BIBLE.md              # Visual rules for AI pipeline
├── NARRATIVE_BIBLE.md          # Story rules for AI pipeline
│
├── data/                       # All balance/content data (JSON)
│   ├── towers.json             # Tower stats, costs, synergies
│   ├── enemies.json            # Enemy stats, abilities
│   ├── waves.json              # Wave compositions, scaling
│   ├── transmissions.json      # 36 transmissions: text + effects + truth tags
│   ├── modifiers.json          # Run modifiers (pick 1 of 3)
│   ├── rewards.json            # Reward pool definitions
│   ├── upgrades.json           # Tower upgrade branches (12 paths)
│   ├── meta_tree.json          # Meta progression costs + unlocks
│   ├── achievements.json       # Steam achievement definitions
│   ├── contracts.json          # Optional challenge contracts
│   └── sectors.json            # Sector definitions + node layouts
│
├── scripts/
│   ├── autoload/               # Singletons
│   │   ├── game_manager.gd     # Wave state, scrap, power, core HP
│   │   ├── run_manager.gd      # Current run: modifiers, rewards, transmissions
│   │   ├── meta_manager.gd     # Persistent: unlocks, fragments, codex
│   │   └── audio_manager.gd    # Music/SFX control
│   │
│   ├── towers/                 # Tower scripts
│   │   ├── tower_base.gd       # Base class: targeting, attacking, upgrading
│   │   ├── pulse_emitter.gd
│   │   ├── arc_relay.gd
│   │   ├── cryo_node.gd
│   │   ├── scrambler_dish.gd
│   │   ├── prism_beam.gd
│   │   ├── salvage_matrix.gd
│   │   └── synergy_calculator.gd
│   │
│   ├── enemies/                # Enemy scripts
│   │   ├── enemy_base.gd       # Base: pathing, HP, debuffs, death
│   │   ├── glitch_swarm.gd
│   │   ├── corrupted_carrier.gd
│   │   ├── mirror_fragment.gd
│   │   ├── null_shield.gd
│   │   ├── phase_leech.gd
│   │   ├── parasite_packet.gd
│   │   ├── the_choir.gd
│   │   └── black_relay.gd
│   │
│   ├── systems/                # Core systems
│   │   ├── grid_manager.gd     # Grid, placement, A* pathfinding
│   │   ├── wave_spawner.gd     # Wave composition, spawning
│   │   ├── reward_system.gd    # Post-wave reward draft (pick 1 of 3)
│   │   ├── transmission_system.gd  # Story + gameplay effects
│   │   ├── signal_charge.gd    # Signal Charge meter
│   │   ├── elite_modifier.gd   # Runtime elite modification
│   │   └── save_system.gd      # Local save/load
│   │
│   ├── ui/                     # UI controllers
│   │   ├── game_hud.gd         # In-game HUD
│   │   ├── reward_panel.gd     # Post-wave reward choice
│   │   ├── transmission_panel.gd   # Transmission decode UI
│   │   ├── run_summary.gd      # End-of-run stats
│   │   ├── hub_terminal.gd     # Hub menu controller
│   │   ├── codex_viewer.gd     # Codex/dossier browser
│   │   ├── upgrade_tree.gd     # Meta upgrade tree
│   │   ├── settings_menu.gd    # Settings + accessibility
│   │   └── main_menu.gd        # Main menu
│   │
│   └── game/
│       └── game_scene.gd       # Main gameplay scene orchestrator
│
├── scenes/                     # Godot scenes (.tscn)
│   ├── main_menu.tscn
│   ├── hub_terminal.tscn
│   ├── game_scene.tscn
│   ├── run_summary.tscn
│   └── settings.tscn
│
├── assets/
│   ├── sprites/
│   │   ├── towers/             # Tower sprites (6 types x levels)
│   │   ├── enemies/            # Enemy sprites (8 types)
│   │   ├── effects/            # VFX (projectiles, explosions, freeze)
│   │   └── ui/                 # UI icons, frames
│   ├── tilesets/
│   │   ├── relay_spine.tres
│   │   ├── split_chamber.tres
│   │   ├── orbital_ring.tres
│   │   └── broken_conduit.tres
│   ├── shaders/
│   │   ├── crt.gdshader        # CRT post-process
│   │   └── glow.gdshader       # Phosphor glow
│   ├── fonts/
│   │   └── terminal.ttf        # Monospace terminal font
│   └── audio/
│       ├── music/              # BGM tracks
│       ├── sfx/                # Sound effects
│       └── voice/              # Transmission voice lines
│
├── docs/
│   ├── adr/                    # Architecture Decision Records
│   └── prompts/                # AI prompt templates (Midjourney, ElevenLabs)
│
└── exports/
    ├── windows/
    ├── linux/
    └── demo/
```

---

## 4. AI Task Pipeline

---

### CLAUDE (Code + Writing + Planning)

| Task | Input | Prompt Format | Output | Quality Check | Human Control |
|------|-------|---------------|--------|---------------|---------------|
| GDScript systems | GDD section + existing code | "Implement [system] per GDD v2 section [X]. Follow existing patterns in [file]. Use preload, not class_name." | .gd files | Run in Godot, no errors | Review game feel |
| Transmission writing | NARRATIVE_BIBLE.md + crew profile | "Write transmission for [crew member], fragment [N]. Include: 2-3 lines text, gameplay effect, risk, truth tag. Tone: [reference]." | JSON entry | Read aloud test (15 sec max?) | Approve tone + effect balance |
| Balance tuning | Current JSON + playtest notes | "Rebalance [system]. Problem: [X]. Constraints: [Y]. Adjust values in [file].json." | Updated JSON | Playtest 3 runs | Approve feel |
| Store page copy | GDD sections 43-44 | "Write Steam store description. Short desc (1 sentence), 5 bullets, About section. Hook: 'The story changes your build.'" | Markdown text | Read on mobile (quick scan test) | Final wordsmithing |
| Patch notes | Git diff + commit messages | "Write patch notes from these commits. Group by: features, fixes, balance. Tone: concise dev log." | Markdown | Accuracy check | Final edit |
| Codex entries | NARRATIVE_BIBLE.md + transmissions | "Write codex entry for [crew member]. 150-200 words. Reveal [X], hint at [Y], never confirm [Z]." | Text | Consistency with transmissions | Lore accuracy |

---

### MIDJOURNEY (Visual Assets)

| Task | Input | Prompt Format | Output | Quality Check | Human Control |
|------|-------|---------------|--------|---------------|---------------|
| Tower sprites | ASSET_BIBLE.md + tower description | "Sci-fi energy tower, top-down view, [color] glow, dark background, pixel art style, 64x64, clean silhouette, no text --ar 1:1 --s 250" | PNG (clean up in editor) | Silhouette test (recognizable at 32px?) | Select from 4 options |
| Enemy sprites | ASSET_BIBLE.md + enemy description | "Corrupted digital entity, top-down, [color] core, glitch effects, dark bg, 48x48, distinct shape --ar 1:1 --s 200" | PNG | Distinct from other enemies at zoom? | Select + cleanup |
| Boss sprites | ASSET_BIBLE.md + boss description | "Large corrupted [shape], multiple glowing elements, menacing, 128x128, sci-fi terminal aesthetic --ar 1:1 --s 300" | PNG | Reads as "boss" immediately? | Select + heavy cleanup |
| Map backgrounds | ASSET_BIBLE.md + sector description | "Deep space relay station interior, [sector type], dark metallic, green terminal glow, top-down perspective, tileable --ar 16:9 --s 250" | PNG | Tiles without obvious seam? | Select + tile edit |
| Capsule art | Game identity + trailer frames | "Sci-fi tower defense game key art, glowing grid, towers firing, approaching threat, CRT terminal aesthetic, dramatic lighting --ar 2:1 --s 400" | PNG | Reads at thumbnail size on Steam? | Heavy edit/composite |
| UI frames | ASSET_BIBLE.md | "Sci-fi terminal UI frame, dark metal border, subtle glow, transparent center, 9-slice compatible --ar 1:1 --s 200" | PNG | Works as 9-slice in Godot? | Edit for 9-slice |

**Midjourney workflow:**
1. Generate 4 options per prompt
2. Select best candidate
3. Upscale
4. Clean up in image editor (remove artifacts, fix edges, ensure transparency)
5. Import to Godot, test in-game
6. Iterate if needed

---

### ELEVENLABS (Voice / Audio)

| Task | Input | Prompt Format | Output | Quality Check | Human Control |
|------|-------|---------------|--------|---------------|---------------|
| Transmission VO | Transmission text + crew voice profile | Voice: [clone/preset]. Text: "[transmission text]". Style: radio distortion, tired/tense/clinical. | WAV/MP3 | Sounds in-character? Under 15 sec? | Approve + post-process |
| Trailer VO | Trailer script | Voice: deep, calm, cryptic. Text: "[line]". | WAV | Works with trailer pacing? | Edit timing |
| Station alerts | Alert text | Voice: robotic/synthetic. Text: "Core integrity critical." | WAV | Reads clearly through CRT filter? | Approve |

**ElevenLabs workflow:**
1. Pick/create voice profile per crew member (6 voices)
2. Generate raw audio
3. Post-process: add radio static, bandpass filter, subtle reverb
4. Test in-game with CRT visual
5. Must work WITHOUT audio (text-first design)

---

### CHATGPT (Supplementary)

| Task | Input | Output | When to use |
|------|-------|--------|-------------|
| Achievement name brainstorming | Achievement descriptions | 20 name options per achievement | When Claude context is full |
| Steam tag research | Competitor games list | Tag recommendations + reasoning | Pre-store page |
| Community post drafts | Update notes | Reddit/Steam post variations | Marketing phase |
| Bug report triage | Tester feedback text | Categorized bug list | Beta phase |

---

### OTHER AI TOOLS

| Tool | Task | Input | Output |
|------|------|-------|--------|
| **Suno AI** | Music generation | "Ambient sci-fi, dark, minimal, 120bpm, electronic, no vocals" | Background music tracks |
| **Stable Diffusion** (local) | Texture generation | Tileable patterns for grid/background | Seamless textures |
| **Topaz Gigapixel** | Sprite upscaling | Low-res Midjourney output | Clean high-res sprites |
| **Audacity** | Audio post-process | Raw ElevenLabs/Suno output | Filtered, game-ready audio |
| **TexturePacker** | Sprite atlas | Individual sprite PNGs | Optimized atlas .tres |

---

## 5. MVP Plan (Gate 1 Focus)

### Do First (this week)

| # | Task | Why | Hours |
|---|------|-----|-------|
| 1 | Reward choice system | Core loop incomplete | 7 |
| 2 | Run win/loss flow | Can't evaluate "fun" without it | 3 |
| 3 | Run restart | Must be able to play again | 2 |
| 4 | Run summary screen | Player needs feedback | 3 |
| 5 | Balance pass | Untuned = unfun = bad data | 7 |

### Cut from MVP

| Feature | Why cut | When to add |
|---------|---------|-------------|
| Transmissions | Not needed to test core TD fun | Gate 2 |
| Tower branches | 3-level linear is enough for Gate 1 | Gate 2 |
| Multiple maps | 1 map tests core loop | Gate 3 |
| Meta progression | Not needed for "is this fun?" | Gate 3 |
| Art/sprites | _draw() is fine for Gate 1 | Gate 2 |
| Audio | Silence is fine for Gate 1 | Gate 2 |
| Save/load | Restart-only is fine | Gate 3 |

### 3 Tests That Prove the Game Works

**Test 1 — "One More Run" Test**
> After losing on wave 7, does the player immediately want to restart?
> - YES → core loop works
> - NO → fix economy, tower feel, or wave pacing

**Test 2 — "Build Identity" Test**
> By wave 5, can the player describe their strategy in one sentence?
> - "I'm doing Cryo + Prism beam combo on the chokepoint"
> - "I went full economy with Salvage Matrix"
> - If player can't articulate a build → towers are too generic

**Test 3 — "Meaningful Choice" Test**
> Do reward choices between waves feel like real decisions?
> - Player pauses to think → good
> - Player always picks the same type → choices too obvious
> - Player picks randomly → choices don't matter enough

---

## 6. Release Timeline

```
Mar 2026   ████ Gate 1 (Proof of Fun) ← YOU ARE HERE
           ████ Gate 2 prep (bibles, transmissions)
Apr 2026   ████████ Gate 2 (Vertical Slice)
           ████ Art pipeline active
May 2026   ████████ Gate 3 start (content production)
Jun 2026   ████████ Gate 3 continue
           ████ Store page LIVE (screenshots, trailer v1)
Jul 2026   ████████ Gate 3 complete
           ████ Steam Playtest
Aug 2026   ████████ Gate 4 (Beta / external testing)
Sep 2026   ████████ Gate 4 continue + polish
           ████ Demo final
Oct 2026   ████ Steam Next Fest (demo)
           ████████ Gate 5 (Release prep)
Nov 2026   ████ RELEASE
Dec 2026   ████ Post-launch Update 1
```

---

## 7. Key Rules

1. **No feature without a gate.** Every feature must belong to a gate. If it doesn't fit any gate, it's post-launch.
2. **Gate 1 blocks everything.** If core loop isn't fun, don't add content. Fix the loop.
3. **AI generates, human approves.** Every AI output gets reviewed before shipping.
4. **Data-driven everything.** Towers, enemies, waves, transmissions, rewards — all JSON. Never hardcode balance.
5. **One sector first.** Build Relay Spine to perfection. Other sectors follow the template.
6. **Ship small, iterate.** Better to release with 4 tight sectors than 6 broken ones.
