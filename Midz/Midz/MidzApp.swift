//
//  MidzApp.swift
//  Midz
//
//  Main entry point for the Midz app.
//

import SwiftUI
import SwiftData

/// The main application struct for Midz
@main
struct MidzApp: App {

    /// Manages authentication state
    @State private var authManager = AuthManager()

    /// Manages user boards and locations
    @State private var boardsManager = BoardsManager()

    /// SwiftData model container
    let container: ModelContainer

    /// Initializes the app and sets up the model container
    init() {
        do {
            // Define the data schema
            let schema = Schema([
                User.self,
                Message.self,
                GroupChat.self
            ])

            // Use in-memory storage to avoid schema conflicts
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try ModelContainer(for: schema, configurations: [config])

        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            // Root view with environment objects
            ContentView()
                .modelContainer(container)
                .environment(authManager)
                .environment(boardsManager)
        }
    }
}

