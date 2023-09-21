import ComposableArchitecture
import Analytics

extension Gallery {

    var analyticsReducer: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .setup:
                return .run { _ in
                    await analytics.track(.init(name: "view-gallery"))
                }

            case .handleLoadAssets(let result):
                return .run { _ in
                    switch result {
                    case .success:
                        await analytics.track(.init(name: "gallery-load-assets-success"))
                    case .failure(let error):
                        await analytics.track(
                            .init(
                                name: "gallery-load-assets-failure",
                                properties: [
                                    "error": error.localizedDescription
                                ]
                            )
                        )
                    }
                }

            default:
                return .none
            }
        }
    }
}
