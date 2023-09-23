import Foundation

public struct Asset: Decodable, Hashable, Identifiable {

    public enum Locator: Hashable {
        case fileURL(URL)
        case remote(bucketId: String, path: String, fileType: String)
    }

    public let id: UUID
    public let locator: Locator
//    let metadata: [String: AnyCodable]? // Using AnyCodable to handle arbitrary JSON data

    public enum CodingKeys: String, CodingKey {
        case id
        case fileType = "file_type"
        case bucketId = "bucket_id"
        case path
    }

    public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(UUID.self, forKey: .id)

            // Try to decode properties specific to a `remote` asset
            if let bucketId = try? container.decode(String.self, forKey: .bucketId),
               let path = try? container.decode(String.self, forKey: .path),
               let fileType = try? container.decode(String.self, forKey: .fileType) {
                self.locator = .remote(bucketId: bucketId, path: path, fileType: fileType)
            } else {
                // Handle the other case here, e.g., a file URL.
                // For the sake of the example, we will throw an error.
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Data doesn't match any known format"))
            }
        }

    public init(id: UUID, locator: Locator) {
        self.id = id
        self.locator = locator
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

public struct AssetContainer: Decodable, Hashable, Identifiable {

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
