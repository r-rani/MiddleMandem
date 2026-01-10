import SwiftUI

struct AddLocationsView: View {
    @State private var user1Location = ""
    @State private var user2Location = ""
    @State private var navigate = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Locations")
                .font(.title)
                .fontWeight(.bold)

            TextField("User 1 Location", text: $user1Location)
                .textFieldStyle(.roundedBorder)

            TextField("User 2 Location", text: $user2Location)
                .textFieldStyle(.roundedBorder)

            NavigationLink(
                destination: ResultsView(user1Location: user1Location, user2Location: user2Location),
                isActive: $navigate
            ) {
                EmptyView()
            }

            Button("Continue") {
                // Trigger navigation
                navigate = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 30)

            Spacer()
        }
        .padding()
    }
}

struct AddLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        AddLocationsView()
    }
}

