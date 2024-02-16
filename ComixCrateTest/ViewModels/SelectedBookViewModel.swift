//
//  SelectedBookViewModel.swift
//  ComixCrateTestTest
//
//  Created by Ben Carney on 9/25/23.
//

import Foundation
import CoreData

class SelectedBookViewModel: ObservableObject {
    var moc: NSManagedObjectContext
    
    @Published var isSaveComplete: Bool = false
    
    @Published var tempTitle: String
    @Published var tempIssueNumber: String
    @Published var tempSeries: String
    @Published var tempStoryArcs: [String] = []
    @Published var tempStoryArcParts: [Int16] = []
    @Published var originalStoryArcs: [String]
    @Published var tempReleasedDate: Date
    @Published var tempPurchaseDate: Date
    @Published var tempCoverDate: Date
    @Published var tempSummary: String
    
    var book: Books
    
    var hasChanges: Bool {
        return tempTitle != book.title ||
               Int16(tempIssueNumber) != book.issueNumber ||
               tempSeries != book.bookSeries?.name ||
        tempStoryArcParts != (book.joinStoryArcs?.compactMap { ($0 as? JoinStoryArc)?.storyArcPart } ?? [])
    }
    
    init(book: Books, moc: NSManagedObjectContext) {
        
        self.book = book
        self.moc = moc
        
        // Initialize the viewModel's properties with the book's properties
        self.tempTitle = book.title ?? ""
        self.tempIssueNumber = String(book.issueNumber)
        self.tempSeries = book.bookSeries?.name ?? ""
        
        // Initialize tempReleasedDate
        if let releaseDate = book.releaseDate {
            self.tempReleasedDate = releaseDate
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            self.tempReleasedDate = dateFormatter.date(from: "01/01/1900") ?? Date()
        }
        
        // Initialize the Purchased Date
        if let purchaseDate = book.purchaseDate {
            self.tempPurchaseDate = purchaseDate
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            self.tempPurchaseDate = dateFormatter.date(from: "01/01/1900") ?? Date()
        }
        
        // Initialize the Cover Date
        if let coverDate = book.coverDate {
            self.tempCoverDate = coverDate
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            self.tempCoverDate = dateFormatter.date(from: "01/01/1900") ?? Date()
        }
        
        self.tempSummary = book.summary ?? ""
        self.originalStoryArcs = book.joinStoryArcs?.compactMap { ($0 as? JoinStoryArc)?.storyArc?.name } ?? []
        self.tempStoryArcs = self.originalStoryArcs
        self.tempStoryArcParts = book.joinStoryArcs?.compactMap { ($0 as? JoinStoryArc)?.storyArcPart } ?? []
        
        
        // Debugging statement
        print("SelectedBookViewModel initialized with:")
        print("ViewModel - Title: \(tempTitle), Issue Number: \(tempIssueNumber), Series: \(tempSeries)")
        print("Original Book - Title: \(book.title ?? "nil"), Issue Number: \(String(book.issueNumber)), Series: \(book.bookSeries?.name ?? "nil")")
    }


    func saveStoryArcs(for book: Books, joinStoryArc: String, joinStoryArcPart: Int16) {
        // Add the initial story arc and its part to the arrays
        if !joinStoryArc.isEmpty {
            tempStoryArcs.insert(joinStoryArc, at: 0)
            tempStoryArcParts.insert(joinStoryArcPart, at: 0)
        }

        for (index, arcName) in tempStoryArcs.enumerated() {
            // Fetch or create the BookStoryArc entity
            let storyArcFetchRequest: NSFetchRequest<BookStoryArcs> = BookStoryArcs.fetchRequest()
            storyArcFetchRequest.predicate = NSPredicate(format: "name == %@", arcName)

            if let existingStoryArc = try? moc.fetch(storyArcFetchRequest).first {
                // If the story arc already exists, create a JoinStoryArc relationship
                let join = JoinStoryArc(context: moc)
                join.book = book
                join.storyArc = existingStoryArc
                join.storyArcPart = tempStoryArcParts[index] != 0 ? tempStoryArcParts[index] : 0  // Ensure it's set to 0 if blank
            } else {
                // If the story arc doesn't exist, create it and then create a JoinStoryArc relationship
                let newStoryArc = BookStoryArcs(context: moc)
                newStoryArc.name = arcName
                    
                let join = JoinStoryArc(context: moc)
                join.book = book
                join.storyArc = newStoryArc
                join.storyArcPart = tempStoryArcParts[index] != 0 ? tempStoryArcParts[index] : 0  // Ensure it's set to 0 if blank
            }
        }
    }


