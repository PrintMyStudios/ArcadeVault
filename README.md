# Arcade Vault

**Subtitle (App Store):** Retro Arcade Mini Games

Arcade Vault is a single iPhone app that hosts multiple **original** retro-inspired mini-games in a polished “arcade cabinet” shell. The games are inspired by classic **mechanics**, but use **fully original** names, visuals, audio, UI, and level design.

## Status

We're building this in phases.

- **Phase 0 (complete):** Cabinet foundation + shared systems (themes, settings, persistence, game container) + one playable game ("Test Range") + three stubs.
- **Phase 1+:** Build real games one at a time (Maze Chase style, Fixed Shooter style, Platform Climber style).

## Tech

- iOS 17+
- Swift 5.9+
- SwiftUI (app shell)
- SpriteKit (gameplay scenes)

No external assets are required for Phase 0 (procedural shapes/gradients + simple generated tones for SFX).

## Features (Phase 0)

- Home screen with animated game tiles
- One playable game (Test Range) with touch controls
- Three stub games with "Coming Soon" teaser screens
- Three selectable visual themes with full token systems
- CRT overlay effect (scanlines + vignette)
- Procedural audio SFX
- Haptic feedback
- Pause/resume/game-over flow
- Best score persistence per game
- Settings screen with toggles
- About/credits screen

## Run

### Xcode (recommended)
1) Open the project in Xcode  
2) Select an iPhone simulator  
3) Run (⌘R)

### CLI (optional)
If the scheme is named `ArcadeVault`, a typical command is:

```bash
xcodebuild -scheme ArcadeVault -destination 'platform=iOS Simulator,name=iPhone 15' -configuration Debug build
```

## App structure

```
ArcadeVault/
├── ArcadeVault.xcodeproj/
├── ArcadeVault/
│   ├── App/                    # Entry point, branding, content view
│   ├── UI/
│   │   ├── Home/               # VaultHomeView, game tiles
│   │   ├── GameContainer/      # SpriteKit host + overlays
│   │   ├── Settings/           # Settings, theme picker
│   │   ├── About/              # Credits screen
│   │   ├── ComingSoon/         # Teaser for stubs
│   │   └── Components/         # CRT overlay, buttons, header
│   ├── Themes/                 # Theme struct + 3 implementations
│   ├── ArcadeCore/
│   │   ├── Protocols/          # ArcadeGame, GameSceneDelegate
│   │   ├── Registry/           # GameRegistry
│   │   ├── State/              # GameState, OverlayCoordinator
│   │   ├── Services/           # Audio, Haptics, Persistence
│   │   └── Helpers/            # Constants, Extensions
│   ├── Games/
│   │   ├── TestRange/          # PLAYABLE
│   │   ├── GlyphRunner/        # stub
│   │   ├── StarlineSiege/      # stub
│   │   └── RivetClimb/         # stub
│   ├── Resources/              # Assets.xcassets
│   └── Preview Content/
├── THEME-PITCH.md
├── ADDING-A-GAME.md
├── CLAUDE.md
├── plan.md
└── README.md
```

## Adding a new game (high level)

1) Create a folder under `Games/<NewGameName>/`
2) Implement the `ArcadeGame` protocol (id, displayName, description, availability, scene factory)
3) Register it in `GameRegistry`
4) Confirm:
   - Home tile appears
   - Game launches inside `GameContainerView`
   - Best score persists correctly (if applicable)

## Themes

The app supports 3 selectable retro theme concepts (see `THEME-PITCH.md` for details):

| Theme | Vibe | Key Colors |
|-------|------|------------|
| **Neon CRT** | 80s arcade, glowing neon | Magenta + Cyan on navy |
| **Vector Arcade** | Asteroids, terminal | Phosphor green on black |
| **8-Bit Candy** | Playful home console | Pink + Aqua on purple |

Theme selection, CRT overlay toggle, and sound/haptics settings persist locally.

## Games

| Game | Status | Description |
|------|--------|-------------|
| Test Range | PLAYABLE | Touch-drag to collect tokens, dodge hazards |
| Glyph Runner | Coming Soon | Maze chase style |
| Starline Siege | Coming Soon | Fixed shooter style |
| Rivet Climb | Coming Soon | Platform climber style |

## IP & originality guardrails

- Do **not** use classic game names (e.g., “Pac-Man”, “Space Invaders”, “Donkey Kong”, “Pong”, “Breakout”) in user-facing UI, App Store metadata, or assets.
- Do **not** copy sprites, sounds, level layouts, or UI from existing games.
- Mechanics may be inspired by classics, but the app’s expression must be original.

## Working with Claude Code

- Keep project instructions in `CLAUDE.md` (loaded automatically by Claude Code).
- Keep the product/phase requirements in `plan.md`.
- When architecture changes, update this README and/or `ADDING-A-GAME.md`.
