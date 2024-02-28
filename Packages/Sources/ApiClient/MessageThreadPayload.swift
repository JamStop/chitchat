// Created by Jimmy Yue in 2024

import Foundation
import SharedModels
import ComposableArchitecture

struct MessageThreadPayload: Codable {
    let messages: IdentifiedArrayOf<Message>
}
