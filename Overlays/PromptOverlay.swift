//
//  PromptOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/23/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A protocol that defines the prompt, used to manage text input.
///
protocol Prompt {
    
    /// Appends a character to the end of the buffer.
    ///
    /// - Parameter character: The character to append.
    /// - Returns: `true` if the character could be appended to the buffer, `false` otherwise.
    ///
    func append(character: String) -> Bool
    
    /// Removes the last character from the buffer.
    ///
    /// - Returns: The removed character, or `nil` if the buffer was empty.
    ///
    func removeLast() -> String?
    
    /// Removes all characters from the buffer.
    ///
    func removeAll()
    
    /// Retrieves the result.
    ///
    /// - Returns: A `(String, Bool)` tuple, where the first value contains the resulting text and
    ///   the second value contains a flag stating whether or not the result is valid.
    ///
    func result() -> (text: String, isValid: Bool)
}

/// A `Prompt` type that manages quantities.
///
class QuantityPrompt: Prompt {
    
    /// The quantity range.
    ///
    private let range: ClosedRange<Int>
    
    /// The character buffer.
    ///
    private var buffer: [String]
    
    /// Creates a new instance from the given range.
    ///
    /// - Parameter range: A closed range of positive values greater than `0`, defining the valid values.
    ///
    init(range: ClosedRange<Int>) {
        assert(range.lowerBound > 0)
        
        self.range = range
        
        buffer = []
        var x = range.upperBound
        repeat {
            buffer.append("\(x % 10)")
            x /= 10
        } while x != 0
        buffer.reverse()
    }
    
    func append(character: String) -> Bool {
        buffer.append(character)
        let text = buffer.reduce("") { (previous, character) in previous + character }
        if let quantity = Int(text, radix: 10), range.contains(quantity) { return true }
        buffer.removeLast()
        return false
    }
    
    func removeLast() -> String? {
        return buffer.popLast()
    }
    
    func removeAll() {
        buffer = []
    }
    
    func result() -> (text: String, isValid: Bool) {
        let text = buffer.reduce("") { (previous, character) in previous + character }
        let quantity = Int(text, radix: 10)
        return (text, quantity != nil ? range.contains(quantity!) : false)
    }
}

/// A `Prompt` type that manages words.
///
class WordPrompt: Prompt {
    
    /// The word length.
    ///
    private let length: ClosedRange<Int>
    
    /// The validation function.
    ///
    private let isValidCharacter: (String) -> Bool
    
    /// The character buffer.
    ///
    private var buffer: [String]
    
    /// Creates a new instance from the given length and validation function.
    ///
    /// - Parameters:
    ///   - length: A closed range of positive values greater than `0`, stating the word length.
    ///   - isValidCharacter: A validation function that takes a character and returns whether
    ///     or not it can be appended to the buffer.
    ///
    init(length: ClosedRange<Int>, isValidCharacter: @escaping (String) -> Bool) {
        assert(length.lowerBound > 0)
        
        self.length = length
        self.isValidCharacter = isValidCharacter
        buffer = []
    }
    
    func append(character: String) -> Bool {
        guard buffer.count < length.upperBound, isValidCharacter(character) else { return false }
        buffer.append(character)
        return true
    }
    
    func removeLast() -> String? {
        return buffer.popLast()
    }
    
    func removeAll() {
        buffer = []
    }
    
    func result() -> (text: String, isValid: Bool) {
        let text = buffer.reduce("") { (previous, character) in previous + character }
        return (text, length.contains(buffer.count))
    }
}

/// A `Prompt` type that manages percentages.
///
class PercentagePrompt: Prompt {
    
    /// The percentage range.
    ///
    private let range: ClosedRange<Int>
    
    /// The character buffer.
    ///
    private var buffer: [String]
    
