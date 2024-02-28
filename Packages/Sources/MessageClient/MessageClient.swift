// Created by Jimmy Yue in 2024

import Foundation
import ComposableArchitecture
import SharedModels

@DependencyClient
public struct MessageClient {
    public var sendMessageAndGetReply: @Sendable (Message) async throws -> Message
    public var sendSeedMessageAndGetReply: @Sendable () async throws -> Message
    public var requestFollowupMessage: @Sendable () async throws -> Message
}
