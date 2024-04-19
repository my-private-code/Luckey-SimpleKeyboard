//
//  KeyboardInput.swift
//  Luckey
//
//  Created by Yuwei Dong on 14/4/24.
//
import Foundation
import SimpleKeyboard
import SwiftUI
import Combine

// 类似测试文件中的 InputTester
class KeyBoardInput: ObservableObject, SimpleKeyboardInput {
    var imeService = ImeService()
    
    var textDocumentProxy: any UITextDocumentProxy
    private var cancellables: Set<AnyCancellable> = []
    private var cancellables2: Set<AnyCancellable> = []
    
    @ObservedObject private var sharedState = SharedState.shared
    
    public var currentText: String {
        return ""
    }
    
    func replaceAll(with text: String) {
        // do nothing for now
    }
    
    init(textDocumentProxy: any UITextDocumentProxy) {
        self.textDocumentProxy = textDocumentProxy
        
        sharedState.$compositionString
            .sink { [weak self] newCompositionString in
                self?.compositionStringDidChange(to: newCompositionString)
            }
            .store(in: &cancellables)
        
        sharedState.$commitCandidate
            .sink { [weak self] newCommitString in
                self?.commitStringDidChange(to: newCommitString)
            }
            .store(in: &cancellables2)
    }
    
    func compositionStringDidChange(to input: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if input.isEmpty {
                self.sharedState.candidates = []
            } else if self.isSymbolChar(text: input) {
                let lastChar = input.unicodeScalars.last
                if (lastChar != " ") {
                    self.textDocumentProxy.insertText(input + " ")
                } else {
                    self.textDocumentProxy.insertText(input)
                }
                self.sharedState.candidates = []
                self.sharedState.compositionString = ""
            } else {
                let words = self.sharedState.selectedLanguage == "en" ? 
                            self.imeService.fetchEnglishWords(withPrefix: input) :
                            self.imeService.fetchHanZiByPinyin(withPrefix: input)
                self.sharedState.candidates = [self.sharedState.selectedLanguage == "en" ? input + " " : input] + words
            }
        }
    }

    func commitStringDidChange(to input: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !input.isEmpty {
                self.sharedState.candidates = []
                self.textDocumentProxy.insertText(input)
                self.sharedState.compositionString = ""
                self.sharedState.commitCandidate = ""
            }
        }
    }

    
    func isSymbolChar(text: String) -> Bool {
        if let lastChar = text.unicodeScalars.last {
            return  CharacterSet.decimalDigits.contains(lastChar) ||
                    CharacterSet.symbols.contains(lastChar) ||
                    CharacterSet.punctuationCharacters.contains(lastChar) ||
                    lastChar == " "
        }
        return false
    }
}
