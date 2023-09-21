//
//  CuteLittleSampleTests.swift
//  CuteLittleSampleTests
//
//  Created by Jacob Martin on 9/21/23.
//

import ComposableArchitecture
import XCTest

@testable import CuteLittleSample

@MainActor
final class GalleryTests: XCTestCase {

    func testSetup() async throws {
        let store = TestStore(
            initialState: Gallery.State()
        ) {
            Gallery()
        } withDependencies: { values in

        }

        await store.send(.setup)

        await store.receive(.setup)

        await store.receive(.loadAssets)
    }
}
