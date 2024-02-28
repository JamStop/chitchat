// Created by Jimmy Yue in 2024

import ComposableArchitecture
@_implementationOnly import FirebaseFunctions
import Foundation
import SharedModels

extension ApiClient: DependencyKey {
    public static let liveValue = Self(
        sendMessageThreadAndGetReply: { messageThread in
            let functions = Functions.functions()
//            functions.useEmulator(withHost: "127.0.0.1:4400", port: 4500)
            return try await sendMessageThread(
                messageThread: messageThread,
                firebaseFunctions: functions
            )
        }
    )
}

private let sendMessageThreadFunction = "sendmessagethread"

private func sendMessageThread(messageThread: IdentifiedArrayOf<Message>, firebaseFunctions: Functions) async throws -> Message {
    let payload = MessageThreadPayload(messages: messageThread)
    guard let encodedPayload = firebaseEncode(payload) else {
        throw ApiClientError.internalError("Failed to convert MessageThread \(messageThread) to [String: Any]")
    }
    let response = try await firebaseFunctions.httpsCallable(sendMessageThreadFunction).call(encodedPayload)
    guard let data = response.data as? [String: Any] else {
        throw ApiClientError.failedToParseFirebaseResponse("Failed to convert response to [String: Any]")
    }
    return try firebaseDecode(dict: data)
}

private let encoder = { () -> JSONEncoder in
    let encoder = JSONEncoder()
    #if DEBUG
    encoder.outputFormatting = .prettyPrinted
    #endif
    return encoder
}()
