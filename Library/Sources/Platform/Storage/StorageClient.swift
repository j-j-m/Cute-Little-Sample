import Foundation
import Dependencies
import XCTestDynamicOverlay

import SupabaseStorage

public struct StorageClient {

    public var getPublicURL: (PublicURLRequest) throws -> URL = unimplemented("\(Self.self).getPublicURL")
    public var listFiles: (ListFilesRequest) async throws -> [String] = unimplemented("\(Self.self).listFiles")

    public init() { }
}

extension StorageClient: DependencyKey {
    public static let liveValue: StorageClient = .live
}

extension DependencyValues {
    public var storage: StorageClient {
      get { self[StorageClient.self] }
      set { self[StorageClient.self] = newValue }
    }
}

// MARK: - Implementation

extension StorageClient {
    
    static var live: Self {

        @Dependency(\.supabase) var supabase

        var client = StorageClient()

        client.getPublicURL = { request in
            return try supabase.storage
                .from(id: request.bucketID)
                .getPublicURL(path: request.path, options: request.transform?.raw)
        }

        client.listFiles = { request in
            let files = try await supabase.storage
                .from(id: request.bucketID)
                .list(path: request.path, options: .none)

            return files
                .map(\.name)
        }

        return client
    }
}
