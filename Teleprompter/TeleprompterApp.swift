//
//  TeleprompterApp.swift
//  Teleprompter
//
//  Created by Rohan Roy - Personal on 05/04/25.
//

import SwiftUI

@main
struct TeleprompterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
