// Created by Jimmy Yue in 2024

import Foundation
import AudioToolbox
import ComposableArchitecture

@DependencyClient
public struct AudioClient {
    public var playMessageSent: () -> Void
    public var playMessageReceived: () -> Void
    public var playChitbotTapped: () -> Void
}

extension AudioClient: DependencyKey {
    public static let liveValue: AudioClient = Self(
        playMessageSent: { AudioServicesPlaySystemSound(1004) },
        playMessageReceived: { AudioServicesPlaySystemSound(1003) },
        playChitbotTapped: { AudioServicesPlaySystemSound(1022) }
    )
}

public extension DependencyValues {
    var audioClient: AudioClient {
        get { self[AudioClient.self] }
        set { self[AudioClient.self] = newValue }
    }
}
