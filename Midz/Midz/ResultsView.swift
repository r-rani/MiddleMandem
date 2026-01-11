//
//  ResultsView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI

struct ResultsView: View {
    let userName: String
    let friendName: String
    let midpoint: String // or coordinates

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Hey \(userName) & \(friendName)")
                    .font(.largeTitle)
                    .foregroundColor(Color(hexString: "#FF2F92"))
                    .bold()

                Text("Your meeting point is:")
                    .foregroundColor(.white)
                    .font(.headline)

                Text(midpoint)
                    .foregroundColor(.yellow)
                    .font(.title2)
                    .padding()

                // TODO: maybe show a map here
                Spacer()

                Button(action: {
                    // Go back or reset
                }) {
                    Text("Start Over")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hexString: "#FF2F92"), Color(hexString: "#FF69B4")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 32)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ResultsView(userName: "Komal", friendName: "Rani", midpoint: "Central Park Cafe")
}
