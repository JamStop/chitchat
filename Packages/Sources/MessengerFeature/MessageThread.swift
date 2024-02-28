// Created by Jimmy Yue in 2024

import MessageClient
import ComposableArchitecture
import Haptics
import SettingsFeature
import SharedModels
import SwiftUI
import UIKit
import AudioClient

@Reducer
public struct MessageThreadReducer {
    @ObservableState
    public struct State: Equatable {
        var thread: IdentifiedArrayOf<Message>
        var text: String = ""
        var lastMessageId: UUID?
        var chitbotAnimates = false
        var sendButtonAnimates = false

        public init(thread: IdentifiedArrayOf<Message> = []) {
            self.thread = thread
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case sendButtonTapped
        case textFieldSubmitted
        case sendMessage
        case messageReceived(Result<Message, Error>)
        case settingsButtonTapped
        case resetChitbotAnimates
        case onAppear
        case chitbotTapped
    }

    @Dependency(\.messageClient) var messageClient
    @Dependency(\.hapticsClient) var hapticsClient
    @Dependency(\.suspendingClock) var clock
    @Dependency(\.audioClient) var audioClient

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .sendButtonTapped:
                // Recursive reducing here as we plan to add animations
                // to the send button that don't exist in the text field submission
                state.sendButtonAnimates.toggle()
                hapticsClient.generateSelectionHaptic()
                return self.reduce(into: &state, action: .sendMessage)
            case .textFieldSubmitted:
                return self.reduce(into: &state, action: .sendMessage)
            case .sendMessage:
                guard !state.text.isEmpty else { return .none }
                let message = Message(content: state.text, type: .user)
                state.thread.append(message)
                state.lastMessageId = message.id
                state.text = ""
                audioClient.playMessageSent()
                return .run { send in
                    await send(
                        .messageReceived(
                            Result {
                                try await messageClient.sendMessageAndGetReply(message)
                            }
                        )
                    )
                }
            case let .messageReceived(.success(message)):
                state.thread.append(message)
                state.lastMessageId = message.id
                state.chitbotAnimates = true
                hapticsClient.generateSuccessHaptic()
                audioClient.playMessageReceived()
                return .run { send in
                    try await Task.sleep(nanoseconds: UInt64(0.1 * Double(NSEC_PER_SEC)))
                    await send(.resetChitbotAnimates)
                }
            case .messageReceived(.failure):
                hapticsClient.generateFailureHaptic()
                // TODO: Error presentation state handling
                return .none
            case .settingsButtonTapped:
                return .none
            case .resetChitbotAnimates:
                state.chitbotAnimates = false
                return .none
            case .onAppear:
                return .run { send in
                    await send(
                        .messageReceived(
                            Result {
                                try await messageClient.sendSeedMessageAndGetReply()
                            }
                        )
                    )

                }
            case .chitbotTapped:
                hapticsClient.generateSelectionHaptic()
                audioClient.playChitbotTapped()
                state.chitbotAnimates = true
                return .run { send in
                    try await Task.sleep(nanoseconds: UInt64(0.05 * Double(NSEC_PER_SEC)))
                    await send(.resetChitbotAnimates)
                    await send(
                        .messageReceived(
                            Result {
                                try await messageClient.sendSeedMessageAndGetReply()
                            }
                        )
                    )
                }
            }
        }
    }

    public init() {}
}

public struct MessageThreadView: View {
    @Bindable var store: StoreOf<MessageThreadReducer>
    @State private var hasAppeared = false

    public init(store: StoreOf<MessageThreadReducer>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            HStack {
                Image(packageResource: "bot", ofType: "png")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .padding(.leading, 24)
                    .rotationEffect(.degrees(store.chitbotAnimates ? -15 : 0))
                    .animation(.interpolatingSpring(stiffness: 140, damping: 5), value: store.chitbotAnimates)
                    .onTapGesture {
                        store.send(.chitbotTapped)
                    }
                VStack(alignment: .leading) {
                    Text("Chitbot")
                        .fontWeight(.medium)
                        .font(.title3)
                    Text("Online")
                        .fontWeight(.medium)
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
                .padding(.leading, 8)
                Spacer()
                Button {
                    store.send(.settingsButtonTapped)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.orange.opacity(0.8))
                        .padding(.horizontal, 5)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
                .padding(.trailing, 24)
            }
            VStack {
                GeometryReader { geometry in
                    ScrollViewReader { scrollView in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack {
                                ForEach(store.thread, id: \.id) { message in
                                    MessageBubble(message: message)
                                        .scrollTransition { content, phase in
                                            content
                                                .opacity(phase.isIdentity ? 1 : 0)
                                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                                .blur(radius: phase.isIdentity ? 0 : 10)
                                        }
                                        .id(message.id)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .bottom)
                            .animation(.spring(bounce: 0.2), value: store.thread)
                            .padding(8)
                        }
                        .defaultScrollAnchor(.bottom)
                        .onChange(of: store.lastMessageId) { _, id in
                            withAnimation {
                                scrollView.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }
                }

                HStack {
                    // Rounded Textfields seem to be throwing an error
                    // Apple issue? https://forums.developer.apple.com/forums/thread/738726
                    // Seems like a simulator thing
                    // https://forums.developer.apple.com/forums/thread/742528
                    TextField("Enter a message", text: $store.text)
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(12)
                        .submitLabel(.send)
                        .onSubmit {
                            store.send(.textFieldSubmitted)
                        }
                    Button {
                        Task {
                            store.send(.sendButtonTapped)
                        }
                    } label: {
                        Image(systemName: "paperplane.circle.fill")
                            .foregroundColor(.orange)
                            .padding(.horizontal, 5)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    }
                    .symbolEffect(.bounce.down, options: .speed(3), value: store.sendButtonAnimates)
                    .disabled(store.text.isEmpty)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
        }.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            store.send(.onAppear)
        }
    }
}

#Preview("No messages") {
    MessageThreadView(
        store: Store(
            initialState: MessageThreadReducer.State(thread: [])
        ) {
            MessageThreadReducer()
        }
    )
}

#Preview("Filled with messages") {
    MessageThreadView(
        store: Store(
            initialState: MessageThreadReducer.State(thread: Message.mockMessagesLong)
        ) {
            MessageThreadReducer()
        }
    )
}
