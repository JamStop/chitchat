// Created by Jimmy Yue in 2024

import ComposableArchitecture
import MessengerFeature
import SettingsFeature
import SharedModels
import SwiftUI

@Reducer
public struct AppReducer {
    @Reducer
    public struct Path {
        @ObservableState
        public enum State: Equatable {
            case settings(SettingsReducer.State)
        }

        public enum Action {
            case settings(SettingsReducer.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.settings, action: \.settings) {
                SettingsReducer()
            }
        }

        public init() {}
    }

    @ObservableState
    public struct State: Equatable {
        public var path = StackState<Path.State>()
        public var appDelegate: AppDelegateReducer.State
        public var messageThread: MessageThreadReducer.State

        public init(
            appDelegate: AppDelegateReducer.State = AppDelegateReducer.State(),
            messageThread: MessageThreadReducer.State = .init()
        ) {
            self.appDelegate = appDelegate
            self.messageThread = messageThread
        }
    }

    public enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case appDelegate(AppDelegateReducer.Action)
        case messageThread(MessageThreadReducer.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegateReducer()
        }
        Scope(state: \.messageThread, action: \.messageThread) {
            MessageThreadReducer()
        }
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
                return .none
            case .messageThread(.settingsButtonTapped):
                state.path.append(.settings(SettingsReducer.State()))
                return .none
            case .messageThread:
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}

public struct AppView: View {
    @Bindable var store: StoreOf<AppReducer>

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            MessageThreadView(store: store.scope(state: \.messageThread, action: \.messageThread))
        } destination: { store in
            switch store.state {
            case .settings:
                if let store = store.scope(state: \.settings, action: \.settings) {
                    SettingsView(store: store)
                }
            }
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppReducer.State()) {
        AppReducer()
    })
}
