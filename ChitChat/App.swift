// Created by Jimmy Yue in 2024
import AppFeature
import SwiftUI
import ComposableArchitecture

final class AppDelegate: NSObject, UIApplicationDelegate {
    let store = Store(initialState: AppReducer.State()) {
      AppReducer()
    }

    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
      self.store.send(.appDelegate(.didFinishLaunching))
      return true
    }
}

@main
struct ChitChat: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: AppReducer.State()) {
                AppReducer()
            })
        }
    }
}
