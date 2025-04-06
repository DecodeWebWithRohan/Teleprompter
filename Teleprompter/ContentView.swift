//
//  ContentView.swift
//  Teleprompter
//
//  Created by Rohan Roy - Personal on 05/04/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddScript = false
    @State private var newScriptTitle = ""
    @State private var newScriptContent = ""

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Script.createdAt, ascending: false)],
        animation: .default)
    private var scripts: FetchedResults<Script>

    var body: some View {
        NavigationView {
            List {
                ForEach(scripts) { script in
                    NavigationLink {
                        ScriptEditorView(script: script)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(script.title ?? "")
                                .font(.headline)
                            Text((script.content ?? "").prefix(50) + "...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteScripts)
            }
            .navigationTitle("Scripts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { showingAddScript = true }) {
                        Label("Add Script", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddScript) {
                NavigationView {
                    Form {
                        TextField("Title", text: $newScriptTitle)
                        TextEditor(text: $newScriptContent)
                            .frame(height: 200)
                    }
                    .navigationTitle("New Script")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingAddScript = false
                        },
                        trailing: Button("Save") {
                            addScript()
                            showingAddScript = false
                        }
                    )
                }
            }
        }
    }

    private func addScript() {
        withAnimation {
            let newScript = Script(context: viewContext)
            newScript.id = UUID().uuidString
            newScript.title = newScriptTitle
            newScript.content = newScriptContent
            newScript.createdAt = Date()
            newScript.updatedAt = Date()
            newScript.fontSize = 30.0
            newScript.scrollSpeed = 10.0

            do {
                try viewContext.save()
                newScriptTitle = ""
                newScriptContent = ""
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteScripts(offsets: IndexSet) {
        withAnimation {
            offsets.map { scripts[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
