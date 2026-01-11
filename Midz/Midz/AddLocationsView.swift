//
//  AddLocationsView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI

struct AddLocationsView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Add Locations")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)

                Text("Enter locations for you and your friend")
                    .foregroundColor(.white)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // TODO: Add input fields for two locations
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    AddLocationsView()
}
