// Created by Jimmy Yue in 2024

import SwiftUI
import SharedModels

public struct MessageBubble: View {
    var message: Message
    public var body: some View {
        HStack {
            if message.type == .user { Spacer() }
            Text(message.content)
                .foregroundColor(message.type == .user ? .white : nil)
                .padding()
                .background(message.type == .user ? .orange : .gray.opacity(0.4))
                .cornerRadius(17)
            if message.type == .assistant { Spacer() }
        }
    }
}

#Preview {
    Group {
        MessageBubble(message: Message.mockAssistantMessage())
        MessageBubble(message: Message.mockUserMessage())
    }
}
