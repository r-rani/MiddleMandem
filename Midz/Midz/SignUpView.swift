//  SignUpView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI
import SwiftData

struct SignUpView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName = ""
    @State private var username = ""
    @State private var address = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var navigateToHome = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Logo
                    Image("midz_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120)
                    
                    // Title
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                    
                    // Subtitle
                    Text("Sign up to get started")
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
                    
                    // Full Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter your full name", text: $fullName)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .autocapitalization(.words)
                    }
                    .padding(.horizontal, 32)
                    
                    // Username Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Choose a username", text: $username)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 32)
                    
                    // Address Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Address")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        TextField("Enter your address", text: $address)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .foregroundColor(.white)
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
                    
                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        SecureField("Re-enter your password", text: $confirmPassword)
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
                    
                    // Sign Up Button
                    Button(action: {
                        handleSignUp()
                    }) {
                        Text("Sign Up")
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
                    
                    // Already have an account
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.white)
                        Button("Login") {
                            dismiss()
                        }
                        .foregroundColor(.pink)
                        .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                }
                .padding(.top, 40)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToHome) {
            DashboardView()
        }
    }
    
    var isFormValid: Bool {
        !fullName.isEmpty && !username.isEmpty && !address.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }
    
    func handleSignUp() {
        // Validate passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }
        
        // Validate password length
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return
        }
        
        // Validate username format
        guard username.count >= 3 else {
            errorMessage = "Username must be at least 3 characters"
            showError = true
            return
        }
        
        // Attempt to sign up
        do {
            let user = try authManager.signUp(
                fullName: fullName,
                username: username,
                address: address,
                password: password,
                context: modelContext
            )
            
            // Clear any errors
            showError = false
            errorMessage = ""
            
            print("User created successfully: \(user.fullName) (@\(user.username))")
            
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
        SignUpView()
            .modelContainer(for: User.self, inMemory: true)
            .environment(AuthManager())
    }
}
