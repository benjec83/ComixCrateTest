//
//  SuggestionPopover.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/26/23.
//

import SwiftUI
import CoreData

struct SuggestionPopover: View {
    var header: String
    var filter: [String] // Change this to a list of strings
    var selection: Binding<String>
    var showPopover: Binding<Bool>

    var body: some View {
        VStack(spacing: 0) {
            Text(header)
                .font(.headline)
                .padding(.horizontal)
                .padding(.vertical, 20)

            VStack(spacing: 0) { // Use a VStack instead of List for more control
                ForEach(Array(filter.enumerated()), id: \.element) { index, currentField in
                    Text(currentField)
                        .frame(width: 340, height: 44) // Set the height for each item
                        .padding(.horizontal) // Optional: Add horizontal padding if needed
                        .onTapGesture {
                            selection.wrappedValue = currentField
                            showPopover.wrappedValue = false
                        }
                    if index < filter.count - 1 {
                        Divider()
                            .frame(width: 330)
                            .background(Color(UIColor.systemGroupedBackground))
                    }
                }
            }
            .background(Color.white) // Background color for the VStack
            .cornerRadius(10) // Round the corners
        }
        .padding(.bottom, 15.0)
        .frame(width: 400)
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
