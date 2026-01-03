import UIKit

/// Manages haptic feedback
final class HapticsManager {
    static let shared = HapticsManager()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()

    var isEnabled: Bool {
        get { PersistenceStore.shared.hapticsEnabled }
        set { PersistenceStore.shared.hapticsEnabled = newValue }
    }

    private init() {
        prepareGenerators()
    }

    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
    }

    func trigger(_ type: HapticType) {
        guard isEnabled else { return }

        switch type {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        case .success:
            notification.notificationOccurred(.success)
        case .warning:
            notification.notificationOccurred(.warning)
        case .error:
            notification.notificationOccurred(.error)
        }

        prepareGenerators()
    }
}
