import Foundation
import CoreData

public struct AnalyticsDomain: Hashable, Codable {
    var filter: String?

    public init(filter: String? = nil) {
        self.filter = filter
    }
}
