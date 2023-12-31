import SwiftUI
import ComposableArchitecture
import UI

extension ImageStaging {

    struct ContentView: View {

        @Environment(\.dismiss) private var dismiss

        let store: StoreOf<ImageStaging>

        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ZStack(alignment: .top) {
                    ScrollView {
                        MasonryVStack(
                            columns: 3,
                            spacing: 10
                        ){
                            ForEach(viewStore.references) { item in
                                AssetImageView(asset: .init(id: item.id, locator: .fileURL(item.url)))
                                    .cornerRadius(10)
                                    .overlay {
                                        if item.completed {
                                            Image(systemName: "check")
                                                .foregroundStyle(.green)
                                                .transition(.scale)
                                        } else if let progress = item.uploadProgress {
                                            Color.gray.shimmering()
                                            ProgressView(progress)
                                                .labelsHidden()
                                                .progressViewStyle(.circular)
                                                .transition(.opacity.animation(.easeInOut))
                                        }
                                    }
                            }
                        }
                        .padding([.horizontal, .bottom])
                        .padding(.top, 80)
                    }

                    VStack(spacing: 0) {
                        HStack {
                            if let progress = viewStore.uploadProgress {
                                ProgressView(progress)
                                    .transition(.opacity.animation(.easeInOut))
                            } else {
                                Text("Confirm")
                                    .font(.title)
                                Spacer()
                                Button {
                                    dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                        .padding()
                        .background(Material.bar)
                        Divider()

                        Spacer()

                        Divider()
                        HStack {
                            Spacer()
                            Button {
                                store.send(.confirm)
                            } label: {
                                Label {
                                    Text("Upload")
                                } icon: {
                                    Image(systemName: "arrow.up.circle")
                                }
                                .bold()
                            }
                        }
                        .padding()
                        .background(Material.bar)
                    }
                }
                .task {
                    viewStore.send(.setup)
                }
            }
        }
    }
}
