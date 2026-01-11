//  ResultsView.swift
//  Midz
//
//  Created by Komal Khan on 2026-01-10.
//

import SwiftUI
import MapKit

struct ResultsView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Image("midz_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .padding(.top, 40)
                
                Text("Find Your Midpoint")
                    .font(.largeTitle)
                    .foregroundColor(Color(hexString: "#FF2F92"))
                    .bold()

                Text("Coming Soon!")
                    .foregroundColor(.white)
                    .font(.headline)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ResultsView()
}
