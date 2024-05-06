//
//  KeyboardSettings.swift
//  
//
//  Created by Henrik Storch on 12/25/19.
//

import Combine
import SwiftUI

public protocol SimpleKeyboardInput {
    var currentText: String { get }
    mutating func replaceAll(with text: String)
}

extension Binding: SimpleKeyboardInput where Value == String {
    public var currentText: String {
        self.wrappedValue
    }

    public mutating func replaceAll(with text: String) {
        self.wrappedValue = text
    }
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
extension NSTextField: SimpleKeyboardInput {
    public var currentText: String {
        self.stringValue
    }

    public func replaceAll(with text: String) {
        stringValue = text
    }
}
#endif

#if canImport(UIKit)
import UIKit

extension UITextField: SimpleKeyboardInput {
    public var currentText: String {
        self.text ?? ""
    }

    public func replaceAll(with text: String) {
        self.text = text
    }
}
#endif

public class KeyboardSettings: ObservableObject {
    public var text: String = "" {
        didSet {
            textInput?.replaceAll(with: text)
        }
    }

    @Published public var language: Language

    public var theme: KeyboardTheme

    /// `nil` mean there is no action icon
    var actionButton: Icon?
    var languageButton: Icon?

    public var textInput: SimpleKeyboardInput?
    public var action: (() -> Void)?

    @Published public var isShown = true

    @Published public var showNumbers: Bool
    @Published public var showSymbols: Bool
    @Published public var showSpace: Bool
    @Published public var showCandidates: Bool

    /// `nil` mean there is no need to switch, so there will be no shift-key
    @Published public var isUpperCase: Bool?

    /// `textInput` should be `nil` when working directly with SwiftUI,
    /// in that case you would bind your input directly to the `textInput` of the Keyboard
    public init(
        language: Language,
        textInput: SimpleKeyboardInput?,
        theme: KeyboardTheme = .system,
        actionButton: Icon? = .done,
        languageButton: Icon? = .language,
        showNumbers: Bool = false,
        showSymbols: Bool = false,
        showSpace: Bool = true,
        showCandidates: Bool = true,
        isUpperCase: Bool? = nil,
        action: (() -> Void)? = nil) {
            self.textInput = textInput
            self.theme = theme
            self.language = language
            self.action = action
            self.showNumbers = showNumbers
            self.showSymbols = showSymbols
            self.showSpace = showSpace
            self.isUpperCase = isUpperCase
            self.actionButton = actionButton
            self.languageButton = languageButton
            self.showCandidates = showCandidates
        }

    func changeTextInput(to newInput: SimpleKeyboardInput) {
        self.textInput = newInput
        self.text = newInput.currentText
    }
}


public class SharedState: ObservableObject {
    public static let shared = SharedState()
    
    @Published public var candidates: [String] = []
    @Published public var selectedLanguage: String = "en"
    
    // 用户当前输入字符串
    @Published public var compositionString: String = ""
    // 用户选中的单词
    @Published public var commitCandidate: String = ""
    
    // If user input any non-alphabeta symbols, then reset commitSentence to empty string.
    // Otherwise append commitCandidate to commitSentence, to be used to predict next word.
    @Published public var commitSentence: String = ""
    
    @Published public var textDocumentProxy: (any UITextDocumentProxy)?

    // Private initializer to ensure Singleton usage
    private init() {}  
}
