import SwiftUI
import CoreData

struct ScriptEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var script: Script
    
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var showingSettings = false
    @State private var isPlaying = false
    @State private var scrollPosition: CGFloat = 0
    @State private var scrollTimer: Timer?
    @State private var showingFloatingWindow = false
    
    init(script: Script) {
        self.script = script
        _editedTitle = State(initialValue: script.title ?? "")
        _editedContent = State(initialValue: script.content ?? "")
    }
    
    var body: some View {
        ZStack {
            VStack {
                if isEditing {
                    Form {
                        TextField("Title", text: $editedTitle)
                        TextEditor(text: $editedContent)
                            .frame(height: 300)
                    }
                    .navigationBarItems(
                        trailing: Button("Save") {
                            saveChanges()
                        }
                    )
                } else {
                    ScrollView {
                        Text(script.content ?? "")
                            .font(.system(size: CGFloat(script.fontSize)))
                            .padding()
                            .offset(y: scrollPosition)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isPlaying {
                                    scrollPosition += value.translation.height
                                }
                            }
                    )
                }
                
                HStack {
                    Button(action: { isEditing.toggle() }) {
                        Image(systemName: isEditing ? "play.fill" : "pencil")
                    }
                    
                    Button(action: { showingSettings.toggle() }) {
                        Image(systemName: "gear")
                    }
                    
                    if !isEditing {
                        Button(action: { resetScroll() }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        
                        Button(action: { scrollBackward() }) {
                            Image(systemName: "backward.fill")
                        }
                        
                        Button(action: { togglePlayback() }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        }
                        
                        Button(action: { scrollForward() }) {
                            Image(systemName: "forward.fill")
                        }
                        
                        Button(action: { showingFloatingWindow.toggle() }) {
                            Image(systemName: "pip.enter")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(isEditing ? "Edit Script" : (script.title ?? ""))
            .sheet(isPresented: $showingSettings) {
                SettingsView(script: script)
            }
            
            if showingFloatingWindow {
                FloatingScriptView(script: script, isVisible: $showingFloatingWindow)
            }
        }
    }
    
    private func saveChanges() {
        script.title = editedTitle
        script.content = editedContent
        script.updatedAt = Date()
        
        do {
            try viewContext.save()
            isEditing = false
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func resetScroll() {
        withAnimation {
            scrollPosition = 0
        }
    }
    
    private func scrollBackward() {
        withAnimation {
            scrollPosition += 100
        }
    }
    
    private func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startScrolling()
        } else {
            stopScrolling()
        }
    }
    
    private func startScrolling() {
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                scrollPosition -= CGFloat(script.scrollSpeed)
                
                // Check if we've scrolled past the content height
                let contentHeight = (script.content ?? "").height(withConstrainedWidth: UIScreen.main.bounds.width - 40, font: .systemFont(ofSize: CGFloat(script.fontSize)))
                if scrollPosition < -contentHeight {
                    scrollPosition = 0
                }
            }
        }
    }
    
    private func stopScrolling() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }
    
    private func scrollForward() {
        withAnimation {
            scrollPosition -= 100
        }
    }
}

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var script: Script
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display Settings")) {
                    HStack {
                        Text("Font Size")
                        Slider(value: $script.fontSize, in: 10...100, step: 1)
                        Text("\(Int(script.fontSize))")
                    }
                    
                    HStack {
                        Text("Scroll Speed")
                        Slider(value: $script.scrollSpeed, in: 10...100, step: 1)
                        Text(String(format: "%.1f", script.scrollSpeed))
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
} 
