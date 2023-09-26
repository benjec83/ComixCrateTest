//
//  AddComicView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/16/23.
//

import SwiftUI
import CoreData

struct AddComicView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    @State private var showChangesAlert: Bool = false
    
    @FetchRequest(entity: BookSeries.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \BookSeries.name, ascending: true)])
    var allSeries: FetchedResults<BookSeries>
    @FetchRequest(entity: BookLocations.entity(), sortDescriptors: [])
    var bookLocations: FetchedResults<BookLocations>
    
    @State private var title = ""
    @State private var issueNumber = ""
    @State private var series = ""
    @State private var showSeriesSuggestions = false
    @State private var filteredSeries: [BookSeries] = []
    
    init(initialSeries: String = "") {
        _series = State(initialValue: initialSeries)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title of comic", text: $title)
                    TextField("Issue Number", text: $issueNumber)
                    TextField("Series", text: $series)
                        .onChange(of: series) {
                            filteredSeries = allSeries.filter { $0.name?.lowercased().contains(series.lowercased()) ?? false }
                            showSeriesSuggestions = !filteredSeries.isEmpty && !series.isEmpty
                        }
                    
                    //                        .popover(
                    //                            isPresented: $showSeriesSuggestions,
                    //                            attachmentAnchor: .rect(.bounds), // anchor to the bounds of the TextField
                    //                            arrowEdge: .leading, // arrow on the trailing edge
                    //                            content: {
                    //                                VStack(spacing: 0) { // Set spacing to 0
                    //                                    Text("Choose an Existing Series")
                    //                                        .font(.headline)
                    //                                        .padding(.horizontal)
                    //                                        .padding(.vertical, 20) // Adjust vertical padding
                    //
                    //                                    List(filteredSeries, id: \.self) { currentSeries in
                    //                                        Text(currentSeries.name ?? "")
                    //                                            .onTapGesture {
                    //                                                series = currentSeries.name ?? ""
                    //                                                showSeriesSuggestions = false
                    //                                            }
                    //                                    }
                    //
                    //                                    .frame(height: min(max(CGFloat(filteredSeries.count) * 44 + 70, 100), 1000))
                    //                                }
                    //                                .frame(width: 400)
                    //                                .background(Color.white) // Set a background color
                    //                                .cornerRadius(10) // Round the corners
                    //                                .shadow(radius: 5) // Add a shadow
                    //                            }
                    //                        )
                    //
                    
                        .popover(
                            isPresented: $showSeriesSuggestions,
                            attachmentAnchor: .rect(.bounds),
                            arrowEdge: .leading,
                            content: {
                                SuggestionPopover(header: "Choose an Existing Series", filter: filteredSeries.map { $0.name ?? "" }, selection: $series, showPopover: $showSeriesSuggestions)
                            }
                        )

//                        .popover(
//                            isPresented: $showSeriesSuggestions,
//                            attachmentAnchor: .rect(.bounds),
//                            arrowEdge: .leading,
//                            content: {
//                                VStack(spacing: 0) {
//                                    Text("Choose an Existing Series")
//                                        .font(.headline)
//                                        .padding(.horizontal)
//                                        .padding(.vertical, 20)
//                                    
//                                    VStack(spacing: 0) { // This VStack will contain the items
//                                        ForEach(filteredSeries, id: \.self) { currentSeries in
//                                            Text(currentSeries.name ?? "")
//                                                .frame(width: 340, height: 44) // Set the height for each item
//                                                .padding(.horizontal) // Optional: Add horizontal padding if needed
//                                                .onTapGesture {
//                                                    series = currentSeries.name ?? ""
//                                                    showSeriesSuggestions = false
//                                                    
//                                                }
//                                                Divider()
//                                                    .frame(width: 320)
//                                                    .background(Color(UIColor.systemGroupedBackground))
//                                            
//                                        }
//                                        
//                                    }
//                                    .background(Color.white) // Background color for the VStack
//                                    .cornerRadius(10) // Round the corners
//                                }
//                                .padding(.bottom, 15.0)
//                                
//                                .frame(width: 400)
//                                .background(Color(UIColor.systemGroupedBackground)) // Background color for the VStack
//                                .cornerRadius(10)
//                                .shadow(radius: 5)
//                            }
//                        )
                    
                }
                Section {
                    Text("Some Text")
                    Text("Some more text")
                    
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button("Save") {
                            let newBook = Books(context: moc)
                            newBook.id = UUID()
                            newBook.title = title
                            newBook.issueNumber = Int16(issueNumber) ?? 0
                            
                            // Fetch or create the BookSeries entity
                            let fetchRequest: NSFetchRequest<BookSeries> = BookSeries.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "name == %@", series)
                            
                            if let existingSeries = try? moc.fetch(fetchRequest).first {
                                newBook.bookSeries = existingSeries
                            } else {
                                let newSeries = BookSeries(context: moc)
                                newSeries.name = series
                                newBook.bookSeries = newSeries
                            }
                            
                            if moc.hasChanges {
                                try? moc.save()
                                print("Changes have Been Saved")
                            } else {
                                print("No Changes to Save")
                            }
                            
                            dismiss()
                        }
                        
                        .buttonStyle(.borderedProminent)
                        Button("Cancel") {
                            if moc.hasChanges {
                                showChangesAlert.toggle()
                            } else {
                                dismiss()
                            }
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                    }
                }
                
            }
            .navigationTitle("Add a New Comic")
            
        }
        
    }
}

struct AddComicView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = NSManagedObjectContext.preview
        previewContext.populateSampleData()
        
        return AddComicView(initialSeries: "Sample") // Replace "Sample Series Name" with a series name from your sample data
            .environment(\.managedObjectContext, previewContext)
    }
}



