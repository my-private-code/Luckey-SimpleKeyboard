//
//  SimpleStandardKeyboard.swift
//  
//
//  Created by Henrik Storch on 12/25/19.
//

import SwiftUI

struct EmojiPickerView: View {
    let emojis = ["😊", "👍", "❤️", "😂", "🔥", "😍", "👏", "✔️", "💩", "👀"]
    let emojis2 = ["🥰", "😍", "😇", "😋", "🤗", "🤔", "😴", "🥵", "😱", "😓"]
    var onEmojiSelect: (String) -> Void
    
    var body: some View {
        VStack(spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: {
                            onEmojiSelect(emoji)
                        }) {
                            Text(emoji)
                                .font(.largeTitle)
                                .frame(width: 40, height: 40)
                        }
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(emojis2, id: \.self) { emoji in
                        Button(action: {
                            onEmojiSelect(emoji)
                        }) {
                            Text(emoji)
                                .font(.largeTitle)
                                .frame(width: 40, height: 40)
                        }
                    }
                }
            }
        })
        

    }
}

public struct SimpleStandardKeyboard: View, ThemeableView {
    var theme: KeyboardTheme { settings.theme }

    @ObservedObject var settings: KeyboardSettings
    @ObservedObject private var sharedState = SharedState.shared
    @State private var showEmojiPicker = false

    public init(settings: KeyboardSettings, textInput textInputOverride: Binding<String>? = nil) {
        self.settings = settings

        if let overrideStr = textInputOverride {
            self.settings.changeTextInput(to: overrideStr)
        }
    }

    var emojiButton: some View {
        Button(action: {
            showEmojiPicker.toggle()
        }) {
            Text("\u{1F60A}")
        }
    }
    
    var spaceRow: some View {
        HStack {
            if let languageIcon = settings.languageButton {
                SwitchLanguageButton()
            }
            emojiButton
            if settings.showSpace {
                SpaceKeyButton(text: $settings.text)
                    .layoutPriority(2)
            }
            if let actionIcon = settings.actionButton {
                ActionKeyButton(icon: actionIcon) {
                    self.settings.action?()
                    
                    sharedState.textDocumentProxy?.insertText("\n")
                }
            }
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    var candidatesRow: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 0) {
                ForEach($sharedState.candidates, id: \.self) { key in
                    Text(key.currentText)
                        .padding(.leading, 10)
                        .foregroundColor(.primary)
                        .background(Color.clear)
                        .onTapGesture {
                            sharedState.commitCandidate = key.currentText
                        }
                }
            }
        }
        .frame(height: 30)
        .foregroundColor(.primary)
        .background(Color.clear)
        .cornerRadius(5)
    }

    var numbersRow: some View {
        HStack(spacing: 10) {
            ForEach(Language.numbers(areUppercased: false), id: \.self) { key in
                KeyButton(text: self.$settings.text, letter: key)
            }
        }
    }
    
    var commonSymbolsRow: some View {
        HStack(spacing: 10) {
            ForEach(Language.numbers(areUppercased: true), id: \.self) { key in
                KeyButton(text: self.$settings.text, letter: key)
            }
        }
    }

    var keyboardRows: some View {
        ForEach(0..<settings.language.rows(areUppercased: settings.isUpperCase ?? false).count, id: \.self) { idx in
            HStack(spacing: 0) {
                if idx == 2 {
                    if self.settings.isUpperCase != nil {
                        ShiftKeyButton(isUpperCase: self.$settings.isUpperCase)
                        Spacer(minLength: 2)
                            .frame(maxWidth: 15)
                            .layoutPriority(2)
                    }
                } else if idx == 1 {
                    Spacer(minLength: 3)
                        .frame(maxWidth: 10)
                        .layoutPriority(11)
                }
                self.rowFor(idx)
                if idx == 2 {
                    Group {
                        Spacer(minLength: 2)
                            .frame(maxWidth: 15)
                            .layoutPriority(2)
                        if settings.language == .french {
                            FRAccentKeyButton(text: $settings.text)
                            Spacer()
                        }
                        DeleteKeyButton(text: self.$settings.text)
                    }
                } else if idx == 1 {
                    Spacer(minLength: 3)
                        .frame(maxWidth: 10)
                        .layoutPriority(11)
                }
            }
        }
    }

    fileprivate func rowFor(_ index: Int) -> some View {
        let rows = self.settings.language.rows(areUppercased: settings.isUpperCase ?? false)[index]
        return ForEach(rows, id: \.self) { key in
            Spacer(minLength: settings.language.spacing)
            KeyButton(text: self.$settings.text, letter: key)
            Spacer(minLength: settings.language.spacing)
        }
    }

    public var body: some View {
        if settings.isShown {
            VStack(spacing: 10) {
                if settings.showCandidates {
                    candidatesRow
                        .padding(.bottom, 0)
                }
                if settings.showSymbols {
                    commonSymbolsRow
                        .padding(.bottom, 5)
                }
                if settings.showNumbers {
                    numbersRow
                        .padding(.bottom, 5)
                    
                }
                keyboardRows
                spaceRow
            }
            .overlay(
                Group {
                    if showEmojiPicker {
                        EmojiPickerView { emoji in
                            showEmojiPicker = false
                            
                            sharedState.textDocumentProxy?.insertText(emoji)
                            sharedState.compositionString = ""
                            sharedState.commitSentence = ""
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.7))
                        .transition(.opacity) // Smooth transition for showing/hiding
                    }
                },
                alignment: .bottom // Align to the bottom to cover the keyboard area
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .modifier(OuterKeyboardThemingModifier(theme: theme, backroundColor: Color.clear))
        }
    }
}

struct SimpleStandardKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(colors: [.red, .green, .purple], startPoint: .bottomLeading, endPoint: .topTrailing)
            VStack {
                Spacer()
                SimpleStandardKeyboard(
                    settings: KeyboardSettings(
                        language: .english,
                        textInput: nil,
                        theme: .system,
                        actionButton: .search,
                        showNumbers: true,
                        showSpace: true,
                        isUpperCase: true))
                SimpleStandardKeyboard(
                    settings: KeyboardSettings(
                        language: .english,
                        textInput: nil,
                        theme: .system,
                        actionButton: .search,
                        showNumbers: true,
                        showSpace: false,
                        isUpperCase: true))
                    .environment(\.locale, .init(identifier: "ru"))
                    .preferredColorScheme(.dark)
            }
        }
    }
}