    /// Creates a new instance from the given range.
    ///
    /// - Parameters:
    ///   - range: A closed range of positive values, defining the valid values.
    ///   - initialValue: A value that falls within the provided range to set as the initial value.
    ///
    init(range: ClosedRange<Int>, initialValue: Int) {
        assert(range.lowerBound >= 0)
        assert(range.contains(initialValue))
        
        self.range = range
        
        buffer = []
        var x = initialValue
        repeat {
            buffer.append("\(x % 10)")
            x /= 10
        } while x != 0
        buffer.reverse()
    }
    
    func append(character: String) -> Bool {
        if buffer.count > 0 && Int(buffer[0], radix: 10) == 0 { return false }
        buffer.append(character)
        let text = buffer.reduce("") { (previous, character) in previous + character }
        if let percentage = Int(text, radix: 10), range.contains(percentage) { return true }
        buffer.removeLast()
        return false
    }
    
    func removeLast() -> String? {
        return buffer.popLast()
    }
    
    func removeAll() {
        buffer = []
    }
    
    func result() -> (text: String, isValid: Bool) {
        let text = buffer.reduce("") { (previous, character) in previous + character }
        let percentage = Int(text, radix: 10)
        return (text != "" ? text + "%" : text, percentage != nil ? range.contains(percentage!) : false)
    }
}

/// A `ControllableOverlay` type that displays a prompt window.
///
class PromptOverlay: ControllableOverlay, TextureUser {
    
    static var textureNames: Set<String> {
        return PromptOverlayData.textureNames
    }
    
    /// An enum that defines the available selections.
    ///
    private enum Selection {
        case prompt, confirm, cancel
    }
    
    /// The tracking data for the prompt element.
    ///
    private typealias PromptTrackingData = Selection
    
    let node: SKNode
    
    var onEnd: () -> Void
    
    /// The `UIPromptElement` instance.
    ///
    private let promptElement: UIPromptElement
    
    /// The current selection.
    ///
    private var selection: Selection?
    
    /// The prompt.
    ///
    private var prompt: Prompt
    
    /// The flag stating whether or not the current prompt text is valid.
    ///
    private var isValid: Bool {
        didSet {
            guard oldValue != isValid else { return }
            
            if isValid {
                promptElement.leftOptionLabel.undull()
                if let selection = selection { select(selection) }
            } else {
                promptElement.leftOptionLabel.dull()
                if let selection = selection { unselect(selection, nullifySelection: false) }
            }
        }
    }
    
    /// The text that was entered in the prompt.
    ///
    var promptText: String?
    
    /// The flag stating whether or not the overlay ended with a confirmation.
    ///
    var confirmed: Bool = false
    
    /// Creates a new instance inside the given rect, with the given content and callback.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - content: The textual content to present.
    ///   - prompt: The `Prompt` instance to use when handling text input.
    ///   - onEnd: The callback to be called when no more input is needed.
    ///
    private init(rect: CGRect, content: String, prompt: Prompt, onEnd: @escaping () -> Void) {
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound + 20
        self.prompt = prompt
        self.onEnd = onEnd
        
        // Create the prompt element
        promptElement = UIPromptElement(contentOffset: PromptOverlayData.Prompt.contentOffset,
                                        topLabelSize: PromptOverlayData.Prompt.topLabelSize,
                                        middleLabelSize: PromptOverlayData.Prompt.middleLabelSize,
                                        bottomLabelSize: PromptOverlayData.Prompt.bottomLabelSize,
                                        backgroundImage: PromptOverlayData.Prompt.backgroundImage,
                                        backgroundBorder: PromptOverlayData.Prompt.backgroundBorder,
                                        backgroundOffset: PromptOverlayData.Prompt.backgroundOffset)
        
        // Set the contents
        promptElement.topLabel.text = content
        promptElement.promptLabel.text = prompt.result().text
        promptElement.leftOptionLabel.text = "Confirm"
        promptElement.rightOptionLabel.text = "Cancel"
        
        // Add tracking data
        promptElement.addTrackinDataForPrompt(data: PromptTrackingData.prompt)
        promptElement.addTrackinDataForLeftOption(data: PromptTrackingData.confirm)
        promptElement.addTrackinDataForRightOption(data: PromptTrackingData.cancel)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(promptElement)
        let tree = UITree(rect: rect, root: container)
        if let treeNode = tree.generate() {
            treeNode.zPosition = 1
            node.addChild(treeNode)
        }
        
        // Check validity
        if !prompt.result().isValid {
            isValid = false
            promptElement.leftOptionLabel.dull()
        } else {
            isValid = true
        }
        
        // Update the input marker
        promptElement.updateMarker()
    }
    
