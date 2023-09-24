import SwiftUI
import Utility


/// Modifier that constrains a view to a standard size based on platform.
struct PlatformModalConstraintModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .inContext { view in
                #if os(macOS)
                view.frame(
                    idealWidth: NSApp.keyWindow?.contentView?.bounds.width ?? 800,
                    idealHeight: NSApp.keyWindow?.contentView?.bounds.height ?? 500
                )
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
