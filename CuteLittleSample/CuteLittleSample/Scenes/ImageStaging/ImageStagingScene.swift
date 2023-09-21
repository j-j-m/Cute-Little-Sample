import Foundation
import ComposableArchitecture
import Model
import Utility

struct ImageStaging: Reducer {

    struct ImageContainer: Equatable, Identifiable {
        let id: UUID
        let image: PlatformImage
    }

    struct State: Equatable {
        let images: IdentifiedArrayOf<ImageContainer>
    }

    enum Action {

    }

    var body: some Reducer<State, Action> {

        EmptyReducer()
    }
}
