import ComposableArchitecture
import Analytics

extension Application {

    var analyticsReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setup:
                return .run { _ in
                    await analytics.configure()
                    await analytics.track(.init(name: "view-landing"))
                }

            default:
                return .none
            }
        }
    }
}
