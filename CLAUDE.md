# Arcade Vault — Claude Code Memory (CLAUDE.md)

See @README.md for project overview and @plan.md for requirements.

## Project status
- **Phase 0**: COMPLETE — Cabinet foundation, Test Range playable, 3 stub games
- **Phase 1**: NEXT — Implement Glyph Runner (maze chase)
- **Phase 2**: TODO — Implement Starline Siege (fixed shooter)
- **Phase 3**: TODO — Implement Rivet Climb (platformer)

---

## NEXT TASK: Phase 1 — Glyph Runner

### What to build
Replace the stub at `Games/GlyphRunner/` with a fully playable **maze chase** game (inspired by Pac-Man mechanics but 100% original).

### Game concept
- Player navigates a maze collecting glyphs/symbols
- Enemies patrol the maze and chase the player
- Clear all glyphs to complete a level
- Multiple levels with increasing difficulty
- Power-ups that let player defeat enemies temporarily

### Implementation steps
1. **Read existing stub** at `Games/GlyphRunner/GlyphRunnerGame.swift` and `GlyphRunnerScene.swift`
2. **Create new files**:
   - `GlyphRunnerConstants.swift` — tuning values
   - `GlyphRunnerPlayer.swift` — player node
   - `GlyphRunnerEnemy.swift` — enemy AI
   - `GlyphRunnerMaze.swift` — maze generation/structure
3. **Update `GlyphRunnerGame.swift`** — change availability to `.available`
4. **Implement `GlyphRunnerScene.swift`**:
   - Maze rendering (procedural, no assets)
   - Player movement (swipe or tap direction)
   - Glyph collection
   - Enemy spawning and AI (patrol + chase)
   - Collision detection
   - Level completion and progression
   - Score tracking via `gameDelegate`
5. **Update `GameContainerView.restartGame()`** to handle GlyphRunner restart
6. **Test**: Home tile works, game plays, pause/resume/game-over flow, best score persists

### Design constraints
- Procedural visuals only (shapes, gradients — no external images)
- Use theme colors from `ThemeManager.shared.currentTheme.palette`
- Keep game logic in `Games/GlyphRunner/` folder
- Follow patterns from TestRange (delegate calls, physics categories)

### Reference: TestRange pattern
Look at `Games/TestRange/` for the working pattern:
- `TestRangeConstants.swift` — physics categories, tuning values
- `TestRangePlayer.swift` — SKShapeNode subclass with physics
- `TestRangeScene.swift` — full gameplay loop, delegate communication
- `TestRangeGame.swift` — ArcadeGame protocol conformance

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
| Glyph Runner | STUB | `Games/GlyphRunner/*` |
| Starline Siege | STUB | `Games/StarlineSiege/*` |
| Rivet Climb | STUB | `Games/RivetClimb/*` |

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
