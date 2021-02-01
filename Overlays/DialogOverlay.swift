//
//  DialogOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/1/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `ControllableOverlay` type that displays a dialog between the protagonist and a trader NPC.
///
class DialogOverlay: ControllableOverlay, TextureUser {
    
    static var textureNames: Set<String> {
        return DialogOverlayData.textureNames
    }
    
    /// An enum that defines the available selections.
    ///
    private enum Selection {
        case text, trade, leave
    }
    
    /// The tracking data for the dialog element.
    ///
    private typealias DialogTrackingData = Selection
    
    private var subject: Entity? {
        return Game.subject
    }
    
    private var portraitComponent: PortraitComponent? {
        return subject?.component(ofType: PortraitComponent.self)
    }
    
    let node: SKNode
    
    var onEnd: () -> Void
    
    /// The `UIDialogElement` instance.
    ///
    private let dialogElement: UIDialogElement
    
    /// The current selection.
    ///
    private var selection: Selection?
    
    /// The current scroll value. Negative goes up, positive goes down, `nil` stops.
    ///
    private var scroll: CGFloat?
    
    /// The speed of main text scrolling, equal or greater than `1.0`.
    ///
    var scrollSpeed: CGFloat = 16.0 {
        didSet { scrollSpeed = max(1.0, scrollSpeed) }
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - text: The text to display.
    ///   - rect: The bounding rect.
    ///   - onEnd: The callback to be called when no more input is needed.
    ///
    init(text: String, rect: CGRect, onEnd: @escaping () -> Void) {
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound + 4
        self.onEnd = onEnd
        
        // Create the dialog element
        dialogElement = UIDialogElement(text: text,
                                        entryOffset: DialogOverlayData.Dialog.entryOffset,
                                        contentOffset: DialogOverlayData.Dialog.contentOffset,
                                        mainLabelSize: DialogOverlayData.Dialog.mainLabelSize,
                                        optionLabelSize: DialogOverlayData.Dialog.optionLabelSize,
                                        emptyPortraitImage: DialogOverlayData.Dialog.emptyPortraitImage,
                                        separatorImage: DialogOverlayData.Dialog.separatorImage,
                                        backgroundImage: DialogOverlayData.Dialog.backgroundImage,
                                        backgroundBorder: DialogOverlayData.Dialog.backgroundBorder,
                                        backgroundOffset: DialogOverlayData.Dialog.backgroundOffset)
        
        // Set the contents
        dialogElement.portrait.portrait = portraitComponent?.portrait
        dialogElement.leftOptionLabel.text = "Trade"
        dialogElement.rightOptionLabel.text = "Leave"
        
        // Add tracking data
        dialogElement.addTrackinDataForMainLabel(data: DialogTrackingData.text)
        dialogElement.addTrackinDataForLeftOption(data: DialogTrackingData.trade)
        dialogElement.addTrackinDataForRightOption(data: DialogTrackingData.leave)
        
        // The dialog overlay will be placed at the center-left of the rect
        let offsetX: CGFloat = 8.0
        let overlayRect = CGRect(origin: CGPoint(x: rect.minX + offsetX,
                                                 y: rect.midY - (dialogElement.size.height / 2.0)),
                                 size: dialogElement.size)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(dialogElement)
        let tree = UITree(rect: overlayRect, root: container)
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
        case .text:
            scroll = -scrollSpeed
        case .trade:
            dialogElement.leftOptionLabel.unflash()
            dialogElement.leftOptionLabel.restore()
        case .leave:
            dialogElement.rightOptionLabel.unflash()
            dialogElement.rightOptionLabel.restore()
        }
        if self.selection == selection { self.selection = nil }
    }
    
    /// Selects the given `Selection`.
    ///
    /// - Parameter selection: The new selection.
    ///
    private func select(_ selection: Selection) {
        switch selection {
        case .text:
            scroll = scrollSpeed
        case .trade:
            dialogElement.leftOptionLabel.flash()
            dialogElement.leftOptionLabel.whiten()
        case .leave:
            dialogElement.rightOptionLabel.flash()
            dialogElement.rightOptionLabel.whiten()
        }
        self.selection = selection
    }
    
    func update(deltaTime seconds: TimeInterval) {
        guard let scroll = scroll else { return }
        
        if scroll < 0 {
            if dialogElement.isMainLabelAtBeggining() {
                self.scroll = nil
                return
            }
        } else {
            if dialogElement.isMainLabelAtEnd() {
                self.scroll = nil
                return
            }
        }
        
        dialogElement.scrollMainLabelBy(amount: scroll * CGFloat(seconds))
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
            onEnd()
            switch selection {
            case .trade:
                let _ = SceneManager.switchToScene(ofKind: .tradeMenu)
            default:
                break
            }
        default:
            break
        }
    }
    
    /// Handles mouse entered events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseEnteredEvent(_ event: MouseEvent) {
        if let data = event.data as? DialogTrackingData {
            if let selection = selection { unselect(selection) }
            select(data)
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? DialogTrackingData {
            unselect(data)
        }
    }
    
    /// Handles keyboard key down events.
    ///
    /// - Parameter event: The event.
    ///
    private func keyDownEvent(_ event: KeyboardEvent) {
        guard !event.isRepeating,
            let mapping = KeyboardMapping.mappingFor(keyCode: event.keyCode, modifiers: event.modifiers)
            else { return }
    
        if mapping.contains(.cancel) {
            onEnd()
        }
    }
}

/// A struct that defines the data associated with the `DialogOverlay` class.
///
fileprivate struct DialogOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Dialog.emptyPortraitImage,
                Dialog.separatorImage,
                Dialog.backgroundImage]
    }
    
    private init() {}
    
    /// The `UIDialogElement` data.
    ///
    struct Dialog {
        private init() {}
        static let entryOffset: CGFloat = 16.0
        static let contentOffset: CGFloat = 6.0
        static let mainLabelSize = CGSize(width: 300.0, height: 60.0)
        static let optionLabelSize = CGSize(width: 100.0, height: 30.0)
        static let emptyPortraitImage = "UI_Window_Empty_Portrait"
        static let separatorImage = "UI_Window_Separator"
        static let backgroundImage = "UI_Window_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat =  10.0
    }
}
