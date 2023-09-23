import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

public struct UploadClient {

    public var upload: @Sendable (URL, Upload.Info, Data) async -> Upload = unimplemented("\(Self.self).upload")
}

extension DependencyValues {
    public var uploadClient: UploadClient {
        get { self[UploadClient.self] }
        set { self[UploadClient.self] = newValue }
    }
}

extension UploadClient: DependencyKey {
    public static let liveValue: UploadClient = {
        @Dependency(\.uploadManager) var uploadManager
        @Dependency(\.uuid) var uuid

        var client = UploadClient()
        client.upload = { url, info, data in

            let upload = Upload(id: uuid(), info: info, data: data)
            await uploadManager.register(upload)

            return upload
        }

        return client
    }()

    public static let testValue = Self(
        upload: unimplemented("\(Self.self).upload")
    )
}

