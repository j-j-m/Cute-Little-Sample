import Foundation
import SwiftUI
import Nuke
import NukeUI
import Dependencies
import Platform
import Model

// MARK: - Style Setup
public struct AssetImageConfiguration {
    let store: AssetStore
    let onCompletion: ((Result<Nuke.ImageResponse, Error>) -> Void)?
}

public protocol AssetImageStyle {
    associatedtype Background: View
    associatedtype Overlay: View
    associatedtype Item: View

    func makeBackground() -> Self.Background
    func makeClip() -> ErasedShape
    func makeOverlay() -> Self.Overlay
    func makeItem(configuration: AssetImageConfiguration) -> Self.Item
    func makeAnimation() -> Animation?
}

extension AssetImageStyle {

    func makeBackgroundTypeErased() -> AnyView {
        AnyView(self.makeBackground())
    }

    func makeClipTypeErased() -> ErasedShape {
        self.makeClip()
    }

    func makeOverlayTypeErased() -> AnyView {
        AnyView(self.makeOverlay())
    }

    func makeItemTypeErased(configuration: AssetImageConfiguration) -> AnyView {
        AnyView(self.makeItem(configuration: configuration))
    }

    public func makeAnimation() -> Animation? {
        return .default
    }
}

public struct AnyAssetImageStyle: AssetImageStyle {

    private let _makeBackground: () -> AnyView
    public func makeBackground() -> some View {
        return self._makeBackground()
    }

    private let _makeClip: () -> ErasedShape
    public func makeClip() -> ErasedShape {
        return self._makeClip()
    }

    private let _makeOverlay: () -> AnyView
    public func makeOverlay() -> some View {
        return self._makeOverlay()
    }

    private let _makeItem: (AssetImageConfiguration) -> AnyView
    public func makeItem(configuration: AssetImageConfiguration) -> some View {
        return self._makeItem(configuration)
    }

    private let _makeAnimation: () -> Animation?
    public func makeAnimation() -> Animation? {
        return self._makeAnimation()
    }

    init<ST: AssetImageStyle>(_ style: ST) {
        self._makeBackground = style.makeBackgroundTypeErased
        self._makeClip = style.makeClipTypeErased
        self._makeOverlay = style.makeOverlayTypeErased
        self._makeItem = style.makeItemTypeErased
        self._makeAnimation = style.makeAnimation
    }
}

public struct AssetImageStyleKey: EnvironmentKey {
    public static let defaultValue: AnyAssetImageStyle  = AnyAssetImageStyle(DefaultAssetImageStyle())
}

extension EnvironmentValues {
    public var assetImageStyle: AnyAssetImageStyle {
        get {
            return self[AssetImageStyleKey.self]
        }
        set {
            self[AssetImageStyleKey.self] = newValue
        }
    }
}

extension View {
    public func assetImageStyle<S>(_ style: S) -> some View where S: AssetImageStyle {
        self.environment(\.assetImageStyle, AnyAssetImageStyle(style))
    }
}

public class AssetStore: ObservableObject {
    var asset: Asset?
    var url: URL?

    @Dependency(\.storage) var storage

    public init(asset: Asset?, transform: StorageClient.PublicURLRequest.TransformOptions? = nil) {
        self.asset = asset
        guard let asset else {
            self.url = nil
            return
        }

        switch asset.locator {
        case .fileURL(let url):
            self.url = url
        case .remote(let bucketId, let path, let fileType):
            self.url = try? storage.getPublicURL(
                .init(
                    bucketID: bucketId,
                    path: path,
                    transform: transform
                )
            )
        }
    }

}

private struct _AssetImageView: View {
    public init(asset: Asset?, transform: StorageClient.PublicURLRequest.TransformOptions? = nil) {
        _store = StateObject(
            wrappedValue: AssetStore(
                asset: asset,
                transform: transform
            )
        )

    }

    @StateObject fileprivate var store: AssetStore
    @Environment(\.assetImageStyle) var style: AnyAssetImageStyle

    private var onCompletion: ((Result<Nuke.ImageResponse, Error>) -> Void)?

    public var body: some View {
        style.makeItem(
            configuration: .init(
                store: store,
                onCompletion: onCompletion
            )
        )
            .background(style.makeBackground())
    }

    /// Gets called when the current request is completed.
    public func onCompletion(_ closure: ((Result<Nuke.ImageResponse, Error>) -> Void)?) -> Self {
        map { $0.onCompletion = closure }
    }

    private func map(_ closure: (inout _AssetImageView) -> Void) -> Self {
        var copy = self
        closure(&copy)
        return copy
    }
}

public struct AssetImageView: View {

    var asset: Asset?
    var transform: StorageClient.PublicURLRequest.TransformOptions?

    private var idHash: Int {
        // Combine the hashes of both properties
        var hasher = Hasher()
        hasher.combine(asset)
        hasher.combine(transform)
        return hasher.finalize()
    }

    public init(asset: Asset?, transform: StorageClient.PublicURLRequest.TransformOptions? = nil) {
        self.asset = asset
        self.transform = transform
    }

    private var onCompletion: ((Result<Nuke.ImageResponse, Error>) -> Void)?

    public var body: some View {
        _AssetImageView(asset: asset, transform: transform)
            .onCompletion(onCompletion)
            .id(idHash)
    }

    /// Gets called when the current request is completed.
    public func onCompletion(_ closure: @escaping (Result<Nuke.ImageResponse, Error>) -> Void) -> Self {
        map { $0.onCompletion = closure }
    }

    private func map(_ closure: (inout AssetImageView) -> Void) -> Self {
        var copy = self
        closure(&copy)
        return copy
    }
}
