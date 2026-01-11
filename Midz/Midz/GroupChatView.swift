//  GroupChatView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-11.
//

import SwiftUI
import SwiftData

struct GroupChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthManager.self) private var authManager
    @Environment(\.dismiss) var dismiss
    
    let groupChat: GroupChat
    let members: [User]
    
    @Query private var allMessages: [Message]
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    
    var messages: [Message] {
        allMessages.filter { $0.groupChatID == groupChat.id }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with members
                VStack(spacing: 8) {
                    Text(groupChat.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(members.map { $0.fullName }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(
                                    message: message,
                                    isCurrentUser: message.senderID == authManager.currentUser?.id
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom()
                    }
                    .onChange(of: messages.count) { _, _ in
                        scrollToBottom()
                    }
                }
                
                // Message Input
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $messageText, axis: .vertical)
                        .padding(12)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                        .lineLimit(1...5)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(messageText.isEmpty ? .gray : .pink)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.black)
            }
        }
        .navigationTitle("Group Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func sendMessage() {
        guard let currentUser = authManager.currentUser, !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let message = Message(
            content: messageText.trimmingCharacters(in: .whitespacesAndNewlines),
            senderID: currentUser.id,
            senderName: currentUser.fullName,
            groupChatID: groupChat.id
        )
        
        modelContext.insert(message)
        
        do {
            try modelContext.save()
            messageText = ""
        } catch {
            print("Failed to send message: \(error)")
        }
    }
    
    func scrollToBottom() {
        guard let lastMessage = messages.last else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                if !isCurrentUser {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        isCurrentUser ?
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hexString: "#FF2F92"), Color(hexString: "#FF69B4")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(20)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        GroupChatView(
            groupChat: GroupChat(
                name: "Hangout Group",
                memberIDs: [],
                createdBy: UUID()
            ),
            members: []
        )
        .modelContainer(for: [Message.self, GroupChat.self], inMemory: true)
        .environment(AuthManager())
    }
}
