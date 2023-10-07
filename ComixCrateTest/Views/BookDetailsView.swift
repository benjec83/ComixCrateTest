//
//  BookDetailsView.swift
//  ComixCrateTestTest
//
//  Created by Ben Carney on 9/16/23.
//

import SwiftUI
import CoreData

struct BookDetailsView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var viewModel: EditBookViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image("P00001")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                .shadow(radius: 4)
                Spacer()
            }
            VStack(alignment: .leading) {
                Text("#\(viewModel.tempIssueNumber) - \(viewModel.tempTitle)")
                Text("Story Arcs: \(storyArcs(for: viewModel.book))")
                    .truncationMode(/*@START_MENU_TOKEN@*/.tail/*@END_MENU_TOKEN@*/)
                    .lineLimit(/*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                Text("Series: \(viewModel.tempSeries)")
                    .truncationMode(/*@START_MENU_TOKEN@*/.tail/*@END_MENU_TOKEN@*/)
                    .lineLimit(/*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            }
            .foregroundStyle(.black)
            .multilineTextAlignment(.leading)


        }
        .frame(height: 250)
        
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
}


struct BookDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        // Fetch a sample book from the preview context
        let sampleBook = try! NSManagedObjectContext.preview.fetch(Books.fetchRequest()).first!
        
        // Initialize the EditBookViewModel with the sample book
        let viewModel = EditBookViewModel(book: sampleBook, moc: NSManagedObjectContext.preview)
        
        // Use the sample book and view model in the BookDetailsView preview
        BookDetailsView(viewModel: viewModel)
    }
}


