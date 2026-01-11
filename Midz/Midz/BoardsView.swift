//  BoardsView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI
import MapKit

// MARK: - Models
struct Board: Identifiable, Codable {
    let id: UUID
    var name: String
    var emoji: String
    var color: String
    var locations: [Location]
    
    init(id: UUID = UUID(), name: String, emoji: String, color: String, locations: [Location] = []) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.color = color
        self.locations = locations
    }
}

struct Location: Identifiable, Codable {
    let id: UUID
    var name: String
    var address: String
    var notes: String
    
    init(id: UUID = UUID(), name: String, address: String = "", notes: String = "") {
        self.id = id
        self.name = name
        self.address = address
        self.notes = notes
    }
}

// MARK: - Main Boards View
struct BoardsView: View {
    @Environment(BoardsManager.self) private var boardsManager
    @State private var showAddBoard = false
    @State private var selectedBoard: Board?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    // Header
                    HStack {
                        Text("Your Boards")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            showAddBoard = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                Text("New Board")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.pink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Boards Grid
                    if boardsManager.boards.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding(.top, 60)
                            
                            Text("No boards yet")
                                .font(.title3)
                                .foregroundColor(.white)
                            
                            Text("Create a board to organize your locations")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(boardsManager.boards) { board in
                                    BoardCard(board: board) {
                                        selectedBoard = board
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddBoard) {
                AddBoardView { newBoard in
                    boardsManager.addBoard(newBoard)
                }
            }
            .sheet(item: $selectedBoard) { board in
                if let index = boardsManager.boards.firstIndex(where: { $0.id == board.id }) {
                    BoardDetailView(board: Binding(
                        get: { boardsManager.boards[index] },
                        set: { boardsManager.boards[index] = $0 }
                    ))
                }
            }
        }
    }
}

// MARK: - Board Card
struct BoardCard: View {
    let board: Board
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Emoji Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hexString: board.color),
                                    Color(hexString: board.color).opacity(0.6)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text(board.emoji)
                        .font(.system(size: 40))
                }
                
                VStack(spacing: 4) {
                    Text(board.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("\(board.locations.count) locations")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hexString: board.color).opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Add Board View
struct AddBoardView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (Board) -> Void
    
    @State private var boardName = ""
    @State private var selectedEmoji = "📍"
    @State private var selectedColor = "#FF2F92"
    
    let emojis = ["🍽️", "☕️", "🌳", "🎬", "🏃", "🎨", "🛍️", "🎵", "📚", "✈️", "🏖️", "🎮"]
    let colors = ["#FF2F92", "#FF69B4", "#FFA07A", "#FFD700", "#87CEEB", "#98FB98", "#DDA0DD", "#F0E68C"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Board Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Board Name")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            TextField("Enter board name", text: $boardName)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        
                        // Emoji Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose an Icon")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                                ForEach(emojis, id: \.self) { emoji in
                                    Button(action: {
                                        selectedEmoji = emoji
                                    }) {
                                        Text(emoji)
                                            .font(.system(size: 32))
                                            .frame(width: 50, height: 50)
                                            .background(
                                                selectedEmoji == emoji ?
                                                Color.pink.opacity(0.3) :
                                                Color.gray.opacity(0.2)
                                            )
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose a Color")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Button(action: {
                                        selectedColor = color
                                    }) {
                                        Circle()
                                            .fill(Color(hexString: color))
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Create Button
                        Button(action: {
                            let newBoard = Board(name: boardName, emoji: selectedEmoji, color: selectedColor)
                            onSave(newBoard)
                            dismiss()
                        }) {
                            Text("Create Board")
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
                        .disabled(boardName.isEmpty)
                        .opacity(boardName.isEmpty ? 0.6 : 1)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("New Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
            }
        }
    }
}

