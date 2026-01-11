//  ContentView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI

struct ContentView: View {

    @State private var navigateToSignUp = false
    @State private var navigateToLogin = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 28) {

                    Spacer()

                    // Logo
                    Image("midz_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)

                    // App Title
                    Text("Meet in the Middle")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hexString: "#FF2F92"))

                    // Subtitle
                    Text("Find the perfect spot to meet your friends")
                        .foregroundColor(.white)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    // Road dashes
                    HStack(spacing: 12) {
                        ForEach(0..<6) { _ in
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 30, height: 4)
                        }
                    }
                    .padding(.vertical, 20)

                    // Sign Up Button (Hot Pink Gradient)
                    Button(action: {
                        navigateToSignUp = true
                    }) {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hexString: "#FF2F92"), Color(hexString: "#FF69B4")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.white.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal, 32)

                    // Login Button (Outlined)
                    Button(action: {
                        navigateToLogin = true
                    }) {
                        Text("Login")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(Color(hexString: "#FF2F92"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hexString: "#FF2F92"), lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                }
                .navigationDestination(isPresented: $navigateToSignUp) {
                    SignUpView()
                }
                .navigationDestination(isPresented: $navigateToLogin) {
                    LoginView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Hex Color Extension
extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
