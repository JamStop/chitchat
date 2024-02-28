// Created by Jimmy Yue in 2024

import Foundation
import SnapshotTesting
import ComposableArchitecture
import XCTest
@testable import AppFeature

class AppFeatureTests: XCTestCase {
    func testBasics() {
        assertSnapshot(
            matching: AppView(
                store: Store(
                    initialState: AppReducer.State()
                ) {}
            ),
            as: .image(
                perceptualPrecision: 0.98,
                layout: .device(
                    config: .iPhone13Pro
                )
            )
        )
    }
}
