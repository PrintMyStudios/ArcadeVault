import SwiftUI

/// Home screen showing game tiles grid
struct VaultHomeView: View {
    @Environment(\.themeManager) private var themeManager
    @Binding var navigationPath: NavigationPath

    private let columns = [
        GridItem(.adaptive(minimum: Constants.Layout.tileMinWidth, maximum: Constants.Layout.tileMaxWidth), spacing: 16)
    ]

    var body: some View {
        let theme = themeManager.currentTheme
        let palette = theme.palette

        ScrollView {
            VStack(spacing: 24) {
                MarqueeHeaderView()
                    .padding(.top, 8)

                LazyVGrid(columns: columns, spacing: theme.layout.gridSpacing) {
                    ForEach(GameRegistry.shared.games, id: \.id) { game in
                        GameTileView(game: game) {
                            if game.availability == .available {
                                navigationPath.append(GameDestination.play(game))
                            } else {
                                navigationPath.append(GameDestination.comingSoon(game))
                            }
                        }
                    }
                }
                .padding(.horizontal, theme.layout.contentPadding.leading)
            }
            .padding(.bottom, 24)
        }
        .background(palette.background)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    navigationPath.append(AppDestination.settings)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(palette.accent)
                }
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    navigationPath.append(AppDestination.about)
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(palette.foregroundSecondary)
                }
            }
        }
    }
}

/// Navigation destinations for games
enum GameDestination: Hashable {
    case play(any ArcadeGame)
    case comingSoon(any ArcadeGame)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .play(let game):
            hasher.combine("play")
            hasher.combine(game.id)
        case .comingSoon(let game):
            hasher.combine("comingSoon")
            hasher.combine(game.id)
        }
    }

    static func == (lhs: GameDestination, rhs: GameDestination) -> Bool {
        switch (lhs, rhs) {
        case (.play(let a), .play(let b)):
            return a.id == b.id
        case (.comingSoon(let a), .comingSoon(let b)):
            return a.id == b.id
        default:
            return false
        }
    }
}

/// Navigation destinations for app screens
enum AppDestination: Hashable {
    case settings
    case about
}
