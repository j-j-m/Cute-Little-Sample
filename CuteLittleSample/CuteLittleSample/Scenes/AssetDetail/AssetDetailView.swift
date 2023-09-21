import SwiftUI
import ComposableArchitecture

extension AssetDetail {

    struct ContentView: View {

        let store: StoreOf<AssetDetail>

        @SwiftUI.State private var showImporter = false

        var body: some View {
            Color.red
        }

    }
}
