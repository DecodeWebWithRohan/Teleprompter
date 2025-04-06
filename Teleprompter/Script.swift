import Foundation
import CoreData

@objc(IScript)
public class IScript: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var fontSize: Double
    @NSManaged public var scrollSpeed: Double
}

extension IScript {
    static func fetchRequest() -> NSFetchRequest<IScript> {
        return NSFetchRequest<IScript>(entityName: "Script")
    }
} 
