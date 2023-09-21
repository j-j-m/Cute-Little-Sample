import SwiftUI
import Dependencies
import Haptics

public typealias ButtonStyleClosure<A: View, B: View> = (ButtonStyleConfiguration, A) -> B

precedencegroup ForwardComposition {
    associativity: left
}

infix operator >>>: ForwardComposition

public func >>> <A: View, B: View, C: View>(
    _ f: @escaping ButtonStyleClosure<A, B>,
    _ g: @escaping ButtonStyleClosure<B, C>
) -> ButtonStyleClosure<A, C> {
    return { configuration, a in
        g(configuration, f(configuration, a))
    }
}

public struct ComposableButtonStyle<B: View>: ButtonStyle {
    let buttonStyleClosure: ButtonStyleClosure<ButtonStyleConfiguration.Label, B>

    public init(_ buttonStyleClosure: @escaping ButtonStyleClosure<ButtonStyleConfiguration.Label, B>) {
        self.buttonStyleClosure = buttonStyleClosure
    }

    public func makeBody(configuration: Configuration) -> some View {
        return buttonStyleClosure(configuration, configuration.label)
    }
}

extension Button {
    public func composableStyle<B: View>(_ buttonStyleClosure: @escaping ButtonStyleClosure<ButtonStyleConfiguration.Label, B>) -> some View {
        return self.buttonStyle(ComposableButtonStyle(buttonStyleClosure))
    }
}

extension NavigationLink {
    public func composableStyle<B: View>(_ buttonStyleClosure: @escaping ButtonStyleClosure<ButtonStyleConfiguration.Label, B>) -> some View {
        return self.buttonStyle(ComposableButtonStyle(buttonStyleClosure))
    }
}

extension Menu {
    public func composableStyle<B: View>(_ buttonStyleClosure: @escaping ButtonStyleClosure<ButtonStyleConfiguration.Label, B>) -> some View {
        return self.buttonStyle(ComposableButtonStyle(buttonStyleClosure))
    }
}

public struct ButtonStateColors {
    let pressed: Color
    let notPressed: Color
}

public func scaledButtonStyle<A: View>(_ configuration: ButtonStyleConfiguration, _ view: A) -> some View {
    return view
        .scaleEffect(configuration.isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.5))
}

public func roundedButtonStyle<A: View>(_ configuration: ButtonStyleConfiguration, _ view: A) -> some View {
    return view.cornerRadius(8)
}

public func circularButtonStyle<A: View>(_ configuration: ButtonStyleConfiguration, _ view: A) -> some View {
    return GeometryReader { proxy in
        view
            .aspectRatio(1, contentMode: .fill)
            .cornerRadius(proxy.size.width)
    }
}

public func navBarButtonStyle<A: View>(_ configuration: ButtonStyleConfiguration, _ view: A) -> some View {
    return view
        .padding(5)
        .background {
            GeometryReader { proxy in
                    Circle()
                    .fill(Material.ultraThick)
            }
        }
        .opacity(configuration.isPressed ? 0.9 : 1.0)
}

public func defaultPaddingButtonStyle<A: View>(_ configuration: ButtonStyleConfiguration, _ view: A) -> some View {
    return view.padding()
}

public func coloredButtonStyle<A: View>(_ configuration: ButtonStyleConfiguration, _ view: A) -> some View {
    let backgroundColors = ButtonStateColors(
        pressed: Color("cta_button_highlight_color"),
        notPressed: Color("cta_button_color"))
    let foregroundColors = ButtonStateColors(
        pressed: Color("cta_button_text_color"),
        notPressed: Color("cta_button_text_color"))

    return view
        .background(configuration.isPressed ? backgroundColors.pressed : backgroundColors.notPressed)
        .foregroundColor(configuration.isPressed ? foregroundColors.pressed : foregroundColors.notPressed)
}



public func materialButtonStyle<A: View>(_ configuration: ButtonStyleConfiguration, _ view: A) -> some View {

    return view
        .padding()
        .background(Material.ultraThick)
        .cornerRadius(5)
        .opacity(configuration.isPressed ? 0.9 : 1.0)

}

public func scalingButtonStyle<A: View>(_ configuration: ButtonStyleConfiguration, _ view: A) -> some View {

    return view
        .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
        .animation(.interactiveSpring(), value: configuration.isPressed)
}

public func unalteredForeground<A: View>(_ configuration: ButtonStyleConfiguration, _ view: A) -> some View {

    return view
        .foregroundColor(nil)
}

public func hapticButtonStyle<A: View>(_ configuration: ButtonStyleConfiguration, _ view: A) -> some View {
    @Dependency(\.haptics) var haptics
    return view
        .onChange(of: configuration.isPressed) { newValue in
            haptics.interaction()
        }
}

public struct CircularMaterialButtonStyle: ButtonStyle {

    public init() { }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.primary)  // Set your desired color here
            .background(
                Circle()
                .fill(Material.ultraThin)
            )
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.interactiveSpring(), value: configuration.isPressed)
    }
}
