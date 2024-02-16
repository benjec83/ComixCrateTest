//
//  FakePublisherLogo.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 10/11/23.
//

import SwiftUI

struct FakePublisherLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 40, height: 40)
            
            Text("P")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    FakePublisherLogo()
}
