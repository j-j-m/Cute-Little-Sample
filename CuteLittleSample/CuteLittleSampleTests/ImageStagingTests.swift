//
//  ImageStagingTests.swift
//  CuteLittleSampleTests
//
//  Created by Jacob Martin on 9/22/23.
//

import ComposableArchitecture
import XCTest
import Analytics
import Model
import Platform
import CustomDump
@testable import CuteLittleSample

@MainActor
final class ImageStagingTests: XCTestCase {

    func testSetupWithEmptyAssets() async throws {

        let id = UUID(uuidString: "DEADBEEF-0000-0000-0000-000000000000")!

        let testAssetClient = {
            var client = AssetClient()

            return client
        }()

        let eventStore = AnalyticsClient.TestEventStore()

        let store = TestStore(
            initialState: ImageStaging.State(images: [.init(id: id, image: .init())])
        ) {
            ImageStaging()
        } withDependencies: {
            $0.assets = testAssetClient
            $0.analytics = .accumulating(in: eventStore)
        }

        await store.send(.setup)

        XCTAssertEqual(
            eventStore.events,
            [
                .init(name: "view-image-staging")
            ]
        )
    }
}
