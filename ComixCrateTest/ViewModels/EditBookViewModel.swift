//
//  EditBookViewModel.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/25/23.
//

import Foundation
import CoreData

class EditBookViewModel: ObservableObject {
    var moc: NSManagedObjectContext
    
    @Published var isSaveComplete: Bool = false
    
    @Published var tempTitle: String
    @Published var tempIssueNumber: String
    @Published var tempSeries: String
    
    var book: Books
    
    var hasChanges: Bool {
        
        return tempTitle != book.title ||
               Int16(tempIssueNumber) != book.issueNumber ||
               tempSeries != book.bookSeries?.name
    }

    
    init(book: Books, moc: NSManagedObjectContext) {

        self.book = book
        self.moc = moc
        
        // Initialize the viewModel's properties with the book's properties
        self.tempTitle = book.title ?? ""
        self.tempIssueNumber = String(book.issueNumber ?? 0)
        self.tempSeries = book.bookSeries?.name ?? ""
        
        // Debugging statement
        print("EditBookViewModel initialized with:")
        print("ViewModel - Title: \(tempTitle), Issue Number: \(tempIssueNumber), Series: \(tempSeries)")
        print("Original Book - Title: \(book.title ?? "nil"), Issue Number: \(String(book.issueNumber ?? 0)), Series: \(book.bookSeries?.name ?? "nil")")
    }

    
    func saveChanges() {
        if tempTitle != book.title {
            book.title = tempTitle
        }
        if let intValue = Int16(tempIssueNumber), intValue != book.issueNumber {
            book.issueNumber = intValue
        }
        
        // Fetch or create the BookSeries entity
        let fetchRequest: NSFetchRequest<BookSeries> = BookSeries.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", tempSeries)
        
        if let existingSeries = try? moc.fetch(fetchRequest).first {
            book.bookSeries = existingSeries
        } else {
            let newSeries = BookSeries(context: moc)
            newSeries.name = tempSeries
            book.bookSeries = newSeries
        }
        if moc.hasChanges {
            do {
                try moc.save()
                print("Changes have Been Saved")
                isSaveComplete = true
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("No Changes to Save")
        }
    }
    
    func discardChanges() -> Bool {
        // Debugging statements
        print("Checking for changes...")
        print("ViewModel - Title: \(tempTitle), Issue Number: \(tempIssueNumber), Series: \(tempSeries)")
        print("Original Book - Title: \(book.title ?? "nil"), Issue Number: \(String(book.issueNumber ?? 0)), Series: \(book.bookSeries?.name ?? "nil")")

        return tempTitle != book.title ||
               Int16(tempIssueNumber) != book.issueNumber ||
               tempSeries != book.bookSeries?.name
    }
}
