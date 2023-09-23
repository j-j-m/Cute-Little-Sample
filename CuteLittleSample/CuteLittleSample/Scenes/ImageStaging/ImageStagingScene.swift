import Foundation
import ComposableArchitecture
import Model
import Platform
import Utility

struct ImageStaging: Reducer {

    struct ImageContainer: Equatable, Identifiable {
        let id: UUID
        let image: PlatformImage
        var uploadProgress: Progress? = nil
    }

    struct State: Equatable {
        var images: IdentifiedArrayOf<ImageContainer>

        var uploadProgress: Progress?
    }

    enum Action: Equatable {
        case setup
        case confirm

        case uploadImages
        case updateProgress(UUID, Double)
        case finishedUploading
    }

    @Dependency(\.analytics) var analytics
    @Dependency(\.assets) var assets
    @Dependency(\.uuid) var uuid

    var body: some Reducer<State, Action> {

        Reduce { state, action in
            switch action {
            case .setup:
                return .none
                
            case .confirm:
                return .send(.uploadImages)

            case .uploadImages:
                let images = state.images
                let overallProgress = Progress(totalUnitCount: Int64(images.count)) // Total files
                state.uploadProgress = overallProgress

                return .run { send in
                    try await withThrowingTaskGroup(of: Void.self) { group in
                        for image in images {

                            group.addTask {
                                if let imageData = image.image.pngDataRepresentation() {
                                    let fileUUID = image.id
                                    let upload = try await assets.createAssetUpload(
                                        fileUUID,
                                        StorageClient.UploadRequest.File(
                                            name: "\(fileUUID)",
                                            data: imageData,
                                            fileName: "\(fileUUID).png",
                                            contentType: "image/png"
                                        )
                                    )

                                    for try await event in upload {
                                        switch event {
                                        case .updateProgress(let progress):
                                            await send(.updateProgress(fileUUID, progress))

                                        case .success(let asset):
                                            // Handle individual success if needed
//                                            await send(.handleItem(asset))
                                            break
                                        }
                                    }
                                }
                            }
                        }

                        // Wait for all tasks to complete
                        try await group.waitForAll()
                    }

                    // Once all uploads are successful
                    await send(.finishedUploading)
                }

            case .updateProgress(let id, let progress):
                if state.images[id: id]?.uploadProgress == nil,
                let uploadProgress = state.uploadProgress {
                    state.images[id: id]?.uploadProgress = Progress(
                        totalUnitCount: 100,
                        parent: uploadProgress,
                        pendingUnitCount: 1
                    )
                }
                // Assuming progress is a value between 0 and 1
                state.images[id: id]?.uploadProgress?.completedUnitCount = Int64(progress * 100)

                return .none

            case .finishedUploading:
                state.uploadProgress = nil
                return .none
            }
        }

        analyticsReducer
    }
}
