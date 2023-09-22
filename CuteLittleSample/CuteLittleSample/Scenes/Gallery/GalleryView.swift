//
//  GalleryView.swift
//  CuteLittleSample
//
//  Created by Jacob Martin on 9/20/23.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
import UI
import Utility

extension Gallery {

    struct ContentView: View {

        @Environment(\.horizontalSizeClass) var horizontalSizeClass

        let store: StoreOf<Gallery>

        @SwiftUI.State private var showImporter = false

        init(store: StoreOf<Gallery>) {
            self.store = store
        }

        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ZStack {
                    if viewStore.assets.isEmpty == false {
                        ScrollView {
                            MasonryVStack(
                                columns: horizontalSizeClass == .compact ? 2 : 3,
                                spacing: 10
                            ){
                                ForEach(viewStore.assets) { asset in
                                    Button {
                                        store.send(.tappedAsset(asset), animation: .easeIn)
                                    } label: {
                                        VStack {
                                            AssetImageView(asset: asset)
                                                .cornerRadius(10)
                                        }
                                    }
                                    .composableStyle(
                                        scalingButtonStyle
                                    )
                                    .transition(.opacity.animation(.easeIn))
                                    .contextMenu {
                                        Button {
                                            store.send(.tappedDeleteAsset(asset))
                                        } label: {
                                            Label {
                                                Text("Delete")
                                            } icon: {
                                                Image(systemName: "trash")
                                            }
                                        }

                                    }
                                    .inContext {
#if os(macOS)
                                        $0.sheet(
                                            isPresented: viewStore.$currentDetailID
                                                .isPresentAndEqual(to: asset.id)
                                        ) {
                                            AssetDetail.ContentView(asset: asset)
                                                .platformConstrained()
                                        }
#else
                                        $0.presentation(
                                            transition: .heroMove,
                                            isPresented: viewStore.$currentDetailID
                                                .isPresentAndEqual(to: asset.id)
                                        ) {
                                            AssetDetail.ContentView(asset: asset)
                                        }
#endif
                                    }
                                }
                            }
                            .padding(10)
                        }
                    } else if viewStore.requestInFlight {
                        ProgressView()
                    } else if viewStore.error {
                        Text("Something went wrong.")
                    } else {
                        Text("Nothing here. Add some images...")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    ToolbarItemGroup {
                        PhotosPicker(
                            selection: viewStore.$imageSelection,
                            matching: .images,
                            preferredItemEncoding: .compatible,
                            label: {
                                Image(systemName: "photo.stack")
                            }
                        )

                        Button {
                            self.showImporter = true
                        } label: {
                            Image(systemName: "folder")
                        }
                        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.image], allowsMultipleSelection: true) { result in
                            switch result {
                            case .failure(let error):
                                print("Error selecting file \(error.localizedDescription)")
                            case .success(let urls):
                                var images: [PlatformImage] = []

                                for url in urls {
                                    print("selected url = \(url)")

                                    do {
                                        if url.startAccessingSecurityScopedResource() {
                                            let data = try Data(contentsOf: url)
                                            if let image = PlatformImage(data: data) {
                                                images.append(image)
                                            }
                                        }
                                    } catch let error {
                                        print("Error reading file \(error.localizedDescription)")
                                    }
                                }

                                viewStore.send(.stageImages(images))
                            }
                        }
                    }
                }
                .sheet(
                    store: store.scope(state: \.$detail, action: { .detail($0) }),
                    state: /Detail.State.imageStaging,
                    action: Detail.Action.imageStaging
                ) {
                    ImageStaging.ContentView(store: $0)
                        .platformConstrained()
                }
                .alert(
                    store: self.store.scope(state: \.$alert, action: { .alert($0) })
                )
                .task {
                    store.send(.loadAssets)
                }
            }
        }
    }
}
