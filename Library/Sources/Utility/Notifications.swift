import Foundation
import Dependencies
import SwiftUI
#if canImport(UIKit)
let becameActive = UIApplication.didBecomeActiveNotification
#else
let becameActive = NSApplication.didBecomeActiveNotification
#endif

extension DependencyValues {
  public var becameActive: @Sendable () async -> AsyncStream<Void> {
    get { self[BecameActiveKey.self] }
    set { self[BecameActiveKey.self] = newValue }
  }
}

private enum BecameActiveKey: DependencyKey {
  static let liveValue: @Sendable () async -> AsyncStream<Void> = {
    await AsyncStream(
      NotificationCenter.default
        .notifications(named: becameActive)
        .map { _ in }
    )
  }
  static let testValue: @Sendable () async -> AsyncStream<Void> = unimplemented(
    #"@Dependency(\.screenshots)"#, placeholder: .finished
  )
}
