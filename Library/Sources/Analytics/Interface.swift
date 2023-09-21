import Dependencies
import XCTestDynamicOverlay

public struct AnalyticsClient {

    public struct Event: Equatable {

        public let name: String
        public let properties: [String: AnyHashable]

        public init(name: String, properties: [String: AnyHashable] = [:]) {
            self.name = name
            self.properties = properties
        }
    }

    public var configure: @Sendable () async -> Void = unimplemented("\(Self.self).configure")
    public var identify: @Sendable (String?) async -> Void = unimplemented("\(Self.self).identify")
    public var track: @Sendable (Event) async -> Void = unimplemented("\(Self.self).track")

    public init() { }
}

extension AnalyticsClient {
    public func scope(_ scope: String?) -> AnalyticsClient {
        var client = self

        if let scope = scope {
            client.track = { event in
                let currentPathComponents = event.properties["pathComponents"] as? [String] ?? []
                let pathComponents = [scope] + currentPathComponents
                let newEvent = Event(
                    name: event.name,
                    properties: event.properties.merging(
                        [
                            "pathComponents": pathComponents
                        ],
                        uniquingKeysWith: { $1 }
                    )
                )
                return await self.track(newEvent)
            }
        }

        return client
    }
}

extension DependencyValues {
    public var analytics: AnalyticsClient {
      get { self[AnalyticsClientKey.self] }
      set { self[AnalyticsClientKey.self] = newValue }
    }

    private enum AnalyticsClientKey: DependencyKey {
        static let liveValue: AnalyticsClient = .live
        public static let testValue: AnalyticsClient = {
            var client = AnalyticsClient()
            client.configure = { }
            client.identify = { _ in }
            client.track = { _ in }
            return client
        }()
    }
}
