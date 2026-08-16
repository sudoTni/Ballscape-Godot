# 🎱 Ballscape

[![Version](https://img.shields.io/badge/Version-v0.2.0-orange.svg)]()
[![Godot Engine](https://img.shields.io/badge/Godot-v4.7%2B-blue?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS-lightgrey)]()

**Ballscape** is an action-packed, retro arcade brick-breaker game built with Godot Engine 4. It modernizes the classic breakout genre with dynamic physics, powerup transformations, hazard mechanics, procedural retro sound synthesis, multi-phase boss battles, and a full in-game custom level editor.

---

## ✨ Features

- 🎮 **Dynamic Arcade Controls & Physics**
  - Smooth paddle movement supporting both responsive mouse tracking and keyboard arrow keys.
  - Realistic angle deflection based on where the ball impacts the paddle.
  - Combo system with dynamic score multipliers ($1.5\times$ to $3.0\times$) and pop-up floating score animations.

- ⚡ **10 Powerups & Transformations**
  - 🟡 **Multiball**: Spawns additional active balls into play.
  - ❤️ **Extra Life**: Grants an extra life.
  - ↔️ **Expand Paddle**: Increases paddle width for easier control.
  - 🤏 **Shrink Paddle**: Decreases paddle size for higher challenge.
  - 🧲 **Sticky Paddle**: Holds the ball on contact until re-launched.
  - 🔫 **Laser Cannon**: Equips twin lasers to blast bricks and hazards directly.
  - 🔥 **Fireball**: Allows ball to pierce straight through regular bricks.
  - ⏱️ **Slow Ball**: Reduces ball velocity for precision control.
  - 🛡️ **Bottom Shield**: Deploys a protective boundary line preventing ball loss.
  - 💎 **Score 2x**: Doubles all point gains while active.

- 🧱 **16 Distinct Brick Variations**
  - Standard Color Bricks (Red, Orange, Yellow, Green, Blue, Purple).
  - Multi-HP Damaged Bricks (1 to 3 hits required with visual damage progression).
  - Armored Dark & Gold Bricks (High durability requiring up to 5 hits).
  - Unbreakable Barriers & Moving Bricks.
  - Explosive Chain-Reaction Bricks with physics area-of-effect detonations.
  - Teleportation Portals that warp balls instantly across the arena.

- ⚠️ **Hazards & Enemies**
  - **Spikes**: Destroys balls on contact.
  - **Mines**: Detonates when touched by balls or paddle.
  - **Bumpers**: Pinball-style bouncy obstacles.
  - **Electric Hazards**: Sparks on ball impact.
  - **Turrets**: Automated cannons firing energy bolts downward at the player.

- 👑 **Epic Multi-Phase Boss Battle**
  - Stage 6 features a Mega Boss with 100 HP, health bar, and 3 distinct attack phases:
    1. *Phase 1*: Twin vertical laser salvos.
    2. *Phase 2*: Angled 3-way fan laser attacks.
    3. *Phase 3 (Enraged)*: Fast movement & 5-way spread barrage.

- 🎵 **Procedural Retro Audio Synthesizer**
  - Zero external sound files required! Includes a procedural audio generator ([audio_manager.gd](file:///home/michael/tmp/ballscape-godot/scripts/audio_manager.gd)) using Godot's `AudioStreamWAV` to synthesize retro 8-bit sound effects (sine sweeps, square waves, noise explosions, laser zaps, and arpeggios) in memory on startup.

- 🛠️ **Built-in Level Editor**
  - Full in-game visual stage editor! Place or erase 12 brick types on an $8 \times 6$ tile grid, save layout data to `user://custom_level.json`, and test custom levels in real time.

- 🎨 **Visual Effects & Game Juice**
  - Trauma-decay camera shake on impacts and explosions.
  - Particle FX for debris shards, shockwaves, laser sparks, and glow halos.
  - Animated HUD with heart life bars, score formatting, and overlay menus.

---

## 🛠️ Project Structure

```
ballscape-godot/
├── project.godot            # Engine Configuration File
├── scenes/                  # Godot Packed Scenes (.tscn)
│   ├── main_menu.tscn       # Main Title Screen & Level Select
│   ├── game.tscn            # Primary Gameplay Arena & Camera
│   ├── level_editor.tscn    # Tile Grid Level Creator
│   ├── hud.tscn             # CanvasLayer Heads-Up Display
│   ├── ball.tscn            # Ball Physics Node (CharacterBody2D)
│   ├── paddle.tscn          # Player Paddle Node (CharacterBody2D)
│   ├── brick.tscn           # Brick Node (StaticBody2D)
│   ├── boss.tscn            # Boss Enemy Node (Area2D)
│   ├── hazard.tscn          # Hazard Area Node (Area2D)
│   ├── powerup.tscn         # Falling Powerup Node (Area2D)
│   └── laser_bolt.tscn      # Projectile Node (Area2D)
├── scripts/                 # GDScript Logic (.gd)
│   ├── global.gd            # Autoload Singleton: Game State & Powerups
│   ├── audio_manager.gd     # Autoload Singleton: Procedural Audio Synth
│   ├── game.gd              # Main Game Coordinator
│   ├── level_loader.gd      # Stage Layout Generator & Custom JSON Loader
│   ├── level_editor.gd      # Level Creator Interface Logic
│   ├── ball.gd              # Ball Physics & Collision Logic
│   ├── paddle.gd            # Paddle Movement & Laser Logic
│   ├── brick.gd             # Brick Destruction & Explosion Logic
│   ├── boss.gd              # Boss AI & Bullet Patterns
│   ├── hazard.gd            # Hazard Behaviors & Turret Firing
│   ├── powerup.gd           # Falling Collectible Behaviors
│   ├── camera_shake.gd      # Camera Trauma Shake Math
│   ├── particle_fx.gd       # Sprite Visual FX Animation
│   └── floating_text.gd     # Floating Score Indicator Animation
└── assets/                  # Texture Slices & Atlases
    ├── ballscape_sprite_sheet.png
    └── sprites/             # Texture Atlas Slice Resources (.tres)
```

---

## 🚀 How to Run

### Requirements
- **Godot Engine 4.0+** (Tested on Godot 4.7)

### Launching the Game

1. **Via Godot Editor**:
   - Open Godot Engine and choose **Import**.
   - Select the `project.godot` file in this directory.
   - Press **F5** (or click **Play**) to start from `res://scenes/main_menu.tscn`.

2. **Via Command Line**:
   ```bash
   # Run directly using the included Linux Godot binary:
   ./Godot_v4.7.1-stable_linux.x86_64 --path .
   ```

---

## 🎮 Controls

| Action | Control |
| :--- | :--- |
| **Move Paddle** | Move Mouse OR `Left` / `Right` Arrow Keys (`A` / `D`) |
| **Launch Ball / Fire Lasers** | Left Mouse Button OR `Spacebar` / `Enter` |
| **Pause Game** | Click **Pause Button** in HUD |
| **Level Editor** | Left Click to Place Brick, Right Click to Erase |

---

## ⚙️ Technical Highlights

- **Autoload State Architecture**: `Global` handles reactive state propagation via signals (`score_changed`, `lives_changed`, `combo_changed`, `powerup_activated`, `shield_state_changed`).
- **Physics Shape Intersections**: Explosive bricks query nearby static bodies in a radius using `PhysicsShapeQueryParameters2D` and `direct_space_state` to perform multi-brick chain explosions.
- **Dynamic Waveform Generation**: `AudioManager` generates custom 16-bit PCM `AudioStreamWAV` buffers using trigonometric sine wave sweeps, square wave pulse modulation, lowpass-filtered noise, and chromatic frequency arrays.

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
