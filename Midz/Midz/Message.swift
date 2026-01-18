//
//  Message.swift
//  Midz
//
//  Defines data models for messages and group chats.
//

import Foundation
import SwiftData

/// Represents a single message sent within a group chat
@Model
final class Message {

    /// Unique identifier for the message
    @Attribute(.unique) var id: UUID

    /// Message text content
    var content: String

    /// Identifier of the user who sent the message
    var senderID: UUID

    /// Display name of the message sender
    var senderName: String

    /// Time the message was created
    var timestamp: Date

    /// Identifier of the group chat this message belongs to
    var groupChatID: UUID

    /// Creates a new message
    init(
        content: String,
        senderID: UUID,
        senderName: String,
        groupChatID: UUID
    ) {
        self.id = UUID()
        self.content = content
        self.senderID = senderID
        self.senderName = senderName
        self.timestamp = Date()
        self.groupChatID = groupChatID
    }
}

/// Represents a group chat between multiple users
@Model
final class GroupChat {

    /// Unique identifier for the group chat
    @Attribute(.unique) var id: UUID

    /// Display name of the group chat
    var name: String

    /// IDs of users participating in the chat
    var memberIDs: [UUID]

    /// Timestamp indicating when the group chat was created
    var createdAt: Date

    /// ID of the user who created the group chat
    var createdBy: UUID

    /// Creates a new group chat
    init(
        name: String,
        memberIDs: [UUID],
        createdBy: UUID
    ) {
        self.id = UUID()
        self.name = name
        self.memberIDs = memberIDs
        self.createdAt = Date()
        self.createdBy = createdBy
    }
}
