//  WelcomeView.swift
//  Midz
//
//
//  Landing screen that allows users to sign up or log in.
//

import SwiftUI

/// The initial welcome screen shown to unauthenticated users
struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                //Background colour
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // App Logo
                    Image("midz_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    // App Title
                    Text("Midz")
                        .font(.system(size: 60))
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    // Subtitle
                    Text("Find the perfect midpoint")
                        .font(.title3)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    //Decorative  Road dashes
                    HStack(spacing: 12) {
                        ForEach(0..<6) { _ in
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 40, height: 5)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    Spacer()
                    
                    // Action Buttons
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
