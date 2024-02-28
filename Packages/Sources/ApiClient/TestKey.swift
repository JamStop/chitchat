// Created by Jimmy Yue in 2024

import ComposableArchitecture
import Foundation
import SharedModels

public extension DependencyValues {
    var apiClient: ApiClient {
        get { self[ApiClient.self] }
        set { self[ApiClient.self] = newValue }
    }
}

extension ApiClient: TestDependencyKey {
    public static let previewValue = Self(
        sendMessageThreadAndGetReply: { _ in
            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
            return Message.mockAssistantMessage()
        }
    )
    public static let testValue = Self.noop
}

extension ApiClient {
    static let noop = Self(
        sendMessageThreadAndGetReply: { _ in try await Task.never() }
    )
}
