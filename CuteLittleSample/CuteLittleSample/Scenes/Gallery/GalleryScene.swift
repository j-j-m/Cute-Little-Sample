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
    struct State: Equatable {
        @BindingState var imageSelection: PhotosPickerItem? = nil

        var assets: IdentifiedArrayOf<Asset> = []
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case stageImages([PlatformImage])
    }

    var body: some Reducer<State, Action> {

        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .stageImages(let images):
                return .none
            }
        }
    }
}
