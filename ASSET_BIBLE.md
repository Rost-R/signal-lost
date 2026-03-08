# SIGNAL LOST — Asset Bible

> **Purpose:** Single source of truth for ALL visual assets produced by AI tools
> (Midjourney, Stable Diffusion, etc.) and manual editing. Every artist,
> AI prompt, and sprite must follow these rules. Without this document,
> AI outputs will "drift" and the game will look like a collection of
> different projects.
>
> **Reference:** GDD v2 Section 26 (Art Direction), Section 34 (Asset Bible Requirements)

---

## 1. Visual Identity

### Style
**Retro-futuristic CRT / terminal sci-fi / clean tactical grid**

### Mood References
- Alien (1979) — control room aesthetic
- Into the Breach — clarity and readability
- FTL — loneliness and isolation
- Digital corruption — glitch as threat
- Phosphor glow and scanlines — CRT warmth

### Design Mantra
> **"Beauty is secondary to readability."**

Effects NEVER obscure:
- Enemy movement paths
- Tower attack radii
- Damage numbers / debuff indicators
- Core integrity state
- Grid slot availability

---

## 2. Color Palette

### Primary Palette

| Role | Color | Hex | Usage |
|------|-------|-----|-------|
| Background | Dark charcoal-blue | `#0A0F14` | World background, empty space |
| Background Alt | Deep navy | `#0E1520` | Panel backgrounds, overlays |
| Grid Lines | Muted teal | `#1A3040` | Grid structure, inactive slots |
| Terminal Green | Phosphor green | `#00FF88` | Primary UI text, interactive elements |
| Accent Cyan | Cool cyan | `#00C8FF` | Info text, selected items, secondary UI |
| Warning Amber | Alert orange | `#FFB800` | Warnings, scrap amounts, caution |
| Danger Red | Signal red | `#FF2244` | Danger, enemies, low HP, core damage |
| Corruption Purple | Deep violet | `#AA44FF` | Corruption effects, special enemies |

### Tower Colors (Each tower MUST have a unique, consistent color)

| Tower | Color | Hex | Rationale |
|-------|-------|-----|-----------|
| Pulse Emitter | Bright cyan | `#00C8FF` | Clean energy pulse |
| Arc Relay | Electric blue | `#4488FF` | Lightning / electrical |
| Cryo Node | Ice blue | `#88DDFF` | Cold / frost |
| Scrambler Dish | Violet | `#DD70FF` | Disruption / interference |
| Prism Beam | Gold | `#FFD700` | Focused light / premium |
| Salvage Matrix | Lime green | `#33E566` | Economy / organic growth |

### Enemy Colors

| Enemy Type | Color | Hex | Rationale |
|------------|-------|-----|-----------|
| Standard enemies | Red-orange | `#FF4422` | Immediate threat |
| Armored enemies | Dark red | `#CC2222` | Heavy, dangerous |
| Fast enemies | Bright magenta | `#FF44AA` | Fast, elusive |
| Shielded enemies | Blue-red | `#4466FF` shield / `#FF4422` body | Dual-layer |
| Boss enemies | Deep purple | `#8822CC` | Rare, powerful |
| Corruption effects | Red-purple glow | `#CC22AA` | Alien, wrong |

### UI Colors

| Element | Color | Hex |
|---------|-------|-----|
| Panel background | Near-black | `#0A0F16` at 85% opacity |
| Panel border | Dim green | `#00FF88` at 30% opacity |
| Active text | Full green | `#00FF88` |
| Inactive text | Dim grey | `#666666` |
| Highlight | Bright cyan | `#00C8FF` |
| Button hover | Green glow | `#00FF88` at 10% fill |

### Forbidden Colors
- Pure white `#FFFFFF` — too harsh for CRT aesthetic. Use `#CCDDCC` max
- Bright saturated yellow — conflicts with gold/amber warning system
- Pastel tones — break the dark terminal mood
- Brown/earth tones — wrong genre

---

## 3. Shape Language

### Grid & Environment
- **Hexagonal influence** — towers sit on hex-inspired slots
- **Straight lines** — grid is clean, rectilinear
- **No organic curves** in UI or environment — everything is engineered
- **Right angles** dominate panels, menus, info boxes

