# Adding a New Game to Arcade Vault

Step-by-step guide for adding a new game module.

---

## Quick Checklist

- [ ] Create folder: `Games/<GameName>/`
- [ ] Create `<GameName>Game.swift` (implements `ArcadeGame`)
- [ ] Create `<GameName>Scene.swift` (extends `SKScene`)
- [ ] Create `<GameName>Constants.swift` (optional, for tuning)
- [ ] Add icon style to `GameIconStyle` enum (if new style needed)
- [ ] Register in `GameRegistry.registerGames()`
- [ ] Test: tile appears on home, game launches, pause/resume/game-over work, score persists

---

## Step 1: Create the Folder

```
ArcadeVault/Games/<GameName>/
```

Example: `ArcadeVault/Games/MeteorStorm/`

---

## Step 2: Implement `ArcadeGame` Protocol

Create `<GameName>Game.swift`:

```swift
import SpriteKit

struct MeteorStormGame: ArcadeGame {
    let id = "meteorStorm"                    // Unique, used for persistence
    let displayName = "Meteor Storm"           // Shown on tile
    let description = "Survive the asteroid field"  // Tile subtitle
    let availability: GameAvailability = .available  // or .comingSoon
    let iconStyle: GameIconStyle = .fixedShooter     // For procedural icon

    func createScene(size: CGSize, delegate: GameSceneDelegate?) -> SKScene {
        let scene = MeteorStormScene(size: size)
        scene.scaleMode = .aspectFill
        scene.gameDelegate = delegate
        return scene
    }
}
```

---

## Step 3: Implement the Scene

Create `<GameName>Scene.swift`:

```swift
import SpriteKit

class MeteorStormScene: SKScene, SKPhysicsContactDelegate {
    weak var gameDelegate: GameSceneDelegate?
    private var score = 0

    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.contactDelegate = self
        setupGame()
        gameDelegate?.gameScene(self, requestSound: .gameStart)
    }

    private func setupGame() {
        // Initialize player, enemies, etc.
    }

    // Update score
    private func addScore(_ points: Int) {
        score += points
        gameDelegate?.gameScene(self, didUpdateScore: score)
        gameDelegate?.gameScene(self, requestHaptic: .medium)
        gameDelegate?.gameScene(self, requestSound: .collect)
    }

    // End game
    private func endGame() {
        gameDelegate?.gameScene(self, requestSound: .gameOver)
        gameDelegate?.gameSceneDidEnd(self, finalScore: score)
    }

    // For restart support
    func restartGame() {
        removeAllChildren()
        score = 0
        setupGame()
        gameDelegate?.gameScene(self, didUpdateScore: 0)
    }
}
```

---

## Step 4: Register the Game

In `ArcadeCore/Registry/GameRegistry.swift`, add to `registerGames()`:

```swift
private func registerGames() {
    games = [
        TestRangeGame(),
        GlyphRunnerGame(),
        StarlineSiegeGame(),
        RivetClimbGame(),
        MeteorStormGame()   // <-- Add here
    ]
}
```

Order in array = order on home screen.

---

## Step 5: Add Icon Style (if needed)

If your game needs a unique icon, add to `GameIconStyle` in `ArcadeGame.swift`:

```swift
enum GameIconStyle {
    case testRange
    case mazeChase
    case fixedShooter
    case platformer
    case meteorStorm  // <-- Add case
}
```

Then add drawing code in `ProceduralIconView.swift`.

---

## Step 6: Handle Restart (Important!)

For restart to work, update `GameContainerView.restartGame()`:

```swift
private func restartGame() {
    if let testRangeScene = scene as? TestRangeScene {
        testRangeScene.restartGame()
        coordinator.restart()
    } else if let meteorStormScene = scene as? MeteorStormScene {
        meteorStormScene.restartGame()
        coordinator.restart()
    }
    // Add more games as needed
}
```

Or refactor to use a protocol for cleaner handling.

---

## Communication with Container

Use `gameDelegate` to communicate with the SwiftUI container:

| Method | When to Call |
|--------|--------------|
| `didUpdateScore(score:)` | Score changes |
| `gameSceneDidEnd(finalScore:)` | Game over |
| `gameSceneDidRequestPause()` | Player requests pause |
| `requestHaptic(type:)` | Trigger haptic feedback |
| `requestSound(type:)` | Play sound effect |

---

## Best Score Persistence

Automatic! The container handles saving via `PersistenceStore` using your game's `id`.

---

## Testing Checklist

1. **Home screen:** Tile appears with correct title, description, icon
2. **Launch:** Game starts, player can interact
3. **Scoring:** Score updates in HUD
4. **Pause:** Pause button works, resume returns to game
5. **Game over:** Final score shows, best score updates if beaten
6. **Restart:** Play Again resets game correctly
7. **Exit:** Returns to home screen
8. **Persistence:** Best score persists after app restart
9. **Theme:** Game respects current theme (optional for SpriteKit content)

---

## Example: Stub Game (Coming Soon)

For games not yet implemented:

```swift
struct FutureGame: ArcadeGame {
    let id = "futureGame"
    let displayName = "Future Game"
    let description = "Something amazing"
    let availability: GameAvailability = .comingSoon  // <-- Key difference
    let iconStyle: GameIconStyle = .mazeChase

    func createScene(size: CGSize, delegate: GameSceneDelegate?) -> SKScene {
        let scene = FutureGameScene(size: size)
        scene.scaleMode = .aspectFill
        return scene
    }
}
```

Coming-soon games show the "COMING SOON" badge and open `ComingSoonView` instead of launching.
