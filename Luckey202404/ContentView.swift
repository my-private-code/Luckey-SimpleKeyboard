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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

