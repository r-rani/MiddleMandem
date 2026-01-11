//  Message.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-11.
//

import Foundation
import SwiftData

@Model
final class Message {
    @Attribute(.unique) var id: UUID
    var content: String
    var senderID: UUID
    var senderName: String
    var timestamp: Date
    var groupChatID: UUID
    
    init(content: String, senderID: UUID, senderName: String, groupChatID: UUID) {
        self.id = UUID()
        self.content = content
        self.senderID = senderID
        self.senderName = senderName
        self.timestamp = Date()
        self.groupChatID = groupChatID
    }
}

@Model
final class GroupChat {
    @Attribute(.unique) var id: UUID
    var name: String
    var memberIDs: [UUID]
    var createdAt: Date
    var createdBy: UUID
    
    init(name: String, memberIDs: [UUID], createdBy: UUID) {
        self.id = UUID()
        self.name = name
        self.memberIDs = memberIDs
        self.createdAt = Date()
        self.createdBy = createdBy
    }
}
