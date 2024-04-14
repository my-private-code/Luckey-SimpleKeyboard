//
//  KeyboardInput.swift
//  Luckey
//
//  Created by Yuwei Dong on 14/4/24.
//

import SimpleKeyboard
import SwiftUI

// 类似测试文件中的 InputTester
class KeyBoardInput: ObservableObject, SimpleKeyboardInput {
    var imeService = ImeService()
    var textDocumentProxy: any UITextDocumentProxy

    @Published var text: String = ""
    @State private var sharedState = SharedState.shared
    
    public var currentText: String {
        // This might not be directly possible as `textDocumentProxy` does not provide the entire text directly
        return self.textDocumentProxy.documentContextBeforeInput ?? "" + (self.textDocumentProxy.documentContextAfterInput ?? "")
    }
    
    func replaceAll(with text: String) {
        self.text = text

        let words = imeService.fetchEnglishWords(withPrefix: text)
        sharedState.candidates = Array(words.prefix(4))
        
        // First, delete all existing text
        if let beforeText = self.textDocumentProxy.documentContextBeforeInput {
            for _ in 0..<beforeText.count {
                self.textDocumentProxy.deleteBackward()
            }
        }
        self.textDocumentProxy.insertText(text)
    }

    init(textDocumentProxy: any UITextDocumentProxy) {
        self.textDocumentProxy = textDocumentProxy
    }
}
