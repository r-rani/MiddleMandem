//  ContentView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                DashboardView()
            } else {
                WelcomeView()
            }
        }
    }
}
