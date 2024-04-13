//
//  KeyboardViewController.swift
//  Luckey
//
//  Created by Yuwei Dong on 13/4/24.
//

import UIKit
import SimpleKeyboard
import SwiftUI

extension UIInputViewController: SimpleKeyboardInput {
    public var currentText: String {
        // This might not be directly possible as `textDocumentProxy` does not provide the entire text directly
        return self.textDocumentProxy.documentContextBeforeInput ?? "" + (self.textDocumentProxy.documentContextAfterInput ?? "")
    }

    public func replaceAll(with text: String) {
        // First, delete all existing text
        if let beforeText = self.textDocumentProxy.documentContextBeforeInput {
            for _ in 0..<beforeText.count {
                self.textDocumentProxy.deleteBackward()
            }
        }

        // Insert new text
        self.textDocumentProxy.insertText(text)
    }
}

struct MyKeyboardMaker {
    
    @ObservedObject var settings: KeyboardSettings
    
    func makeViewController() -> UIHostingController<SimpleStandardKeyboard> {
        UIHostingController(rootView: SimpleStandardKeyboard(settings: settings))
    }
}

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentKeyboardView()
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
//        print(textInput)
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    func presentKeyboardView() {
        let keyboardSettings = KeyboardSettings(language: .english, 
                                                // 还可以参考 SimpleKeyboard/Tests/SimpleKeyboardTests/InputTester.swift
                                                textInput: self,
                                                theme: KeyboardTheme.floating,
                                                showNumbers: true,
                                                isUpperCase: false
                                                )
        let hostingController = MyKeyboardMaker(settings: keyboardSettings).makeViewController()
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        // Set constraints for the hosting controller's view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            hostingController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}
