import SwiftUI

struct AddLocationsView: View {
    // 2 @State vars to store user input
    @State private var user1Location: String = ""
    @State private var user2Location: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Locations")
                .font(.title)
                .fontWeight(.bold)

            // User 1
            VStack(alignment: .leading) {
                Text("User 1 Location:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("Enter address", text: $user1Location)
                    .textFieldStyle(.roundedBorder)
            }

            // User 2
            VStack(alignment: .leading) {
                Text("User 2 Location:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                TextField("Enter address", text: $user2Location)
                    .textFieldStyle(.roundedBorder)
            }

            Button("Continue") {
                // For now, just print the inputs
                print("User1: \(user1Location), User2: \(user2Location)")
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