### Towers
- **Geometric, angular silhouettes** — each tower MUST be recognizable at 32x32px
- **Base:** hexagonal footprint (6 towers all share hex base shape)
- **Turret/top:** unique per tower type — THIS is what differentiates them
- **Level indicators:** dots/pips below the tower (1/2/3)
- **Glow:** subtle tower-color glow around base, intensity increases with level
- **Branch visual:** level 2+ branch choice adds a subtle visual modifier (antenna shape, barrel count, etc.)

| Tower | Silhouette Rule |
|-------|----------------|
| Pulse Emitter | Single barrel/cannon pointing up |
| Arc Relay | Forked antenna / tesla coil top |
| Cryo Node | Crystal/star shape radiating outward |
| Scrambler Dish | Satellite dish / concave reflector |
| Prism Beam | Triangular prism / gem shape |
| Salvage Matrix | Claw/grabber / recycling symbol |

### Enemies
- **Soft geometry with hard edges** — organic corruption meeting digital structure
- **Diamond/rhombus base shape** — enemies are diamond-oriented (45° rotated square)
- **Size = threat:** larger enemies are more dangerous (scale 0.4–1.2 of cell size)
- **Status effects visible on body:** frozen = ice crystals, debuffed = purple tint, slowed = trailing particles

| Enemy | Silhouette Rule | Size |
|-------|----------------|------|
| Glitch Swarm | Tiny, numerous, jittery | 0.4x |
| Corrupted Carrier | Medium, trailing particles | 0.7x |
| Mirror Fragment | Angular, reflective glint | 0.5x |
| Null Shield | Shield ring around body | 0.7x |
| Phase Leech | Elongated, fast silhouette | 0.5x |
| Parasite Packet | Small, splits visually | 0.4x |
| The Choir (boss) | Large, multiple glowing nodes | 1.2x |
| Black Relay (boss) | Massive, dark with inverse glow | 1.5x |

### UI Elements
- **Rectangular panels** with single-pixel borders
- **No rounded corners** — sharp terminal aesthetic
- **Monospace font** for all game UI
- **Brackets for labels:** `[WAVE 3/10]`, `[CORE: 18/20]`
- **All caps** for status labels

---

## 4. Effect Rules

### Projectiles
- **Pulse Emitter:** single bright dot traveling in straight line
- **Arc Relay:** jagged lightning segments, 2-3 midpoint offsets
- **Cryo Node:** expanding ring / aura (no projectile — area effect)
- **Scrambler Dish:** dashed line / scan beam to target
- **Prism Beam:** continuous beam line, width 6-10px
- **Salvage Matrix:** no attack — ambient pulse ring on scrap collect

### Impact Effects
- Brief flash at impact point (2-3 frames)
- Color matches the tower that caused it
- Never lasts more than 0.2 seconds
- Never larger than 1.5x the projectile size

### Status Effect Visuals
- **Slow:** enemy tints slightly blue, subtle trailing particles
- **Freeze:** ice crystal overlay, enemy stops, blue-white tint
- **Debuff:** purple/violet outline pulse
- **Vulnerability:** red crack lines on frozen body

### Death Effects
- Small burst of particles in enemy color (4-6 particles)
- Fade out over 0.15 seconds
- No large explosions — keep it clean
- Scrap pickup: small green `+N` text floats up

### Corruption Effects
- Glitch: brief horizontal displacement (1-2 pixel shift)
- Static: scanline distortion in small area
- Used SPARINGLY — corruption is spice, not noise

---

## 5. UI Grammar

### Panel Layout Rules
- **Top bar:** 32px height, full width — CORE / SCRAP / PWR / WAVE / SIGNAL
- **Bottom bar:** 64px height — tower selection buttons + start wave
- **Right panel:** 180px wide — selected tower info (appears on selection)
- **Center overlays:** reward choice, transmission panel, game over — centered, semi-transparent bg

### Text Hierarchy
| Level | Size | Weight | Color | Usage |
|-------|------|--------|-------|-------|
| Label | 10-11px | Regular | Dim green/grey | Sublabels, descriptions |
| Body | 12-13px | Regular | Green | Stats, info text |
| Header | 14-16px | Bold | Cyan or green | Section titles, tower names |
| Display | 18-20px | Bold | Amber or green | Phase indicator, alerts |

### Button States
- **Normal:** dark bg, dim border
- **Hover:** tower-color fill at 10%, bright border
- **Selected:** tower-color fill at 20%, full color border
- **Disabled:** grey text, no border glow
- **Affordance:** keyboard shortcut shown in brackets `[1]`, `[U]`, `[SPACE]`

