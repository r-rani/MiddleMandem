//  FriendsView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI
import SwiftData

struct FriendsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    
    @State private var searchQuery = ""
    @State private var searchResults: [User] = []
    @State private var friends: [User] = []
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Friends")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                        
                        // Tab Selector
                        Picker("View", selection: $selectedTab) {
                            Text("My Friends").tag(0)
                            Text("Add Friends").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 32)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Content based on selected tab
                    if selectedTab == 0 {
                        // My Friends List
                        myFriendsView
                    } else {
                        // Add Friends View
                        addFriendsView
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                }
            }
        }
        .onAppear {
            loadFriends()
        }
    }
    
    var myFriendsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if friends.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding(.top, 60)
                        
                        Text("No friends yet")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("Search for users to add as friends")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    ForEach(friends, id: \.id) { friend in
                        FriendRow(user: friend, isFriend: true) {
                            removeFriend(friend)
                        }
                    }
                    .padding(.horizontal, 32)
                }
            }
            .padding(.top, 20)
        }
    }
    
    var addFriendsView: some View {
        VStack(spacing: 16) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search username", text: $searchQuery)
                    .foregroundColor(.white)
                    .onChange(of: searchQuery) { _, newValue in
                        searchUsers(query: newValue)
                    }
                
                if !searchQuery.isEmpty {
                    Button(action: {
                        searchQuery = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            // Search Results
            ScrollView {
                VStack(spacing: 16) {
                    if searchQuery.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding(.top, 60)
                            
                            Text("Search for friends")
                                .font(.title3)
                                .foregroundColor(.white)
                            
                            Text("Enter a username to find users")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    } else if searchResults.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.badge.xmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding(.top, 60)
                            
                            Text("No users found")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    } else {
                        ForEach(searchResults, id: \.id) { user in
                            // Don't show current user in results
                            if user.id != authManager.currentUser?.id {
                                let isFriend = authManager.currentUser?.isFriend(user.id) ?? false
                                FriendRow(user: user, isFriend: isFriend) {
                                    if isFriend {
                                        removeFriend(user)
                                    } else {
                                        addFriend(user)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                }
                .padding(.top, 20)
            }
        }
    }
    
    func searchUsers(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        do {
            searchResults = try authManager.searchUsers(query: query, context: modelContext)
        } catch {
            errorMessage = "Failed to search users"
            showError = true
        }
    }
    
    func loadFriends() {
        guard let currentUser = authManager.currentUser else { return }
        
        do {
            friends = try authManager.getFriends(for: currentUser, context: modelContext)
        } catch {
            errorMessage = "Failed to load friends"
            showError = true
        }
    }
    
    func addFriend(_ friend: User) {
        guard let currentUser = authManager.currentUser else { return }
        
        currentUser.addFriend(friend.id)
        
        do {
            try modelContext.save()
            loadFriends()
            
            // Update search results to reflect new friend status
            searchUsers(query: searchQuery)
        } catch {
            errorMessage = "Failed to add friend"
            showError = true
        }
    }
    
    func removeFriend(_ friend: User) {
        guard let currentUser = authManager.currentUser else { return }
        
        currentUser.removeFriend(friend.id)
        
        do {
            try modelContext.save()
            loadFriends()
            
            // Update search results if we're on that tab
            if selectedTab == 1 {
                searchUsers(query: searchQuery)
            }
        } catch {
            errorMessage = "Failed to remove friend"
            showError = true
        }
    }
}

struct FriendRow: View {
    let user: User
    let isFriend: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(Color.pink.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(user.fullName.prefix(1).uppercased())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.pink)
                )
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Follow/Unfollow Button
            Button(action: action) {
                Text(isFriend ? "Following" : "Follow")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Group {
                            if isFriend {
                                Color.gray.opacity(0.3)
                            } else {
                                LinearGradient(
                                    gradient: Gradient(colors: [.pink, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        FriendsView()
            .modelContainer(for: User.self, inMemory: true)
            .environment(AuthManager())
    }
}
