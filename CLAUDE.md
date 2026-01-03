# Arcade Vault — Claude Code Memory (CLAUDE.md)

See @README.md for project overview and @plan.md for requirements.

## Project status
- **Phase 0**: COMPLETE — Cabinet foundation, Test Range playable, 3 stub games
- **Phase 1**: TODO — Implement Glyph Runner (maze chase)
- **Phase 2**: TODO — Implement Starline Siege (fixed shooter)
- **Phase 3**: TODO — Implement Rivet Climb (platformer)

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

## Output / collaboration rules
- When asked to “write out the full code”, output **full file contents**, not snippets.
- If editing existing files, preserve formatting and keep diffs minimal.
- After implementing a feature:
  - ensure the project compiles
  - sanity-check navigation and pause/resume flows
  - update docs when behavior or structure changes

## Documentation expectations
- Maintain:
  - `THEME-PITCH.md` (theme concepts)
  - `ADDING-A-GAME.md` (how to add modules)
- Update README.md when project structure changes.

## Hard no’s
- No classic trademarked titles in UI/metadata (Pac-Man, Space Invaders, Donkey Kong, Pong, Breakout).
- No copied assets, no ripped audio, no “remake” branding.
