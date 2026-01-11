//  HomeView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

// MARK: - Location Manager
@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            location = locations.first
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            
            if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
                startUpdating()
            }
        }
    }
}

// MARK: - Map Pin Model
struct MapPin: Identifiable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
    let color: String
    let emoji: String
    var distance: Double = 0 // Distance in meters
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MapPin, rhs: MapPin) -> Bool {
        lhs.id == rhs.id
    }
    
    // Formatted distance
    var distanceText: String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            let km = distance / 1000
            return String(format: "%.1fkm", km)
        }
    }
}

// MARK: - Home View with Map Card & List
struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var mapPins: [MapPin] = []
    @State private var selectedPin: MapPin?
    @State private var showingLocationError = false
    @State private var showPlanMeetup = false // NEW
    
    var boards: [Board] = []
    
    var sortedPins: [MapPin] {
        mapPins.sorted { $0.distance < $1.distance }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Logo & App Name
                        VStack(spacing: 12) {
                            Image("midz_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                            
                            Text("Midz")
                                .font(.system(size: 36))
                                .fontWeight(.bold)
                                .foregroundColor(.pink)
                        }
                        .padding(.top, 20)
                        
                        // Plan a Meetup Button
                        Button(action: {
                            showPlanMeetup = true
                        }) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.title3)
                                Text("Plan a Meetup")
                                    .fontWeight(.semibold)
                                    .font(.headline)
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
                            .shadow(color: .pink.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        
                        // Map Card
                        VStack(spacing: 0) {
                            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: mapPins) { pin in
                                MapAnnotation(coordinate: pin.coordinate) {
                                    Button(action: {
                                        selectedPin = pin
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hexString: pin.color))
                                                .frame(width: 36, height: 36)
                                                .shadow(radius: 4)
                                            
                                            Text(pin.emoji)
                                                .font(.system(size: 18))
                                        }
                                    }
                                }
                            }
                            .frame(height: 300)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.pink.opacity(0.3), lineWidth: 2)
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Locations List Header
                        HStack {
                            Text("Nearby Locations")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if !sortedPins.isEmpty {
                                Text("Sorted by distance")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Locations List
                        if mapPins.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "mappin.slash")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                                
                                Text("No locations yet")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                Text("Add locations to your boards to see them here")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(sortedPins) { pin in
                                    LocationListCard(pin: pin, isSelected: selectedPin?.id == pin.id) {
                                        selectedPin = pin
                                        withAnimation {
                                            region.center = pin.coordinate
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                locationManager.requestPermission()
                geocodeAllLocations()
            }
            .onChange(of: locationManager.location) { _, newLocation in
                if let location = newLocation {
                    region.center = location.coordinate
                    updateDistances()
                }
            }
            .alert("Location Access Required", isPresented: $showingLocationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enable location access in Settings to see your location on the map.")
            }
            .sheet(item: $selectedPin) { pin in
                LocationDetailSheet(pin: pin)
            }
            .sheet(isPresented: $showPlanMeetup) {
                PlanMeetupView()
            }
        }
    }
    
    // Geocode all locations from boards
    func geocodeAllLocations() {
        mapPins.removeAll()
        
        for board in boards {
            for location in board.locations {
                if !location.address.isEmpty {
                    geocodeAddress(location.address, location: location, board: board)
                }
            }
        }
    }
    
    func geocodeAddress(_ address: String, location: Location, board: Board) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                var pin = MapPin(
                    coordinate: coordinate,
                    title: location.name,
                    subtitle: board.name,
                    color: board.color,
                    emoji: board.emoji
                )
                
                // Calculate distance if user location is available
                if let userLocation = locationManager.location {
                    let pinLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    pin.distance = userLocation.distance(from: pinLocation)
                }
                
                mapPins.append(pin)
            }
        }
    }
    
    func updateDistances() {
        guard let userLocation = locationManager.location else { return }
        
        for i in 0..<mapPins.count {
            let pinLocation = CLLocation(
                latitude: mapPins[i].coordinate.latitude,
                longitude: mapPins[i].coordinate.longitude
            )
            mapPins[i].distance = userLocation.distance(from: pinLocation)
        }
    }
}

// MARK: - Location List Card
struct LocationListCard: View {
    let pin: MapPin
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Emoji Badge
                ZStack {
                    Circle()
                        .fill(Color(hexString: pin.color).opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    Text(pin.emoji)
                        .font(.system(size: 24))
                }
                
                // Location Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(pin.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(pin.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Distance Badge
                VStack(alignment: .trailing, spacing: 4) {
                    Text(pin.distanceText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hexString: pin.color))
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(Color(hexString: pin.color).opacity(0.6))
                        .font(.title3)
                }
            }
            .padding()
            .background(isSelected ? Color(hexString: pin.color).opacity(0.2) : Color.gray.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hexString: pin.color) : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Location Detail Sheet
struct LocationDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let pin: MapPin
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Emoji
                    ZStack {
                        Circle()
                            .fill(Color(hexString: pin.color).opacity(0.3))
                            .frame(width: 100, height: 100)
                        
                        Text(pin.emoji)
                            .font(.system(size: 50))
                    }
                    .padding(.top, 20)
                    
                    // Location Name
                    Text(pin.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Board Badge
                    HStack {
                        Text(pin.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hexString: pin.color).opacity(0.3))
                            .cornerRadius(20)
                    }
                    
                    // Distance
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.pink)
                        Text(pin.distanceText + " away")
                            .foregroundColor(.white)
                    }
                    .font(.headline)
                    
                    Spacer()
                    
                    // Open in Maps Button
                    Button(action: {
                        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: pin.coordinate))
                        mapItem.name = pin.title
                        mapItem.openInMaps()
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
        }
    }
}

#Preview {
    HomeView(boards: [
        Board(name: "Restaurants", emoji: "🍽️", color: "#FF2F92", locations: [
            Location(name: "Joe's Pizza", address: "123 Main St, New York, NY")
        ]),
        Board(name: "Coffee", emoji: "☕️", color: "#FF69B4", locations: [
            Location(name: "Starbucks", address: "456 Park Ave, New York, NY")
        ])
    ])
}
