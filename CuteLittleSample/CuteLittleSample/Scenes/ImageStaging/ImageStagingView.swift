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
                            ForEach(viewStore.images) {
                                Image(platformImage: $0.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        .padding([.horizontal, .bottom])
                        .padding(.top, 80)
                    }

                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
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
            }
        }
    }
}
