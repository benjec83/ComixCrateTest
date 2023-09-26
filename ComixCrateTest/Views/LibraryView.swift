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
    
    @FetchRequest(entity: Books.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Books?.?.bookSeries?.name, ascending: true),
        NSSortDescriptor(keyPath: \Books.issueNumber, ascending: true)
    ])
    
    var books: FetchedResults<Books>
    
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
                ForEach(books) { book in
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
                    EditBook(book: $selectedBook, activeViews: $activeViews, viewModel: viewModel)
                case .addComic:
                    AddComicView()
                }
            }
        }
    }
    
    func storyArcs(for book: Books) -> String {
        let arcs = book.joinStoryArcs?.compactMap { ($0 as? JoinStoryArc)?.storyArc?.name } ?? []
        return arcs.joined(separator: ", ")
    }
    
    func deleteComic(at offsets: IndexSet) {
        for index in offsets {
            let book = books[index]
            
            // Check the bookSeries relationship of the book
            if let bookSeries = book.bookSeries {
                // Nullify the relationship
                book.bookSeries = nil
                
                // Check if the bookSeries has any remaining related books
                if bookSeries.book?.count == 0 {
                    // If no related books, delete the bookSeries
                    moc.delete(bookSeries)
                }
            }
            
            // Delete the book
            moc.delete(book)
            
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
