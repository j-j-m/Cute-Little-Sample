//
//  GalleryScene.swift
//  CuteLittleSample
//
//  Created by Jacob Martin on 9/20/23.
//

import ComposableArchitecture
import SwiftUI
import PhotosUI
import Model
import Utility

enum WorkSpaceError: Error {
    case unknownFormat
}

private func workspaceSecurityScoped(url: URL) throws -> URL? {

    @Dependency(\.uuid) var uuid
    guard url.startAccessingSecurityScopedResource() else {
        return nil
    }

    let data = try Data(contentsOf: url)
    guard let image = PlatformImage(data: data) else {
        return nil
    }

    guard let imageInfo = imageTypes(from: data) else {
        print("Unknown image format or corrupted data")
        throw WorkSpaceError.unknownFormat
    }

    let tempDirectory = FileManager.default.temporaryDirectory
    let tempFileURL = tempDirectory.appendingPathComponent(uuid().uuidString).appendingPathExtension(imageInfo.fileExtension)
    try data.write(to: tempFileURL)  // might want better error handling here

    return tempFileURL
}

struct Gallery: Reducer {

    public struct Detail: Reducer {
        public enum State: Equatable{
            case imageStaging(ImageStaging.State)
        }

        public enum Action: Equatable  {
            case imageStaging(ImageStaging.Action)
        }

        public var body: some Reducer<State, Action> {

            Scope(state: /State.imageStaging, action: /Action.imageStaging) {
                ImageStaging()
            }
        }
    }

    struct State: Equatable {
        var assets: IdentifiedArrayOf<Asset> = []
        
        var awaitingInitialLoad = true
        @BindingState var requestInFlight = false
        var error = false

        @BindingState var imageSelection: PhotosPickerItem? = nil
        @PresentationState var detail: Detail.State?
        @PresentationState var alert: AlertState<Action.Alert>?

        @BindingState var currentDetailID: Asset.ID?
    }

    enum Action: Equatable, BindableAction {

        enum Alert: Equatable {
            case tappedOkay
        }

        case setup
        case binding(BindingAction<State>)

        case detail(PresentationAction<Detail.Action>)
        case alert(PresentationAction<Alert>)

        case loadAssets
        case handleLoadAssets(TaskResult<IdentifiedArrayOf<Asset>>)

        case processFiles([URL])
        case stageImages([ImageStaging.ImageReference])

        case tappedAsset(Asset)
        case tappedDeleteAsset(Asset)

        case handleDeleteAssets(TaskResult<Asset>)
    }

    @Dependency(\.analytics) var analytics
    @Dependency(\.uuid) var uuid
    @Dependency(\.assets) var assets
    @Dependency(\.haptics) var haptics

    var body: some Reducer<State, Action> {

        BindingReducer()

        Reduce { state, action in
            switch action {

            case .setup:
                return .send(.loadAssets)
                
            case .binding(\.$imageSelection):
                return .run { [imageSelection = state.imageSelection] send in
                    guard let imageSelection else {
                        return
                    }
                    guard let imageData = try await imageSelection.loadTransferable(type: Data.self) else {
                        return
                    }

                    guard let imageInfo = imageTypes(from: imageData) else {
                        print("Unknown image format or corrupted data")
                        throw WorkSpaceError.unknownFormat
                    }

                    let tempDirectory = FileManager.default.temporaryDirectory
                    let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(imageInfo.fileExtension)

                    try? imageData.write(to: tempFileURL)  // Consider better error handling here

                    await send(.binding(.set(\.$imageSelection, nil)))
                    await send(
                        .stageImages(
                            [.init(id: uuid(), url: tempFileURL)]
                        )
                    )
                }

            case .detail(.presented(.imageStaging(.finishedUploading))):
                state.detail = nil
                return .run { send in
                    await send(.loadAssets)
                }

            case .loadAssets:
                return .run { send in
                    await send(.binding(.set(\.$requestInFlight, true)))
                    await send(
                        .handleLoadAssets(
                            TaskResult {
                                try await assets.list()
                            }
                        ),
                        animation: .default
                    )
                }

            case .handleLoadAssets(let result):
                switch result {
                case .success(let items):
                    state.assets = items
                case .failure:
                    state.error = true
                }
                state.awaitingInitialLoad = false
                return .send(.binding(.set(\.$requestInFlight, false)))

            case .processFiles(let urls):
                return .run { send in
                    let workspaceUrls: [URL] = try await urls.parallelMap(workspaceSecurityScoped).compactMap { $0 }

                    await send(
                        .stageImages(
                            workspaceUrls.map { ImageStaging.ImageReference(id: uuid(), url: $0) }
                        )
                    )
                }


            case .stageImages(let images):
                state.detail = .imageStaging(
                    .init(
                        references: .init(
                            uniqueElements: images
                        )
                    )
                )
                return .none

            case .tappedAsset(let asset):

                // ideally we would set present this scene in this fashion, but currently it doesnt not work.
                // most likely an issue with the Transmission library.
//                state.detail = .assetDetail(.init(asset: asset))

                state.currentDetailID = asset.id
                haptics.interaction()
                return .none

            case .tappedDeleteAsset(let asset):
                return .run { send in
                    await send(
                        .handleDeleteAssets(
                            TaskResult {
                                try await assets.deleteAsset(asset.id)
                            }
                        ),
                        animation: .default
                    )
                }

            case .handleDeleteAssets(.success):
                return .send(.loadAssets)

            case .handleDeleteAssets(.failure):

                state.alert = AlertState {
                    TextState("")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                } message: {
                    TextState("Delete failed. Try again later.")
                }

                return .none

            default:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
        .ifLet(\.$detail, action: /Action.detail) {
            Detail()
        }

        analyticsReducer
    }
}
