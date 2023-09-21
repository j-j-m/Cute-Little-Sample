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

