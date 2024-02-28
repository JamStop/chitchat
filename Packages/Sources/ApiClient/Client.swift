// Created by Jimmy Yue in 2024

import ComposableArchitecture
import Foundation
import SharedModels

@DependencyClient
public struct ApiClient {
    public var sendMessageThreadAndGetReply: @Sendable (IdentifiedArrayOf<Message>) async throws -> Message
}

public enum ApiClientError: Error {
    case internalError(String)
    case failedToParseFirebaseResponse(String)
}
