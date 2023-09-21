import SwiftUI
import ComposableArchitecture
import UI

extension AssetDetail {

    struct ContentView: View {

        @Environment(\.isPresented) private var isPresented
        @Environment(\.dismiss) private var dismiss

        let store: StoreOf<AssetDetail>

        @SwiftUI.State private var showImporter = false

        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                ZStack(alignment: .top) {
                    AssetImageViewer(asset: viewStore.asset)

                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .buttonStyle(CircularMaterialButtonStyle())
                    }
                    .padding()
                }
            }
        }

    }
}
