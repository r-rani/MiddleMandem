//  WelcomeView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI

struct WelcomeView: View {
    @State private var userName = ""
    @State private var navigate = false

    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // Logo
            Image("midz_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)

            // App name
            Text("Midz")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Welcome text
            Text("Welcome! What should we call you?")
                .font(.headline)
                .foregroundColor(.secondary)

            // Name input
            TextField("Enter your name", text: $userName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            // Continue button
            Button("Continue") {
                navigate = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(userName.isEmpty)

            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $navigate) {
            AddLocationsView(userName: userName)
        }
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
}
