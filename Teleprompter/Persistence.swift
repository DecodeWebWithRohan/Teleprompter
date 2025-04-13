//
//  Persistence.swift
//  Teleprompter
//
//  Created by Rohan Roy - Personal on 05/04/25.
//

import Foundation
import SwiftData

@MainActor
public class PersistenceController {
    public static let shared = PersistenceController()

    public let modelContainer: ModelContainer

    var context: ModelContext {
        modelContainer.mainContext
    }

    public init() {
        let schema = Schema([Script.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            let count = try context.fetchCount(FetchDescriptor<Script>())
            if count == 0 {
                insertSampleScript()
            }
            try context.save()
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    private func insertSampleScript() {
        let newScript = Script(
            id: UUID().uuidString,
            title: "Sample Script",
            content: """
                Welcome to your teleprompter! This is a sample script to help you get started.

                This text will scroll smoothly on your screen, allowing you to read naturally while recording.
                You can adjust the scroll speed and font size to match your speaking pace and comfort.

                Try moving this window around, resizing it, or locking it in place.
                Use the play/pause button to control scrolling, and the forward/back buttons to adjust position.

                When you're ready, create your own script by tapping the + button on the main screen.
                Happy recording!
                """,
            createdAt: Date(),
            updatedAt: Date(),
            fontSize: 30.0,
            scrollSpeed: 10.0
        )
        context.insert(newScript)
    }
}
