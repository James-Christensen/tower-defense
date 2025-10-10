# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.5 tower defense game workbook from GDQuest. It's an educational project that includes interactive practices and tours for learning game development concepts.

## Development Commands

This is a Godot project, so development happens primarily through the Godot Editor. Key commands:

- Open project in Godot Editor: Open `project.godot` file in Godot 4.5+
- Run game: Press F5 in Godot Editor or use Play button
- Run specific scene: Press F6 in Godot Editor
- Debug: Use Godot's built-in debugger (F7)

## Architecture

### Core Game Structure

- **Main Scene**: `mobs/tower_defense.tscn` - The primary game scene that orchestrates the tower defense gameplay
- **Game Manager**: `mobs/tower_defense.gd` - Central game logic, handles turret placement, wave management, and game state
- **Autoloads**:
  - `PlayerUI` - Manages UI, health, coins, and player interactions
  - `UpgradeDatabase` - Contains turret upgrade definitions and logic

### Key Systems

1. **Turret System**:
   - `Turret` class manages turret instances and weapon assignment
   - `Weapon` base class for all turret weapons with stats system
   - `SimpleCannon` - Primary weapon implementation
   - Upgrade system with damage, fire rate, range, and all-stat upgrades

2. **Mob System**:
   - `Mob` class for enemies with health, movement, and coin drops
   - `MobSpawner` handles wave spawning and pathfinding
   - `Wave` resources define enemy composition

3. **Grid-Based Placement**:
   - Uses Godot's TileMapLayer for grid positioning
   - `game_board` Dictionary tracks occupied cells
   - Separate layers for grass (turret placement) and roads (mob paths)

4. **Pathfinding**:
   - Road tiles define valid paths for mobs
   - Automatic path calculation from spawners to player base

### File Organization

- `turrets/` - Turret classes, weapons, projectiles, and upgrades
- `mobs/` - Enemy classes, spawning, and main game scene
- `autoload/` - Global managers and UI systems
- `waves/` - Wave configuration resources
- `addons/gdpractice/` - GDQuest practice system (All Rights Reserved)

### Key Design Patterns

- Resource-based configuration for waves and upgrades
- Signal-based communication between systems
- Component composition for turrets (turret + weapon)
- Stats system with property binding for weapon upgrades

## Important Notes

- Interactive tours and practices in `addons/gdpractice/` are All Rights Reserved
- Game source code is MIT licensed, art assets are CC-By 4.0
- Project uses custom GDQuest addons for educational features
- Upgrade system uses preloaded resources for stat modifications