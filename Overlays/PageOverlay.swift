//
//  PageOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/2/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `ControllableOverlay` type that displays a page with textual information.
///
class PageOverlay: ControllableOverlay, TextureUser {
    
    static var textureNames: Set<String> {
        return PageOverlayData.textureNames
    }
    
    /// An enum that defines the available selections.
    ///
    private enum Selection {
        case left, right
    }
    
    /// The tracking data for the page element.
    ///
    private typealias PageTrackingData = Selection
    
    let node: SKNode
    
    var onEnd: () -> Void
    
    /// The `UIPageElement` instance.
    ///
    private let pageElement: UIPageElement
    
    /// The current selection.
    ///
    private var selection: Selection?
    
    /// The flag stating whether or not the left option was chosen.
    ///
    private var choseLeft = false
    
    /// The flag stating whether or not the right option was chosen.
    ///
    private var choseRight = false
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - entries: An array containing the kinds of entries to add in the page.
    ///   - leftOption: An optional text for the selectable left option.
    ///   - rightOption: An optional text for the selectable right option.
    ///   - rect: The bounding rect.
    ///   - onEnd: The callback to be called when no more input is needed.
    ///
    init(entries: [UIPageElement.Entry], leftOption: String?, rightOption: String?,
         rect: CGRect, onEnd: @escaping () -> Void) {
        
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound + 16
        self.onEnd = onEnd
        
        // Create the page element
        pageElement = UIPageElement(entries: entries,
                                    leftOption: leftOption,
                                    rightOption: rightOption,
                                    entryOffset: PageOverlayData.Page.entryOffset,
                                    contentOffset: PageOverlayData.Page.contentOffset,
                                    minLabelSize: PageOverlayData.Page.minLabelSize,
                                    maxLabelSize: PageOverlayData.Page.maxLabelSize,
                                    optionLabelSize: PageOverlayData.Page.optionLabelSize,
                                    backgroundImage: PageOverlayData.Page.backgroundImage,
                                    backgroundBorder: PageOverlayData.Page.backgroundBorder,
                                    backgroundOffset: PageOverlayData.Page.backgroundOffset)
        
        // Add tracking data
        if leftOption != nil { pageElement.addTrackinDataForLeftOption(data: PageTrackingData.left) }
        if rightOption != nil { pageElement.addTrackinDataForRightOption(data: PageTrackingData.right) }
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(pageElement)
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
        case .left:
            pageElement.leftOptionLabel.unflash()
            pageElement.leftOptionLabel.restore()
        case .right:
            pageElement.rightOptionLabel.unflash()
            pageElement.rightOptionLabel.restore()
        }
        if self.selection == selection { self.selection = nil }
    }
    
    /// Selects the given `Selection`.
    ///
    /// - Parameter selection: The new selection.
    ///
    private func select(_ selection: Selection) {
        switch selection {
        case .left:
            pageElement.leftOptionLabel.flash()
            pageElement.leftOptionLabel.whiten()
        case .right:
            pageElement.rightOptionLabel.flash()
            pageElement.rightOptionLabel.whiten()
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
            case .left:
                choseLeft = true
            case .right:
                choseRight = true
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
        if let data = event.data as? PageTrackingData {
            if let selection = selection { unselect(selection) }
            select(data)
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? PageTrackingData {
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

/// A struct that defines the data associated with the `PageOverlay` class.
///
fileprivate struct PageOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Page.backgroundImage]
    }
    
    private init() {}
    
    /// The `UIPageElement` data.
    ///
    struct Page {
        private init() {}
        static let entryOffset: CGFloat = 16.0
        static let contentOffset: CGFloat = 6.0
        static let minLabelSize = CGSize(width: 160.0, height: 100.0)
        static let maxLabelSize = CGSize(width: 600.0, height: 600.0)
        static let optionLabelSize = CGSize(width: 100.0, height: 30.0)
        static let backgroundImage = "UI_Alpha_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat =  10.0
    }
}
