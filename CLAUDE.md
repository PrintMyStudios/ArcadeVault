# Arcade Vault — Claude Code Memory (CLAUDE.md)

See @README.md for project overview and @plan.md for requirements.

## Project status
- **Phase 0**: COMPLETE — Cabinet foundation, Test Range playable, 3 stub games
- **Phase 1**: COMPLETE — Glyph Runner fully playable (maze chase)
- **Phase 2**: COMPLETE — Starline Siege fully playable (fixed shooter)
- **Phase 3**: COMPLETE — Rivet Climb fully playable (platform climber)

---

## ALL CORE GAMES COMPLETE

All 3 planned games are now fully playable:
- **Glyph Runner** — Maze chase style
- **Starline Siege** — Fixed shooter style
- **Rivet Climb** — Platform climber style

### Potential future work
- Polish and balance existing games
- Add more levels/variations
- Custom pixel art assets (see Asset Design System below)
- Additional game modes
- Leaderboards / achievements
- Sound design improvements

---

## Asset Design System (Optional Enhancement)

The plan file at `~/.claude/plans/async-greeting-coral.md` contains a complete asset design system for creating custom sprites. Games work with procedural placeholders, but custom assets can be added following these specs:

- **Player/Enemy sprites**: 64×64 points (@3x = 192×192 pixels)
- **Collectibles**: 32×32 points
- **Format**: PNG with transparency
- **Style**: Pixel art at 16×16 or 32×32 scaled up

When you add assets to `Assets.xcassets`, tell Claude to update the corresponding node class from `SKShapeNode` to `SKSpriteNode`.

---

## Operating principles (follow strictly)
- Build **original** retro-inspired games: never copy classic names, art, sounds, UI layouts, or level designs.
- Prefer **small, testable steps** with clean commits.
- Keep changes **consistent with plan.md**; if a detail is missing, choose the simplest implementation that keeps the architecture extensible.
- Keep this file concise. If it grows large, split into `.claude/rules/*.md` and import those files here.

## Tech constraints
- iOS 17+
- Swift 5.9+
- SwiftUI shell + SpriteKit gameplay
- Uses iOS 17 `@Observable` macro (not ObservableObject)
- Procedural visuals and generated SFX (no external assets)

## Common tasks / commands
- Build & run: use Xcode (⌘R).
- Optional CLI build (if scheme is `ArcadeVault`):
  - `xcodebuild -scheme ArcadeVault -destination 'platform=iOS Simulator,name=iPhone 15' -configuration Debug build`

## Code conventions
### Swift / SwiftUI
- Prefer `struct` views, value types, and clear state flow.
- Keep view models small and testable; avoid global state.
- Centralise app strings (e.g., `AppBrand.swift`) and tuning constants (e.g., `Constants.swift`).

### SpriteKit
- One `SKScene` per game module (e.g., `TestRangeScene`, `GlyphRunnerScene`).
- Use clear physics categories + `SKPhysicsContactDelegate`.
- Keep gameplay logic in the game module folder; shared helpers live in `ArcadeCore/`.

## Architecture rules
- `GameRegistry` is the single source of truth for what appears on the home screen.
- `GameContainerView` is the only place that hosts the `SKView` and overlays.
- Shared systems live in `ArcadeCore/` (themes, audio/haptics, persistence).
- Themes are tokenised. UI must read from the theme tokens (no hard-coded colours).

## Key files reference
| Purpose | File |
|---------|------|
| App entry | `App/ArcadeVaultApp.swift` |
| Branding strings | `App/AppBrand.swift` |
| Game protocol | `ArcadeCore/Protocols/ArcadeGame.swift` |
| Scene delegate | `ArcadeCore/Protocols/GameSceneDelegate.swift` |
| Game registry | `ArcadeCore/Registry/GameRegistry.swift` |
| Theme tokens | `Themes/Theme.swift` |
| Theme state | `Themes/ThemeManager.swift` |
| Game host | `UI/GameContainer/GameContainerView.swift` |
| Overlay state | `ArcadeCore/State/OverlayCoordinator.swift` |
| Persistence | `ArcadeCore/Services/PersistenceStore.swift` |

## Implemented games
| Game | Status | Files |
|------|--------|-------|
| Test Range | PLAYABLE | `Games/TestRange/*` |
| Glyph Runner | PLAYABLE | `Games/GlyphRunner/*` (6 files) |
| Starline Siege | PLAYABLE | `Games/StarlineSiege/*` (6 files) |
| Rivet Climb | PLAYABLE | `Games/RivetClimb/*` (6 files) |

## Adding a new game
See `ADDING-A-GAME.md` for step-by-step instructions. Quick summary:
1. Create `Games/<Name>/<Name>Game.swift` implementing `ArcadeGame`
2. Create `Games/<Name>/<Name>Scene.swift` extending `SKScene`
3. Register in `GameRegistry.registerGames()`
4. Update `GameContainerView.restartGame()` for restart support

