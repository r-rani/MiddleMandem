//  PlanMeetupView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData

// MARK: - User Location Pin
struct UserLocationPin: Identifiable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let name: String
    let address: String
    let isCurrentUser: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UserLocationPin, rhs: UserLocationPin) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Plan Meetup View
struct PlanMeetupView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(BoardsManager.self) private var boardsManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var friends: [User] = []
    @State private var selectedFriends: Set<UUID> = []
    @State private var showMap = false
    @State private var userPins: [UserLocationPin] = []
    @State private var midpoint: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var isGeocoding = false
    
    // Meetup Details - NEW
    @State private var meetupDate = Date()
    @State private var activity = ""
    @State private var budget: Budget = .moderate
    @State private var nearbyLocations: [MKMapItem] = []
    @State private var boardLocations: [MapPin] = []
    @State private var selectedLocation: MKMapItem?
    @State private var isSearchingLocations = false
    
    enum Budget: String, CaseIterable {
        case low = "$"
        case moderate = "$$"
        case high = "$$$"
        
        var description: String {
            switch self {
            case .low: return "Budget-friendly"
            case .moderate: return "Moderate"
            case .high: return "Fine dining"
            }
        }
        
        var color: Color {
            switch self {
            case .low: return .green
            case .moderate: return .orange
            case .high: return .pink
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                if !showMap {
                    // Friend Selection View
                    friendSelectionView
                } else {
                    // Map View with Midpoint
                    mapView
                }
            }
            .navigationTitle("Plan Meetup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.pink)
                }
                
                if showMap {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Back") {
                            showMap = false
                        }
                        .foregroundColor(.pink)
                    }
                }
            }
            .onAppear {
                loadFriends()
            }
        }
    }
    
    var friendSelectionView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 50))
                        .foregroundColor(.pink)
                        .padding(.top, 20)
                    
                    Text("Plan Your Meetup")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Choose friends, date, time, and activity")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Meetup Details Section
                VStack(spacing: 16) {
                    // Activity Input
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.pink)
                            Text("Activity")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        TextField("e.g., Dinner, Coffee, Movie", text: $activity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    
                    // Date & Time Picker
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.pink)
                            Text("Date & Time")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        DatePicker("", selection: $meetupDate, in: Date()...)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .accentColor(.pink)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    
                    // Budget Selection
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.pink)
                            Text("Budget")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 12) {
                            ForEach(Budget.allCases, id: \.self) { budgetOption in
                                Button(action: {
                                    budget = budgetOption
                                }) {
                                    VStack(spacing: 4) {
                                        Text(budgetOption.rawValue)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Text(budgetOption.description)
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(budget == budgetOption ? budgetOption.color.opacity(0.3) : Color.gray.opacity(0.2))
                                    .foregroundColor(budget == budgetOption ? budgetOption.color : .gray)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(budget == budgetOption ? budgetOption.color : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                
                // Friends Selection Header
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.pink)
                    Text("Select Friends")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    if !selectedFriends.isEmpty {
                        Text("\(selectedFriends.count) selected")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                
                // Friends List
                VStack(spacing: 12) {
                    if friends.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                            
                            Text("No friends yet")
                                .font(.title3)
                                .foregroundColor(.white)
                            
                            Text("Add friends to plan meetups together")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.vertical, 40)
                    } else {
                        ForEach(friends, id: \.id) { friend in
                            FriendSelectionRow(
                                friend: friend,
                                isSelected: selectedFriends.contains(friend.id)
                            ) {
                                toggleFriendSelection(friend.id)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Find Midpoint Button
                if !selectedFriends.isEmpty && !activity.isEmpty {
                    Button(action: {
                        findMidpoint()
                    }) {
                        HStack {
                            if isGeocoding {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Finding midpoint...")
                            } else {
                                Image(systemName: "map.fill")
                                Text("Find Midpoint")
                            }
                        }
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
                        .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .disabled(isGeocoding)
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    var mapView: some View {
        VStack(spacing: 0) {
            // Map
            Map(coordinateRegion: $region, annotationItems: userPins) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(pin.isCurrentUser ? Color.blue : Color.pink)
                                .frame(width: 40, height: 40)
                                .shadow(radius: 4)
                            
                            Text(pin.name.prefix(1).uppercased())
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Text(pin.name.split(separator: " ").first ?? "")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
            }
            .overlay(
                // Midpoint Marker
                Group {
                    if let midpoint = midpoint {
                        GeometryReader { geometry in
                            let position = coordinate(for: midpoint, in: geometry.size)
                            
                            VStack {
                                Image(systemName: "star.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.yellow)
                                    .shadow(radius: 8)
                                
                                Text("Midpoint")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.yellow)
                                    .cornerRadius(12)
                            }
                            .position(x: position.x, y: position.y)
                        }
                    }
                }
            )
            .ignoresSafeArea(edges: .top)
            
            // Info Card
            VStack(spacing: 16) {
                // Meetup Details - NEW
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Meetup Details")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    // Activity
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.pink)
                        Text(activity)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    
                    // Date & Time
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.pink)
                        Text(meetupDate, style: .date)
                            .foregroundColor(.white)
                        Text("at")
                            .foregroundColor(.gray)
                        Text(meetupDate, style: .time)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Participants
                VStack(alignment: .leading, spacing: 8) {
                    Text("Participants (\(userPins.count))")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(userPins) { pin in
                                VStack(spacing: 4) {
                                    Circle()
                                        .fill(pin.isCurrentUser ? Color.blue : Color.pink)
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text(pin.name.prefix(1).uppercased())
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        )
                                    
                                    Text(pin.name.split(separator: " ").first ?? "")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // Midpoint Info
                if let midpoint = midpoint {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.yellow)
                            Text("Meetup Location")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                        Text("Lat: \(midpoint.latitude, specifier: "%.4f"), Lon: \(midpoint.longitude, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            openInMaps()
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Open in Maps")
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
                    }
                }
            }
            .padding(20)
            .background(Color.black)
        }
    }
    
    func loadFriends() {
        guard let currentUser = authManager.currentUser else { return }
        
        do {
            friends = try authManager.getFriends(for: currentUser, context: modelContext)
        } catch {
            print("Failed to load friends: \(error)")
        }
    }
    
    func toggleFriendSelection(_ friendId: UUID) {
        if selectedFriends.contains(friendId) {
            selectedFriends.remove(friendId)
        } else {
            selectedFriends.insert(friendId)
        }
    }
    
    func findMidpoint() {
        isGeocoding = true
        userPins.removeAll()
        boardLocations.removeAll()
        nearbyLocations.removeAll()
        
        // Get current user
        guard let currentUser = authManager.currentUser else {
            print("DEBUG: No current user")
            return
        }
        
        print("DEBUG: Starting geocoding...")
        print("DEBUG: Current user address: \(currentUser.address)")
        
        // Geocode current user's address
        geocodeAddress(currentUser.address, name: currentUser.fullName, isCurrentUser: true)
        
        // Geocode selected friends' addresses
        let selectedFriendsList = friends.filter { selectedFriends.contains($0.id) }
        print("DEBUG: Selected \(selectedFriendsList.count) friends")
        
        for friend in selectedFriendsList {
            print("DEBUG: Friend address: \(friend.address)")
            geocodeAddress(friend.address, name: friend.fullName, isCurrentUser: false)
        }
        
        // Wait for geocoding to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            print("DEBUG: Geocoding complete. User pins: \(self.userPins.count)")
            self.calculateMidpoint()
            self.loadBoardLocations()
            self.searchNearbyLocations()
            self.isGeocoding = false
            self.showMap = true
            
            print("DEBUG: Board locations: \(self.boardLocations.count)")
            print("DEBUG: Nearby locations: \(self.nearbyLocations.count)")
        }
    }
    
    func loadBoardLocations() {
        guard let midpoint = midpoint else { return }
        let midpointLocation = CLLocation(latitude: midpoint.latitude, longitude: midpoint.longitude)
        
        print("DEBUG: Loading board locations...")
        print("DEBUG: Total boards: \(boardsManager.boards.count)")
        
        // Load locations from all boards
        for board in boardsManager.boards {
            print("DEBUG: Board '\(board.name)' has \(board.locations.count) locations")
            for location in board.locations {
                if !location.address.isEmpty {
                    print("DEBUG: Geocoding board location: \(location.name)")
                    geocodeBoardLocation(location.address, location: location, board: board, midpointLocation: midpointLocation)
                }
            }
        }
    }
    
    func geocodeBoardLocation(_ address: String, location: Location, board: Board, midpointLocation: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("DEBUG: Board location geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let coordinate = placemarks?.first?.location?.coordinate {
                let locationCoord = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                let distance = locationCoord.distance(from: midpointLocation)
                
                print("DEBUG: ✅ Board location '\(location.name)' at \(coordinate.latitude), \(coordinate.longitude)")
                
                let pin = MapPin(
                    coordinate: coordinate,
                    title: location.name,
                    subtitle: board.name,
                    color: board.color,
                    emoji: board.emoji,
                    distance: distance
                )
                
                DispatchQueue.main.async {
                    self.boardLocations.append(pin)
                    print("DEBUG: Total board locations now: \(self.boardLocations.count)")
                }
            }
        }
    }
    
    func searchNearbyLocations() {
        guard let midpoint = midpoint else {
            print("DEBUG: No midpoint for search")
            return
        }
        
        isSearchingLocations = true
        print("DEBUG: Searching for '\(activity)' near midpoint")
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = activity
        request.region = MKCoordinateRegion(
            center: midpoint,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            self.isSearchingLocations = false
            
            if let error = error {
                print("DEBUG: Search error: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else {
                print("DEBUG: No search response")
                return
            }
            
            print("DEBUG: Found \(response.mapItems.count) locations")
            
            // Filter and sort by distance from midpoint
            let midpointLoc = CLLocation(latitude: midpoint.latitude, longitude: midpoint.longitude)
            let sorted = response.mapItems.sorted { item1, item2 in
                let loc1 = CLLocation(latitude: item1.placemark.coordinate.latitude,
                                     longitude: item1.placemark.coordinate.longitude)
                let loc2 = CLLocation(latitude: item2.placemark.coordinate.latitude,
                                     longitude: item2.placemark.coordinate.longitude)
                
                return loc1.distance(from: midpointLoc) < loc2.distance(from: midpointLoc)
            }
            
            DispatchQueue.main.async {
                self.nearbyLocations = Array(sorted.prefix(10))
                print("DEBUG: Added \(self.nearbyLocations.count) nearby locations")
            }
        }
    }
    
    func distanceFromMidpoint(_ coordinate: CLLocationCoordinate2D) -> String {
        guard let midpoint = midpoint else { return "" }
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let midpointLocation = CLLocation(latitude: midpoint.latitude, longitude: midpoint.longitude)
        let distance = location.distance(from: midpointLocation)
        
        if distance < 1000 {
            return "\(Int(distance))m from midpoint"
        } else {
            return String(format: "%.1fkm from midpoint", distance / 1000)
        }
    }
    
    func confirmLocation() {
        guard let location = selectedLocation else { return }
        
        // TODO: Save the meetup with the selected location
        // For now, just open in Maps
        location.openInMaps()
        dismiss()
    }
    
    func geocodeAddress(_ address: String, name: String, isCurrentUser: Bool) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("DEBUG: Geocoding error for \(name): \(error.localizedDescription)")
                return
            }
            
            if let coordinate = placemarks?.first?.location?.coordinate {
                print("DEBUG: Geocoded \(name): \(coordinate.latitude), \(coordinate.longitude)")
                let pin = UserLocationPin(
                    coordinate: coordinate,
                    name: name,
                    address: address,
                    isCurrentUser: isCurrentUser
                )
                DispatchQueue.main.async {
                    self.userPins.append(pin)
                }
            } else {
                print("DEBUG: No coordinates found for \(name)")
            }
        }
    }
    
    func calculateMidpoint() {
        guard !userPins.isEmpty else {
            print("DEBUG: No user pins to calculate midpoint")
            return
        }
        
        print("DEBUG: Calculating midpoint from \(userPins.count) locations")
        
        // Calculate geographic midpoint
        var x = 0.0
        var y = 0.0
        var z = 0.0
        
        for pin in userPins {
            let lat = pin.coordinate.latitude * .pi / 180.0
            let lon = pin.coordinate.longitude * .pi / 180.0
            
            x += cos(lat) * cos(lon)
            y += cos(lat) * sin(lon)
            z += sin(lat)
        }
        
        let total = Double(userPins.count)
        x /= total
        y /= total
        z /= total
        
        let centralLon = atan2(y, x)
        let centralSquareRoot = sqrt(x * x + y * y)
        let centralLat = atan2(z, centralSquareRoot)
        
        let avgLat = centralLat * 180.0 / .pi
        let avgLon = centralLon * 180.0 / .pi
        
        print("DEBUG: Raw midpoint: \(avgLat), \(avgLon)")
        
        // Verify if midpoint is on land
        let calculatedMidpoint = CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon)
        let location = CLLocation(latitude: avgLat, longitude: avgLon)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first, placemark.locality != nil {
                // Point is on land
                print("DEBUG: ✅ Midpoint is on land: \(placemark.locality ?? "unknown")")
                DispatchQueue.main.async {
                    self.midpoint = calculatedMidpoint
                    self.updateMapRegion(center: calculatedMidpoint)
                }
            } else {
                // Point is in water, find nearest land
                print("DEBUG: ⚠️ Midpoint is in water, finding nearest land...")
                self.findNearestLand(to: calculatedMidpoint)
            }
        }
    }
    
    func findNearestLand(to waterPoint: CLLocationCoordinate2D) {
        // Search for any location near the water point
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant" // Generic query to find populated areas
        request.region = MKCoordinateRegion(
            center: waterPoint,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let firstResult = response?.mapItems.first {
                let landPoint = firstResult.placemark.coordinate
                print("DEBUG: ✅ Found nearest land at: \(landPoint.latitude), \(landPoint.longitude)")
                
                DispatchQueue.main.async {
                    self.midpoint = landPoint
                    self.updateMapRegion(center: landPoint)
                }
            } else {
                // Fallback: use the water point anyway
                print("DEBUG: ❌ Could not find land, using water point")
                DispatchQueue.main.async {
                    self.midpoint = waterPoint
                    self.updateMapRegion(center: waterPoint)
                }
            }
        }
    }
    
    func updateMapRegion(center: CLLocationCoordinate2D) {
        self.region.center = center
        
        // Calculate appropriate zoom level
        let maxLat = userPins.map { $0.coordinate.latitude }.max() ?? center.latitude
        let minLat = userPins.map { $0.coordinate.latitude }.min() ?? center.latitude
        let maxLon = userPins.map { $0.coordinate.longitude }.max() ?? center.longitude
        let minLon = userPins.map { $0.coordinate.longitude }.min() ?? center.longitude
        
        let latDelta = (maxLat - minLat) * 2.0
        let lonDelta = (maxLon - minLon) * 2.0
        
        self.region.span = MKCoordinateSpan(
            latitudeDelta: max(latDelta, 0.1),
            longitudeDelta: max(lonDelta, 0.1)
        )
        
        print("DEBUG: Map centered at: \(center.latitude), \(center.longitude)")
    }
    
    func coordinate(for location: CLLocationCoordinate2D, in size: CGSize) -> CGPoint {
        let centerLat = region.center.latitude
        let centerLon = region.center.longitude
        
        let latDelta = region.span.latitudeDelta
        let lonDelta = region.span.longitudeDelta
        
        let x = size.width * (0.5 + (location.longitude - centerLon) / lonDelta)
        let y = size.height * (0.5 - (location.latitude - centerLat) / latDelta)
        
        return CGPoint(x: x, y: y)
    }
    
    func openInMaps() {
        guard let midpoint = midpoint else { return }
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: midpoint))
        mapItem.name = "Meetup Point"
        mapItem.openInMaps()
    }
}

// MARK: - Friend Selection Row
struct FriendSelectionRow: View {
    let friend: User
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Avatar
                Circle()
                    .fill(isSelected ? Color.pink : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(friend.fullName.prefix(1).uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? .white : .gray)
                    )
                
                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.fullName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(friend.address)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Checkmark
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .pink : .gray)
                    .font(.title2)
            }
            .padding()
            .background(isSelected ? Color.pink.opacity(0.2) : Color.gray.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Recommended Location Card
struct RecommendedLocationCard: View {
    let name: String
    let category: String
    let distance: String
    let isFromBoard: Bool
    let emoji: String
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hexString: color).opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    if isFromBoard {
                        Text(emoji)
                            .font(.system(size: 24))
                    } else {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color(hexString: color))
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if isFromBoard {
                            Text("📌")
                                .font(.caption)
                        }
                    }
                    
                    Text(category)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(distance)
                        .font(.caption)
                        .foregroundColor(Color(hexString: color))
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .pink : .gray)
                    .font(.title3)
            }
            .padding()
            .background(isSelected ? Color.pink.opacity(0.2) : Color.gray.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 2)
            )
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    PlanMeetupView()
        .modelContainer(for: User.self, inMemory: true)
        .environment(AuthManager())
}
