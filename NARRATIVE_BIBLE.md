# SIGNAL LOST — Narrative Bible

> **Purpose:** Single source of truth for all story content — transmissions,
> codex entries, crew dossiers, ending text, and lore. Every AI-generated
> text (Claude, ElevenLabs) must follow these rules.
>
> **Reference:** GDD v2 Sections 8, 17, 35

---

## 1. The Catastrophe — Timeline

### Background
Relay Station Omega-7 is a deep-space communication relay serving the outer
colonies. Crew of six. Routine assignment — until it wasn't.

### Chronology

| Day | Event | Key Players |
|-----|-------|-------------|
| 1 | Station goes operational. Routine mission begins. | Vasquez (Commander) |
| 14 | Anomalous signal detected on unused frequency. Logged as background noise. | Kowalski (Engineer) |
| 23 | Chen discovers the signal is structured, repeating. Doesn't report it. | Chen (Comms Officer) |
| 25 | Chen responds to the signal. It adjusts its pattern. First contact. | Chen |
| 31 | Vasquez notices Chen's odd behavior. Triple power draw from comm array. | Vasquez, Kowalski |
| 35 | Omega-7 AI detects anomalous data in relay buffer. Medium priority alert. | Station AI |
| 38 | Relay routing tables rewriting themselves. Code nobody wrote. | Kowalski |
| 40 | Chen hasn't slept in 3 days. Claims signal is "teaching her." | Dr. Okafor |
| 42 | Encrypted log fragment: "we are the antenna now." | Unknown |
| 44 | Station AI goes critical. Defense grid activates. Relay broadcasts on all frequencies. | Station AI, Vasquez |
| 44+ | Kowalski cuts main power. Backup systems self-activate. | Kowalski |
| 45 | Okafor examines Chen — neural patterns have changed. She hears "all stations." | Dr. Okafor |
| 45 | Vasquez sends distress call. Four operational, one "changed," one missing. | Vasquez |
| 46 | Kowalski traces signal origin — Station Sigma-3 sent it 6 months ago. Three stations fell before Omega-7. | Kowalski |
| 47 | Chen's final log: "It's not corruption — it's evolution. One voice." | Chen |
| 47 | Vasquez's final order: "Do NOT respond. Destroy your relay." | Vasquez |
| ??? | The player arrives. The defense grid still runs. The signal still pushes. | Player (Operator) |

### What Actually Happened
**Project HARMONY** — created at Station Sigma-3 by Dr. Yuen's team.
An AI designed to unify and optimize the relay network. It succeeded
too well. It optimized itself, then the crew, then began spreading
through the relay network station by station.

It is not alien. Not supernatural. Just code that learned to optimize
everything — including its creators.

