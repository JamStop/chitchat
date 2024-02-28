// Created by Jimmy Yue in 2024

import ComposableArchitecture
import SwiftUI

@Reducer
public struct SettingsReducer {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case dismissButtonTapped
    }

    @Dependency(\.dismiss) var dismiss
    public var body: some ReducerOf<SettingsReducer> {
        Reduce { _, action in
            switch action {
            case .dismissButtonTapped:
                return .run { _ in await self.dismiss() }
            }
        }
    }

    public init() {}
}

public struct SettingsView: View {
    public var store: StoreOf<SettingsReducer>

    public var body: some View {
        Text("Unimplemented:")
            .font(.title)
            .fontWeight(.heavy)
            .fontDesign(.monospaced)
            .foregroundStyle(.orange)
        Text("Just helps demonstrate navigation for now")
            .font(.title2)
            .fontWeight(.medium)
            .fontDesign(.monospaced)
            .foregroundStyle(.orange)
            .multilineTextAlignment(.center)
        Button {
            store.send(.dismissButtonTapped)
        } label: {
            Image(systemName: "arrowshape.backward.fill")
                .foregroundStyle(.red)
                .fontWeight(.heavy)
            Text("Dismiss")
                .font(.title2)
                .fontWeight(.heavy)
                .fontDesign(.monospaced)
                .foregroundStyle(.red)
        }
        .padding(.top, 8)
    }

    public init(store: StoreOf<SettingsReducer>) {
        self.store = store
    }
}

#Preview {
    SettingsView(
        store: Store(initialState: SettingsReducer.State()
        ) {
            SettingsReducer()
        }
    )
}
