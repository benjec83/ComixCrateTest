import SwiftUI
import CoreData

struct AddComicView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State private var showChangesAlert: Bool = false
    @State private var isEditing: Bool = false
    
    @FetchRequest(fetchRequest:
                    BookSeries.sortedBySeriesFetchRequest)
    var allSeriesByName: FetchedResults<BookSeries>
    
    @FetchRequest(fetchRequest:
                    BookLocations.sortedByName)
    var allLocationsByName: FetchedResults<BookLocations>
    
    @FetchRequest(fetchRequest: BookStoryArcs.sortedByNameFetchRequest)
    var allStoryArcsByName: FetchedResults<BookStoryArcs>
    
    @State private var title = ""
    @State private var issueNumber = ""
    @State private var series = ""
    @State private var joinStoryArc = ""
    @State private var joinStoryArcPart: Int16 = 0
    @State private var storyArcs: [String] = []
    @State private var storyArcParts: [Int16] = []
    
    // Show Suggestions based on text field and existing entity values
    @State private var showSeriesSuggestions = false
    @State private var showStoryArcSuggestions: [Int: Bool] = [:]

    @State private var filteredSeries: [BookSeries] = []
    @State private var filteredStoryArcs: [BookStoryArcs] = []
    
    init(book: Books? = nil) {
        if let book = book {
            _title = State(initialValue: book.title ?? "")
            _issueNumber = State(initialValue: String(book.issueNumber))
            _series = State(initialValue: book.bookSeries?.name ?? "")
            isEditing = true
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title of comic", text: $title)
                    TextField("Issue Number", text: $issueNumber)
                    
                    TextField("Series", text: $series)
                        .onChange(of: series) {
                            filteredSeries = allSeriesByName.filter { $0.name?.lowercased().contains(series.lowercased()) ?? false }
                            showSeriesSuggestions = !filteredSeries.isEmpty && !series.isEmpty
                        }
                        .popover(
                            isPresented: $showSeriesSuggestions,
                            attachmentAnchor: .point(.center),
                            arrowEdge: .leading,
                            content: {
                                SuggestionPopover(header: "Choose an Existing Series", filter: filteredSeries.map { $0.name ?? "" }, selection: $series, showPopover: $showSeriesSuggestions)
                            }
                        )
                }
                Section(header: HStack {
                    Text("Story Arcs")
                    Spacer()
                    AddStoryArcButton(storyArcs: $storyArcs, storyArcParts: $storyArcParts)
                }) {
                    ForEach(storyArcs.indices, id: \.self) { index in
                        HStack {
                            TextField("Story Arc \(index + 1)", text: $storyArcs[index])
                                .onChange(of: storyArcs[index]) { oldValue, newValue in
                                    filteredStoryArcs = allStoryArcsByName.filter { $0.name?.lowercased().contains(newValue.lowercased()) ?? false }
                                    showStoryArcSuggestions[index] = !filteredStoryArcs.isEmpty && !newValue.isEmpty
                                }
                                .popover(
                                    isPresented: Binding<Bool>(
                                        get: { showStoryArcSuggestions[index] ?? false },
                                        set: { showStoryArcSuggestions[index] = $0 }
                                    ),
                                    attachmentAnchor: .point(.center),
                                    arrowEdge: .leading,
                                    content: {
                                        SuggestionPopover(
                                            header: "Choose an Existing Story Arcs",
                                            filter: filteredStoryArcs.map { $0.name ?? "" },
                                            selection: Binding<String>(
                                                get: { storyArcs[index] },
                                                set: { newValue in
                                                    storyArcs[index] = newValue
                                                    // Reset the popover state to false after selection to ensure it can be triggered again.
                                                    showStoryArcSuggestions[index] = false
                                                }
                                            ),
                                            showPopover: Binding<Bool>(
                                                get: { showStoryArcSuggestions[index] ?? false },
                                                set: { showStoryArcSuggestions[index] = $0 }
                                            )
                                        )
                                    }
                                )

                            TextField("Story Arc Part \(index + 1)", value: $storyArcParts[index], format: .number)
                        }
                    }
                    .onDelete(perform: removeStoryArc)
                }
                
                Section {
                    HStack(alignment: .center) {
                        Spacer()
                        Button("Save") {
                            saveComic()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Comic" : "Add a New Comic")
            .alert(isPresented: $showChangesAlert) {
                Alert(
                    title: Text("Unsaved Changes"),
                    message: Text("You have unsaved changes. Do you want to discard them?"),
                    primaryButton: .destructive(Text("Discard Changes")) {
                        dismiss()
                    },
                    secondaryButton: .cancel(Text("Continue Editing"))
                )
            }
        }
    }
    
    // Save the comic to Core Data
    private func saveComic() {
        let newComic = Books(context: moc)
        newComic.title = title
        newComic.issueNumber = Int16(issueNumber) ?? 0
        newComic.id = UUID()
        
        // Set the series if it exists, otherwise create a new series
        if let series = allSeriesByName.first(where: { $0.name == series }) {
            newComic.bookSeries = series
        } else {
            let newSeries = BookSeries(context: moc)
            newSeries.name = series
            newComic.bookSeries = newSeries
        }
        
        // Add story arcs
        for (index, arcName) in storyArcs.enumerated() {
            let storyArc = BookStoryArcs(context: moc)
            storyArc.name = arcName
            // Create JoinStoryArc entity and set its properties
            let joinStoryArc = JoinStoryArc(context: moc)
            joinStoryArc.storyArc = storyArc
            joinStoryArc.storyArcPart = storyArcParts[index]
            newComic.addToJoinStoryArcs(joinStoryArc) // Ensure addToJoinStoryArcs expects JoinStoryArc
        }
        
        do {
            try moc.save()
            dismiss()
        } catch {
            print("Failed to save comic: \(error)")
        }
    }

    // Example of adding a new story arc
    func addStoryArc() {
        let newIndex = storyArcs.count // Assuming you're appending to the end
        storyArcs.append("")
        storyArcParts.append(0)
        showStoryArcSuggestions[newIndex] = false // Initialize the state
    }

    // Example of removing a story arc
    func removeStoryArc(at offsets: IndexSet) {
        storyArcs.remove(atOffsets: offsets)
        storyArcParts.remove(atOffsets: offsets)
        // Also remove the corresponding states from the dictionary
        offsets.forEach { index in
            showStoryArcSuggestions.removeValue(forKey: index)
        }
    }
}

struct AddComicView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = NSManagedObjectContext.preview
        previewContext.populateSampleData()
        
        return AddComicView()
            .environment(\.managedObjectContext, previewContext)
    }
}
