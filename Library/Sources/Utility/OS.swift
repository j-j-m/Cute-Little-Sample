import Foundation

public enum OS {
    case iOS
    case macOS
    case watchOS
    case tvOS
    case unknown

    public static var current: OS {
        #if os(iOS)
        return .iOS
        #elseif os(macOS)
        return .macOS
        #elseif os(watchOS)
        return .watchOS
        #elseif os(tvOS)
        return .tvOS
        #else
        return .unknown
        #endif
    }
}
