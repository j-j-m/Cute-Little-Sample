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
            case assetDetail(AssetDetail.State)
            case imageStaging(ImageStaging.State)
        }

        public enum Action  {
            case assetDetail(AssetDetail.Action)
            case imageStaging(ImageStaging.Action)
        }

        public var body: some Reducer<State, Action> {
            Scope(state: /State.assetDetail, action: /Action.assetDetail) {
                AssetDetail()
            }

            Scope(state: /State.imageStaging, action: /Action.imageStaging) {
                ImageStaging()
            }
        }
    }

    struct State: Equatable {
        var assets: IdentifiedArrayOf<Asset> = []
        var error = false

        @BindingState var imageSelection: PhotosPickerItem? = nil
        @PresentationState var detail: Detail.State?
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)

        case detail(PresentationAction<Detail.Action>)

        case loadAssets
        case handleLoadAssets(TaskResult<IdentifiedArrayOf<Asset>>)

        case stageImages([PlatformImage])

        case tappedAsset(Asset)
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
                    await send(
                        .handleLoadAssets(
                            TaskResult {
                                try await assets.list()
                            }
                        )
                    )
                }

            case .handleLoadAssets(let result):
                switch result {
                case .success(let items):
                    state.assets = items
                    return .none

                case .failure:
                    state.error = true
                    return .none
                }

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
                state.detail = .assetDetail(.init(asset: asset))
                haptics.interaction()
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.$detail, action: /Action.detail) {
            Detail()
        }
    }
}
