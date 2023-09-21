import SwiftUI
import ComposableArchitecture
import UI
import Model

enum AssetDetail {

    struct ContentView: View {

        @Environment(\.isPresented) private var isPresented
        @Environment(\.dismiss) private var dismiss

        let asset: Asset

        var body: some View {
            ZStack(alignment: .top) {
                AssetImageViewer(asset: asset)

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
