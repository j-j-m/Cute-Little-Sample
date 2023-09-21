//
//  CuteLittleSampleTests.swift
//  CuteLittleSampleTests
//
//  Created by Jacob Martin on 9/21/23.
//

import ComposableArchitecture
import XCTest
import Model
import Platform
@testable import CuteLittleSample

@MainActor
final class GalleryTests: XCTestCase {

    func testSetupWithEmptyAssets() async throws {

        let testAssetClient = {
            var client = AssetClient()
            client.list = { return [] }
            return client
        }()

        let store = TestStore(
            initialState: Gallery.State()
        ) {
            Gallery()
        } withDependencies: {
            $0.assets = testAssetClient
        }

        await store.send(.setup)

        await store.receive(.loadAssets) {
            $0.requestInFlight = true
        }

        await store.receive(.handleLoadAssets(.success([]))) {
            $0.requestInFlight = false
        }
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

        let store = TestStore(
            initialState: Gallery.State()
        ) {
            Gallery()
        } withDependencies: {
            $0.assets = testAssetClient
        }

        await store.send(.setup)

        await store.receive(.loadAssets) {
            $0.requestInFlight = true
        }

        await store.receive(.handleLoadAssets(.success(expected))) {
            $0.requestInFlight = false
            $0.assets = expected
        }
    }
}
