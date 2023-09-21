import SwiftUI
import NukeUI
import Utility

public struct DefaultAssetImageStyle: AssetImageStyle {

    public init() {}

    public func makeBackground() -> some View {
        EmptyView()
    }

    public func makeClip() -> ErasedShape {
        ErasedShape(shape: Rectangle())
    }

    public func makeOverlay() -> some View {
        EmptyView()
    }

    @MainActor public func makeItem(configuration: AssetImageConfiguration) -> some View {
        LazyImage(url: configuration.store.url, transaction: .init(animation: .default)) { state in
            if let image = state.image {
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .transition(.opacity)
            } else if state.isLoading {
                Color.gray.shimmering()
                    .transition(.opacity)
            } else {
                Image(systemName: "photo.on.rectangle.angled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .transition(.opacity)
            }
        }
        .inContext {
            if let onCompletion = configuration.onCompletion {
                $0.onCompletion(onCompletion)
            } else {
                $0
            }
        }
    }

    public func makeAnimation() -> Animation? {
        return .default
    }
}

public struct DimensionallyConstrainedImageStyle: AssetImageStyle {

    let width: CGFloat
    let height: CGFloat
    let offset: CGFloat

    public init(width: CGFloat, height: CGFloat, offset: CGFloat) {
        self.width = width
        self.height = height
        self.offset = offset
    }

    public func makeBackground() -> some View {
        EmptyView()
    }

    public func makeClip() -> ErasedShape {
        ErasedShape(shape: Rectangle())
    }

    public func makeOverlay() -> some View {
        EmptyView()
    }

    @MainActor public func makeItem(configuration: AssetImageConfiguration) -> some View {
        LazyImage(url: configuration.store.url, transaction: .init(animation: .easeOut)) { state in
            ZStack {
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                        .transition(.opacity)
                } else {
                    Color.gray.shimmering()
                        .transition(.opacity)
                }
            }
            .offset(y: offset)
        }
        .inContext {
            if let onCompletion = configuration.onCompletion {
                $0.onCompletion(onCompletion)
            } else {
                $0
            }
        }
    }

    public func makeAnimation() -> Animation? {
        return .default
    }
}

public struct SquareImageStyle: AssetImageStyle {

    let contentMode: ContentMode
    public init(contentMode: ContentMode = .fill) {
        self.contentMode = contentMode
    }

    public func makeBackground() -> some View {
        EmptyView()
    }

    public func makeClip() -> ErasedShape {
        ErasedShape(shape: Rectangle())
    }

    public func makeOverlay() -> some View {
        EmptyView()
    }

    @MainActor public func makeItem(configuration: AssetImageConfiguration) -> some View {
        GeometryReader { proxy in
            LazyImage(url: configuration.store.url, transaction: .init(animation: .default)) { state in
                if let image = state.image {
                    image.resizable().aspectRatio(contentMode: contentMode)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .transition(.opacity)
                } else if state.isLoading {
                    Color.gray.shimmering()
                        .transition(.opacity)
                } else if let error = state.error {
                    Image(systemName: "questionmark.square.dashed")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .inContext {
                if let onCompletion = configuration.onCompletion {
                    $0.onCompletion(onCompletion)
                } else {
                    $0
                }
            }
        }
        .clipped()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: .infinity)
    }

    public func makeAnimation() -> Animation? {
        return .default
    }
}

public extension AssetImageStyle where Self == AnyAssetImageStyle {
    static var defaultStyle: DefaultAssetImageStyle {
        DefaultAssetImageStyle()
    }

    static func constrained(width: CGFloat, height: CGFloat, offset: CGFloat = 0) -> DimensionallyConstrainedImageStyle {
        DimensionallyConstrainedImageStyle(width: width, height: height, offset: offset)
    }

    static func square(contentMode: ContentMode = .fill) -> SquareImageStyle {
        SquareImageStyle(contentMode: contentMode)
    }
}
