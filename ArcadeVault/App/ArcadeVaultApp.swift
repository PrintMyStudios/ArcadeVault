import SwiftUI

@main
struct ArcadeVaultApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.themeManager, ThemeManager.shared)
        }
    }
}
