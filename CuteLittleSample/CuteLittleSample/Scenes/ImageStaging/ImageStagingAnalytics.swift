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

            case .uploadImages(let images):
                let count = images.count
                let sizeInMB = images.compactMap(\.pngSizeInMB).reduce(0, +)
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
            }
        }
    }
}
