import Nuke
import Tagged
import Dependencies

public enum AssetImageTag {}
public typealias AssetImageCache = Tagged<AssetImageTag, ImageCache>

extension DependencyValues {
    public var imageAssetCache: AssetImageCache {
        get { self[AssetImageCache.self] }
        set { self[AssetImageCache.self] = newValue }
    }
}

extension AssetImageCache: DependencyKey, TestDependencyKey {
    public static let liveValue: AssetImageCache = .init(rawValue: ImageCache.shared)
    public static let testValue: AssetImageCache = .init(rawValue: ImageCache.shared)
}
