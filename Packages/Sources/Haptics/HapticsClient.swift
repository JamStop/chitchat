// Created by Jimmy Yue in 2024

import ComposableArchitecture
import UIKit

@DependencyClient
public struct HapticsClient {
    public var generateSuccessHaptic: () -> Void
    public var generateFailureHaptic: () -> Void
    public var generateSelectionHaptic: () -> Void
}

extension HapticsClient: DependencyKey {
    public static let liveValue: HapticsClient = { () -> HapticsClient in
        let notificationGenerator = UINotificationFeedbackGenerator()
        let selectionGenerator = UISelectionFeedbackGenerator()
        return Self(
            generateSuccessHaptic: { notificationGenerator.notificationOccurred(.success) },
            generateFailureHaptic: { notificationGenerator.notificationOccurred(.error) },
            generateSelectionHaptic: { selectionGenerator.selectionChanged() }
        )
    }()
    // Haptics don't fire in previews
    public static let previewValue: HapticsClient = Self.noop
}

extension HapticsClient {
    static let noop = Self(
        generateSuccessHaptic: { return },
        generateFailureHaptic: { return },
        generateSelectionHaptic: { return }
    )
}

public extension DependencyValues {
    var hapticsClient: HapticsClient {
        get { self[HapticsClient.self] }
        set { self[HapticsClient.self] = newValue }
    }
}
