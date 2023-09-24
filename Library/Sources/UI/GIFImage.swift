import SwiftUI

#if os(iOS) || os(tvOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

public struct GIFImage: View {
    private let source: GIFSource
    private var loopCount = 0
    private var isResizable = false

    /// Initializes the view with the given GIF image data.
    public init(data: Data) {
        self.source = .data(data)
    }

    /// Initialzies the view with the given GIF image url.
    public init(url: URL) {
        self.source = .url(url)
    }

    /// Initialzies the view with the given GIF image name.
    public init(imageName: String) {
        self.source = .imageName(imageName)
    }

    /// Sets the desired number of loops. By default, the number of loops is infinite.
    public func loopCount(_ value: Int) -> GIFImage {
        var copy = self
        copy.loopCount = value
        return copy
    }

    /// Sets an image to fit its space.
    public func resizable() -> GIFImage {
        var copy = self
        copy.isResizable = true
        return copy
    }

    public var body: some View {
        #if os(iOS) || os(tvOS)
        _GIFImage(source: source, loopCount: loopCount, isResizable: isResizable)
        #elseif os(macOS)
        MacGIFImage(source: source)
        #endif
    }
}

#if os(iOS) || os(tvOS)
import Gifu

@available(iOS 13, tvOS 13, *)
private struct _GIFImage: UIViewRepresentable {
    let source: GIFSource
    let loopCount: Int
    let isResizable: Bool

    func makeUIView(context: Context) -> GIFImageView {
        let imageView = GIFImageView()
        if isResizable {
            imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            imageView.setContentHuggingPriorityForOrientation(.defaultLow, for: .horizontal)
            imageView.setContentHuggingPriorityForOrientation(.defaultLow, for: .vertical)
        }
        return imageView
    }

    func updateUIView(_ imageView: GIFImageView, context: Context) {
        switch source {
        case .data(let data):
            imageView.animate(withGIFData: data, loopCount: loopCount)
        case .url(let url):
            imageView.animate(withGIFURL: url, loopCount: loopCount)
        case .imageName(let imageName):
            imageView.animate(withGIFNamed: imageName, loopCount: loopCount)
        }
    }

    static func dismantleUIView(_ imageView: GIFImageView, coordinator: ()) {
        imageView.prepareForReuse()
    }
}
#endif

#if os(macOS)
@available(macOS 10.15, *)
private struct MacGIFImage: NSViewRepresentable {
    let gifSource: GIFSource
    var isResizable: Bool = false

    init(source: GIFSource) {
        self.gifSource = source
    }

    func resizable() -> MacGIFImage {
        var copy = self
        copy.isResizable = true
        return copy
    }

    func makeNSView(context: Context) -> NSImageView {
        let imageView = NSImageView()
        imageView.animates = true
        imageView.canDrawSubviewsIntoLayer = true

        // Handle image scaling based on resizable
        imageView.imageScaling = isResizable ? .scaleAxesIndependently : .scaleProportionallyUpOrDown

        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        return imageView
    }

    func updateNSView(_ nsView: NSImageView, context: Context) {
        switch gifSource {
        case .data(let data):
            nsView.image = NSImage(data: data)
        case .url(let url):
            nsView.image = NSImage(contentsOf: url)
        case .imageName(let imageName):
            nsView.image = NSImage(named: NSImage.Name(imageName))
        }
    }
}
#endif

private enum GIFSource {
    case data(Data)
    case url(URL)
    case imageName(String)
}
