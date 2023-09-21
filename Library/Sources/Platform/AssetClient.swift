import Foundation
import Dependencies
import XCTestDynamicOverlay
import IdentifiedCollections
import Model
import Networking
import SupabaseStorage

public struct AssetClient {

    public var get: @Sendable (Asset.ID) async throws -> Asset = unimplemented("\(Self.self).get")
    public var list: @Sendable () async throws -> IdentifiedArrayOf<Asset> = unimplemented("\(Self.self).list")

    public enum AssetUploadEvent: Equatable {
        case success(AssetContainer)
        case updateProgress(Double)
    }

    public var createAssetUpload: @Sendable (UUID, StorageClient.UploadRequest.File) async throws -> AsyncThrowingStream<AssetUploadEvent, Error> = unimplemented("\(Self.self).createAssetUpload")

    public var deleteAsset: @Sendable (Asset.ID) async throws -> Void = unimplemented("\(Self.self).deleteAsset")

    public init() { }
}

extension AssetClient: DependencyKey {
    public static let liveValue: AssetClient = .live
}

extension DependencyValues {
    public var assets: AssetClient {
        get { self[AssetClient.self] }
        set { self[AssetClient.self] = newValue }
    }
}

// MARK: - Implementation

extension AssetClient {

    static var live: Self {

        @Dependency(\.supabase) var supabase
        @Dependency(\.storage) var storage
        @Dependency(\.uploadClient) var uploadClient
        @Dependency(\.uuid) var uuid

        var client = AssetClient()

        client.get = { id in
            return try await supabase.database
                .from("asset")
                .select()
                .match(query: ["id" : id])
                .single()
                .execute().value
        }

        client.list = {
            return try await supabase.database
                .from("asset")
                .select()
                .order(column: "upload_date", ascending: false)
                .execute()
                .value
        }

        struct AssetUploadRequest: Codable {
            let bucket: String
            let path: String
        }

        struct UploadInfo: Codable {
            let signedUrl: URL
            let path: String
            let token: String?
        }

        client.createAssetUpload = { id, file in
            let path = "\(id)/\(file.fileName)"

            // the usual scenario for this is for logged in users.
            // unfortunately supabase tries to authenticate each invocation request.
            // since this app is unauthenticated those requests will fail
            let uploadInfo: UploadInfo = try await supabase.functions.invoke(
                functionName: "get-upload-url",
                invokeOptions: .init(
                    body: AssetUploadRequest(bucket: "asset_media", path: path)
                )
            )

            return AsyncThrowingStream<AssetUploadEvent, Error> { continuation in
                Task {
                    let upload = await uploadClient.upload(
                        uploadInfo.signedUrl,
                        .init(url: uploadInfo.signedUrl, token: uploadInfo.token),
                        file.data
                    )

                    for try await event in upload {
                        switch event {
                        case .updateProgress(let progress):
                            continuation.yield(.updateProgress(progress))
                        case .success:
                            break
                        }
                    }

                    let newAsset = Asset.Insert(bucketId: "asset_media", path: path, fileType: file.contentType)
                    let asset: Asset = try await supabase.database
                        .from("asset")
                        .insert(values: newAsset, returning: .representation)
                        .single()
                        .execute().value


                    continuation.yield(.success(AssetContainer(id: asset.id, asset: asset)))
                    continuation.finish()
                }
            }
        }

        client.deleteAsset = { assetId in
            try await supabase.database
                .from("asset")
                .delete()
                .eq(column: "id", value: assetId)
                .execute()
        }

        return client
    }
}
