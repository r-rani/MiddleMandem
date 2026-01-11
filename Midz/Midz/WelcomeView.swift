//  WelcomeView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Logo
                    Image("midz_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    // Title
                    Text("Midz")
                        .font(.system(size: 60))
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    // Subtitle
                    Text("Find the perfect midpoint")
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Road dashes
                    HStack(spacing: 12) {
                        ForEach(0..<6) { _ in
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 40, height: 5)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 16) {
                        // Sign Up Button
                        NavigationLink(destination: SignUpView()) {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.pink, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: Color.white.opacity(0.2), radius: 5, x: 0, y: 3)
                        }
                        
                        // Login Button
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}
