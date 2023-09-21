import Foundation

public struct Asset: Codable, Hashable, Identifiable {
    public let id: UUID
    public let bucketId: String
    public let path: String
    public let fileType: String
//    let metadata: [String: AnyCodable]? // Using AnyCodable to handle arbitrary JSON data

    public enum CodingKeys: String, CodingKey {
        case id
        case bucketId = "bucket_id"
        case path
        case fileType = "file_type"
    }

    public init(id: UUID, bucketId: String, path: String, fileType: String) {
        self.id = id
        self.bucketId = bucketId
        self.path = path
        self.fileType = fileType
    }
}

extension Asset {
    public struct Insert: Codable, Equatable {
        public let bucketId: String
        public let path: String
        public let fileType: String
    //    let metadata: [String: AnyCodable]? // Using AnyCodable to handle arbitrary JSON data

        public enum CodingKeys: String, CodingKey {
            case bucketId = "bucket_id"
            case path
            case fileType = "file_type"
        }

        public init(bucketId: String, path: String, fileType: String) {
            self.bucketId = bucketId
            self.path = path
            self.fileType = fileType
        }
    }
}

public struct AssetContainer: Codable, Hashable, Identifiable {

    public let id: UUID
    public let asset: Asset
    public var context: String?

    public init(id: UUID, asset: Asset, context: String? = nil) {
        self.id = id
        self.asset = asset
        self.context = context
    }

    public struct Update: Codable, Hashable {
        public let asset: Asset.ID?
        public var context: String?

        public init(asset: Asset.ID? = nil, context: String? = nil) {
            self.asset = asset
            self.context = context
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(asset, forKey: .asset)
            if let context {
                try container.encode(context, forKey: .context)
            } else {
                try container.encodeNil(forKey: .context)
            }
        }
    }
}

public struct AssetItem: Equatable, Identifiable {
    public var asset: AssetContainer
    public let url: URL?

    public var id: Asset.ID { asset.id }

    public init(asset: AssetContainer, url: URL? = nil) {
        self.asset = asset
        self.url = url
    }
}
