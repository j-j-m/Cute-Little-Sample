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

struct Gallery: Reducer {

    public struct Detail: Reducer {
        public enum State: Equatable{
            case imageStaging(ImageStaging.State)
        }

        public enum Action  {
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
        
        @BindingState var requestInFlight = false
        var error = false

        @BindingState var imageSelection: PhotosPickerItem? = nil
        @PresentationState var detail: Detail.State?
        @PresentationState var alert: AlertState<Action.Alert>?

        @BindingState var currentDetailID: Asset.ID?
    }

    enum Action: BindableAction {

        enum Alert {
            case tappedOkay
        }

        case binding(BindingAction<State>)

        case detail(PresentationAction<Detail.Action>)
        case alert(PresentationAction<Alert>)

        case loadAssets
        case handleLoadAssets(TaskResult<IdentifiedArrayOf<Asset>>)

        case stageImages([PlatformImage])

        case tappedAsset(Asset)
        case tappedDeleteAsset(Asset)

        case handleDeleteAssets(TaskResult<Void>)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.assets) var assets
    @Dependency(\.haptics) var haptics

    var body: some Reducer<State, Action> {

        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.$imageSelection):
                return .run { [imageSelection = state.imageSelection] send in
                    guard let imageSelection else {
                        return
                    }
                    // unbox the image from data
                    guard let imageData = try await imageSelection.loadTransferable(type: Data.self),
                            let image = PlatformImage(data: imageData) else {
                        return
                    }

                    await send(.binding(.set(\.$imageSelection, nil)))
                    // send it to staging
                    await send(.stageImages([image]))
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

                return .send(.binding(.set(\.$requestInFlight, false)))

            case .stageImages(let images):
                state.detail = .imageStaging(
                    .init(
                        images: .init(
                            uniqueElements: images.map { .init(id: uuid(), image: $0) }
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
    }
}
