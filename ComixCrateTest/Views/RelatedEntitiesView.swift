//
//  RelatedEntitiesView.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 10/8/23.
//

import SwiftUI

struct RelatedEntitiesView: View {
    @FetchRequest(fetchRequest: BookStoryArcs.sortedByNameFetchRequest)
    var allBookStoryArcsByName: FetchedResults<BookStoryArcs>
    
    @FetchRequest(fetchRequest: BookSeries.sortedBySeriesFetchRequest)
    var allSeriesByName: FetchedResults<BookSeries>
    
    func relatedBooks(for arc: BookStoryArcs) -> String {
        let joins = arc.joinStoryArc?.allObjects as? [JoinStoryArc] ?? []
        let sortedJoins = joins.sorted { ($0.book?.issueNumber ?? 0) < ($1.book?.issueNumber ?? 0) }
        let titlesWithParts = sortedJoins.map { "Part \($0.storyArcPart) - \($0.book?.title ?? "Unknown")" }
        return titlesWithParts.joined(separator: ", ")
    }
    
    var body: some View {
        List {
            Section(header:
                        HStack {
                            Image(systemName: "sparkles.rectangle.stack.fill")
                            Text("Story Arcs on Books")
                        }
            ) {
                ForEach(allBookStoryArcsByName) { arc in
                    VStack(alignment: .leading) {
                        Text("Story Arc Name: \(arc.name ?? "Unknown")")
                        Text("Related Books: \(relatedBooks(for: arc))")
                    }
                    .foregroundStyle(.black)
                }
            }
            Section(header:
                        HStack {
                Image(systemName: "sparkles.rectangle.stack.fill")
                Text("All Story Arcs")
            }
            ){
                ForEach(allBookStoryArcsByName) { arc in
                    VStack(alignment: .leading) {
                        Text(arc.name ?? "Unknown")
                    }
                    .foregroundStyle(.black)
                }
            }
            Section(header: 
                        HStack {
                Image(systemName: "rectangle.stack.fill")
                Text("Series")
            }) {
                ForEach(allSeriesByName) { series in
                    VStack(alignment: .leading) {
                        Text(series.name ?? "Unknown")
                    }
                    .foregroundStyle(.black)
                }
            }
        }
    }
}


#Preview {
    RelatedEntitiesView()
}
