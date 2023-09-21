import SwiftUI
import Utility


/// Modifier that constrains a view to a standard size based on platform.
struct PlatformModalConstraintModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .inContext { view in
                #if os(macOS)
                view.frame(width: 800, height: 500)
                #else
                view
                // .interactiveDismissDisabled(false)
                #endif
            }
    }
}

extension View {
    func platformConstrained() -> some View {
        self.modifier(PlatformModalConstraintModifier())
    }
}
