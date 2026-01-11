//  MidzApp.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI
import SwiftData

@main
struct MidzApp: App {
    @State private var authManager = AuthManager()
    @State private var boardsManager = BoardsManager()
    
    let container: ModelContainer
    
    init() {
        do {
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
            ContentView()
                .modelContainer(container)
                .environment(authManager)
                .environment(boardsManager)
        }
    }
}
