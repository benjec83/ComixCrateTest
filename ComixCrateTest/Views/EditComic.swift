//
//  EditComic.swift
//  ComixCrateTestTest
//
//  Created by Ben Carney on 9/23/23.
//

import SwiftUI
import CoreData

struct EditComic: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var viewModel: SelectedBookViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var book: Books?
    @State private var showChangesAlert = false
    
    @Binding var activeViews: [Books]
    
    @FetchRequest(fetchRequest:
                    BookSeries.sortedBySeriesFetchRequest)
    var allSeriesByName: FetchedResults<BookSeries>
    
    @FetchRequest(fetchRequest:
                    BookLocations.sortedByName)
    var allLocationsByName: FetchedResults<BookLocations>
    
    @FetchRequest(fetchRequest: BookStoryArcs.sortedByNameFetchRequest)
    var allStoryArcsByName: FetchedResults<BookStoryArcs>
    
    // Show Suggestions based on text field and existing entity values
    @State private var showSeriesSuggestions = false
    @State private var showStoryArcSuggestions = false
    
    @State private var filteredSeries: [BookSeries] = []
    @State private var filteredStoryArcs: [BookStoryArcs] = []
    
    init(book: Binding<Books?>,activeViews: Binding<[Books]>, viewModel: SelectedBookViewModel) {
        _book = book
        
        _activeViews = activeViews
        self.viewModel = viewModel
        print("EditComic init completed")
    }
    
    
    
    var body: some View {
        
        Form {
            Section {
                Text("Title")
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
                TextField("Add Title", text: $viewModel.tempTitle)
                Text("Issue Number")
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
                TextField("Add Issue Number", text: $viewModel.tempIssueNumber)
                Text("Series")
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
                
                TextField("Add Series", text: $viewModel.tempSeries)
                    .onChange(of: viewModel.tempSeries) {
                        filteredSeries = allSeriesByName.filter { $0.name?.lowercased().contains(viewModel.tempSeries.lowercased()) ?? false }
                        showSeriesSuggestions = !filteredSeries.isEmpty && !viewModel.tempSeries.isEmpty
                    }
                    .popover(
                        isPresented: $showSeriesSuggestions,
                        attachmentAnchor: .point(.center),
                        arrowEdge: .leading,
                        content: {
                            SuggestionPopover(header: "Choose an Existing Series", filter: filteredSeries.map { $0.name ?? "" }, selection: $viewModel.tempSeries, showPopover: $showSeriesSuggestions)
                        }
                    )
            }
            
            Section(header: Text("Dates")) {
                DatePicker("Released Date", selection: $viewModel.tempReleasedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                DatePicker("Purchase Date", selection:  $viewModel.tempPurchaseDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                DatePicker("Cover Date", selection: $viewModel.tempCoverDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }
            
            Section(header:
                        HStack {
                Text("Story Arcs")
                Spacer()
                AddStoryArcButton(storyArcs: $viewModel.tempStoryArcs, storyArcParts: $viewModel.tempStoryArcParts)
            }
            ) {
                ForEach(viewModel.tempStoryArcs.indices, id: \.self) { index in
                    HStack {
                        TextField("Story Arc \(index + 1)", text: $viewModel.tempStoryArcs[index])
                            .onChange(of: viewModel.tempStoryArcs[index]) { (oldValue, newValue) in
                                filteredStoryArcs = allStoryArcsByName.filter { $0.name?.lowercased().contains(newValue.lowercased()) ?? false }
                                showStoryArcSuggestions = !filteredStoryArcs.isEmpty && !newValue.isEmpty
                                print("ShowStoryArcSuggestions: \($showStoryArcSuggestions.wrappedValue)")
                            }

                            .popover(
                                isPresented: $showStoryArcSuggestions,
                                attachmentAnchor: .point(.center),
                                arrowEdge: .leading,
                                content: {
                                    SuggestionPopover(header: "Choose an Existing Story Arcs", filter: filteredStoryArcs.map { $0.name ?? "" }, selection: Binding(get: { viewModel.tempStoryArcs[index] }, set: { viewModel.tempStoryArcs[index] = $0 }), showPopover: $showStoryArcSuggestions)
                                }
                            )
                        TextField("Story Arc Part \(index + 1)", value: $viewModel.tempStoryArcParts[index], format: .number)
                    }
                }
                .onDelete(perform: removeStoryArc)
            }
            Section(header: Text("Summary")) {
                TextField("Summary", text: $viewModel.tempSummary, axis: .vertical)
            }
            
            Section {
                HStack(alignment: .center) {
                    Spacer()
                    Button("Save") {
                        viewModel.saveChanges()
                        if viewModel.isSaveComplete {
                            dismiss()
                        }
                        
                    }
                    .buttonStyle(.borderedProminent)
                    
                    
                    Button("Cancel") {
                        if viewModel.discardChanges() {
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
        
        .alert(isPresented: $showChangesAlert) {
            Alert(
                title: Text("Unsaved Changes"),
                message: Text("You have unsaved changes. Do you want to discard them?"),
                primaryButton: .destructive(Text("Discard Changes")) {
                    moc.rollback()
                    dismiss()
                },
                secondaryButton: .cancel(Text("Continue Editing"))
            )
        }
        .onAppear {
            print("EditComic View appears")
            print("Book title: \(book?.title ?? "nil")")
            print("Book issue number: \(book?.issueNumber ?? 0)")
            print("Book series: \(book?.bookSeries?.name ?? "nil")")
            
            // Debugging statements
            print("ViewModel - Title: \(viewModel.tempTitle), Issue Number: \(viewModel.tempIssueNumber), Series: \(viewModel.tempSeries)")
            print("Original Book - Title: \(book?.title ?? "nil"), Issue Number: \(String(book?.issueNumber ?? 0)), Series: \(book?.bookSeries?.name ?? "nil")")
        }
        
        .navigationTitle(Text(book?.title ?? "Edit This Book"))
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    func removeStoryArc(at offsets: IndexSet) {
        for index in offsets {
            let arcName = viewModel.tempStoryArcs[index]
            
            // Fetch the story arc from the database
            let arcFetchRequest: NSFetchRequest<BookStoryArcs> = BookStoryArcs.fetchRequest()
            arcFetchRequest.predicate = NSPredicate(format: "name == %@", arcName)
            
            if let existingArc = try? moc.fetch(arcFetchRequest).first {
                // Check if there are any other related JoinStoryArcs
                if existingArc.joinStoryArc?.count == 1 {
                    // If not, delete the BookStoryArcs entity
                    moc.delete(existingArc)
                }
            }
            
            // Remove the JoinStoryArc relationship
            if let joinArcToDelete = book?.joinStoryArcs?.first(where: { ($0 as? JoinStoryArc)?.storyArc?.name == arcName }) as? JoinStoryArc {
                moc.delete(joinArcToDelete)
            }
        }
        
        viewModel.tempStoryArcs.remove(atOffsets: offsets)
        viewModel.tempStoryArcParts.remove(atOffsets: offsets)
    }
    
}

struct EditComic_Previews: PreviewProvider {
    static var previews: some View {
        let context = NSManagedObjectContext.preview
        let sampleBook = Books(context: context)
        sampleBook.title = "Sample Book"
        sampleBook.issueNumber = 1
        
        let sampleSeries = BookSeries(context: context)
        sampleSeries.name = "Sample Series"
        sampleBook.bookSeries = sampleSeries
        
        let viewModel = SelectedBookViewModel(book: sampleBook, moc: context)
        
        return EditComic(book: .constant(sampleBook), activeViews: .constant([sampleBook]), viewModel: viewModel)
            .environment(\.managedObjectContext, context)
    }
}