    func saveNewComic(joinStoryArc: String, joinStoryArcPart: Int16) {
        book.id = UUID()
        book.title = tempTitle
        book.issueNumber = Int16(tempIssueNumber) ?? 0
        
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

        saveStoryArcs(for: book, joinStoryArc: joinStoryArc, joinStoryArcPart: joinStoryArcPart)

        if moc.hasChanges {
            do {
                try moc.save()
                print("New Comic has been saved")
            } catch {
                print("Error saving new comic: \(error.localizedDescription)")
            }
        } else {
            print("No Changes to Save")
        }
    }

    
    func saveChanges() {
        if tempTitle != book.title {
            book.title = tempTitle
        }
        if let intValue = Int16(tempIssueNumber), intValue != book.issueNumber {
            book.issueNumber = intValue
        } else if tempIssueNumber.isEmpty {
            book.issueNumber = 0
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
        
        book.releaseDate = tempReleasedDate
        book.coverDate = tempCoverDate
        book.purchaseDate = tempPurchaseDate
        book.summary = tempSummary
        
        // Handle story arcs

        for (index, arcName) in tempStoryArcs.enumerated() {
            // Fetch the story arc from the database
            let arcFetchRequest: NSFetchRequest<BookStoryArcs> = BookStoryArcs.fetchRequest()
            arcFetchRequest.predicate = NSPredicate(format: "name == %@", arcName)
            
            if let existingArc = try? moc.fetch(arcFetchRequest).first {
                // If the story arc already exists, update it
                existingArc.name = arcName
                
                // Update the storyArcPart property of the corresponding JoinStoryArc relationship
                if let joinArc = book.joinStoryArcs?.first(where: { ($0 as? JoinStoryArc)?.storyArc?.name == arcName }) as? JoinStoryArc {
                    joinArc.storyArcPart = tempStoryArcParts[index]
                }
            } else {
                // If the story arc doesn't exist, create it and then create a JoinStoryArc relationship
                let newStoryArc = BookStoryArcs(context: moc)
                newStoryArc.name = arcName
                
                let join = JoinStoryArc(context: moc)
                join.book = book
                join.storyArc = newStoryArc
                join.storyArcPart = tempStoryArcParts[index]
            }
        }

        // Check and delete any BookStoryArcs entity that no longer has any related JoinStoryArcs
        let allStoryArcsFetchRequest: NSFetchRequest<BookStoryArcs> = BookStoryArcs.fetchRequest()
        if let allStoryArcs = try? moc.fetch(allStoryArcsFetchRequest) {
            for storyArc in allStoryArcs {
                if storyArc.joinStoryArc?.count == 0 {
                    moc.delete(storyArc)
                }
            }
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

    func deleteBook() {
        moc.delete(book)
        do {
            try moc.save()
        } catch {
            print("Failed to delete book: \(error.localizedDescription)")
        }
    }
    
    func discardChanges() -> Bool {
        // Debugging statements
        print("Checking for changes...")
        print("ViewModel - Title: \(tempTitle), Issue Number: \(tempIssueNumber), Series: \(tempSeries)")
        print("Original Book - Title: \(book.title ?? "nil"), Issue Number: \(String(book.issueNumber )), Series: \(book.bookSeries?.name ?? "nil")")

        return tempTitle != book.title ||
               Int16(tempIssueNumber) != book.issueNumber ||
               tempSeries != book.bookSeries?.name
    }
}