    /// Unselects the given `Selection`.
    ///
    /// - Parameters:
    ///   - selection: The selection.
    ///   - nullifySelection: A flag stating whether or not the instance's `selection` property should
    ///     be set to `nil` when it is the same as the method's parameter. The default value is `true`.
    ///
    private func unselect(_ selection: Selection, nullifySelection: Bool = true) {
        switch selection {
        case .prompt:
            break
        case .confirm:
            promptElement.leftOptionLabel.unflash()
            promptElement.leftOptionLabel.restore()
        case .cancel:
            promptElement.rightOptionLabel.unflash()
            promptElement.rightOptionLabel.restore()
        }
        if nullifySelection, self.selection == selection { self.selection = nil }
    }
    
    /// Selects the given `Selection`.
    ///
    /// - Parameter selection: The new selection.
    ///
    private func select(_ selection: Selection) {
        switch selection {
        case .prompt:
            break
        case .confirm:
            guard isValid else { break }
            promptElement.leftOptionLabel.flash()
            promptElement.leftOptionLabel.whiten()
        case .cancel:
            promptElement.rightOptionLabel.flash()
            promptElement.rightOptionLabel.whiten()
        }
        self.selection = selection
    }
    
    func update(deltaTime seconds: TimeInterval) {
        
    }
    
    func didReceiveEvent(_ event: Event) {
        switch event.type {
        case .mouseDown:
            if let event = event as? MouseEvent {
                mouseDownEvent(event)
            }
        case .mouseEntered:
            if let event = event as? MouseEvent {
                mouseEnteredEvent(event)
            }
        case .mouseExited:
            if let event = event as? MouseEvent {
                mouseExitedEvent(event)
            }
        case .keyDown:
            if let event = event as? KeyboardEvent {
                keyDownEvent(event)
            }
        default:
            break
        }
    }
    
    /// Handles mouse down events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseDownEvent(_ event: MouseEvent) {
        guard let selection = selection else { return }
        
