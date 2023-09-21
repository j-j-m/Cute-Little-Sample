import SwiftUI

extension View {
    @ViewBuilder public func `if`<Content: View>(_ condition: Bool, @ViewBuilder content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }

    @ViewBuilder public func inContext<Content: View>(@ViewBuilder content: (Self) -> Content) -> some View {
        content(self)
    }
}

extension Scene {

    @SceneBuilder public func inContext<Content: Scene>(@SceneBuilder content: (Self) -> Content) -> some Scene {
        content(self)
    }
}
