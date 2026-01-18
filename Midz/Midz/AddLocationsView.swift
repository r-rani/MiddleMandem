//
//  AddLocationsView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//  View for allowing users to input starting locations
//  for themselves and a friend.
//

import SwiftUI

/// A view that prompts the user to add locations
/// used for calculating a midpoint or meetup spot.
struct AddLocationsView: View {

    //Main view layout
    var body: some View {
        ZStack {
            // Background color filling the entire screen
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Screen title
                Text("Add Locations")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)

                // Instructional subtitle
                Text("Enter locations for you and your friend")
                    .foregroundColor(.white)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // TODO: Add input fields for two locations
                Spacer() // Pushes content toward the top
            }
            .padding()
        }
    }
}
/// Preview for SwiftUI canvas
#Preview {
    AddLocationsView()
}
