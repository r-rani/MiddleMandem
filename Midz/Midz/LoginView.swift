//  LoginView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) var dismiss
    
    @State private var username = ""
    @State private var password = ""
    @State private var navigateToHome = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // Logo
                    Image("midz_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                    
                    // Title
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    // Subtitle
                    Text("Login to continue")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    // Road dashes
                    HStack(spacing: 12) {
                        ForEach(0..<6) { _ in
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 30, height: 4)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Username Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter your username", text: $username)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 32)
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        SecureField("Enter your password", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 32)
                    
                    // Error message
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal, 32)
                    }
                    
                    // Login Button
                    Button(action: {
                        handleLogin()
                    }) {
                        Text("Login")
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
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1 : 0.6)
                    
                    // Don't have an account
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white)
                        Button("Sign Up") {
                            dismiss()
                        }
                        .foregroundColor(.pink)
                        .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                    
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToHome) {
            DashboardView()
        }
    }
    
    var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty
    }
    
    func handleLogin() {
        // Attempt to login
        do {
            let user = try authManager.login(
                username: username,
                password: password,
                context: modelContext
            )
            
            // Clear any errors
            showError = false
            errorMessage = ""
            
            print("User logged in successfully: \(user.fullName) (@\(user.username))")
            
            // Navigate to home/locations view
            navigateToHome = true
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .modelContainer(for: User.self, inMemory: true)
            .environment(AuthManager())
    }
}
