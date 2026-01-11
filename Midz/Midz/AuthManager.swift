//  AuthManager.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import Foundation
import SwiftData
import Observation

@Observable
class AuthManager {
    var currentUser: User? = nil
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    func signUp(fullName: String, username: String, address: String, password: String, context: ModelContext) throws -> User {
        // Check if username already exists
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.username == username
            }
        )
        
        let existingUsers = try context.fetch(descriptor)
        
        if !existingUsers.isEmpty {
            throw AuthError.usernameAlreadyExists
        }
        
        // Create new user
        let newUser = User(fullName: fullName, username: username, address: address, password: password)
        context.insert(newUser)
        
        try context.save()
        
        // Set as current user
        currentUser = newUser
        
        return newUser
    }
    
    func login(username: String, password: String, context: ModelContext) throws -> User {
        // Find user by username
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.username == username
            }
        )
        
        let users = try context.fetch(descriptor)
        
        guard let user = users.first else {
            throw AuthError.userNotFound
        }
        
        // Check password
        if user.passwordHash != password.simpleHash() {
            throw AuthError.incorrectPassword
        }
        
        // Set as current user
        currentUser = user
        
        return user
    }
    
    func logout() {
        currentUser = nil
    }
    
    // FRIENDS METHODS
    func searchUsers(query: String, context: ModelContext) throws -> [User] {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.username.localizedStandardContains(query) ||
                user.fullName.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.username)]
        )
        
        return try context.fetch(descriptor)
    }
    
    func getFriends(for user: User, context: ModelContext) throws -> [User] {
        let friendIDs = user.friendIDs
        
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                friendIDs.contains(user.id)
            },
            sortBy: [SortDescriptor(\.fullName)]
        )
        
        return try context.fetch(descriptor)
    }
}

enum AuthError: LocalizedError {
    case usernameAlreadyExists
    case userNotFound
    case incorrectPassword
    
    var errorDescription: String? {
        switch self {
        case .usernameAlreadyExists:
            return "This username is already taken"
        case .userNotFound:
            return "User not found"
        case .incorrectPassword:
            return "Incorrect password"
        }
    }
}
