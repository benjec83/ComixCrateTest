//
//  LibraryView.swift
//  ComixCrateTestTest
//
//  Created by Ben Carney on 9/16/23.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(fetchRequest: Books.sortedBySeriesIssueFetchRequest)
    var allBooksBySeriesIssueNumber: FetchedResults<Books>
    
    @FetchRequest(fetchRequest: BookStoryArcs.sortedByNameFetchRequest)
    var allBookStoryArcsByName: FetchedResults<BookStoryArcs>
    
    @FetchRequest(fetchRequest: BookSeries.sortedBySeriesFetchRequest)
    var allSeriesByName: FetchedResults<BookSeries>
    
    @State private var activeViews: [Books] = []
    @State private var selectedBook: Books?
    
    @State private var isSelecting: Bool = false
    @State private var isGalleryView: Bool = true
    
    // Grid View Properties
    private let spacing: CGFloat = 10
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 180))]
    }
    
    enum ActiveSheet: Identifiable {
        case editBook(Books)
        case addComic
        
        var id: Int {
            switch self {
            case .editBook:
                return 0
            case .addComic:
                return 1
            }
        }
    }
    
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Books")) {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: gridItems, spacing: spacing) {
                            ForEach(allBooksBySeriesIssueNumber, id: \.self) { book in
                                bookTile(for: book)
                                    .environmentObject(EditBookViewModel(book: book, moc: moc))
                            }

                        }
                    }
                }


                Section(header: Text("Story Arcs on Books")) {
                    ForEach(allBookStoryArcsByName) { arc in
                        VStack(alignment: .leading) {
                            Text("Story Arc Name: \(arc.name ?? "Unknown")")
                            Text("Related Books: \(relatedBooks(for: arc))")
                        }
                        .foregroundStyle(.black)
                    }
                }
                Section(header: Text("All Story Arcs")) {
                    ForEach(allBookStoryArcsByName) { arc in
                        VStack(alignment: .leading) {
                            Text(arc.name ?? "Unknown")
                        }
                        .foregroundStyle(.black)
                    }
                }
                Section(header: Text("Series")) {
                    ForEach(allSeriesByName) { series in
                        VStack(alignment: .leading) {
                            Text(series.name ?? "Unknown")
                        }
                        .foregroundStyle(.black)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .addComic
                    } label: {
                        Label("Add Book", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Library")
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .editBook(let book):
                    let viewModel = EditBookViewModel(book: book, moc: moc)
                    EditComic(book: $selectedBook, activeViews: $activeViews, viewModel: viewModel)
                case .addComic:
                    AddComicView()
                }
            }
            .onAppear {
                print("LibraryView appeared!")
            }
        }
    }
    
    // UI Func
    
    private var toolbarContent: some View {
        HStack {
            if isSelecting {
//                deleteButton
//                doneButton
            } else {
                toggleViewButton
                filterButton
//                addBooksButton
//                selectButton
//                deleteAllButton
            }
        }
    }
    
//    private var selectButton: some View {
//        Button(action: {
//            isSelecting.toggle()
//        }) {
//            Text("Select")
//        }
//    }
//    
//    private var deleteAllButton: some View {
//        Button(action: {
//            activeAlert = .deleteAll
//            showingAlert = true
//        }) {
//            Text("Delete All")
//                .foregroundColor(.red)
//        }
//    }
//    
//    private var deleteButton: some View {
//        Button(action: {
//            activeAlert = .deleteSelected
//            showingAlert = true
//        }) {
//            Image(systemName: "trash")
//                .foregroundColor(.red)
//        }
//    }
//    
//    private var doneButton: some View {
//        Button(action: {
//            isSelecting.toggle()
//            selectedBooks.removeAll()
//        }) {
//            Text("Done")
//        }
//    }
    
    private var toggleViewButton: some View {
        Button(action: {
            isGalleryView.toggle()
        }) {
            if isGalleryView {
                Label("List", systemImage: "line.3.horizontal")
            } else {
                Label("Gallery", systemImage: "square.grid.2x2")
            }
        }
    }
    
    private var filterButton: some View {
        Button(action: {
            // TODO: Implement filter action
        }) {
            Label("Filter", systemImage: "line.3.horizontal.decrease")
        }
    }
    
    // Grid and List View configurations
    
    private var listViewContent: some View {
        ForEach(allBooksBySeriesIssueNumber) { book in
            let viewModel = EditBookViewModel(book: book, moc: moc)
            BookDetailsView(viewModel: viewModel)
                .foregroundStyle(.black)
                .onTapGesture {
                    selectedBook = book
                    activeSheet = .editBook(book)
                }
        }
        .onDelete(perform: { offsets in
            for index in offsets {
                let bookToDelete = allBooksBySeriesIssueNumber[index]
                let viewModel = EditBookViewModel(book: bookToDelete, moc: moc)
                viewModel.deleteBook()
            }
        })
    }
        
//    private var addBooksButton: some View {
//        Button(action: {
//            showingDocumentPicker.toggle()
//        }) {
//            Label("Add Books", systemImage: "plus.app")
//        }
//    }
    
    private func bookTile(for book: Books) -> some View {
        let viewModel = EditBookViewModel(book: book, moc: moc)
        return BookDetailsView(viewModel: viewModel)
            .contextMenu {
                Button(action: {
                    // Handle the action for marking the book as read
                    // You can add your logic here
                }) {
                    Label("Mark as Read", systemImage: "book.closed")
                }
                
                Button(action: {
                    // Handle the action for deleting the book
                    deleteSpecificBook(book: book)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
            .onTapGesture {
                selectedBook = book
                activeSheet = .editBook(book)
            }
    }

    
    func relatedBooks(for arc: BookStoryArcs) -> String {
        let books = arc.joinStoryArc?.compactMap { ($0 as? JoinStoryArc)?.book } ?? []
        let sortedBooks = books.sorted { $0.issueNumber < $1.issueNumber }
        let titles = sortedBooks.map { $0.title ?? "Unknown" }
        return titles.joined(separator: ", ")
    }

    
    func deleteSpecificBook(book: Books) {
        // Handle the bookSeries relationship
        if let bookSeries = book.bookSeries {
            // Nullify the relationship
            book.bookSeries = nil
            
            // Check if the bookSeries has any remaining related books
            if bookSeries.book?.count == 0 {
                // If no related books, delete the bookSeries
                moc.delete(bookSeries)
            }
        }
        
        // Delete the book (this will also automatically delete related JoinStoryArc entities due to the cascade delete rule)
        moc.delete(book)
        
        do {
            try moc.save()
            moc.refreshAllObjects()
        } catch {
            print(error.localizedDescription)
            print("Failed to save changes!")
        }
        
        // Check if any BookStoryArcs no longer have associated JoinStoryArcs and delete them
        for storyArc in allBookStoryArcsByName {
            if storyArc.joinStoryArc?.count == 0 {
                moc.delete(storyArc)
                print("Deleted \(storyArc.name ?? "Unknown")")
            }
        }
        
        // Save the changes
        do {
            try moc.save()
            moc.refreshAllObjects()
        } catch {
            print(error.localizedDescription)
            print("Failed to save changes!")
        }
    }

}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
            .environment(\.managedObjectContext, NSManagedObjectContext.preview)
    }
}

