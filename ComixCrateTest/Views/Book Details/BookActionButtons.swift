//
//  BookActionButtons.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 10/11/23.
//

import SwiftUI
import CoreData

struct BookActionButtons: View {
    
    @Environment(\.managedObjectContext) var moc

    @Binding var book: Books?
    

    @State private var userRating: Double
    
    enum ActionTitle: String {
        case readNow = "Read Now"
        case markAsRead = "Mark As Read"
        case markAsUnread = "Mark As Unread"
        case addToReadingPile = "Add to Reading Pile"
    }
 
    init(book: Books?) {
        _book = .constant(book)
        if let book = book {
            _userRating = State(initialValue: Double(book.personalRating) / 2.0)
        } else {
            _userRating = State(initialValue: 0.0)
        }
    }

    var body: some View {
        VStack {
            Spacer()
            actionButton(title: .readNow, icon: "magazine")
            actionButton(title: book!.bookIsRead ? .markAsUnread : .markAsRead, icon: "checkmark.circle")
            actionButton(title: .addToReadingPile, icon: "square.stack.3d.up")
            Spacer()
            ratingsSection(title: "Personal Rating", rating: userRating)
        }
        .frame(height: 250)
        .onAppear {
            userRating = book!.personalRating
        }
    }
    
    func ratingsSection(title: String, rating: Double) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            HStack(spacing: -1.0) {
                ForEach(0..<5) { index in
                    BookActionButtons.starImage(for: index, in: rating)
                        .onTapGesture {
                            updateUserRating(to: Double(index) + 0.5)
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let width = value.location.x
                                    let computedRating = Double(width / 30)
                                    updateUserRating(to: min(max(computedRating, 0.5), 5))
                                }
                        )
                }
            }
        }
    }
    
    func updateUserRating(to newRating: Double) {
        userRating = newRating
        book!.personalRating = newRating
        saveContext()
    }
    
    static func starImage(for index: Int, in rating: Double) -> some View {
        if rating > Double(index) + 0.5 {
            return Image(systemName: "star.fill").foregroundColor(Color.yellow)
        } else if rating > Double(index) {
            return Image(systemName: "star.leadinghalf.fill").foregroundColor(Color.yellow)
        } else {
            return Image(systemName: "star").foregroundColor(Color.gray)
        }
    }
    
    private func actionButton(title: ActionTitle, icon: String) -> some View {
        Button {
            switch title {
            case .markAsRead:
                markBookAsRead()
            case .markAsUnread:
                markBookAsUnread()
            default:
                print("\(title.rawValue) \(book!.title ?? "") pressed")
            }
        } label: {
            Label(title.rawValue, systemImage: icon)
                .frame(width: 345.0, height: 55.0)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(51.0)
                .font(.headline)

        }
//        .disabled(isEditMode) // Disable the button when in edit mode
    }

    func saveContext() {
        do {
            try moc.save()
        } catch {
            print("Failed to update read status: \(error)")
        }
    }
    
    var bookIsRead: Bool {
        book!.read == 100
    }
    
    func markBookAsRead() {
        book!.read = 100
        saveContext()
    }
    
    func markBookAsUnread() {
        book!.read = 0
        saveContext()
    }
}

struct BookActionButtons_Preview: PreviewProvider {
    static var previews: some View {
        let context = NSManagedObjectContext.preview
        let sampleBook = Books(context: context)
        sampleBook.bookIsRead = true
        let sampleBook2 = Books(context: context)
        sampleBook2.bookIsRead = false
        return
            VStack {
                BookActionButtons(book: (sampleBook))
                    .environment(\.managedObjectContext, context)
        }
    }
}

