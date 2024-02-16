//
//  LibraryView.swift
//  ComixCrateTestTest
//
//  Created by Ben Carney on 9/16/23.
//

import SwiftUI
import CoreData

enum ActiveSheet: Identifiable {
    case editBook(Books)
    case addComic
    case bookDetails
    
    var id: Int {
        switch self {
        case .editBook:
            return 0
        case .addComic:
            return 1
        case .bookDetails:
            return 2
        }
    }
}

struct LibraryView: View {
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(fetchRequest: Books.sortedBySeriesIssueFetchRequest)
    var allBooksBySeriesIssueNumber: FetchedResults<Books>
    
    @FetchRequest(fetchRequest: BookStoryArcs.sortedByNameFetchRequest)
    var allBookStoryArcsByName: FetchedResults<BookStoryArcs>
    
    @FetchRequest(fetchRequest: BookSeries.sortedBySeriesFetchRequest)
    var allSeriesByName: FetchedResults<BookSeries>
    
    @State private var activeViews: [Books] = []
    @State private var selectedBook: Books? = nil
    @State private var isEditMode: Bool = false
    @State private var activeSheet: ActiveSheet?
    
    // Table View Properties
    @State private var tableSelectedBook = Set<Books.ID>()
    
    @State private var isSelecting: Bool = false
    @State private var viewType: String = "gallery"

