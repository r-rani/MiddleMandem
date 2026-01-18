//  AuthManager.swift
//  Midz
//  Manages user authentication, session state,
//  and friend-related data operations.
//


import Foundation
import SwiftData
import Observation

/// Manages authentication state and user-related operations
/// such as sign-up, login, logout, and friend queries.
@Observable
class AuthManager {
     /// The currently authenticated user (nil if logged out)
    var currentUser: User? = nil
    /// Indicates whether a user is currently authenticated
    var isAuthenticated: Bool {
        currentUser != nil
    }

    /// Registers a new user and logs them in
    /// - Parameters:
    ///   - fullName: User's full name
    ///   - username: Unique username
    ///   - address: User's address
    ///   - password: Plain-text password
    ///   - context: SwiftData model context
    /// - Returns: The newly created `User`
    /// - Throws: `AuthError.usernameAlreadyExists` if the username is taken
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
        
         // Create and store a new user
        let newUser = User(fullName: fullName, username: username, address: address, password: password)
        context.insert(newUser)
        
        try context.save()
        
         // Set newly created user as the current session user
        currentUser = newUser
        
        return newUser
    }

    /// Logs in an existing user
    /// - Parameters:
    ///   - username: User's username
    ///   - password: Plain-text password
    ///   - context: SwiftData model context
    /// - Returns: The authenticated `User`
    /// - Throws:
    ///   - `AuthError.userNotFound` if no user exists
    ///   - `AuthError.incorrectPassword` if password does not match
    func login(username: String, password: String, context: ModelContext) throws -> User {
         // Fetch user matching the provided username
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { user in
                user.username == username
            }
        )
        
        let users = try context.fetch(descriptor)
        
        guard let user = users.first else {
            throw AuthError.userNotFound
        }
        
         // Verify password hash
        if user.passwordHash != password.simpleHash() {
            throw AuthError.incorrectPassword
        }
        
        // Set authenticated user
        currentUser = user
        
        return user
    }

    /// Logs out the current user
    func logout() {
        currentUser = nil
    }
    
    // MARK: - Friends Methods

    /// Searches users by username or full name
    /// - Parameters:
    ///   - query: Search string entered by the user
    ///   - context: SwiftData model context
    /// - Returns: A list of matching users
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

    /// Retrieves a user's friends based on stored friend IDs
    /// - Parameters:
    ///   - user: The user whose friends are being fetched
    ///   - context: SwiftData model context
    /// - Returns: A list of the user's friends
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

/// Authentication-related errors
enum AuthError: LocalizedError {
    
    /// Thrown when attempting to register with a taken username
    case usernameAlreadyExists

    /// Thrown when no matching user is found
    case userNotFound

    /// Thrown when a password does not match
    case incorrectPassword

    /// User-friendly error messages
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
