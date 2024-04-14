//
//  ContentView.swift
//  Luckey202404
//
//  Created by Yuwei Dong on 13/4/24.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    var body: some View {
        VStack {
            Text("Luckey Input Method")
            TextEditor(text: $text)
                .border(Color.white, width: 1)
                .background(Color.black)
                .frame(width: 200, height: 40)
            Button("Open Keyboard Settings") {
                openSettings()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        
        UIApplication.shared.open(settingsUrl)
    }
}

//struct ContentView: View {
//    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
//    @State private var isExpanded: Bool = false
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            mainContentView
//            if isExpanded {
//                expandedGridView
//                    .animation(.easeInOut, value: isExpanded)
//                    .transition(.move(edge: .bottom))
//            }
//        }
//        .edgesIgnoringSafeArea(.all)
//    }
//
//    var mainContentView: some View {
//        Button(action: {
//            withAnimation {
//                isExpanded.toggle()
//            }
//        }) {
//            Text(isExpanded ? "Collapse" : "Expand")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .font(.headline)
//        }
//    }
//
//    var expandedGridView: some View {
//        VStack {
//            Spacer()
//            LazyVGrid(columns: columns, spacing: 20) {
//                ForEach(0..<10, id: \.self) { item in
//                    Text("Item \(item)")
//                        .frame(height: 100)
//                        .background(Color.green)
//                        .cornerRadius(10)
//                }
//            }
//            .padding()
//            .background(Color.black.opacity(0.5))
//            .cornerRadius(12)
//        }
//        
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

