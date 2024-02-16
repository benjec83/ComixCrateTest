//
//  BookDetailsView.swift
//  ComixCrateTestTest
//
//  Created by Ben Carney on 9/16/23.
//

import SwiftUI
import CoreData

struct BookTileView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var viewModel: SelectedBookViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Spacer()
                //                Image("P00001")
                //                    .resizable()
                //                    .aspectRatio(contentMode: .fit)
                //
                //                    .cornerRadius(5.0)
                VStack {
                    Text("\(viewModel.tempSeries)")
                    Text("#\(viewModel.tempIssueNumber)")
                }
                .foregroundStyle(.white)
                .fixedSize(horizontal: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .multilineTextAlignment(.center)
                .padding()
                .frame(width: 150, height: 200)
                .background(Rectangle().fill(Color.accentColor))
                .cornerRadius(5)
                
                Spacer()
            }
            .shadow(color: .gray, radius: 4, x: 5, y: 5)
            
            
            VStack(alignment: .leading) {
                Text("#\(viewModel.tempIssueNumber) - \(viewModel.tempTitle)")
                    .font(.subheadline)
                
                Text("\(viewModel.tempSeries) (2016)")
                    .font(.caption)
                    .truncationMode(/*@START_MENU_TOKEN@*/.tail/*@END_MENU_TOKEN@*/)
            }
            .foregroundStyle(.black)
            .multilineTextAlignment(.leading)
            .lineLimit(/*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            
            
            
            Spacer()
        }
        .padding(5)
        .padding(.top, 10)
        
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


struct BookTileView_Previews: PreviewProvider {
    static var previews: some View {
        // Fetch a sample book from the preview context
        let sampleBook = try! NSManagedObjectContext.preview.fetch(Books.fetchRequest()).first!
        
        // Initialize the SelectedBookViewModel with the sample book
        let viewModel = SelectedBookViewModel(book: sampleBook, moc: NSManagedObjectContext.preview)
        
        // Use the sample book and view model in the BookDetailsView preview
        BookTileView(viewModel: viewModel)
    }
}


