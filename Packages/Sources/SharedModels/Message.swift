// Created by Jimmy Yue in 2024
import Foundation
import ComposableArchitecture

public struct Message: Equatable, Codable, Hashable, Identifiable {
    public let id: UUID = UUID()
    public let content: String
    public let type: MessageType

    public init(content: String, type: MessageType) {
        self.content = content
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case type = "role"
    }
}

public enum MessageType: String, Codable, Equatable {
    case system
    case user
    case assistant
}

public extension Message {
    static func mockAssistantMessage() -> Message {
        return Message(content: "Sample message from assistant", type: .assistant)
    }

    static func mockUserMessage() -> Message {
        return Message(content: "Sample message from user", type: .user)
    }

    static let mockMessages = IdentifiedArray(uniqueElements: [
        mockUserMessage(),
        mockAssistantMessage(),
        mockUserMessage(),
    ])

    static let mockMessagesLong = IdentifiedArray(uniqueElements: [
        mockUserMessage(),
        mockAssistantMessage(),
        mockUserMessage(),
        mockAssistantMessage(),
        mockUserMessage(),
        mockAssistantMessage(),
        mockUserMessage(),
        mockAssistantMessage(),
        mockUserMessage(),
        mockAssistantMessage(),
        mockUserMessage(),
    ])
}
