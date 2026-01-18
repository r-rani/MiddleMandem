//
//  Color+Hex.swift
//  Midz
//
//  Adds support for initializing `Color` using hex strings.
//

import SwiftUI

/// Allows creation of a `Color` from a hexadecimal color string
extension Color {

    /// Initializes a color using a hex string (e.g. "#FF2F92" or "FF2F92")
    /// - Parameter hexString: A 6-character hexadecimal color string
    init(hexString: String) {

        // Remove non-hexadecimal characters
        let hex = hexString.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )

        // Convert hex string to integer value
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        // Extract RGB components
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255

        // Initialize Color with RGB values
        self.init(red: r, green: g, blue: b)
    }
}
