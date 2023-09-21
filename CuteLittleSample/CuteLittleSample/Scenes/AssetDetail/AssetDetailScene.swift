import ComposableArchitecture
import Model

struct AssetDetail: Reducer {
    
    struct State: Equatable {
        let asset: Asset
    }

    enum Action {

    }

    var body: some Reducer<State, Action> {

        EmptyReducer()
    }
}
