# Arcade Vault — plan.md

## 0) Product Summary
Arcade Vault is a premium-feeling iPhone “arcade cabinet” app: a single hub that contains multiple original retro-inspired mini games (built one at a time). The vibe is *authentically retro* with modern polish.

**App Store subtitle (plan):** Retro Arcade Mini Games

Initial game inspirations (mechanics only; no copying of names/assets/layouts):
- Maze Chase (inspired by Pac-Man’s core loop)
- Fixed Shooter (inspired by Space Invaders’ core loop)
- Platform Climber (inspired by Donkey Kong’s core loop)

We will create fully original game titles, art, sound, UI, levels, and branding.

## 1) Goals

### Phase 0 (Foundation) — COMPLETE ✓
- One app capable of hosting multiple games via a clean modular system.
- Arcade "vault" shell: home, game picker, settings, credits.
- Theme system to support strong retro styling without locking in one final direction.
- Game Registry to list available and coming-soon games.
- Shared systems: audio, haptics, persistence (best scores), pause/game-over overlays.

**Delivered:**
- 42 Swift files implementing full architecture
- Test Range fully playable (collect tokens, dodge hazards)
- 3 stub games (Glyph Runner, Starline Siege, Rivet Climb)
- 3 selectable themes with full token sets
- CRT overlay (scanlines + vignette) toggle
- Sound/haptics toggles with procedural SFX
- Best score persistence per game
- THEME-PITCH.md and ADDING-A-GAME.md documentation

### Retro feel vision
- Strong “retro cabinet” identity:
  - CRT options: scanlines/vignette/curvature toggle
  - neon/vector/pixel UI options (theme switcher)
  - snappy arcade transitions, “boot-up” feel
  - satisfying original SFX (generated tones for MVP)

## 2) Tech Stack
- iOS 17+
- Swift 5.9+
- SwiftUI for shell/navigation
- SpriteKit for gameplay scenes
- No external assets needed for Phase 0 (procedural shapes/gradients; minimal SF Symbols only if helpful)

## 3) Architecture Overview

### App shell (SwiftUI)
- `VaultHomeView` — game grid/list + marquee header
- `GameContainerView` — hosts `SKView` + overlays (HUD, pause, game over)
- `SettingsView` — theme picker + CRT toggle + sound/haptics
- `AboutView` — credits + version

### Core modularity
- `ArcadeGame` protocol
- `GameRegistry` (single source of truth for available games)
- Each game lives in `Games/<GameName>/...`

### Shared services
- `ThemeManager` + theme tokens (palette, typography, glow intensity, effects toggles)
- `AudioManager` (simple generated tones for taps/hits/wave clear)
- `HapticsManager`
- `PersistenceStore` (UserDefaults now)
- `InputRouter` (maps touch/drag/swipe into per-game actions)
- `OverlayCoordinator` (pause, game over, HUD)

## 4) Game Slots (Roadmap)
We will start by building ONE real game. The rest are stubs until later.

Game slots (titles are ours; not classic names):
1) **Glyph Runner** — Maze Chase style (stub in Phase 0)
2) **Starline Siege** — Fixed Shooter style (stub in Phase 0)
3) **Rivet Climb** — Platform Climber style (stub in Phase 0)

Phase 0 includes a playable placeholder game to validate the system:
- **Test Range** — simple, tiny gameplay (collect/dodge) to prove end-to-end flow.

## 5) Theme System (Retro identity without committing yet)

We want 3 selectable design concepts with token sets:

### Theme A — Neon CRT
- dark background, neon accents, soft glow, scanlines optional

### Theme B — Vector Arcade
- phosphor green/amber, crisp vector lines, high contrast, minimal glow

### Theme C — 8-Bit Candy
- chunky pixel vibe, limited bright palette, playful arcade UI

Theme requirements:
- `Theme` model with:
  - palette (bg/fg/accent/danger/success)
  - typography (system fonts for now; later custom pixel font)
  - effect toggles (scanlines, vignette, glow intensity)
  - spacing/corner radius rules
- Theme switchable at runtime from Settings
- Persist theme selection + toggles

Phase 0 output should include:
- `THEME-PITCH.md` describing the 3 concepts (short but clear)
- Theme token sets for all 3
- Vault home UI uses current theme tokens

## 6) Persistence (Phase 0)
Store in UserDefaults:
- selectedThemeId
- crtOverlayEnabled
- soundEnabled
- hapticsEnabled
- per-game bestScore (keyed by game id)

## 7) Build Phases

### Phase 0 — Cabinet foundation ✓ COMPLETE
Delivered:
- Running app with:
  - Home screen listing 3 "coming soon" game tiles + 1 playable "Test Range"
  - Settings: theme picker + CRT toggle + sound/haptics toggles
  - GameContainer: HUD + pause overlay + game over overlay
  - Best score persistence per game
- Clean file structure and docs:
  - `THEME-PITCH.md`
  - `ADDING-A-GAME.md`

### Phase 1 — Build Game 1 fully (NEXT)
Implement **Glyph Runner** (maze chase style) as the first real game.
- Replace stub with full gameplay
- Maze generation, player movement, collectibles, enemies
- Scoring system, multiple levels/waves

### Phase 2 — Build Game 2 fully (later)
Implement **Starline Siege** (fixed shooter style).
- Player ship, shooting mechanics
- Enemy waves, formations
- Power-ups, boss battles

### Phase 3 — Build Game 3 fully (later)
Implement **Rivet Climb** (platform climber style).
- Platforming physics, ladders
- Obstacles, hazards
- Level progression

## 8) Definition of Done (Phase 0) ✓ ALL MET
- ✓ Builds and runs on iPhone simulator
- ✓ Home → Game → Pause → Resume → Game Over → Back works
- ✓ Best score saves per game
- ✓ Theme switching works and updates shell UI
- ✓ Adding a new game is straightforward (new folder + implement protocol + register)
- ✓ Retro vibe is present even with procedural visuals
