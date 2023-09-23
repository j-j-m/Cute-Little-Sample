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
import Utility
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

        let subjectImages: IdentifiedArrayOf<ImageStaging.ImageReference> = [
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

        // Progress (aka NSProgress) conforms to equatable, but having class semantics makes equality checking difficult
        // so turn off exhaustivity
        store.exhaustivity = .off

        await store.receive(.uploadImages) {
            XCTAssertEqual($0.uploadProgress?.completedUnitCount, 0)
        }

        uploadSimulator.send(action: .simulateProgress(0.25))

        await store.receive(
            .updateProgress(
                uploadID,
                0.25
            )
        ) {
            XCTAssertEqual(
                $0.images[id: uploadID]!.uploadProgress?.fractionCompleted,
                0.25
            )
        }

        uploadSimulator.send(action: .simulateProgress(0.5))

        await store.receive(
            .updateProgress(
                uploadID,
                0.5
            )
        ) {
            XCTAssertEqual(
                $0.images[id: uploadID]!.uploadProgress?.fractionCompleted,
                0.5
            )
        }

        uploadSimulator.send(action: .simulateProgress(1.0))

        await store.receive(
            .updateProgress(
                uploadID,
                1.0
            )
        ) {
            XCTAssertEqual(
                $0.images[id: uploadID]!.uploadProgress?.fractionCompleted,
                1.0
            )
        }

        // everything else from here can be exhaustively exercised
        store.exhaustivity = .on

        uploadSimulator.send(action: .completeUpload)

        await store.receive(.finishedUploading) {
            $0.uploadProgress = nil
        }

        XCTAssertEqual(eventStore.pop(), .init(name: "image-staging-tapped-confirm"))

        let uploadEvent = eventStore.pop()
        XCTAssertEqual(uploadEvent?.name, "image-staging-started-upload")
        XCTAssertEqual(uploadEvent?.properties["image-count"], 1)

        // Image size differs based on the test runner machine. It is sufficient to check that the field is populated.
        XCTAssertNotNil(uploadEvent?.properties["total-size"])
        XCTAssertNotEqual(uploadEvent?.properties["image-count"], 0)

        XCTAssertEqual(eventStore.pop(), .init(name: "image-staging-finished-upload"))
    }
}
