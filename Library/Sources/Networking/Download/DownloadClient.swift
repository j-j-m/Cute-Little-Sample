import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

public struct DownloadClient {

    public var download: @Sendable (URL) -> AsyncThrowingStream<Event, Error>

    public enum Event: Equatable {
        case response(Data)
        case updateProgress(Double)
    }

    public init(download: @escaping @Sendable (URL) -> AsyncThrowingStream<DownloadClient.Event, Error>) {
        self.download = download
    }
}

extension DependencyValues {
  public var downloadClient: DownloadClient {
    get { self[DownloadClient.self] }
    set { self[DownloadClient.self] = newValue }
  }
}

extension DownloadClient: DependencyKey {
  public static let liveValue = Self(
    download: { url in
      .init { continuation in
        Task {
          do {
            let (bytes, response) = try await URLSession.shared.bytes(from: url)
            var data = Data()
            var progress = 0
            for try await byte in bytes {
              data.append(byte)
              let newProgress = Int(
                Double(data.count) / Double(response.expectedContentLength) * 100)
              if newProgress != progress {
                progress = newProgress
                continuation.yield(.updateProgress(Double(progress) / 100))
              }
            }
            continuation.yield(.response(data))
            continuation.finish()
          } catch {
            continuation.finish(throwing: error)
          }
        }
      }
    }
  )

  public static let testValue = Self(
    download: unimplemented("\(Self.self).download")
  )
}
