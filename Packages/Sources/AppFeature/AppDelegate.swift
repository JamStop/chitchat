// Created by Jimmy Yue in 2024

import ComposableArchitecture
@_implementationOnly import FirebaseCore
import Foundation

@Reducer
public struct AppDelegateReducer {
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case didFinishLaunching
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .didFinishLaunching:
                FirebaseApp.configure()
                return .none
            }
        }
    }
}
