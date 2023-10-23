//
//  BookRowView.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 10/8/23.
//

import SwiftUI
import CoreData

struct BookRowView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var viewModel: EditBookViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            HStack(alignment: .center) {
                Text("#\(viewModel.tempIssueNumber) - \(viewModel.tempTitle)")
                    .font(.subheadline)
                Spacer()
                    .frame(width: 20)
                Text("\(viewModel.tempSeries) (2016)")
                    .font(.caption)
                    .truncationMode(/*@START_MENU_TOKEN@*/.tail/*@END_MENU_TOKEN@*/)
                Spacer()
            }
            .foregroundStyle(.black)
            .multilineTextAlignment(.leading)
            .lineLimit(/*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            Spacer()
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
}

struct BookRow_Previews: PreviewProvider {
    static var previews: some View {
        // Fetch a sample book from the preview context
        let sampleBook = try! NSManagedObjectContext.preview.fetch(Books.fetchRequest()).first!
        
        // Initialize the EditBookViewModel with the sample book
        let viewModel = EditBookViewModel(book: sampleBook, moc: NSManagedObjectContext.preview)
        
        // Use the sample book and view model in the BookDetailsView preview
        BookRowView(viewModel: viewModel)
    }
}