### Information Density
- Show what matters NOW, hide what doesn't
- During BUILD phase: tower costs, scrap, power, grid
- During WAVE phase: enemy count, core HP, active effects
- No tooltip walls — 2-3 lines max per info element

---

## 6. Sprite Production Pipeline

### Midjourney Prompt Template
```
[subject description], top-down view, [tower_color] glow,
dark background, pixel art style, [size]x[size],
clean silhouette, no text, sci-fi terminal aesthetic
--ar 1:1 --s 250 --v 6.1
```

### Size Standards
| Asset Type | Canvas Size | Display Size |
|------------|-------------|--------------|
| Tower (level 1) | 64x64 px | ~32x32 in-game |
| Tower (level 2-3) | 64x64 px | ~36x36 in-game |
| Enemy (standard) | 48x48 px | ~24x24 in-game |
| Enemy (boss) | 128x128 px | ~64x64 in-game |
| Projectile | 16x16 px | ~8x8 in-game |
| UI icon | 32x32 px | 32x32 in-game |

### Quality Checklist
Before importing ANY sprite:
- [ ] Recognizable at 50% size (silhouette test)
- [ ] Color matches palette exactly (no rogue hues)
- [ ] Transparent background (no artifacts)
- [ ] No text or watermarks
- [ ] Consistent with existing sprites (lighting, style)
- [ ] Works on dark background
- [ ] Doesn't clash with grid lines

### Post-Processing Steps
1. Remove background (transparency)
2. Color-correct to match palette
3. Remove AI artifacts (extra details, floating pixels)
4. Ensure clean edges
5. Test in-game at actual display size
6. Compare side-by-side with existing sprites

---

## 7. Animation Rules

### Tower Animations
- **Idle:** subtle glow pulse (0.5-1.0 Hz), very subtle
- **Attack:** brief recoil/flash (1-2 frames)
- **Upgrade:** single white flash, then settle to new appearance
- **Sell:** fade out + small particle burst

### Enemy Animations
- **Walk:** bob up/down (2px amplitude) during movement
- **Hit:** white flash (1 frame)
- **Freeze:** stop all animation, add ice overlay
- **Death:** shrink + fade + particles (0.15s)

### UI Animations
- **Panel appear:** instant (no slide-in — terminals don't animate)
- **Text appear:** instant or typewriter effect (for transmissions only)
- **Number change:** instant update (no counting animation)
- **Phase transition:** text blink 2-3 times

---

## 8. Audio Treatment Notes

### SFX Style
- **Synthesized, digital** — no realistic sounds
- **Short, punchy** — longest SFX is 0.5 seconds
- **Frequency space:** towers = mid-high, enemies = low-mid, UI = high clicks

### Music Style
- **Ambient electronic** — pads, drones, subtle rhythms
- **Build phase:** calm, spacious, contemplative
- **Wave phase:** tension layers added (not full track change)
- **Boss:** additional percussion, deeper bass
- **No vocals** in gameplay music

### Voice Treatment (Transmissions)
- Heavy radio filter (bandpass 300Hz-3kHz)
- Subtle static/crackle underneath
- Brief burst of noise at start/end of transmission
- Each crew member has a distinct voice profile

---

## 9. Forbidden Motifs

Do NOT include in any asset:
- Cartoon/chibi proportions
- Organic/nature themes (trees, animals, water)
- Fantasy elements (swords, magic, runes)
- Realistic human characters
- Text embedded in sprites
- Bright pastel colors
- Lens flare or bloom effects
- Busy patterns or textures (clean geometry only)
- Round/bubbly UI elements

---

## 10. Naming Conventions

### Files
```
sprites/towers/pulse_emitter_lv1.png
sprites/towers/pulse_emitter_lv2_a.png    # Branch A
sprites/towers/pulse_emitter_lv2_b.png    # Branch B
sprites/enemies/glitch_swarm.png
sprites/effects/pulse_projectile.png
sprites/ui/icon_scrap.png
audio/sfx/tower_place.wav
audio/sfx/tower_shoot_pulse.wav
audio/music/build_phase_01.ogg
audio/voice/voss_tx_01.ogg
```

### Naming Rules
- All lowercase
- Underscores for spaces
- Tower names match `tower_id` from code
- Enemy names match `enemy_id` from code
- Level variants: `_lv1`, `_lv2`, `_lv3`
- Branch variants: `_lv2_a`, `_lv2_b`, `_lv3_a`, `_lv3_b`
- Audio: `category_subcategory_name.ext`
