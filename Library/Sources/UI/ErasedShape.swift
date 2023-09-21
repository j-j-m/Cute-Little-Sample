import SwiftUI

public struct ErasedShape: Shape {
    private var base: (CGRect) -> Path

    public init<S: Shape>(shape: S) {
        base = shape.path(in:)
    }

    public func path(in rect: CGRect) -> Path {
        base(rect)
    }
}
