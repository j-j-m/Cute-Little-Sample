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
import Tagged
@testable import CuteLittleSample

@MainActor
final class ImageStagingTests: XCTestCase {

    func testSetup() async throws {

        let id = UUID(uuidString: "DEADBEEF-0000-0000-0000-000000000000")!

        let eventStore = AnalyticsClient.TestEventStore()

        let store = TestStore(
            initialState: ImageStaging.State(images: [.init(id: id, image: .init())])
        ) {
            ImageStaging()
        } withDependencies: {
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

    func testUpload() async throws {

        let uploadID = UUID(uuidString: "DEADBEEF-0000-0000-0000-000000000000")!
        let assetID = UUID(uuidString: "DEADBEEF-BEEF-0000-0000-000000000000")!
        let testImage = generateCheckerboardImage(
            size: CGSize(width: 200, height: 200),
            squareSize: 20
        )

        let uploadSimulator = AssetUploadSimulator(
            id: uploadID,
            file: .init(
                name: "\(uploadID)",
                data: testImage.pngDataRepresentation()!,
                fileName: "\(uploadID).png",
                contentType: "image/png"
            ),
            assetID: assetID
        )

        let testAssetClient: AssetClient = {
            var client = AssetClient()
            client.createAssetUpload = { _, _ in
                return uploadSimulator.stream()
            }
            return client
        }()

        let eventStore = AnalyticsClient.TestEventStore()

        let subjectImages: IdentifiedArrayOf<ImageStaging.ImageContainer> = [
            .init(id: uploadID, image: testImage)
        ]

        let store = TestStore(
            initialState: ImageStaging.State(
                images: subjectImages
            )
        ) {
            ImageStaging()
        } withDependencies: {
            $0.assets = testAssetClient
            $0.analytics = .accumulating(in: eventStore)
            $0.uuid = .init({ uploadID })
        }

        await store.send(.confirm)

        store.exhaustivity = .off
        await store.receive(.uploadImages(subjectImages.map(\.image))) {
            XCTAssertEqual($0.uploadProgress?.completedUnitCount, 0)
        }

        uploadSimulator.send(action: .simulateProgress(0.25))

        XCTAssertEqual(store.state.uploadProgress?.fractionCompleted, 0.25)

        store.exhaustivity = .on

        await store.receive(.finishedUploading) {
            $0.uploadProgress = nil
        }

        XCTAssertEqual(
            eventStore.events,
            [
                .init(name: "image-staging-tapped-confirm"),
                .init(
                    name: "image-staging-started-upload",
                    properties: [
                        "image-count": 1,
                        "total-size": 0.0
                    ]
                ),
                .init(name: "image-staging-finished-upload")
            ]
        )
    }
}
