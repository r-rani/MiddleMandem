//
//  ResultsView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI

struct ResultsView: View {
    let user1Location: String
    let user2Location: String

    var body: some View {
        VStack(spacing: 20) {
            Text("User 1: \(user1Location)")
            Text("User 2: \(user2Location)")
            Text("Here we will calculate the midpoint and show places.")
        }
        .padding()
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(user1Location: "123 Street", user2Location: "456 Street")
    }
}
