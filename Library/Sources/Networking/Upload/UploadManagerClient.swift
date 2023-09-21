import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

// Though not integrated, this demonstrated a more complex dependency I have been working on.
actor UploadManager {
    private var uploads: [UUID: Upload] = [:]
    private var eventContinuation: AsyncStream<UploadManagerClient.Event>.Continuation?
    var eventStream: AsyncStream<UploadManagerClient.Event>

    init() {
        eventStream = UploadManager.createEventStream(continuation: &eventContinuation)
    }

    private static func createEventStream(continuation: inout AsyncStream<UploadManagerClient.Event>.Continuation?) -> AsyncStream<UploadManagerClient.Event> {
        return AsyncStream { createdContinuation in
            continuation = createdContinuation
        }
    }

    func registerUpload(upload: Upload) {
        uploads[upload.id] = upload
        eventContinuation?.yield(.uploadRegistered(upload.id))
    }

    func getUpload(id: UUID) -> Upload? {
        return uploads[id]
    }

    func getAllUploads() -> [UUID: Upload] {
        return uploads
    }

    func cancelUpload(id: UUID) {
        // cancel the associated URLSessionUploadTask.
        // then remove the upload from the dictionary
        uploads[id] = nil
        // to represent a manual cancellation, uncomment the following:
//         uploads[id]?.status = .cancelled
        eventContinuation?.yield(.uploadCancelled(id))
    }
}

public struct UploadManagerClient {

    public enum Event {
        case uploadRegistered(UUID)
        case uploadCancelled(UUID)
        case uploadCompleted(UUID)
        case uploadErrored(UUID, Error)
        // TODO: add batch processing semantics (i.e. group of files finished downloading)
    }

    public var register: @Sendable (Upload) async -> Void = unimplemented("\(Self.self).register")
    public var getUpload: @Sendable (UUID) async -> Upload? = unimplemented("\(Self.self).getUpload")
    public var getAll: @Sendable () async -> [UUID: Upload] = unimplemented("\(Self.self).getAll")
    public var cancel: @Sendable (UUID) async -> Void = unimplemented("\(Self.self).cancel")
}

extension DependencyValues {
    var uploadManager: UploadManagerClient {
        get { self[UploadManagerClient.self] }
        set { self[UploadManagerClient.self] = newValue }
    }
}

extension UploadManagerClient: DependencyKey {
    public static let liveValue: UploadManagerClient = {
        let manager = UploadManager()

        var client = UploadManagerClient()

        client.register = { upload in
            await manager.registerUpload(upload: upload)
        }

        client.getUpload = { id in
            return await manager.getUpload(id: id)
        }

        client.getAll = {
            return await manager.getAllUploads()
        }

        client.cancel = { id in
            await manager.cancelUpload(id: id)
        }

        return client
    }()

    public static let testValue = Self(
        register: unimplemented("\(Self.self).register"),
        getUpload: unimplemented("\(Self.self).getUpload"),
        getAll: unimplemented("\(Self.self).getAll"),
        cancel: unimplemented("\(Self.self).cancel")
    )
}
