//
//  AddLocationsView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI

struct AddLocationsView: View {
    let userName: String

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Hi \(userName) 👋")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hexString: "#FF2F92"))

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
    AddLocationsView(userName: "Komal")
}

