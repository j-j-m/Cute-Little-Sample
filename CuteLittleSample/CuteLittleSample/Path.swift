import SwiftUI
import ComposableArchitecture

struct Path: Reducer {
    enum State: Equatable {
        case gallery(Gallery.State)
    }

    enum Action {
        case gallery(Gallery.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: /State.gallery, action: /Action.gallery) {
            Gallery()
        }
    }
}

struct StackNavWrapperView<Content: View>: View {
    let content: Content
    let store: Store<StackState<Path.State>, StackAction<Path.State, Path.Action>>

    init(store: Store<StackState<Path.State>, StackAction<Path.State, Path.Action>>, @ViewBuilder content: () -> Content) {
        self.store = store
        self.content = content()
    }

    var body: some View {
        ZStack {
            NavigationStackStore(
                self.store
            ) {
                content
            } destination: {
                switch $0 {
                case .gallery:
                    CaseLet(
                        /Path.State.gallery,
                         action: Path.Action.gallery,
                         then: Gallery.ContentView.init(store:)
                    )
                }
            }
        }
    }
}