## Git workflow
- **Commit after significant changes**: After completing a feature, fixing bugs, or making meaningful progress, create a commit with a clear message.
- **Commit message format**: Brief summary line, then bullet points of what changed.
- **Remind user to push**: When finishing a task or session, remind the user to push to GitHub if there are unpushed commits.
- Check `git status` before ending to ensure nothing is left uncommitted.

## Output / collaboration rules
- When asked to "write out the full code", output **full file contents**, not snippets.
- If editing existing files, preserve formatting and keep diffs minimal.
- After implementing a feature:
  - ensure the project compiles
  - sanity-check navigation and pause/resume flows
  - update docs when behavior or structure changes
  - **commit the changes** with a descriptive message

## Documentation expectations
- Maintain:
  - `THEME-PITCH.md` (theme concepts)
  - `ADDING-A-GAME.md` (how to add modules)
- Update README.md when project structure changes.

## Hard no's
- No classic trademarked titles in UI/metadata (Pac-Man, Space Invaders, Donkey Kong, Pong, Breakout).
- No copied assets, no ripped audio, no "remake" branding.

---

## Session startup checklist
When starting a new conversation:
1. Read this file (CLAUDE.md) for context and next task
2. Check `git status` for any uncommitted changes
3. Check `git log --oneline -3` for recent history
4. Read `plan.md` if more detail needed on requirements
5. If user asks to continue, proceed with the NEXT TASK above

## Phase 0 summary (for context)
Built complete iOS app foundation with:
- **42 Swift files** in modular architecture
- **SwiftUI shell**: NavigationStack, VaultHomeView, SettingsView, AboutView
- **SpriteKit container**: GameContainerView hosts SKScene with SwiftUI overlays
- **Theme system**: 3 themes (Neon CRT, Vector Arcade, 8-Bit Candy) with full token sets
- **Services**: AudioManager (procedural SFX), HapticsManager, PersistenceStore
- **Test Range game**: Playable collect/dodge game validating full flow
- **3 stub games**: GlyphRunner, StarlineSiege, RivetClimb (show "Coming Soon")
- **Overlays**: HUD, Pause menu, Game Over screen
- **Persistence**: Theme, CRT toggle, sound/haptics, per-game best scores

## Phase 1 summary (Glyph Runner)
Implemented full maze chase game with:
- **6 new/modified files** in `Games/GlyphRunner/`
- **Grid-based maze**: 15×21 pre-designed symmetric layout
- **Player**: Hexagon shape, swipe controls, grid movement with input buffering
- **4 Enemies**: Distinct AI personalities (chaser, ambusher, patrol, random)
- **Enemy AI**: State machine (inHome, exiting, scatter, chase, frightened, eaten)
- **Collectibles**: Glyphs (10 pts) + Power glyphs (50 pts) with physics contacts
- **Power-up system**: 8-second vulnerable state, consecutive eat bonuses (100→200→400→800)
- **Lives system**: 3 lives with respawn
- **Level progression**: Faster enemies each level, level completion bonus
- **Bug fixes**: Fixed struct/class delegate conformance, @Observable bindings

## Phase 2 summary (Starline Siege)
Implemented full fixed shooter game with:
- **6 files** in `Games/StarlineSiege/` (4 new, 2 rewritten)
- **Player ship**: Chevron shape, drag to move horizontally, tap to shoot
- **Enemy formation**: 7×4 grid with 3 types (Basic, Fast, Heavy)
- **Formation movement**: Side-to-side with descent on edge hit, speed increases
- **Enemy shooting**: Bottom-most in each column can fire (by screen y-position)
- **Bullets**: Player bullets (fast up), enemy bullets (slower down), precision collision
- **Power-ups**: Shield (8s), Rapid Fire (6s), Multi-Shot (6s) — 10% drop, max 1 on screen
- **Wave system**: Clear all enemies for bonus, next wave harder
- **Lives system**: 3 lives with 2-second invincibility on respawn
- **Game over**: Lives depleted OR enemies reach player level
- **Touch handling**: Tap detection (vs drag) for clean controls

## Phase 3 summary (Rivet Climb)
Implemented full platform climber game with:
- **6 files** in `Games/RivetClimb/` (4 new, 2 rewritten)
- **Pure grid movement**: All entities step cell-to-cell, deterministic behavior
- **Player states**: Grounded (walk left/right), climbing (up/down on ladders), falling
- **Controls**: Tap zones for walking, swipes for climbing, hold-to-repeat for speed
- **Input buffer**: Queue 1 action during movement for responsive feel
- **Obstacles**: Rolling bolts (horizontal) and falling crates (vertical), grid-driven
- **Difficulty scaling**: Spawn rate, obstacle mix, drop-through % increase per level
- **Collectibles**: Rivets with streak bonus (+50 per consecutive without damage)
- **Danger bonus**: +25 points when obstacle passes within 1 cell
- **3 level layouts**: ASCII-defined, cycling with variations
- **Lives system**: 3 lives, 2-second invincibility on respawn, clear nearby obstacles
- **RestartableScene protocol**: Added for cleaner restart handling across all games