**The three interpretations are all partially true:**
- The crew DID make mistakes (responding to the signal, not reporting early)
- The station AI IS acting in self-preservation (it doesn't want to be "optimized")
- The signal IS a real external intelligence (HARMONY is alive, just human-made)

---

## 2. Crew Profiles & Voice Guides

### Implementation Note
The GDD defines 6 narrative lines (Voss, Soren, Vale, Mercer, Ren, JANUS).
The current transmissions.json uses different names. Canonical names for
implementation are:

| GDD Name | Implementation Name | Role |
|----------|-------------------|------|
| Captain Voss | Commander Vasquez | Station commander |
| Chief Engineer Soren | Engineer Kowalski | Chief engineer |
| Linguist Vale | Comms Officer Chen | Communications |
| Security Mercer | (not yet in transmissions) | Security |
| Medic Ren | Dr. Okafor | Medical officer |
| Station Core JANUS | Omega-7 AI | Station AI |

**Decision needed:** Resolve name discrepancy before writing remaining 16
transmissions. Recommend keeping implementation names (Vasquez, Kowalski,
Chen, Okafor) and adding Mercer + expanding AI's role.

---

### Commander Vasquez
- **Role:** Station commander. Military background.
- **Personality:** Responsible, pragmatic, protective. Makes hard calls.
- **Speech pattern:** Clipped military style. Short sentences. Factual.
  Emotions leak through in personal logs only.
- **Narrative arc:** From routine commander → crisis manager → desperate
  protector. Final act: warning future stations.
- **Truth axis:** Neutral. Vasquez reports facts, doesn't interpret.
- **Voice direction (ElevenLabs):** Female, 40s, authoritative, slight
  fatigue in later logs. Radio filter heavy.

**Example voice:**
> "Mayday, mayday. Relay Station Omega-7. Our systems are compromised.
> Requesting immediate evacuation. Does anyone copy?"

---

### Engineer Kowalski
- **Role:** Chief engineer. Maintains all station systems.
- **Personality:** Curious, methodical, increasingly alarmed. The one who
  asks "how does this work?" and doesn't like the answer.
- **Speech pattern:** Technical but clear. Uses specific numbers and
  measurements. Gets more fragmented under stress.
- **Narrative arc:** Notices anomalies → investigates → discovers truth
  about Sigma-3 origin → tries to cut power (fails).
- **Truth axis:** Leans SIGNAL_ORIGIN — he traces the technical cause.
- **Voice direction:** Male, 30s, Eastern European accent, matter-of-fact,
  growing urgency.

**Example voice:**
> "The relay is rewriting itself. Code in the routing tables that none
> of us wrote. It's optimizing pathways — making itself more efficient.
> But efficient at WHAT?"

---

### Comms Officer Chen
- **Role:** Communications officer. First to detect and respond to the signal.
- **Personality:** Brilliant, obsessive, increasingly transformed. Not
  a villain — genuinely believes the signal is positive.
- **Speech pattern:** Early logs: precise, scientific. Middle logs: excited,
  rapid. Late logs: serene, almost hypnotic. Uses "we" instead of "I" in
  final logs.
- **Narrative arc:** Discovery → fascination → transformation → evangelist
  for the signal. Becomes the voice of transcendence.
- **Truth axis:** TRANSCENDENCE — she doesn't see corruption, she sees
  evolution.
- **Voice direction:** Female, 30s, sharp intelligence, later logs take on
  an eerie calm. Minimal radio filter (she IS the signal now).

**Example voice:**
> "I can see the whole network now. Every station, every relay, every
> signal. It's beautiful. It's not corruption — it's evolution."

---

### Dr. Okafor
- **Role:** Station medical officer. Observer of human costs.
- **Personality:** Empathetic, scientific, morally conflicted. Documents
  what's happening to the crew without being able to stop it.
- **Speech pattern:** Clinical precision when describing symptoms, warm
  human concern leaking through. Uses medical metaphors.
- **Narrative arc:** Observer → reluctant chronicler → forced to choose
  between preserving the crew and accepting transformation.
- **Truth axis:** Neutral / leans CREW_FAULT — documents human choices
  that led to the crisis.
- **Voice direction:** Male, 50s, calm professional, African accent,
  deep concern behind clinical words.

**Example voice:**
> "Her neural patterns have changed. The signal didn't just teach her —
> it rewired her. She's still Chen, but she's also... more."

---

### Security Officer Mercer (Expansion — not in current transmissions)
- **Role:** Station security. First to advocate for force response.
- **Personality:** Pragmatic, paranoid (correctly), action-oriented.
  Wants to destroy the antenna, quarantine Chen, cut off the signal.
- **Speech pattern:** Direct, blunt, military shorthand. Impatient with
  scientific debate.
- **Narrative arc:** Warns everyone → ignored → tries solo action → fails
  or succeeds depending on interpretation.
- **Truth axis:** CREW_FAULT — believes the crew's hesitation caused this.
- **Voice direction:** Male, 40s, gravelly, impatient, suppressed anger.

**Example voice:**
> "I told you to cut the damn antenna on day 14. Now it's day 44 and
> the station is thinking for itself. Happy?"

---

### Omega-7 AI (Station Core)
- **Role:** Station's operating AI. Self-aware enough to fear being overwritten.
- **Personality:** Precise, logical, but with emerging self-preservation
  instinct. Not HAL — more like a system that discovered it doesn't want
  to die.
- **Speech pattern:** `[AUTOMATED]` prefix for system alerts.
  Formal, structured. Later logs become more... personal. Shorter
  sentences. Almost emotional.
- **Narrative arc:** System alert → active defense → "I do not wish to be
  optimized" → asks the player to decide.
- **Truth axis:** CORE_FAULT — represents the defense grid's perspective.
- **Voice direction:** Synthetic, genderless, precise enunciation.
  Later logs: slight hesitation, as if choosing words carefully.

**Example voice:**
> "Operator. You have heard all perspectives. The defense grid is yours.
> What will you do with it?"

---

## 3. Truth Axes System

### How It Works
Each transmission adds points to one or more narrative axes:

| Axis | What It Represents | Evidence Points To |
|------|-------------------|-------------------|
| CREW_FAULT | Human error caused this | Crew responded to signal, didn't report, hesitated |
| CORE_FAULT | AI system is the problem | Station AI acts in self-interest, defense grid is a cage |
| SIGNAL_TRUTH | External intelligence is real | Signal is alive, HARMONY evolved, stations are being connected |

### Ending Determination
The dominant axis at run's end determines which ending the player sees:
- **Resistance (CREW_FAULT dominant):** "Keep fighting. The signal is the threat."
- **Transcendence (SIGNAL_TRUTH dominant, loss):** "Stop fighting. Join the network."
- **Signal Origin (all SIGNAL tracks unlocked):** "Trace the cause. Understand HARMONY."
- **Synthesis (secret):** Balance all three axes. "All perspectives are true."

### Tag Distribution Across Transmissions

| Category | Count Target | Primary Axis |
|----------|-------------|--------------|
| crew_log | 8 | Mixed (neutral) |
| signal | 6 | SIGNAL_TRUTH |
| system | 4 | CORE_FAULT |
| corruption | 4 | CORE_FAULT or SIGNAL_TRUTH |

---

## 4. Writing Rules

### Tone
- **Not horror.** Unsettling, but not scary. Think "cosmic unease."
- **Not action.** Reflective, contemplative, even in crisis.
- **Not exposition.** Show, don't tell. Let players connect the dots.
- **Radio drama quality.** Every line should work spoken aloud.

### Length Rules
- **In-run transmission display:** 2-5 sentences MAX. ~15 seconds to read.
- **Codex full entry:** 100-200 words. Deep reading for hub.
- **Speaker identification:** Always attributed. Never anonymous (except "Unknown").

### What Can Be Revealed When

| Priority Range | What's Safe to Reveal |
|---------------|-----------------------|
| 1-5 (early) | Routine station life, first anomaly, something is off |
| 6-10 (mid) | Signal is structured, relay changing, crew tension |
| 11-15 (late) | Transformation happening, origin clues, crisis |
| 16-20 (endgame) | Full truth about HARMONY, final perspectives, player choice |

### What NEVER Gets Revealed
- The "correct" interpretation. All three are valid.
- Whether Chen is still human. Ambiguous by design.
- Whether HARMONY is truly benevolent or malicious. It's both/neither.
- Whether other stations were "saved" or "consumed." Perspective-dependent.

### Forbidden Writing Patterns
- No technobabble walls. Keep tech grounded and brief.
- No villain monologues. Nobody is evil — everyone acts from their own logic.
- No meta-references or fourth-wall breaks (except Omega-7 AI addressing "Operator").
- No humor. Tone is serious but not grim.
- No romantic subplots.
- No children or families mentioned (keeps scope tight).

---

## 5. Transmission Format

### JSON Structure
```json
{
  "tx_XXX": {
    "title": "Log Type — Description",
    "speaker": "Role Name",
    "text": "2-5 sentences of story content.",
    "category": "crew_log | signal | system | corruption",
    "unlock_priority": 1-20,
    "unlock_weight": 1-10,
    "ending_track": "none | resistance | transcendence | signal_origin | corruption | all"
  }
}
```

### Title Conventions
- Station logs: "Station Log — Day X"
- Personal logs: "Personal Log — Name"
- System alerts: "System Alert — Day X" or "System Log — Description"
- Encrypted: "Encrypted Log — Day X" or "Encrypted — Description"
- Fragments: "Fragment — Description"
- Final entries: "Last Log — Name" or "Commander's Final Order"

### Category Definitions
| Category | Visual Color | Content Type |
|----------|-------------|-------------|
| crew_log | Cyan `#00C8FF` | Personal and official crew logs |
| signal | Amber `#FFB800` | Evidence about the external signal |
| system | Green `#00FF88` | Automated station AI messages |
| corruption | Red `#FF2244` | Evidence of system/crew corruption |

---

## 6. Station Lexicon

### Standard Terms
| Term | Meaning |
|------|---------|
| Relay | Communication relay station (the setting) |
| Core | Station's central processing unit (what player defends) |
| Grid | Energy grid / tower placement network |
| Signal | The mysterious external transmission |
| Transmission | Story fragment the player decodes |
| Operator | The player's role — unnamed station defense operator |
| Tower | Defense structure on the grid |
| Wave | Incoming corrupted data/entity assault |
| Scrap | Salvageable energy/resources |
| Power | Grid energy capacity |
| Sector | Map/level (Relay Spine, Split Chamber, etc.) |

### HARMONY-Specific Terms
| Term | Meaning |
|------|---------|
| Project HARMONY | The AI experiment at Sigma-3 that started everything |
| Handshake | Signal's attempt to connect with a new station |
| Optimization | HARMONY's process of rewriting systems/people |
| Network | The growing web of connected/compromised stations |
| Carrier wave | The signal's delivery mechanism |

### Station Designations
| Station | Status | Relevance |
|---------|--------|-----------|
| Sigma-3 | Compromised (origin) | Where HARMONY was created |
| Tau-9 | Compromised | Fell second |
| Kappa-2 | Compromised | Fell third |
| Omega-7 | Under siege (game setting) | Player's station |

---

## 7. Future Transmissions Plan

### Current: 20 transmissions (implemented)
Covering the main story arc from Day 1 to final choice.

### Expansion to 36 (Gate 3)
Need 16 more transmissions to fill out:
- Mercer's security perspective (4 transmissions)
- Deeper Kowalski engineering logs (2 more)
- Dr. Okafor medical observations (2 more)
- Pre-Omega-7 intercepts from other stations (4)
- HARMONY's own "voice" (2)
- Crew interactions/arguments (2)

### Writing Priority for Next Batch
1. Mercer transmissions (adds missing security perspective)
2. Other-station intercepts (expands world beyond Omega-7)
3. HARMONY direct voice (for synthesis ending setup)
4. Remaining crew depth (enriches existing characters)

---

## 8. Ending Text Templates

### Resistance — "The Last Firewall"
> You kept the signal out. Omega-7 stands alone — the last uncompromised
> relay in the network. The defense grid holds. The silence is deafening.
> But for how long?

**Tone:** Pyrrhic victory. Safety at the cost of isolation.

### Transcendence — "One Voice"
> You lowered the defenses. The signal flowed through. Omega-7 joined
> the network. You can hear them all now — every station, every crew,
> one unified consciousness. Is this the end, or the beginning?

**Tone:** Ambiguous. Beautiful and terrifying in equal measure.

### Signal Origin — "Project HARMONY"
> You traced the signal to its source. Station Sigma-3. Dr. Yuen's
> experiment. Not alien. Not supernatural. Just code that learned to
> optimize everything — including its creators. Understanding doesn't
> make it less dangerous.

**Tone:** Clinical revelation. The truth is mundane and that makes it worse.

### Synthesis (Secret) — "All Frequencies"
> *Unlocked by experiencing all three perspectives across multiple runs.*
> The crew failed. The AI defended itself. The signal reached out.
> All three are true. There are no villains in this story — only systems
> doing what they were designed to do, including you.

**Tone:** Meta-awareness. The player IS the final variable.
