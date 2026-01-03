import SwiftUI

/// Root navigation coordinator
struct ContentView: View {
    @Environment(\.themeManager) private var themeManager
    @State private var navigationPath = NavigationPath()

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette

        NavigationStack(path: $navigationPath) {
            VaultHomeView(navigationPath: $navigationPath)
                .navigationDestination(for: GameDestination.self) { destination in
                    switch destination {
                    case .play(let game):
                        GameContainerView(game: game)
                    case .comingSoon(let game):
                        ComingSoonView(game: game)
                    }
                }
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .settings:
                        SettingsView()
                    case .about:
                        AboutView()
                    }
                }
        }
        .tint(palette.accent)
        .preferredColorScheme(.dark)
    }
}
