//
//  BookDetailsTabsView.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 10/9/23.
//

import SwiftUI

struct BookDetailsView: View {
    @Environment(\.managedObjectContext) var moc
    @State private var selectedBook: Books?
    
    var body: some View {
        TabView {
            BookMainDetails()
                .tabItem {
                    Image(systemName: "info")
                    Text("Overview")
                }
            BookDetailsCreativesView()
                .tabItem {
                    Image(systemName: "photo.artframe")
                    Text("Creative Team")
                }
            BookDetailsMoreView()
                .tabItem {
                    Image(systemName: "star")
                    Text("Details")
                }
            BookDetailsLibraryView()
                .tabItem {
                    Image(systemName: "rectangle.grid.3x2")
                    Text("Collection")
                }
        }
    }
}

struct BookMainDetails: View {
    
    var body: some View {
        VStack {
            Text("Main Details View")
        }
    }
}

struct BookDetailsCreativesView: View {
    
    public var body: some View {
        VStack {
            Text("Creatives View")
        }
    }
}

struct BookDetailsMoreView: View {
    
    public var body: some View {
        VStack {
            Text("More Details View")
        }
    }
}

struct BookDetailsLibraryView: View {
    
    public var body: some View {
        VStack {
            Text("Library View")
        }
    }
}

#Preview {
    BookDetailsView()
}


//BookDetailsMainView(book: book, viewModel: viewModel)
//    .tabItem {
//        Image(systemName: "info")
//        Text("Information")
//    }
//BookDetailsCreativesView(book: book)
//    .tabItem {
//        Image(systemName: "photo.artframe")
//        Text("Creative Team")
//    }
//BookDetailsMoreView(book: book)
//    .tabItem {
//        Image(systemName: "star")
//        Text("Details")
//    }
//BookDetailsLibraryView(book: book)
