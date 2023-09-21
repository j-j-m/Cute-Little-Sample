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

        @BindingState var imageSelection: PhotosPickerItem? = nil
        @PresentationState var detail: Detail.State?
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case detail(PresentationAction<Detail.Action>)
        case stageImages([PlatformImage])

        case tappedAsset(Asset)
    }

    var body: some Reducer<State, Action> {

        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .detail:
                return .none

            case .stageImages(let images):
                return .none

            case .tappedAsset(let asset):
                state.detail = .assetDetail(.init(asset: asset))
                return .none
            }
        }
        .ifLet(\.$detail, action: /Action.detail) {
            Detail()
        }
    }
}