// MARK: - Board Detail View
struct BoardDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var board: Board
    @State private var showAddLocation = false
    @State private var isEditingName = false
    @State private var editedName = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with editable name
                    VStack(spacing: 16) {
                        Text(board.emoji)
                            .font(.system(size: 60))
                        
                        if isEditingName {
                            HStack {
                                TextField("Board name", text: $editedName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button("Done") {
                                    board.name = editedName
                                    isEditingName = false
                                }
                                .foregroundColor(.pink)
                            }
                        } else {
                            Button(action: {
                                editedName = board.name
                                isEditingName = true
                            }) {
                                HStack {
                                    Text(board.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                        .foregroundColor(.pink)
                                }
                            }
                        }
                        
                        Text("\(board.locations.count) locations")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Locations List
                    if board.locations.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "mappin.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding(.top, 60)
                            
                            Text("No locations yet")
                                .font(.title3)
                                .foregroundColor(.white)
                            
                            Text("Add your first location to this board")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(board.locations) { location in
                                    LocationRow(location: location)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer()
                    
                    // Add Location Button
                    Button(action: {
                        showAddLocation = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Location")
                                .fontWeight(.semibold)
                        }
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
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
            }
            .sheet(isPresented: $showAddLocation) {
                AddLocationView { newLocation in
                    board.locations.append(newLocation)
                }
            }
        }
    }
}

// MARK: - Location Row
struct LocationRow: View {
    let location: Location
    
    var body: some View {
        HStack(spacing: 16) {
            // Pin Icon
            Circle()
                .fill(Color.pink.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "mappin.circle.fill")
                        .font(.title3)
                        .foregroundColor(.pink)
                )
            
            // Location Info
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                if !location.address.isEmpty {
                    Text(location.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - Add Location View
struct AddLocationView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (Location) -> Void
    
    @State private var locationName = ""
    @State private var locationAddress = ""
    @State private var notes = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Location Name with Search
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location Name")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            TextField("e.g., Central Park Cafe", text: $locationName)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .onChange(of: locationName) { _, newValue in
                                    if !newValue.isEmpty {
                                        searchLocations(query: newValue)
                                    } else {
                                        searchResults.removeAll()
                                    }
                                }
                            
                            // Search Results Dropdown
                            if !searchResults.isEmpty {
                                VStack(spacing: 0) {
                                    ForEach(searchResults, id: \.self) { result in
                                        Button(action: {
                                            selectLocation(result)
                                        }) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(result.name ?? "Unknown")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                
                                                if let address = formatAddress(result.placemark) {
                                                    Text(address)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                        }
                                        
                                        if result != searchResults.last {
                                            Divider()
                                                .background(Color.gray.opacity(0.3))
                                        }
                                    }
                                }
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Address (Auto-populated)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Address")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            TextField("Address will auto-populate", text: $locationAddress)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .foregroundColor(.gray)
                                .disabled(true)
                        }
                        .padding(.horizontal, 20)
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .foregroundColor(.white)
                                .font(.headline)
                            
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                        }
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        Button(action: {
                            let newLocation = Location(name: locationName, address: locationAddress, notes: notes)
                            onSave(newLocation)
                            dismiss()
                        }) {
                            Text("Add Location")
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
                        .disabled(locationName.isEmpty || locationAddress.isEmpty)
                        .opacity((locationName.isEmpty || locationAddress.isEmpty) ? 0.6 : 1)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("New Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
            }
        }
    }
    
    func searchLocations(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            self.searchResults = Array(response.mapItems.prefix(5))
        }
    }
    
    func selectLocation(_ mapItem: MKMapItem) {
        locationName = mapItem.name ?? ""
        locationAddress = formatAddress(mapItem.placemark) ?? ""
        searchResults.removeAll()
    }
    
    func formatAddress(_ placemark: MKPlacemark) -> String? {
        var addressComponents: [String] = []
        
        if let subThoroughfare = placemark.subThoroughfare {
            addressComponents.append(subThoroughfare)
        }
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        if let postalCode = placemark.postalCode {
            addressComponents.append(postalCode)
        }
        
        return addressComponents.isEmpty ? nil : addressComponents.joined(separator: ", ")
    }
}

#Preview {
    BoardsView()
}
