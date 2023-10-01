//
//  EditComic.swift
//  ComixCrateTestTest
//
//  Created by Ben Carney on 9/23/23.
//

import SwiftUI
import CoreData

struct EditComic: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var viewModel: EditBookViewModel

    @Environment(\.dismiss) var dismiss
    
    @Binding var book: Books?
    @State private var showChangesAlert = false

    
    @Binding var activeViews: [Books]
    
    init(book: Binding<Books?>,activeViews: Binding<[Books]>, viewModel: EditBookViewModel) {
        _book = book

        _activeViews = activeViews
        self.viewModel = viewModel
        print("EditComic init completed")
    }
  
    
    
    var body: some View {
        
        Form {
            Section {
                Text("Title")
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
                TextField("Add Title", text: $viewModel.tempTitle)
                Text("Issue Number")
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
                TextField("Add Issue Number", text: $viewModel.tempIssueNumber)
                Text("Series")
                        .font(.subheadline)
                        .foregroundStyle(Color.accentColor)
                TextField("Add Series", text: $viewModel.tempSeries)
            }
            
            Section(header: Text("Story Arcs")) {
                ForEach(viewModel.tempStoryArcs.indices, id: \.self) { index in
                    HStack {
                        TextField("Story Arc \(index + 1)", text: $viewModel.tempStoryArcs[index])
                        TextField("Story Arc Part \(index + 1)", value: $viewModel.tempStoryArcParts[index], format: .number)
                    }
                }
                .onDelete(perform: removeStoryArc)
                
                Button("Add Story Arc") {
                    viewModel.tempStoryArcs.append("")
                }
                .buttonStyle(.borderedProminent)
            }

            Section {
                HStack(alignment: .center) {
                    Spacer()
                    Button("Save") {
                        viewModel.saveChanges()
                        if viewModel.isSaveComplete {
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    
                    Button("Cancel") {
                        if viewModel.discardChanges() {
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
        
        .alert(isPresented: $showChangesAlert) {
            Alert(
                title: Text("Unsaved Changes"),
                message: Text("You have unsaved changes. Do you want to discard them?"),
                primaryButton: .destructive(Text("Discard Changes")) {
                    moc.rollback()
                    dismiss()
                },
                secondaryButton: .cancel(Text("Continue Editing"))
            )
        }
        .onAppear {
            print("EditComic View appears")
            print("Book title: \(book?.title ?? "nil")")
            print("Book issue number: \(book?.issueNumber ?? 0)")
            print("Book series: \(book?.bookSeries?.name ?? "nil")")
            
            // Debugging statements
            print("ViewModel - Title: \(viewModel.tempTitle), Issue Number: \(viewModel.tempIssueNumber), Series: \(viewModel.tempSeries)")
            print("Original Book - Title: \(book?.title ?? "nil"), Issue Number: \(String(book?.issueNumber ?? 0)), Series: \(book?.bookSeries?.name ?? "nil")")
        }

        .navigationTitle(Text(book?.title ?? "Edit This Book"))
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    func removeStoryArc(at offsets: IndexSet) {
        viewModel.tempStoryArcs.remove(atOffsets: offsets)
    }
}
