import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Meet in the Middle")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                NavigationLink(destination: AddLocationsView()) {
                    Text("Start Planning")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}

