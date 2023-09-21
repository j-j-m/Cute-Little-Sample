import Foundation
import Alamofire
import AsyncAlgorithms

public class Upload: NSObject, AsyncSequence {

    public struct Info: Codable {
        public let url: URL
        public let token: String?
       
        public init(url: URL, token: String?) {
            self.url = url
            self.token = token
        }
    }

    public enum Event: Equatable {
        case success
        case updateProgress(Double)
    }

    public typealias Element = Event
    public typealias AsyncIterator = AsyncChannel<Event>.Iterator

    private let channel = AsyncChannel<Event>()

    public let id: UUID

    public init(id: UUID, info: Info, data: Data) {
        self.id = id
        super.init()
        self.start(with: info, data: data)
    }

    private func reportEvent(_ event: Event) async {
        await channel.send(event)
    }

    private func start(with info: Info, data: Data) {
        var request = URLRequest(url: info.url)
        request.httpMethod = "PUT"
        if let token = info.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        AF.upload(data, with: request)
            .uploadProgress { progress in
                let fractionCompleted = progress.fractionCompleted
                print("Upload Progress: \(fractionCompleted)")
                Task {
                    await self.reportEvent(.updateProgress(fractionCompleted))
                }
            }
            .response { response in
                switch response.result {
                case .success:
                    Task {
                        await self.reportEvent(.success)
                        self.channel.finish()
                    }
                case .failure(let error):
                    print("Upload Error: \(error)")
                    self.channel.finish()
                }
            }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return channel.makeAsyncIterator()
    }
}
