//
//  ContentView.swift
//  Teleprompter
//
//  Created by Rohan Roy - Personal on 05/04/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var viewContext
    @State private var showingAddScript = false
    @State private var newScriptTitle = ""
    @State private var newScriptContent = ""

    @Query(sort: \Script.title, animation: .default) private var scripts:
        [Script]

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
            let newScript = Script(
                id: UUID().uuidString,
                title: newScriptTitle,
                content: newScriptContent,
                createdAt: Date(),
                updatedAt: Date(),
                fontSize: 30.0,
                scrollSpeed: 10.0
            )

            viewContext.insert(newScript)

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
    ContentView().environment(
        \.modelContext,
        PersistenceController.shared.context
    )
}
