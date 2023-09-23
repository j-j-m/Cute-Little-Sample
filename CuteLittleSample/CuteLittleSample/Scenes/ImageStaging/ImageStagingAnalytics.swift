import ComposableArchitecture
import Analytics
import CustomDump

extension ImageStaging {

    var analyticsReducer: some ReducerOf<ImageStaging> {
        Reduce { state, action in
            switch action {
            case .setup:
                return .run { _ in
                    await analytics.track(.init(name: "view-image-staging"))
                }

            case .confirm:
                return .run { _ in
                    await analytics.track(.init(name: "image-staging-tapped-confirm"))
                }

            case .uploadImages:
                let references = state.references
                let count = references.count
                let sizeInMB = references.compactMap {
                    imageAssetCache.rawValue[.init(request: .init(url: $0.url))]?
                        .image
                        .pngSizeInMB
                }
                    .reduce(0, +)
                return .run { _ in
                    await analytics.track(
                        .init(
                            name: "image-staging-started-upload",
                            properties: [
                                "image-count": count,
                                "total-size": sizeInMB
                            ]
                        )
                    )
                }

            case .finishedUploading:
                return .run { _ in
                    await analytics.track(.init(name: "image-staging-finished-upload"))
                }

            default:
                return .none
            }
        }
    }
}
