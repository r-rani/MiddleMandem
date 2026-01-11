//  DashboardView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(BoardsManager.self) private var boardsManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab with Map
            HomeView(boards: boardsManager.boards)
                .tabItem {
                    Label("Home", systemImage: "map.fill")
                }
                .tag(0)
            
            // Add/Boards Tab
            BoardsView()
                .tabItem {
                    Label("Boards", systemImage: "square.grid.2x2.fill")
                }
                .tag(1)
            
            // Friends Tab
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.pink)
    }
}

// Profile View with Edit Profile functionality
struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var friends: [User] = []
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let user = authManager.currentUser {
                            // Avatar
                            Circle()
                                .fill(Color.pink.opacity(0.3))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Text(user.fullName.prefix(1).uppercased())
                                        .font(.system(size: 50))
                                        .fontWeight(.bold)
                                        .foregroundColor(.pink)
                                )
                                .padding(.top, 20)
                            
                            // User Info
                            VStack(spacing: 8) {
                                Text(user.fullName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("@\(user.username)")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                            
                            // Edit Profile Button
                            Button(action: {
                                showEditProfile = true
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Profile")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.pink)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.pink.opacity(0.2))
                                .cornerRadius(20)
                            }
                            
                            // Bio Section
                            if let bio = user.bio, !bio.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Bio")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text(bio)
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 32)
                            }
                            
                            // Dietary Restrictions Section
                            if let restrictions = user.dietaryRestrictions, !restrictions.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "fork.knife")
                                            .foregroundColor(.pink)
                                        Text("Dietary Restrictions")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    
                                    FlowLayout(spacing: 8) {
                                        ForEach(restrictions, id: \.self) { restriction in
                                            Text(restriction)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.pink.opacity(0.2))
                                                .foregroundColor(.pink)
                                                .cornerRadius(16)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 32)
                            }
                            
                            // Stats
                            HStack(spacing: 40) {
                                VStack {
                                    Text("\(friends.count)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.pink)
                                    Text("Friends")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack {
                                    Text("0")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.pink)
                                    Text("Locations")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 20)
                            
                            Spacer()
                            
                            // Logout Button
                            Button(action: {
                                authManager.logout()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.right.square.fill")
                                    Text("Logout")
                                        .fontWeight(.semibold)
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 32)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditProfile) {
                if let user = authManager.currentUser {
                    EditProfileView(user: user)
                }
            }
        }
        .onAppear {
            loadFriends()
        }
    }
    
    func loadFriends() {
        guard let currentUser = authManager.currentUser else { return }
        
        do {
            friends = try authManager.getFriends(for: currentUser, context: modelContext)
        } catch {
            print("Failed to load friends: \(error)")
        }
    }
}

// FlowLayout is now in FlowLayout.swift

#Preview {
    DashboardView()
        .modelContainer(for: User.self, inMemory: true)
        .environment(AuthManager())
        .environment(BoardsManager())
}
