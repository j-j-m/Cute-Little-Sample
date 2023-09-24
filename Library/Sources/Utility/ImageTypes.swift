import Foundation

public func imageTypes(from data: Data) -> (fileExtension: String, mimeType: String)? {
    var values = [UInt8](repeating: 0, count: 4)
    data.copyBytes(to: &values, count: 4)

    switch (values[0], values[1], values[2], values[3]) {
    case (0x47, 0x49, 0x46, _):   // GIF
        return ("gif", "image/gif")
    default:
        return ("png", "image/png")
    }
}
