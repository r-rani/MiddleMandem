//  User.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var fullName: String
    var username: String
    var address: String
    var passwordHash: String
    var createdAt: Date
    var friendIDs: [UUID]
    var bio: String?
    var dietaryRestrictions: [String]?
    
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
    
    // Friend Management Methods
    func isFriend(_ userID: UUID) -> Bool {
        return friendIDs.contains(userID)
    }
    
    func addFriend(_ userID: UUID) {
        if !friendIDs.contains(userID) {
            friendIDs.append(userID)
        }
    }
    
    func removeFriend(_ userID: UUID) {
        friendIDs.removeAll { $0 == userID }
    }
}

// Simple password hashing extension (for production, use proper encryption)
extension String {
    func simpleHash() -> String {
        return String(self.hashValue)
    }
}
