//
//  ContentView.swift
//  Midz
//
//  Root view that determines which screen to display
//  based on the user’s authentication state.
//

import SwiftUI

/// Entry point view that switches between authenticated
/// and unauthenticated app flows.
struct ContentView: View {

    /// Authentication manager from the environment
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        Group {
            // Show main dashboard if logged in,
            // otherwise show the welcome screen
            if authManager.isAuthenticated {
                DashboardView()
            } else {
                WelcomeView()
            }
        }
    }
}

