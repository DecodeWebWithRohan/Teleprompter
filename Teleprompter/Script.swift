import Foundation
import SwiftData

@Model
class Script {
    var id: String
    var title: String?
    var content: String?
    var createdAt: Date
    var updatedAt: Date
    var fontSize: Double
    var scrollSpeed: Double

    init(
        id: String,
        title: String?,
        content: String?,
        createdAt: Date,
        updatedAt: Date,
        fontSize: Double,
        scrollSpeed: Double
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.fontSize = fontSize
        self.scrollSpeed = scrollSpeed
    }
}