        switch event.button {
        case .left:
            switch selection {
            case .prompt:
                return
            case .confirm:
                guard isValid else { return }
                promptText = prompt.result().text
                confirmed = true
            case .cancel:
                confirmed = false
            }
            onEnd()
        default:
            break
        }
    }
    
    /// Handles mouse entered events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseEnteredEvent(_ event: MouseEvent) {
        if let data = event.data as? PromptTrackingData {
            if let selection = selection { unselect(selection) }
            select(data)
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? PromptTrackingData {
            unselect(data)
        }
    }
    
    /// Handles keyboard key down events.
    ///
    /// - Parameter event: The event.
    ///
    private func keyDownEvent(_ event: KeyboardEvent) {
        if let mapping = KeyboardMapping.mappingFor(keyCode: event.keyCode, modifiers: event.modifiers) {
            // Note: `.cancel` and ``.confirm` must be bound to unremappable (special) keys
            if mapping.contains(.confirm) {
                if isValid {
                    promptText = prompt.result().text
                    confirmed = true
                    onEnd()
                }
                return
            } else if mapping.contains(.cancel) {
                confirmed = false
                onEnd()
                return
            }
        }
        
        if event.keyCode == KeyboardKeyCode.delete.rawValue {
            let _ = prompt.removeLast()
            isValid = prompt.result().isValid
        } else {
            let _ = prompt.append(character: event.characters)
            isValid = prompt.result().isValid
        }
        promptElement.promptLabel.text = prompt.result().text
        promptElement.updateMarker()
    }
    
    /// Creates a prompt overlay for item purchase.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - item: The `StackableItem` for which to create the prompt.
    ///   - maxQuantity: The maximum quantity that can be purchased, no greater than the item's stack count.
    ///   - onEnd: The callback to be called when no more input is needed.
    /// - Returns: A new `PromptOverlay` for item purchase.
    ///
    class func purchasePrompt(rect: CGRect, item: StackableItem, maxQuantity: Int, onEnd: @escaping () -> Void)
        -> PromptOverlay {
        
        assert(item.stack.count > 0 && maxQuantity > 0)
        
        let content = "Quantity to buy - \(item.name):"
        let prompt = QuantityPrompt(range: 1...min(item.stack.count, maxQuantity))
        return PromptOverlay(rect: rect, content: content, prompt: prompt, onEnd: onEnd)
    }
    
    /// Creates a prompt overlay for item selling.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - item: The `StackableItem` for which to create the prompt.
    ///   - maxQuantity: The maximum quantity that can be sold, no greater than the item's stack count.
    ///   - onEnd: The callback to be called when no more input is needed.
    /// - Returns: A new `PromptOverlay` for item selling.
    ///
    class func sellingPrompt(rect: CGRect, item: StackableItem, maxQuantity: Int, onEnd: @escaping () -> Void)
        -> PromptOverlay {
        
        assert(item.stack.count > 0 && maxQuantity > 0)
        
        let content = "Quantity to sell - \(item.name):"
        let prompt = QuantityPrompt(range: 1...min(item.stack.count, maxQuantity))
        return PromptOverlay(rect: rect, content: content, prompt: prompt, onEnd: onEnd)
    }
    
    /// Creates a prompt overlay for item discarding.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - item: The `StackableItem` for which to create the prompt.
    ///   - onEnd: The callback to be called when no more input is needed.
    /// - Returns: A new `PromptOverlay` for item discarding.
    ///
    class func discardingPrompt(rect: CGRect, item: StackableItem, onEnd: @escaping () -> Void) -> PromptOverlay {
        assert(item.stack.count > 0)
        
        let content = "Quantity to discard - \(item.name):"
        let prompt = QuantityPrompt(range: 1...item.stack.count)
        return PromptOverlay(rect: rect, content: content, prompt: prompt, onEnd: onEnd)
    }
    
    /// Creates a prompt overlay for persona name.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - onEnd: The callback to be called when no more input is needed.
    /// - Returns: A new `PromptOverlay` for persona name.
    ///
    class func personaNamePrompt(rect: CGRect, onEnd: @escaping () -> Void) -> PromptOverlay {
        let content = "Name the character:"
        let prompt = WordPrompt(length: 3...16) { "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains($0.uppercased()) }
        return PromptOverlay(rect: rect, content: content, prompt: prompt, onEnd: onEnd)
    }
    
    /// Creates a prompt overlay for volume setting.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - initialValue: The initial value to set, in the range 0.0...1.0.
    ///   - onEnd: The callback to be called when no more input is needed.
    /// - Returns: A new `PromptOverlay` for volume setting.
    ///
    class func volumePrompt(rect: CGRect, initialValue: Float, onEnd: @escaping () -> Void) -> PromptOverlay {
        let content = "Enter the new volume:"
        let initialValue = max(0, min(Int((initialValue * 100.0).rounded()), 100))
        let prompt = PercentagePrompt(range: 0...100, initialValue: initialValue)
        return PromptOverlay(rect: rect, content: content, prompt: prompt, onEnd: onEnd)
    }
}

/// A struct that defines the data associated with the `PromptOverlay` class.
///
fileprivate struct PromptOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Prompt.backgroundImage]
    }
    
    private init() {}
    
    /// The `UIConfirmationOverlay` data.
    ///
    struct Prompt {
        private init() {}
        static let contentOffset: CGFloat = 6.0
        static let topLabelSize = CGSize(width: 300.0, height: 54.0)
        static let middleLabelSize = CGSize(width: 160.0, height: 54.0)
        static let bottomLabelSize = CGSize(width: 90.0, height: 30.0)
        static let backgroundImage = "UI_Window_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat =  10.0
    }
}
