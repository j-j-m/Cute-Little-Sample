import Foundation
import ComposableArchitecture
import Model
import Platform
import Utility

struct ImageStaging: Reducer {

    struct ImageContainer: Equatable, Identifiable {
        let id: UUID
        let image: PlatformImage
    }

    struct State: Equatable {
        let images: IdentifiedArrayOf<ImageContainer>

        var uploadProgress: Progress?
    }

    enum Action: Equatable {
        case setup
        case confirm

        case uploadImages([PlatformImage])
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
                return .run { [images = state.images] send in
                    await send(.uploadImages(images.map(\.image)))
                }

            case .uploadImages(let images):
                let overallProgress = Progress(totalUnitCount: Int64(images.count)) // Total files
                state.uploadProgress = overallProgress

                return .run { send in
                    try await withThrowingTaskGroup(of: Void.self) { group in
                        for image in images {
                            let fileUploadProgress = Progress(
                                totalUnitCount: 100,
                                parent: overallProgress,
                                pendingUnitCount: 1
                            ) // Assuming each upload progress goes from 0 to 100

                            group.addTask {
                                if let imageData = image.pngDataRepresentation() {
                                    let fileUUID = uuid()
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
                                            // Assuming progress is a value between 0 and 1
                                            fileUploadProgress.completedUnitCount = Int64(progress * 100)

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

            case .finishedUploading:
                state.uploadProgress = nil
                return .none
            }
        }

        analyticsReducer
    }
}