    // Grid View Properties
    private let spacing: CGFloat = 10
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 180))]
    }

    var body: some View {
        NavigationStack {
            VStack {
                Section {
                    VStack {
                        content
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .addComic
                    } label: {
                        Label("Add Book", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink(destination: RelatedEntitiesView()) {
                        Label("Related Entities", systemImage: "list.bullet.rectangle.fill")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    toolbarContent
                }
                
            }
            .navigationTitle("Library")
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .editBook(let book):
                    let viewModel = SelectedBookViewModel(book: book, moc: moc)
                    EditComic(book: $selectedBook, activeViews: $activeViews, viewModel: viewModel)
                case .addComic:
                    AddComicView()
                case .bookDetails:
                    BookDetailsView(book: $selectedBook, activeSheet: $activeSheet) // Pass activeSheet here
                }
            }
        }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var content: some View {
        if allBooksBySeriesIssueNumber.isEmpty {
            emptyLibraryContent
        } else {
            if viewType == "gallery" {
                galleryViewContent
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: viewType)
            } else if viewType == "table" {
                tableViewContent
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: viewType)
            } else {
                listViewContent
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: viewType)
            }
        }
    }
    
    // If there are no books in the library
    
    private var emptyLibraryContent: some View {
        VStack {
            Text("Please Import Books to Your Library")
            Button(action: {
                activeSheet = .addComic
            }, label: {
                Image(systemName: "plus.circle.fill")
            })
        }
    }
    
    // Grid and List View configurations
    
    private var galleryViewContent: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: gridItems, spacing: spacing) {
                ForEach(allBooksBySeriesIssueNumber, id: \.self) { book in
                    bookTile(for: book)
                }
            }
        }
    }
    
    private func bookTile(for book: Books) -> some View {
        let viewModel = SelectedBookViewModel(book: book, moc: moc)
        return BookTileView(viewModel: viewModel)
            .contextMenu {
                Button(action: {
                    selectedBook = book
                    activeSheet = .bookDetails
                }, label: {
                    Label("Information", systemImage: "info")
                })
                Button(action: {
                    selectedBook = book
                    activeSheet = .editBook(book)
                    isEditMode = true
                }) {
                    Label("Edit Book", systemImage: "pencil")
                }
                Button(action: {
                    // Handle the action for marking the book as read
                    // You can add your logic here
                }) {
                    Label("Mark as Read", systemImage: "book.closed")
                }
                Divider()
                Button(role: .destructive, action: {
                    // Handle the action for deleting the book
                    deleteSpecificBook(book: book)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
            .onTapGesture {
                selectedBook = book
                activeSheet = .bookDetails
            }
            .onTapGesture(count: 2) {
                print("Open Reader")
            }
            .cornerRadius(5)
    }
    
    private var tableViewContent: some View {
        Table(allBooksBySeriesIssueNumber, selection: $tableSelectedBook) {
            TableColumn("#") { book in
                Text("\(book.issueNumber)")
            }
            .width(max: 30)
            
            TableColumn("Title") { book in
                Text(book.title ?? "Unknown")
            }
            .width(max: 250)
            
            TableColumn("Series") { book in
                Text(book.bookSeries?.name ?? "Unknown")
            }
            .width(max: 250)
            
            TableColumn("Story Arcs") { book in
                Text(storyArcs(for: book))
                    .truncationMode(/*@START_MENU_TOKEN@*/.tail/*@END_MENU_TOKEN@*/)
            }
            let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter
            }()
            TableColumn("Date Released") { book in
                if let releaseDate = book.releaseDate {
                    Text(dateFormatter.string(from: releaseDate))
                } else {
                    Text("Unknown")
                }
            }
            .width(max: 120)
            TableColumn("Cover Date") { book in
                if let coverDate = book.coverDate {
                    Text(dateFormatter.string(from: coverDate))
                } else {
                    Text("Unknown")
                }
            }
            .width(max: 120)
            TableColumn("Purchased Date") { book in
                if let purchaseDate = book.purchaseDate {
                    Text(dateFormatter.string(from: purchaseDate))
                } else {
                    Text("Unknown")
                }
                
            }
            .width(max: 120)
        }
        .onTapGesture {
            if let selected = tableSelectedBook.first,
               let tappedBook = allBooksBySeriesIssueNumber.first(where: { $0.id == selected }) {
                selectedBook = tappedBook
                activeSheet = .bookDetails
            }
        }
        .onTapGesture(count: 2) {
            print("Open Reader")
        }
        .onLongPressGesture {
            if let selected = tableSelectedBook.first,
               let tappedBook = allBooksBySeriesIssueNumber.first(where: { $0.id == selected }) {
                selectedBook = tappedBook
                activeSheet = .editBook(tappedBook)
                isEditMode = true
                
            }
        }
    }
    
    func storyArcs(for book: Books) -> String {
        let joins = book.joinStoryArcs?.allObjects as? [JoinStoryArc] ?? []
        let sortedJoins = joins.sorted { ($0.storyArcPart) > ($1.storyArcPart) }
        let arcsWithParts = sortedJoins.map { "Part \($0.storyArcPart) - \($0.storyArc?.name ?? "Unknown")" }
        return arcsWithParts.joined(separator: ", ")
    }
    
    
    private var listViewContent: some View {
        List {
            ForEach(allBooksBySeriesIssueNumber) { book in
                let viewModel = SelectedBookViewModel(book: book, moc: moc)
                BookRow(viewModel: viewModel)
                    .foregroundStyle(.black)
                    .onTapGesture {
                        selectedBook = book
                        activeSheet = .bookDetails
                    }
                    .swipeActions(edge: .leading) {
                        Button(action: {
                            selectedBook = book
                            activeSheet = .editBook(book)
                            isEditMode = true
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive, action: {
                            // Handle your delete action here
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .onDelete(perform: { offsets in
                for index in offsets {
                    let bookToDelete = allBooksBySeriesIssueNumber[index]
                    let viewModel = SelectedBookViewModel(book: bookToDelete, moc: moc)
                    viewModel.deleteBook()
                }
            })
        }
    }

    
    private var toolbarContent: some View {
        HStack {
            if isSelecting {
                //                deleteButton
                //                doneButton
            } else {
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
    private var filterButton: some View {
        Menu {
            Section("View") {
                Button(action: {
                    viewType = "gallery"
                }) {
                    HStack {
                        if viewType == "gallery" {
                            Image(systemName: "checkmark")
                                .imageScale(.small)
                        }
                        Text("Gallery")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        Spacer()
                        Image(systemName: "square.grid.2x2")
                            .imageScale(.small)
                    
                }
                Button(action: {
                    viewType = "list"
                }) {
                    HStack {
                        if viewType == "list" {
                            Image(systemName: "checkmark")
                                .imageScale(.small)
                        }
                        Text("List")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Image(systemName: "line.3.horizontal")
                            .imageScale(.small)
                    }
                }
                Button(action: {
                    viewType = "table"
                }) {
                    HStack {
                        if viewType == "table" {
                            Image(systemName: "checkmark")
                                .imageScale(.small)
                        }
                        Text("Table")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Image(systemName: "table")
                            .imageScale(.small)
                    }
                }
            }
            Section("Filter By") {
                Button(action: {
                    // Filter by Author
                    // Implement your code to apply the Author filter
                }) {
                    Label("Author", systemImage: "person")
                }
                Button(action: {
                    // Filter by Series
                    // Implement your code to apply the Series filter
                }) {
                    Label("Series", systemImage: "book")
                }
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease")
        }
    }


    
    //    private var addBooksButton: some View {
    //        Button(action: {
    //            showingDocumentPicker.toggle()
    //        }) {
    //            Label("Add Books", systemImage: "plus.app")
    //        }
    //    }
    
    
    
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

