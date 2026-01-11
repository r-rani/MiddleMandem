//  EditProfileView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-11.
//

import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Bindable var user: User
    
    @State private var editedBio: String
    @State private var selectedRestrictions: Set<String>
    @State private var showAddCustomRestriction = false
    @State private var customRestriction = ""
    
    let commonRestrictions = [
        "Vegetarian",
        "Vegan",
        "Gluten-Free",
        "Dairy-Free",
        "Nut Allergy",
        "Shellfish Allergy",
        "Halal",
        "Kosher",
        "Lactose Intolerant",
        "Pescatarian"
    ]
    
    init(user: User) {
        self.user = user
        _editedBio = State(initialValue: user.bio ?? "")
        _selectedRestrictions = State(initialValue: Set(user.dietaryRestrictions ?? []))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Picture
                        Circle()
                            .fill(Color.pink.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(user.fullName.prefix(1).uppercased())
                                    .font(.system(size: 50))
                                    .fontWeight(.bold)
                                    .foregroundColor(.pink)
                            )
                            .padding(.top, 20)
                        
                        // Username (non-editable)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            
                            Text("@\(user.username)")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        
                        // Full Name (non-editable)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            
                            Text(user.fullName)
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        
                        // Bio
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            TextEditor(text: $editedBio)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                        }
                        .padding(.horizontal, 20)
                        
                        // Dietary Restrictions
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Dietary Restrictions")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action: {
                                    showAddCustomRestriction = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Custom")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.pink)
                                }
                            }
                            
                            // Common restrictions
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(commonRestrictions, id: \.self) { restriction in
                                    RestrictionChip(
                                        text: restriction,
                                        isSelected: selectedRestrictions.contains(restriction)
                                    ) {
                                        toggleRestriction(restriction)
                                    }
                                }
                            }
                            
                            // Custom restrictions
                            let customItems = selectedRestrictions.filter { !commonRestrictions.contains($0) }
                            if !customItems.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Custom")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    FlowLayout(spacing: 8) {
                                        ForEach(Array(customItems), id: \.self) { restriction in
                                            CustomRestrictionChip(text: restriction) {
                                                selectedRestrictions.remove(restriction)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        Button(action: saveProfile) {
                            Text("Save Changes")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.pink, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
            }
            .alert("Add Custom Restriction", isPresented: $showAddCustomRestriction) {
                TextField("Enter restriction", text: $customRestriction)
                Button("Cancel", role: .cancel) {
                    customRestriction = ""
                }
                Button("Add") {
                    if !customRestriction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        selectedRestrictions.insert(customRestriction.trimmingCharacters(in: .whitespacesAndNewlines))
                        customRestriction = ""
                    }
                }
            }
        }
    }
    
    func toggleRestriction(_ restriction: String) {
        if selectedRestrictions.contains(restriction) {
            selectedRestrictions.remove(restriction)
        } else {
            selectedRestrictions.insert(restriction)
        }
    }
    
    func saveProfile() {
        // Update bio (handle empty string)
        let trimmedBio = editedBio.trimmingCharacters(in: .whitespacesAndNewlines)
        user.bio = trimmedBio.isEmpty ? nil : trimmedBio
        
        // Update dietary restrictions
        user.dietaryRestrictions = selectedRestrictions.isEmpty ? nil : Array(selectedRestrictions)
        
        do {
            try modelContext.save()
            print("✅ Profile saved successfully")
            print("Bio: \(user.bio ?? "nil")")
            print("Dietary restrictions: \(user.dietaryRestrictions ?? [])")
            dismiss()
        } catch {
            print("❌ Failed to save profile: \(error)")
        }
    }
}

struct RestrictionChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ?
                    Color.pink.opacity(0.3) :
                    Color.gray.opacity(0.2)
                )
                .foregroundColor(isSelected ? .pink : .white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 1.5)
                )
        }
    }
}

struct CustomRestrictionChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.pink.opacity(0.3))
        .foregroundColor(.pink)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.pink, lineWidth: 1.5)
        )
    }
}

// FlowLayout is now in FlowLayout.swift

#Preview {
    EditProfileView(user: User(fullName: "John Doe", username: "johndoe", address: "123 Main St", password: "password"))
        .modelContainer(for: User.self, inMemory: true)
}
