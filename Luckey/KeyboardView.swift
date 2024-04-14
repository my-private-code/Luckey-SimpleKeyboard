import SwiftUI

// TODO: delete unused file
struct KeyboardView: View {
    var viewController: KeyboardViewController
    var body: some View {
            HStack(spacing: 10) {
                ForEach(["Q", "W", "E", "R", "T", "Y"], id: \.self) { key in
                    Button(key) {
                        // Handle key press
                    }
                    .frame(width: 40, height: 40)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                }
            }
        }
}
