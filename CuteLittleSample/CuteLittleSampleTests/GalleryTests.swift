//
//  CuteLittleSampleTests.swift
//  CuteLittleSampleTests
//
//  Created by Jacob Martin on 9/21/23.
//

import ComposableArchitecture
import XCTest
import Analytics
import Model
import Platform
import CustomDump
@testable import CuteLittleSample

@MainActor
final class GalleryTests: XCTestCase {

    func testSetupWithEmptyAssets() async throws {

        let testAssetClient = {
            var client = AssetClient()
            client.list = { return [] }
            return client
        }()

        let eventStore = AnalyticsClient.TestEventStore()

        let store = TestStore(
            initialState: Gallery.State()
        ) {
            Gallery()
        } withDependencies: {
            $0.assets = testAssetClient
            $0.analytics = .accumulating(in: eventStore)
        }

        await store.send(.setup)

        await store.receive(.loadAssets) {
            $0.requestInFlight = true
        }

        await store.receive(.handleLoadAssets(.success([]))) {
            $0.requestInFlight = false
        }

        XCTAssertEqual(
            eventStore.events,
            [
                .init(name: "view-gallery"),
                .init(name: "gallery-load-assets-success")
            ]
        )
    }

    func testSetupWithPresentAssets() async throws {

        let id = UUID(uuidString: "DEADBEEF-0000-0000-0000-000000000000")!

        let expected: IdentifiedArrayOf<Asset> = [
            Asset(id: id, bucketId: "test", path: "test", fileType: "png")
        ]

        let testAssetClient = {
            var client = AssetClient()
            client.list = {
                return expected
            }
            return client
        }()

        let eventStore = AnalyticsClient.TestEventStore()

        let store = TestStore(
            initialState: Gallery.State()
        ) {
            Gallery()
        } withDependencies: {
            $0.assets = testAssetClient
            $0.analytics = .accumulating(in: eventStore)
        }

        await store.send(.setup)

        await store.receive(.loadAssets) {
            $0.requestInFlight = true
        }

        await store.receive(.handleLoadAssets(.success(expected))) {
            $0.requestInFlight = false
            $0.assets = expected
        }

        XCTAssertEqual(
            eventStore.events,
            [
                .init(name: "view-gallery"),
                .init(name: "gallery-load-assets-success")
            ]
        )
    }

    func testSetupWithLoadError() async throws {

        struct TestError: Error, Equatable {
            var localizedDescription: String {
                return "something bad happened"
            }
        }

        let error = TestError()
        let errorDump = String(customDumping: error)

        let testAssetClient = {
            var client = AssetClient()
            client.list = {
                throw TestError()
            }
            return client
        }()

        let eventStore = AnalyticsClient.TestEventStore()

        let store = TestStore(
            initialState: Gallery.State()
        ) {
            Gallery()
        } withDependencies: {
            $0.assets = testAssetClient
            $0.analytics = .accumulating(in: eventStore)
        }

        await store.send(.setup)

        await store.receive(.loadAssets) {
            $0.requestInFlight = true
        }

        await store.receive(.handleLoadAssets(.failure(TestError()))) {
            $0.requestInFlight = false
            $0.error = true
        }

        XCTAssertEqual(
            eventStore.events,
            [
                .init(name: "view-gallery"),
                .init(name: "gallery-load-assets-failure", properties: ["error": errorDump])
            ]
        )
    }
}
