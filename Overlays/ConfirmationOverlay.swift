//
//  ConfirmationOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/22/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `ControllableOverlay` type that displays a confirmation window.
///
class ConfirmationOverlay: ControllableOverlay, TextureUser {
    
    static var textureNames: Set<String> {
        return ConfirmationOverlayData.textureNames
    }
    
    /// An enum that defines the available selections.
    ///
    private enum Selection {
        case confirm, cancel
    }
    
    /// The tracking data for the confirmation element.
    ///
    private typealias ConfirmationTrackingData = Selection
    
    let node: SKNode
    
    var onEnd: () -> Void
    
    /// The `UIConfirmationElement` instance.
    ///
    private let confirmationElement: UIConfirmationElement
    
    /// The current selection.
    ///
    private var selection: Selection?
    
    /// The text to set for the options. The default value is `("Confirm", "Cancel")`.
    ///
    var optionText: (confirm: String, cancel: String) {
        get {
            return (confirmationElement.leftOptionLabel.text ?? "", confirmationElement.rightOptionLabel.text ?? "")
        }
        set {
            confirmationElement.leftOptionLabel.text = newValue.confirm
            confirmationElement.rightOptionLabel.text = newValue.cancel
        }
    }
    
    /// The flag stating whether or not the overlay ended with a confirmation.
    ///
    var confirmed: Bool = false
    
    /// Creates a new instance inside the given rect, with the given content and callback.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - content: The textual content to present.
    ///   - onEnd: The callback to be called when no more input is needed.
    ///
    init(rect: CGRect, content: String, onEnd: @escaping () -> Void) {
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound + 20
        self.onEnd = onEnd
        
        // Create the confirmation element
        confirmationElement = UIConfirmationElement(
            contentOffset: ConfirmationOverlayData.Confirmation.contentOffset,
            topLabelSize: ConfirmationOverlayData.Confirmation.topLabelSize,
            bottomLabelSize: ConfirmationOverlayData.Confirmation.bottomLabelSize,
            backgroundImage: ConfirmationOverlayData.Confirmation.backgroundImage,
            backgroundBorder: ConfirmationOverlayData.Confirmation.backgroundBorder,
            backgroundOffset: ConfirmationOverlayData.Confirmation.backgroundOffset)
        
        // Set the contents
        confirmationElement.topLabel.text = content
        confirmationElement.leftOptionLabel.text = "Confirm"
        confirmationElement.rightOptionLabel.text = "Cancel"
        
        // Add tracking data
        confirmationElement.addTrackinDataForLeftOption(data: ConfirmationTrackingData.confirm)
        confirmationElement.addTrackinDataForRightOption(data: ConfirmationTrackingData.cancel)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(confirmationElement)
        let tree = UITree(rect: rect, root: container)
        if let treeNode = tree.generate() {
            treeNode.zPosition = 1
            node.addChild(treeNode)
        }
    }
    
    /// Unselects the given `Selection`.
    ///
    /// - Parameter selection: The selection.
    ///
    private func unselect(_ selection: Selection) {
        switch selection {
        case .confirm:
            confirmationElement.leftOptionLabel.unflash()
            confirmationElement.leftOptionLabel.restore()
        case .cancel:
            confirmationElement.rightOptionLabel.unflash()
            confirmationElement.rightOptionLabel.restore()
        }
        if self.selection == selection { self.selection = nil }
    }
    
    /// Selects the given `Selection`.
    ///
    /// - Parameter selection: The new selection.
    ///
    private func select(_ selection: Selection) {
        switch selection {
        case .confirm:
            confirmationElement.leftOptionLabel.flash()
            confirmationElement.leftOptionLabel.whiten()
        case .cancel:
            confirmationElement.rightOptionLabel.flash()
            confirmationElement.rightOptionLabel.whiten()
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
        if let data = event.data as? ConfirmationTrackingData {
            if let selection = selection { unselect(selection) }
            select(data)
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? ConfirmationTrackingData {
            unselect(data)
        }
    }
    
    /// Handles keyboard key down events.
    ///
    /// - Parameter event: The event.
    ///
    private func keyDownEvent(_ event: KeyboardEvent) {
        guard let mapping = KeyboardMapping.mappingFor(keyCode: event.keyCode, modifiers: event.modifiers)
            else { return }
        
        if mapping.contains(.confirm) {
            confirmed = true
            onEnd()
        } else if mapping.contains(.cancel) {
            confirmed = false
            onEnd()
        }
    }
}

/// A struct that defines the data associated with the `ConfirmationOverlay` class.
///
fileprivate struct ConfirmationOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Confirmation.backgroundImage]
    }
    
    private init() {}
    
    /// The `UIConfirmationOverlay` data.
    ///
    struct Confirmation {
        private init() {}
        static let contentOffset: CGFloat = 6.0
        static let topLabelSize = CGSize(width: 300.0, height: 70.0)
        static let bottomLabelSize = CGSize(width: 90.0, height: 30.0)
        static let backgroundImage = "UI_Window_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat =  10.0
    }
}
