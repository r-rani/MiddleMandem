//
//  LoginView.swift
//  Midz
//
//  Login screen that authenticates an existing user.
//

import SwiftUI
import SwiftData

/// Allows users to log into the app using their credentials
struct LoginView: View {

    /// SwiftData model context
    @Environment(\.modelContext) private var modelContext

    /// Authentication manager from the environment
    @Environment(AuthManager.self) private var authManager

    /// Used to dismiss the view (return to sign-up)
    @Environment(\.dismiss) var dismiss

    // MARK: - State

    /// User-entered username
    @State private var username = ""

    /// User-entered password
    @State private var password = ""

    /// Controls navigation to the dashboard on success
    @State private var navigateToHome = false

    /// Error display state
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    Spacer()
                        .frame(height: 60)

                    // App logo
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

                    // Decorative divider
                    HStack(spacing: 12) {
                        ForEach(0..<6) { _ in
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: 30, height: 4)
                        }
                    }
                    .padding(.vertical, 8)

                    // Username input
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

                    // Password input
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

                    // Error message display
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.horizontal, 32)
                    }

                    // Login action button
                    Button {
                        handleLogin()
                    } label: {
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
                            .shadow(
                                color: Color.white.opacity(0.2),
                                radius: 5,
                                x: 0,
                                y: 3
                            )
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1 : 0.6)

                    // Navigation to sign-up
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

        // Navigate to dashboard after successful login
        .navigationDestination(isPresented: $navigateToHome) {
            DashboardView()
        }
    }

    /// Validates that required fields are filled
    var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty
    }

    /// Attempts to authenticate the user and handles errors
    func handleLogin() {
        do {
            let user = try authManager.login(
                username: username,
                password: password,
                context: modelContext
            )

            // Reset error state
            showError = false
            errorMessage = ""

            print("User logged in successfully: \(user.fullName) (@\(user.username))")

            // Trigger navigation to dashboard
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
