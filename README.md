# Signal Lost

> Roguelike Tower Defense with Procedural Storytelling

You are the last operator of a deep-space relay station. Waves of corrupted signals are attacking your network. Build towers from salvaged tech, decode transmissions between waves, and piece together what happened to the crew. Every run reveals new fragments of the story. Every death teaches you something new.

## Tech Stack

- **Engine:** Godot 4.6.1
- **Language:** GDScript
- **Platform:** Steam (Windows / macOS / Linux)
- **Price:** $4.99

## Getting Started

1. Install [Godot 4.6+](https://godotengine.org/download)
2. Clone this repo
3. Open `project.godot` in Godot
4. Press F5 to run

## Project Structure

```
signal-lost/
├── assets/        # Shaders, fonts, audio, UI textures
├── data/          # JSON balance files (towers, enemies, waves, etc.)
├── scenes/        # Godot scenes (.tscn)
├── scripts/       # GDScript source code
│   └── autoload/  # Global singletons
├── docs/          # Design docs, ADRs, synergy matrix
└── exports/       # Build output (gitignored)
```

## Core Features

- 6 tower types with synergy system
- 5 enemy types including boss
- 8-wave runs (15-20 min each)
- Procedural map generation
- Meta-progression across runs
- 20 story transmissions with 3 endings
- Retro-CRT visual aesthetic

## License

All rights reserved.
