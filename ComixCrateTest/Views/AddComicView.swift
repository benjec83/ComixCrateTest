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
    
    @FetchRequest(entity: Books.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Books.title, ascending: true)])
    var allBooks: FetchedResults<Books>
    
    @FetchRequest(entity: BookSeries.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \BookSeries.name, ascending: true)])
    var allSeries: FetchedResults<BookSeries>
    @FetchRequest(entity: BookLocations.entity(), sortDescriptors: [])
    var bookLocations: FetchedResults<BookLocations>
    
    @State private var title = ""
    @State private var issueNumber = ""
    @State private var series = ""
    @State private var joinStoryArc = ""
    @State private var storyArcs: [String] = []

    

    @State private var showSeriesSuggestions = false
    @State private var filteredSeries: [BookSeries] = []
    
    init(initialSeries: String = "") {
        _series = State(initialValue: initialSeries)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title of comic", text: $title)
                    TextField("Issue Number", text: $issueNumber)
                    
                    TextField("Series", text: $series)
                        .onChange(of: series) {
                            filteredSeries = allSeries.filter { $0.name?.lowercased().contains(series.lowercased()) ?? false }
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
                    TextField("Story Arc", text: $joinStoryArc)

                    List {
                        ForEach(storyArcs.indices, id: \.self) { index in
                            TextField("Story Arc \(index + 1)", text: $storyArcs[index])
                        }
                        .onDelete(perform: removeStoryArc)
                    }
                    HStack {
                        Button("Add Story Arc") {
                            storyArcs.append("")
                        }
                        Button("Remove Last Story Arc") {
                            if !storyArcs.isEmpty {
                                storyArcs.removeLast()
                            }
                        }

                    }
                    
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button("Save") {
                            let newBook = Books(context: moc)
                            newBook.id = UUID()
                            newBook.title = title
                            newBook.issueNumber = Int16(issueNumber) ?? 0
                            
                            // Fetch or create the BookSeries entity
                            let fetchRequest: NSFetchRequest<BookSeries> = BookSeries.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "name == %@", series)
                            
                            if let existingSeries = try? moc.fetch(fetchRequest).first {
                                newBook.bookSeries = existingSeries
                            } else {
                                let newSeries = BookSeries(context: moc)
                                newSeries.name = series
                                newBook.bookSeries = newSeries
                            }
                            
                            for arcName in storyArcs {
                                // Fetch or create the BookStoryArc entity
                                let storyArcFetchRequest: NSFetchRequest<BookStoryArcs> = BookStoryArcs.fetchRequest()
                                storyArcFetchRequest.predicate = NSPredicate(format: "name == %@", arcName)

                                if let existingStoryArc = try? moc.fetch(storyArcFetchRequest).first {
                                    // If the story arc already exists, create a JoinStoryArc relationship
                                    let join = JoinStoryArc(context: moc)
                                    join.book = newBook
                                    join.storyArc = existingStoryArc
                                } else {
                                    // If the story arc doesn't exist, create it and then create a JoinStoryArc relationship
                                    let newStoryArc = BookStoryArcs(context: moc)
                                    newStoryArc.name = arcName
                                    
                                    let join = JoinStoryArc(context: moc)
                                    join.book = newBook
                                    join.storyArc = newStoryArc
                                }
                            }

                         
                            if moc.hasChanges {
                                try? moc.save()
                                print("Changes have Been Saved")
                            } else {
                                print("No Changes to Save")
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
        
        return AddComicView(initialSeries: "Sample") // Replace "Sample Series Name" with a series name from your sample data
            .environment(\.managedObjectContext, previewContext)
    }
}



