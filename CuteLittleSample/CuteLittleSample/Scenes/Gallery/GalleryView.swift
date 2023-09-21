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
                ScrollView {
                    MasonryVStack(
                        columns: horizontalSizeClass == .compact ? 2 : 3,
                        spacing: 10
                    ){
                        ForEach(viewStore.assets) { asset in
                            NavigationLink(
                                state: Path.State.assetDetail(
                                    .init(asset: asset)
                                ),
                                label: {
                                    VStack {
                                        AssetImageView(asset: asset)
                                            .cornerRadius(10)
                                    }
                                })
                            .composableStyle(
                                scalingButtonStyle
                                >>> hapticButtonStyle
                            )
                            .transition(.opacity.animation(.easeIn))

                        }
                    }
                    .padding(10)
                }
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
            }
        }
    }
}