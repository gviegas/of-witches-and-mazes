//
//  GameOverOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/3/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `ControllableOverlay` type used for the game over message.
///
class GameOverOverlay: ControllableOverlay, TextureUser {
    
    static var textureNames: Set<String> {
        return GameOverOverlayData.textureNames
    }
    
    /// An enum that defines the available selections.
    ///
    private enum Selection {
        case continueGame, quitGame
    }
    
    /// The tracking data for the game over element.
    ///
    private typealias GameOverTrackingData = Selection
    
    let node: SKNode
    
    var onEnd: () -> Void
    
    /// The `UIGameOverElement` instance.
    ///
    private let gameOverElement: UIGameOverElement
    
    /// The node used to dull the contents behind the overlay.
    ///
    private let dullNode: SKSpriteNode
    
    /// The current selection.
    ///
    private var selection: Selection?
    
    /// Creates a new instance inside the given rect and with the given callback.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - onEnd: The callback to be called when no more input is needed.
    ///
    init(rect: CGRect, onEnd: @escaping () -> Void) {
        node = SKNode()
        node.zPosition = DepthLayer.overlays.upperBound
        dullNode = SKSpriteNode(color: NSColor(red: 0, green: 0, blue: 0, alpha: 0.75), size: rect.size)
        dullNode.anchorPoint = .zero
        node.addChild(dullNode)
        self.onEnd = onEnd
        
        // Create the game over element
        gameOverElement = UIGameOverElement(entryOffset: GameOverOverlayData.GameOver.entryOffset,
                                            contentOffset: GameOverOverlayData.GameOver.contentOffset,
                                            mainLabelSize: GameOverOverlayData.GameOver.mainLabelSize,
                                            optionLabelSize: GameOverOverlayData.GameOver.optionLabelSize,
                                            backgroundImage: GameOverOverlayData.GameOver.backgroundImage,
                                            backgroundBorder: GameOverOverlayData.GameOver.backgroundBorder,
                                            backgroundOffset: GameOverOverlayData.GameOver.backgroundOffset)
        
        // Set the contents
        gameOverElement.mainLabel.text = "You Died"
        gameOverElement.leftOptionLabel.text = "Continue"
        gameOverElement.rightOptionLabel.text = "Quit"
        
        // Add tracking data
        gameOverElement.addTrackinDataForLeftOption(data: GameOverTrackingData.continueGame)
        gameOverElement.addTrackinDataForRightOption(data: GameOverTrackingData.quitGame)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(gameOverElement)
        let tree = UITree(rect: rect, root: container)
        if let treeNode = tree.generate() {
            treeNode.zPosition = 1
            dullNode.addChild(treeNode)
        }
    }
    
    /// Unselects the given `Selection`.
    ///
    /// - Parameter selection: The selection.
    ///
    private func unselect(_ selection: Selection) {
        switch selection {
        case .continueGame:
            gameOverElement.leftOptionLabel.unflash()
            gameOverElement.leftOptionLabel.restore()
        case .quitGame:
            gameOverElement.rightOptionLabel.unflash()
            gameOverElement.rightOptionLabel.restore()
        }
        if self.selection == selection { self.selection = nil }
    }
    
    /// Selects the given `Selection`.
    ///
    /// - Parameter selection: The new selection.
    ///
    private func select(_ selection: Selection) {
        switch selection {
        case .continueGame:
            gameOverElement.leftOptionLabel.flash()
            gameOverElement.leftOptionLabel.whiten()
        case .quitGame:
            gameOverElement.rightOptionLabel.flash()
            gameOverElement.rightOptionLabel.whiten()
        }
        self.selection = selection
    }
    
    /// Chooses the given game over option.
    ///
    /// - Parameter option: The `Selection` that represents the chosen option.
    ///
    private func chooseOption(_ option: Selection) {
        onEnd()
        switch option {
        case .continueGame:
            let _ = Session.restart(andSave: true)
        case .quitGame:
            let _ = Session.end(andSave: true)
            let _ = SceneManager.switchToScene(ofKind: .mainMenu)
        }
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
            chooseOption(selection)
        default:
            break
        }
    }
    
    /// Handles mouse entered events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseEnteredEvent(_ event: MouseEvent) {
        if let data = event.data as? GameOverTrackingData {
            if let selection = selection { unselect(selection) }
            select(data)
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? GameOverTrackingData {
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
            chooseOption(.continueGame)
        } else if mapping.contains(.cancel) {
            // Note: May be better not having a button that instantly quits
//            chooseOption(.quitGame)
        }
    }
}

/// A struct that defines the data associated with the `GameOverOverlay` class.
///
fileprivate struct GameOverOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [GameOver.backgroundImage]
    }
    
    private init() {}
    
    /// The `UIGameOverElement` data.
    ///
    struct GameOver {
        private init() {}
        static let entryOffset: CGFloat = 60.0
        static let contentOffset: CGFloat = 40.0
        static let mainLabelSize = CGSize(width: 300.0, height: 60.0)
        static let optionLabelSize = CGSize(width: 110.0, height: 30.0)
        static let backgroundImage = "UI_Alpha_background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat = 10.0
    }
}
