//
//  AssetUploadSimulator.swift
//  CuteLittleSampleTests
//
//  Created by Jacob Martin on 9/22/23.
//

import Foundation
import Platform

class AssetUploadSimulator {

    enum Action {
        case simulateProgress(Double)
        case completeUpload
        case failWithError(Error)
    }

    private var continuation: AsyncThrowingStream<AssetClient.AssetUploadEvent, Error>.Continuation?

    let id: UUID
    let file: StorageClient.UploadRequest.File

    let assetID: UUID

    init(id: UUID, file: StorageClient.UploadRequest.File, assetID: UUID) {
        self.id = id
        self.file = file
        self.assetID = assetID
    }

    func send(action: Action) {
        switch action {
        case .simulateProgress(let progress):
            continuation?.yield(.updateProgress(progress))
        case .completeUpload:
            continuation?.yield(
                .success(
                    .init(
                        id: id,
                        asset: .init(
                            id: assetID,
                            locator: .remote(
                                bucketId: "test",
                                path: "test/test",
                                fileType: ".png"
                            )
                        )
                    )
                )
            )
            continuation?.finish()
        case .failWithError(let error):
            continuation?.yield(with: .failure(error))
            continuation?.finish()
        }
    }

    func stream() -> AsyncThrowingStream<AssetClient.AssetUploadEvent, Error> {
        AsyncThrowingStream { continuation in
            self.continuation = continuation
        }
    }

}
