// Created by Jimmy Yue in 2024

import ComposableArchitecture
import Foundation
import SharedModels

extension MessageClient: TestDependencyKey {
    public static let previewValue = Self(
        sendMessageAndGetReply: { _ in
            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
            return Message.mockAssistantMessage()
        },
        sendSeedMessageAndGetReply: {
            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
            return Message.mockSeedMessageResponse()
        },
        requestFollowupMessage: {
            try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
            return Message.mockFollowupMessageResponse()
        }
    )

    public static let testValue = Self(
        sendMessageAndGetReply: { _ in
            Message.mockAssistantMessage()
        },
        sendSeedMessageAndGetReply: {
            Message.mockSeedMessageResponse()
        },
        requestFollowupMessage: {
            Message.mockFollowupMessageResponse()
        }
    )
}

public extension DependencyValues {
    var messageClient: MessageClient {
        get { self[MessageClient.self] }
        set { self[MessageClient.self] = newValue }
    }
}

extension Message {
    static func mockSeedMessageResponse() -> Message {
        return Message(
            content: """
            Hi! How are you doing today? It's been a while :)
            """,
            type: .assistant
        )
    }

    static func mockFollowupMessageResponse() -> Message {
        return Message(
            content: """
            This is a followup message!
            """,
            type: .assistant
        )
    }
}
