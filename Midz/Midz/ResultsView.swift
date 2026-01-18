//
//  ResultsView.swift
//  Midz
//
//  Displays the results or midpoint of selected locations.
//

import SwiftUI
import MapKit

/// Placeholder view for displaying midpoint results
struct ResultsView: View {

    var body: some View {
        ZStack {
            // Background color
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {

                // App logo
                Image("midz_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .padding(.top, 40)
                
                // Main title
                Text("Find Your Midpoint")
                    .font(.largeTitle)
                    .foregroundColor(Color(hexString: "#FF2F92"))
                    .bold()

                // Subtitle / placeholder
                Text("Coming Soon!")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ResultsView()
}
