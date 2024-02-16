//
//  BookDetailsTabsView.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 10/9/23.
//

import SwiftUI
import CoreData

struct BookDetailsView: View {
    @Environment(\.managedObjectContext) var moc
    
    @Binding var book: Books?
//    @Binding var isEditMode: Bool
    @Binding var activeSheet: ActiveSheet?
    
    var bookTitle: String {
        return "#" + "\(String(book!.issueNumber))" + " - " + "\(book!.title ?? book?.bookSeries?.name ?? "")"
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                BookMainDetails(book: $book)
                    .tabItem {
                        Image(systemName: "info")
                        Text("Overview")
                    }
                BookDetailsCreativesView(book: $book)
                    .tabItem {
                        Image(systemName: "photo.artframe")
                        Text("Creative Team")
                    }
                BookDetailsMoreView(book: $book)
                    .tabItem {
                        Image(systemName: "star")
                        Text("Details")
                    }
                BookDetailsLibraryView(book: $book)
                    .tabItem {
                        Image(systemName: "rectangle.grid.3x2")
                        Text("Collection")
                    }
            }
            .navigationTitle(bookTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .editBook(book!)
                    } label: {
                        Label("Edit Book", systemImage: "pencil")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Label("Favorite", systemImage: "star")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: {
                            
                        }) {
                            Label("Button 1", systemImage: "pencil")
                        }
                        Button(action: {
                            
                        }) {
                            Label("Button 2", systemImage: "pencil")
                        }
                        Divider()
                        Button(role: .destructive, action: {}) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
    }
}
struct BookMainDetails: View {
    @Environment(\.managedObjectContext) var moc
    
    @Binding var book: Books?
    
    var body: some View {
            ScrollView {
                HStack {
                    HStack {
                        Text("Thumbnail")
                    }
                    VStack {
                        BookMainDetailsBasics(book: $book)
                        BookMainDetailsSecondary(book: $book)
                        BookActionButtons(book: book)
                    }
                    .padding(.all)
                    .frame(width: 380)
                }
                .frame(width: 710)
                
                Divider()
                    .padding(.horizontal, 30.0)
                VStack(alignment: .leading) {
                    HStack {
                        Text("Summary:")
                            .fontWeight(.semibold)
                            .padding(.bottom, 5.0)
                        Spacer()
                    }
                    Text(book!.summary ?? "")
                }
                .font(.subheadline)
                .padding(.horizontal)
                .frame(maxWidth: 690)
            }
            
            .onAppear {
                print("This will be the caching of HighQualityThumbnail if needed")
                //            shouldCacheHighQualityThumbnail = true
            }
    }
}

struct BookDetailsCreativesView: View {
    @Environment(\.managedObjectContext) var moc
    
    @Binding var book: Books?
    
    public var body: some View {
        VStack {
            Text(book!.title ?? "Unknown Title")
            Text("Creatives")
        }
    }
}

struct BookDetailsMoreView: View {
    @Environment(\.managedObjectContext) var moc
    
    @Binding var book: Books?
    
    public var body: some View {
        VStack {
            Text(book!.title ?? "Unknown Title")
            Text("More Details")
        }
    }
}

struct BookDetailsLibraryView: View {
    @Environment(\.managedObjectContext) var moc
    
    @Binding var book: Books?
    
    public var body: some View {
        VStack {
            Text(book!.title ?? "Unknown Title")
            Text("Library")
        }
    }
}

struct BookMainDetailsBasics: View {
    @Environment(\.managedObjectContext) var moc
    
    @Binding var book: Books?
    
    @State private var editableSeriesName: String = ""
    @State private var editableVolumeYear: String = ""
    @State private var editableTitle: String = ""
    
    private var seriesName: String? {
        book!.bookSeries!.name
    }
    
    private var storyArcNames: [String] {
        guard let bookStoryArcSet = book!.joinStoryArcs as? Set<JoinStoryArc> else {
            return []
        }
        
        return bookStoryArcSet.compactMap { bookStoryArc in
            return bookStoryArc.storyArc?.name
        }
    }
    
    var body: some View {
        
            HStack {
                VStack(alignment: .leading) {
                    
                    Text("\(seriesName ?? "") (\(String(book?.volumeYear ?? 0000)))")
                        .font(.body)
                        .lineLimit(2)
                    Text("Story Arcs: \(storyArcNames.joined(separator: ", ").isEmpty ? "" : storyArcNames.joined(separator: ", "))")
                        .font(.caption)
                        .fontWeight(.light)
                        .lineLimit(1)
                }
            }
            
            .multilineTextAlignment(.leading)
            Spacer()
            
                .frame(width: 360)
        }
}
struct BookMainDetailsSecondary: View {
    
    @Binding var book: Books?
    
    var body: some View {
        HStack {
            detailSection(title: "Publisher", image: AnyView(FakePublisherLogo()))
            Divider()
            detailSection(title: "Released", mainText: book!.releaseDate?.yearString, subText: book!.releaseDate?.formattedString)
            Divider()
            detailSection(title: "Length", mainText: "\(book!.pageCount)", subText: "Pages")
        }
        .padding(.top)
        .frame(height: 65)
    }
    private func detailSection(title: String, image: AnyView? = nil, mainText: String? = nil, subText: String? = nil) -> some View {
        VStack {
            Text(title)
                .font(.subheadline)
            Spacer().frame(height: 1)
            if let imageView = image {
                imageView
                    .scaledToFit()
                    .frame(height: 40)
            } else {
                Text(mainText ?? "")
                Spacer().frame(height: 1)
                Text(subText ?? "")
                    .font(.caption)
            }
            Spacer()
        }
        .frame(width: 120)
    }
}


// MARK: Preview

struct BookDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = NSManagedObjectContext.preview
        let sampleBook = Books(context: context)
        sampleBook.title = "This is the New Book Title"
        sampleBook.issueNumber = 1
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if let date = dateFormatter.date(from: "10/06/2022") {
            sampleBook.releaseDate = date
        } else {
            print("Error: Couldn't convert string to date.")
        }
        sampleBook.pageCount = 64
        
        let sampleSeries = BookSeries(context: context)
        sampleSeries.name = "Sample Series"
        sampleBook.bookSeries = sampleSeries
        
        // Create a binding to the sampleBook
        let bookBinding = Binding<Books?>(
            get: { sampleBook },
            set: { _ in }
        )
        
        return BookDetailsView(book: bookBinding, activeSheet: .constant(nil))
            .previewLayout(.sizeThatFits)
            .environment(\.managedObjectContext, context)
    }
}



