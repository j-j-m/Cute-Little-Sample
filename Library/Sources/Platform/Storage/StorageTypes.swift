import Foundation
import SupabaseStorage

extension StorageClient {
    public struct UploadRequest {

        public struct File: Hashable, Equatable {
            public var name: String
            public var data: Data
            public var fileName: String
            public var contentType: String

            public init(name: String, data: Data, fileName: String, contentType: String) {
                self.name = name
                self.data = data
                self.fileName = fileName
                self.contentType = contentType
            }
        }

        public enum Operation {
            case upload
            case upsert
            case displace
        }

        let bucketID: String
        let path: String
        let file: File
        let operation: Operation

        public init(bucketID: String, path: String, file: File, operation: Operation) {
            self.bucketID = bucketID
            self.path = path
            self.file = file
            self.operation = operation
        }
    }
}

extension StorageClient.UploadRequest.File {
    internal var rawFile: File {
        .init(name: self.name, data: self.data, fileName: self.fileName, contentType: self.contentType)
    }
}

extension StorageClient {
    public struct PublicURLRequest {

        public struct TransformOptions: Hashable {
            public var width: Int?
            public var height: Int?
            public var resize: String?
            public var quality: Int?
            public var format: String?

            public init(
                width: Int? = nil,
                height: Int? = nil,
                resize: String? = "cover",
                quality: Int? = 80,
                format: String? = "origin"
            ) {
                self.width = width
                self.height = height
                self.resize = resize
                self.quality = quality
                self.format = format
            }

            var queryItems: [URLQueryItem] {
                var items = [URLQueryItem]()

                if let width = width {
                    items.append(URLQueryItem(name: "width", value: String(width)))
                }

                if let height = height {
                    items.append(URLQueryItem(name: "height", value: String(height)))
                }

                if let resize = resize {
                    items.append(URLQueryItem(name: "resize", value: resize))
                }

                if let quality = quality {
                    items.append(URLQueryItem(name: "quality", value: String(quality)))
                }

                if let format = format {
                    items.append(URLQueryItem(name: "format", value: format))
                }

                return items
            }
        }

        let bucketID: String
        let path: String
        let transform: TransformOptions?

        public init(bucketID: String, path: String, transform: TransformOptions? = nil) {
            self.bucketID = bucketID
            self.path = path
            self.transform = transform
        }
    }
}

extension StorageClient.PublicURLRequest.TransformOptions {
    internal var raw: TransformOptions {
        .init(width: self.width, height: self.height, resize: self.resize, quality: self.quality, format: self.format)
    }
}

public struct ListFilesRequest {
    let bucketID: String
    let path: String

    public init(bucketID: String, path: String) {
        self.bucketID = bucketID
        self.path = path
    }
}
