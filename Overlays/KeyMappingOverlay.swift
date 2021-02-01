//
//  KeyMappingOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `ControllableOverlay` type that displays an input window for keyboard mapping.
///
class KeyMappingOverlay: ControllableOverlay, TextureUser {
    
    static var textureNames: Set<String> {
        return KeyMappingOverlayData.textureNames
    }
    
    /// An enum that defines the available selections.
    ///
    private enum Selection {
        case confirm, cancel
    }
    
    /// The tracking data for the labeled confirmation element.
    ///
    private typealias LabeledConfirmationTrackingData = Selection
    
    let node: SKNode
    
    var onEnd: () -> Void
    
    /// The `UILabeledConfirmationElement` instance.
    ///
    private let labeledConfirmationElement: UILabeledConfirmationElement
    
    /// The current selection.
    ///
    private var selection: Selection?
    
    /// The flag stating whether or not the current mapping is valid.
    ///
    private var isValid: Bool {
        didSet {
            guard oldValue != isValid else { return }
            
            if isValid {
                labeledConfirmationElement.leftOptionLabel.undull()
                if let selection = selection { select(selection) }
            } else {
                labeledConfirmationElement.leftOptionLabel.dull()
                if let selection = selection { unselect(selection, nullifySelection: false) }
            }
        }
    }
    
    /// The input button for which the overlay was created.
    ///
    let inputButton: InputButton
    
    /// The key mapping that was entered.
    ///
    var mapping: (keyCode: UInt, modifiers: UInt)? = nil
    
    /// The flag stating whether or not the overlay ended with a confirmation.
    ///
    var confirmed: Bool = false
    
    /// Creates a new instance inside the given rect, with the given content and callback.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - inputButton: The `InputButton` for which to create the overlay.
    ///   - onEnd: The callback to be called when no more input is needed.
    ///
    init(rect: CGRect, inputButton: InputButton, onEnd: @escaping () -> Void) {
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound + 20
        self.onEnd = onEnd
        self.inputButton = inputButton
        
        // Create the labeled confirmation element
        labeledConfirmationElement = UILabeledConfirmationElement(
            contentOffset: KeyMappingOverlayData.LabeledConfirmation.contentOffset,
            topLabelSize: KeyMappingOverlayData.LabeledConfirmation.topLabelSize,
            middleLabelSize: KeyMappingOverlayData.LabeledConfirmation.middleLabelSize,
            bottomLabelSize: KeyMappingOverlayData.LabeledConfirmation.bottomLabelSize,
            backgroundImage: KeyMappingOverlayData.LabeledConfirmation.backgroundImage,
            backgroundBorder: KeyMappingOverlayData.LabeledConfirmation.backgroundBorder,
            backgroundOffset: KeyMappingOverlayData.LabeledConfirmation.backgroundOffset)
        
        // Set the contents
        labeledConfirmationElement.topLabel.text = "Press the new key to use:"
        labeledConfirmationElement.middleLabel.text = inputButton.symbolFromMapping
        labeledConfirmationElement.leftOptionLabel.text = "Confirm"
        labeledConfirmationElement.rightOptionLabel.text = "Cancel"
        
        // Add tracking data
        labeledConfirmationElement.addTrackinDataForLeftOption(data: LabeledConfirmationTrackingData.confirm)
        labeledConfirmationElement.addTrackinDataForRightOption(data: LabeledConfirmationTrackingData.cancel)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(labeledConfirmationElement)
        let tree = UITree(rect: rect, root: container)
        if let treeNode = tree.generate() {
            treeNode.zPosition = 1
            node.addChild(treeNode)
        }
        
        // Check validity
        if let mapping = KeyboardMapping.mappingFor(inputButton: inputButton), !mapping.isEmpty {
            isValid = true
        } else {
            isValid = false
            labeledConfirmationElement.leftOptionLabel.dull()
        }
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
        case .confirm:
            labeledConfirmationElement.leftOptionLabel.unflash()
            labeledConfirmationElement.leftOptionLabel.restore()
        case .cancel:
            labeledConfirmationElement.rightOptionLabel.unflash()
            labeledConfirmationElement.rightOptionLabel.restore()
        }
        if nullifySelection, self.selection == selection { self.selection = nil }
    }
    
    /// Selects the given `Selection`.
    ///
    /// - Parameter selection: The new selection.
    ///
    private func select(_ selection: Selection) {
        switch selection {
        case .confirm:
            guard isValid else { break }
            labeledConfirmationElement.leftOptionLabel.flash()
            labeledConfirmationElement.leftOptionLabel.whiten()
        case .cancel:
            labeledConfirmationElement.rightOptionLabel.flash()
            labeledConfirmationElement.rightOptionLabel.whiten()
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
            case .confirm:
                guard isValid else { return }
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
        if let data = event.data as? LabeledConfirmationTrackingData {
            if let selection = selection { unselect(selection) }
            select(data)
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? LabeledConfirmationTrackingData {
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
        
        if KeyboardKeyCode(rawValue: event.keyCode)?.isSpecialKey == false,
            let str = KeyboardMapping.convertMappingToSymbol(keyCode: event.keyCode, modifiers: event.modifiers) {
         
            labeledConfirmationElement.middleLabel.style = .goodValue
            labeledConfirmationElement.middleLabel.text = str
            mapping = (event.keyCode, event.modifiers)
            isValid = true
        } else {
            labeledConfirmationElement.middleLabel.style = .badValue
            labeledConfirmationElement.middleLabel.text = "INVALID KEY"
            mapping = nil
            isValid = false
        }
    }
}

/// A struct that defines the data associated with the `KeyMappingOverlay` class.
///
fileprivate struct KeyMappingOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [LabeledConfirmation.backgroundImage]
    }
    
    private init() {}
    
    /// The `UILabeledConfirmationOverlay` data.
    ///
    struct LabeledConfirmation {
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
