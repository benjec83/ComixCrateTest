//
//  EditBook.swift
//  ComixCrateTestTest
//
//  Created by Ben Carney on 9/23/23.
//

import SwiftUI
import CoreData

struct EditBook: View {
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
        print("EditBook init completed")
    }
        
    var body: some View {
        
        Form {
            Section {
                Text("Title")
                TextField("Add Title", text: $viewModel.tempTitle)
                Text("Issue Number")
                TextField("Add Issue Number", text: $viewModel.tempIssueNumber)
                Text("Series")
                TextField("Add Series", text: $viewModel.tempSeries)
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
            print("EditBook View appears")
            print("Book title: \(book?.title ?? "nil")")
            print("Book issue number: \(book?.issueNumber ?? 0)")
            print("Book series: \(book?.bookSeries?.name ?? "nil")")
            
            // Debugging statements
            print("ViewModel - Title: \(viewModel.tempTitle), Issue Number: \(viewModel.tempIssueNumber), Series: \(viewModel.tempSeries)")
            print("Original Book - Title: \(book?.title ?? "nil"), Issue Number: \(String(book?.issueNumber ?? 0)), Series: \(book?.bookSeries?.name ?? "nil")")
            print("Has Changes: \(viewModel.hasChanges)")
        }

        .navigationTitle(Text(book?.title ?? "Edit This Book"))
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
}

//struct EditBook_Previews: PreviewProvider {
//    @State static var dummyActiveViews: [Books] = []
//    
//    static var previews: some View {
//        let context = NSManagedObjectContext.preview
//        let book = Books(context: context)
//        book.title = "Sample Book Title"
//        book.issueNumber = 1
//        
//        let viewModel = EditBookViewModel(book: book, moc: context)
//        
//        return EditBook(book: <#Binding<Books?>#>, activeViews: $dummyActiveViews, viewModel: viewModel) // Removed the book argument
//            .environment(\.managedObjectContext, context)
//    }
//}


