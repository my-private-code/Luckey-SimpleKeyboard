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

// Define a custom error type to handle different error scenarios
enum NetworkError: Error {
    case urlError
    case serializationError
    case networkError(String)
    case dataError
    case parsingError(String)
}

// 类似测试文件中的 InputTester
class KeyBoardInput: ObservableObject, SimpleKeyboardInput {
    var imeService = ImeService()
    
    var textDocumentProxy: any UITextDocumentProxy
    private var cancellables: Set<AnyCancellable> = []
    private var cancellables2: Set<AnyCancellable> = []
    private var cancellables3: Set<AnyCancellable> = []
    
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
        
        sharedState.$commitSentence
            .sink { [weak self] commitSentence in
                self?.commitSentenceDidChange(to: commitSentence)
            }
            .store(in: &cancellables3)
    }
    
    func compositionStringDidChange(to input: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if input.isEmpty {
                self.sharedState.candidates = []
                sharedState.commitSentence = ""
            } else if self.isSymbolChar(text: input) {
                let lastChar = input.unicodeScalars.last
                if (lastChar != " ") {
                    self.textDocumentProxy.insertText(input + " ")
                    self.sharedState.commitSentence = ""
                } else {
                    self.textDocumentProxy.insertText(input)
                    if self.sharedState.selectedLanguage == "en" && !self.sharedState.commitSentence.hasSuffix(" ") {
                        self.sharedState.commitSentence.append(" " + input)
                    } else {
                        self.sharedState.commitSentence.append(input)
                    }
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
                if self.sharedState.selectedLanguage == "en" && !input.hasSuffix(" ") {
                    self.textDocumentProxy.insertText(input + " ")
                } else {
                    self.textDocumentProxy.insertText(input)
                }
                
                self.sharedState.compositionString = ""
                self.sharedState.commitCandidate = ""
                if self.sharedState.selectedLanguage == "en" && !self.sharedState.commitSentence.hasSuffix(" ") {
                    self.sharedState.commitSentence.append(" " + input)
                } else {
                    self.sharedState.commitSentence.append("" + input)
                }
            }
        }
    }
    
    func commitSentenceDidChange(to sentence: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !sentence.isEmpty {
                self.fetchPredictions(for: sentence + " ") { result in
                    switch result {
                    case .success(let response):
                        // Extract 'bert' and 'bert_cn' and convert them to [String]
                        if let bertString = response["bert"] as? String, let bertCNString = response["bert_cn"] as? String {
                            let bertArray = bertString.components(separatedBy: "\n").filter { !$0.isEmpty && $0 != "[UNK]" }
                        let bertCNArray = bertCNString.components(separatedBy: "\n").filter { !$0.isEmpty && $0 != "[UNK]" }
                            self.sharedState.candidates = self.sharedState.selectedLanguage == "en" ? bertArray : bertCNArray;
                        } else {
                            print("Error: Invalid data format")
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
                
            }
        }
    }
    
    // get predicted next words based on previous inputed words.
    func fetchPredictions(for text: String, completion: @escaping (Result<[String: Any], NetworkError>) -> Void) {
//        let urlString = "http://127.0.0.1:8080/get_end_predictions"
        let urlString = "http://47.108.172.220:8080/get_end_predictions"
        guard let url = URL(string: urlString) else {
            completion(.failure(.urlError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonObject: [String: Any] = [
            "input_text": text,
            "top_k": "10"
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            request.httpBody = jsonData
        } catch {
            completion(.failure(.serializationError))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.dataError))
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(jsonResponse))
                } else {
                    completion(.failure(.parsingError("Invalid response format")))
                }
            } catch {
                completion(.failure(.parsingError(error.localizedDescription)))
            }
        }

        task.resume()
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
