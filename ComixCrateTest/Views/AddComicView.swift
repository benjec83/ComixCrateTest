//
//  AddComicView.swift
//  ComixCrateTestTest
//
//  Created by Ben Carney on 9/16/23.
//

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
    
    @State private var book: Books?
    
    @State private var title = ""
    @State private var issueNumber = ""
    @State private var series = ""
    @State private var joinStoryArc = ""
    @State private var joinStoryArcPart: Int16 = 0
    @State private var storyArcs: [String] = []
    @State private var storyArcParts: [Int16] = []
    
    // Show Suggestions based on text field and existing entity values
    @State private var showSeriesSuggestions = false
    @State private var showStoryArcSuggestions = false

    @State private var filteredSeries: [BookSeries] = []
    @State private var filteredStoryArcs: [BookStoryArcs] = []
    
    init(book: Books? = nil) {
        _book = State(initialValue: book)
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
                            attachmentAnchor: .point(.bottomTrailing),
                            arrowEdge: .leading,
                            content: {
                                SuggestionPopover(header: "Choose an Existing Series", filter: filteredSeries.map { $0.name ?? "" }, selection: $series, showPopover: $showSeriesSuggestions)
                            }
                        )
                    

                }
                Section {
                    HStack {
                        TextField("Story Arc", text: $joinStoryArc)
                            .onChange(of: joinStoryArc) {
                                filteredStoryArcs = allStoryArcsByName.filter { $0.name?.lowercased().contains(joinStoryArc.lowercased()) ?? false }
                                showStoryArcSuggestions = !filteredStoryArcs.isEmpty && !joinStoryArc.isEmpty
                            }
                        
                            .popover(
                                isPresented: $showStoryArcSuggestions,
                                attachmentAnchor: .point(.bottomTrailing),
                                arrowEdge: .leading,
                                content: {
                                    SuggestionPopover(header: "Choose an Existing Story Arcs", filter: filteredStoryArcs.map { $0.name ?? "" }, selection: $joinStoryArc, showPopover: $showStoryArcSuggestions)
                                }
                        )
                        TextField("Story Arc Part", value: $joinStoryArcPart, format: .number)

                    }

                    List {
                        ForEach(storyArcs.indices, id: \.self) { index in
                            TextField("Story Arc \(index + 1)", text: $storyArcs[index])
                                .onChange(of: storyArcs[index]) { _ in
                                    filteredStoryArcs = allStoryArcsByName.filter { $0.name?.lowercased().contains(storyArcs[index].lowercased()) ?? false }
                                    showStoryArcSuggestions = !filteredStoryArcs.isEmpty && !storyArcs[index].isEmpty
                                }
                                .popover(
                                    isPresented: $showStoryArcSuggestions,
                                    attachmentAnchor: .point(.bottomTrailing),
                                    arrowEdge: .leading,
                                    content: {
                                        SuggestionPopover(header: "Choose an Existing Story Arcs", filter: filteredStoryArcs.map { $0.name ?? "" }, selection: Binding(get: { storyArcs[index] }, set: { storyArcs[index] = $0 }), showPopover: $showStoryArcSuggestions)
                                    }
                                )
                            TextField("Story Arc Part \(index + 1)", value: $storyArcParts[index], format: .number)

                        }
                        .onDelete(perform: removeStoryArc)
                    }

                    HStack {
                        Button("Add Story Arc") {
                            storyArcs.append("")
                            storyArcParts.append(0)                        }
                        .buttonStyle(.borderedProminent)
                        Button("Remove Last Story Arc") {
                            if !storyArcs.isEmpty {
                                storyArcs.removeLast()
                            }
                        }
                        .buttonStyle(.bordered)

                    }
                    
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button("Save") {
                            let viewModel: EditBookViewModel
                            if let existingBook = book {
                                viewModel = EditBookViewModel(book: existingBook, moc: moc)
                            } else {
                                let newBook = Books(context: moc)
                                viewModel = EditBookViewModel(book: newBook, moc: moc)
                            }
                            viewModel.tempTitle = title
                            viewModel.tempIssueNumber = issueNumber
                            viewModel.tempSeries = series
                            viewModel.tempStoryArcs = storyArcs
                            viewModel.tempStoryArcParts = storyArcParts
                            if isEditing {
                                viewModel.saveChanges()
                            } else {
                                viewModel.saveNewComic(joinStoryArc: joinStoryArc, joinStoryArcPart: joinStoryArcPart)
                            }
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        Button("Cancel") {
                            if moc.hasChanges {
                                showChangesAlert.toggle()
                            } else {
                                dismiss()
                            }
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                    }
                }
                
            }
            .navigationTitle("Add a New Comic")
            
        }
        
    }
    func removeStoryArc(at offsets: IndexSet) {
        storyArcs.remove(atOffsets: offsets)
    }

}

struct AddComicView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = NSManagedObjectContext.preview
        previewContext.populateSampleData()
        
        return AddComicView(/*initialSeries: "Sample"*/) // Replace "Sample Series Name" with a series name from your sample data
            .environment(\.managedObjectContext, previewContext)
    }
}
