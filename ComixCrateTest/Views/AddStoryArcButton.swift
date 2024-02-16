//
//  AddStoryArcButton.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 10/8/23.
//

import SwiftUI

struct AddStoryArcButton: View {
    @Binding var storyArcs: [String]
    @Binding var storyArcParts: [Int16]
    
    var body: some View {
        Button(action: {
            storyArcs.append("")
            storyArcParts.append(0)
        }, label: {
            Image(systemName: "plus.circle.fill")
        })
    }
}

struct AddStoryArcButton_Previews: PreviewProvider {
    static var previews: some View {
        AddStoryArcButton(storyArcs: .constant(["StoryArc"]), storyArcParts: .constant([1]))
    }
}

