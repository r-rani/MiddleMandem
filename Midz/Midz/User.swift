//
//  User.swift
//  Midz
//
//  Defines the User model and friend management.
//

import Foundation
import SwiftData

/// Represents a user of the Midz app
@Model
final class User {

    /// Unique identifier for the user
    @Attribute(.unique) var id: UUID

    /// Full name of the user
    var fullName: String

    /// Username for login and display
    var username: String

    /// User's address (used for midpoint calculations)
    var address: String

    /// Hashed password
    var passwordHash: String

    /// Account creation date
    var createdAt: Date

    /// List of friend user IDs
    var friendIDs: [UUID]

    /// Optional user bio
    var bio: String?

    /// Optional dietary restrictions
    var dietaryRestrictions: [String]?

    /// Creates a new user
    init(fullName: String, username: String, address: String, password: String) {
        self.id = UUID()
        self.fullName = fullName
        self.username = username
        self.address = address
        self.passwordHash = password.simpleHash()
        self.createdAt = Date()
        self.friendIDs = []
        self.bio = nil
        self.dietaryRestrictions = nil
    }

    // MARK: - Friend Management

    /// Checks if a user is a friend
    func isFriend(_ userID: UUID) -> Bool {
        friendIDs.contains(userID)
    }

    /// Adds a friend by ID
    func addFriend(_ userID: UUID) {
        if !friendIDs.contains(userID) {
            friendIDs.append(userID)
        }
    }

    /// Removes a friend by ID
    func removeFriend(_ userID: UUID) {
        friendIDs.removeAll { $0 == userID }
    }
}

// MARK: - Password Hashing (Simple)

/// Simple hash function for demonstration purposes
/// Note: Use proper encryption for production
extension String {
    func simpleHash() -> String {
        String(self.hashValue)
    }
}
