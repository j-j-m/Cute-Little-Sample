import SwiftUI

#if os(iOS)

public typealias PlatformImage = UIImage

extension PlatformImage {
    public func jpegDataWithQuality(_ quality: CGFloat) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }

    public func pngDataRepresentation() -> Data? {
        return self.pngData()
    }
}

extension Image {
    public init(platformImage: PlatformImage) {
        self = Image(uiImage: platformImage)
    }
}

#elseif os(macOS)

public typealias PlatformImage = NSImage

extension PlatformImage {
    public func jpegDataWithQuality(_ quality: CGFloat) -> Data? {
        guard let tiffData = self.tiffRepresentation else { return nil }
        let imageRep = NSBitmapImageRep(data: tiffData)
        return imageRep?.representation(using: .jpeg, properties: [NSBitmapImageRep.PropertyKey.compressionFactor: quality])
    }

    public func pngDataRepresentation() -> Data? {
        guard let tiffData = self.tiffRepresentation else { return nil }
        let imageRep = NSBitmapImageRep(data: tiffData)
        return imageRep?.representation(using: .png, properties: [:])
    }
}

extension Image {
    public init(platformImage: PlatformImage) {
        self = Image(nsImage: platformImage)
    }
}

#endif

// MARK: Size calculation helpers
extension PlatformImage {

    public func jpegSize(quality: CGFloat) -> Int? {
        return jpegDataWithQuality(quality)?.count
    }

    public var pngSize: Int? {
        return pngDataRepresentation()?.count
    }

    public func jpegSizeInKB(quality: CGFloat) -> Double? {
        guard let sizeInBytes = jpegSize(quality: quality) else { return nil }
        return Double(sizeInBytes) / 1024.0
    }

    public var pngSizeInKB: Double? {
        guard let sizeInBytes = pngSize else { return nil }
        return Double(sizeInBytes) / 1024.0
    }

    public func jpegSizeInMB(quality: CGFloat) -> Double? {
        guard let sizeInKB = jpegSizeInKB(quality: quality) else { return nil }
        return sizeInKB / 1024.0
    }

    public var pngSizeInMB: Double? {
        guard let sizeInKB = pngSizeInKB else { return nil }
        return sizeInKB / 1024.0
    }

}
