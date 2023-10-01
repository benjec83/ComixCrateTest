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
                    ForEach(allBooksBySeriesIssueNumber) { book in
                        Button(action: {
                            selectedBook = book
                            activeSheet = .editBook(book)
                            
                        }) {
                            VStack(alignment: .leading) {
                                Text("Title: \(book.title ?? "Unknown")")
                                Text("Issue Number: \(book.issueNumber)")
                                Text("Story Arcs: \(storyArcs(for: book))")
                                Text("Series: \(book.bookSeries?.name ?? "Unknown")")
                            }
                            .foregroundStyle(.black)
                        }
                    }
                    .onDelete(perform: deleteComic)
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
        }
    }
    
    func storyArcs(for book: Books) -> String {
        let arcsWithParts = book.joinStoryArcs?.compactMap { joinArc -> String? in
            if let arc = joinArc as? JoinStoryArc {
                return "\(arc.storyArc?.name ?? "") \(arc.storyArcPart)"
            }
            return nil
        } ?? []
        return arcsWithParts.joined(separator: ", ")
    }
    
    func relatedBooks(for arc: BookStoryArcs) -> String {
        let books = arc.joinStoryArc?.compactMap { ($0 as? JoinStoryArc)?.book } ?? []
        let sortedBooks = books.sorted { $0.issueNumber < $1.issueNumber }
        let titles = sortedBooks.map { $0.title ?? "Unknown" }
        return titles.joined(separator: ", ")
    }
    
    func deleteComic(at offsets: IndexSet) {
        for index in offsets {
            let book = allBooksBySeriesIssueNumber[index]
            
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
            
            // Optionally, check if any story arcs no longer have associated books and delete them
            for storyArc in allBookStoryArcsByName {
                if storyArc.joinStoryArc?.count == 0 {
                    moc.delete(storyArc)
                }
            }
            
            do {
                try moc.save()
                moc.refreshAllObjects()
            } catch {
                print(error.localizedDescription)
                print("FAILED!!")
            }
        }
    }
}
