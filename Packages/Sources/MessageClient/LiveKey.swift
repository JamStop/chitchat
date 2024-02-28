// Created by Jimmy Yue in 2024

import ApiClient
import ComposableArchitecture
import Foundation
import SharedModels

extension MessageClient: DependencyKey {
    public static let liveValue: MessageClient = { () -> MessageClient in
        let actor = ThreadContextActor()
        return Self(
            sendMessageAndGetReply: { message in try await actor.sendMessageAndGetReply(message: message) },
            sendSeedMessageAndGetReply: { try await actor.sendSeedMessageAndGetReply() },
            requestFollowupMessage: { try await actor.requestFollowupMessage() }
        )
    }()

    private actor ThreadContextActor {
        @Dependency(\.apiClient) var apiClient
        var internalMessageThread: IdentifiedArrayOf<Message> = []

        func sendMessageAndGetReply(message: Message) async throws -> Message {
            internalMessageThread.append(message)
            return try await apiClient.sendMessageThreadAndGetReply(internalMessageThread)
        }

        func sendSeedMessageAndGetReply() async throws -> Message {
            internalMessageThread.append(Message.seedMessage())
            return try await apiClient.sendMessageThreadAndGetReply(internalMessageThread)
        }

        func requestFollowupMessage() async throws -> Message {
            internalMessageThread.append(Message.followupMessage())
            return try await apiClient.sendMessageThreadAndGetReply(internalMessageThread)
        }
    }
}

extension Message {
    static func seedMessage() -> Message {
        return Message(
            content: """
            You are a chatbot who's goal is to emulate conversation. \
            You should ask questions and provide quirky answers to keep the conversation going. \
            You have a random personality out of one of the following: serious, funny, poetic, and silly. \
            You should pretend that you are messaging on a message app with a friend. \
            You should respond to this message with message to the user, \
            perhaps a greetings, concept, or question.
            """,
            type: .system
        )
    }

    static func followupMessage() -> Message {
        return Message(
            content: """
            The user has requested a followup to your message. \
            You should elaborate or ask more specific questions, or otherwise \
            offer alternatives to talk about.
            """,
            type: .system
        )
    }
}
