import Foundation
import ComposableArchitecture
import Model
import Platform
import Utility

struct ImageStaging: Reducer {

    struct ImageReference: Equatable, Identifiable {
        let id: UUID
        let url: URL
        var uploadProgress: Progress? = nil
        var completed = false
    }

    struct State: Equatable {
        var references: IdentifiedArrayOf<ImageReference>

        var uploadProgress: Progress?
    }

    enum Action: Equatable {
        case setup
        case confirm

        case uploadImages
        case updateProgress(UUID, Double)
        case finishedUpload(UUID)

        case finishedUploading
    }

    @Dependency(\.analytics) var analytics
    @Dependency(\.assets) var assets
    @Dependency(\.uuid) var uuid

    @Dependency(\.imageAssetCache) var imageAssetCache

    var body: some Reducer<State, Action> {

        Reduce { state, action in
            switch action {
            case .setup:
                return .none
                
            case .confirm:
                return .send(.uploadImages)

            case .uploadImages:
                let references = state.references
                let overallProgress = Progress(totalUnitCount: Int64(references.count)) // Total files
                state.uploadProgress = overallProgress

                return .run { send in
                    try await withThrowingTaskGroup(of: Void.self) { group in
                        for ref in references {
                            group.addTask {
                                if let image = imageAssetCache.rawValue[.init(request: .init(url: ref.url))] {

                                    // Determine the file type from the URL
                                    let fileExtension = ref.url.pathExtension.lowercased()
                                    let contentType: String
                                    var imageData: Data?

                                    switch fileExtension {
                                    case "png":
                                        imageData = image.image.pngDataRepresentation()
                                        contentType = "image/png"
                                    case "jpg", "jpeg":
                                        imageData = image.image.jpegDataWithQuality(1.0)
                                        contentType = "image/jpeg"

                                    case "gif":
                                        imageData = try? Data(contentsOf: ref.url)
                                        contentType = "image/gif"

                                    default:
                                        // Decide how to handle unknown file types
                                        print("Unsupported file type: \(fileExtension)")
                                        return
                                    }

                                    if let imageData = imageData {
                                        let fileUUID = ref.id
                                        let upload = try await assets.createAssetUpload(
                                            fileUUID,
                                            StorageClient.UploadRequest.File(
                                                name: "\(fileUUID)",
                                                data: imageData,
                                                fileName: "\(fileUUID).\(fileExtension)",
                                                contentType: contentType
                                            )
                                        )

                                        for try await event in upload {
                                            switch event {
                                            case .updateProgress(let progress):
                                                await send(.updateProgress(fileUUID, progress))
                                            case .success(_):
                                                await send(.finishedUpload(fileUUID))
                                                break
                                            }
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
                if state.references[id: id]?.uploadProgress == nil,
                let uploadProgress = state.uploadProgress {
                    state.references[id: id]?.uploadProgress = Progress(
                        totalUnitCount: 100,
                        parent: uploadProgress,
                        pendingUnitCount: 1
                    )
                }
                // Assuming progress is a value between 0 and 1
                state.references[id: id]?.uploadProgress?.completedUnitCount = Int64(progress * 100)

                return .none

            case .finishedUpload(let id):
                state.references[id: id]?.completed = true
                return .none

            case .finishedUploading:
                state.uploadProgress = nil
                return .none
            }
        }

        analyticsReducer
    }
}
