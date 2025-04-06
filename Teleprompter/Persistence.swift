//
//  Persistence.swift
//  Teleprompter
//
//  Created by Rohan Roy - Personal on 05/04/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let newScript = Script(context: viewContext)
        newScript.id = UUID().uuidString
        newScript.title = "Sample Script"
        newScript.content = """
        Welcome to your teleprompter! This is a sample script to help you get started.

        This text will scroll smoothly on your screen, allowing you to read naturally while recording.
        You can adjust the scroll speed and font size to match your speaking pace and comfort.

        Try moving this window around, resizing it, or locking it in place.
        Use the play/pause button to control scrolling, and the forward/back buttons to adjust position.

        When you're ready, create your own script by tapping the + button on the main screen.
        Happy recording!
        """
        newScript.createdAt = Date()
        newScript.updatedAt = Date()
        newScript.fontSize = 30.0
        newScript.scrollSpeed = 10.0

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Teleprompter")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Enable automatic migration
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
