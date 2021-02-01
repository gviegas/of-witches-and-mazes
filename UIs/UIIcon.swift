//
//  UIIcon.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that displays an `Icon` instance in the UI.
///
class UIIcon {
    
    /// The flash action.
    ///
    private static let flashAction: SKAction = .repeatForever(.sequence([.fadeAlpha(to: 0, duration: 0.45),
                                                                         .fadeAlpha(to: 0.5, duration: 0.45)]))
    
    /// The darken action.
    ///
    private static let darkenAction: SKAction = .colorize(with: .black, colorBlendFactor: 0.75, duration: 0)
    
    /// The undarken action.
    ///
    private static let undarkenAction: SKAction = .colorize(with: .black, colorBlendFactor: 0, duration: 0)
    
    /// The `UIText` that manages the icon text.
    ///
    private let uiText: UIText
    
    /// The `UIText` that manages the wait time text.
    ///
    private let waitTimeText: UIText
    
    /// The flash node.
    ///
    private let flashNode: SKSpriteNode
    
    /// The circular flash node.
    ///
    private let circularFlashNode: SKShapeNode
    
    /// The highlight node.
    ///
    private let highlightNode: SKShapeNode
    
    /// The circular highlight node.
    ///
    private let circularHighlightNode: SKShapeNode
    
    /// The icon node.
    ///
    let node: SKSpriteNode
    
    /// The icon to display.
    ///
    var icon: Icon? {
        didSet {
            if oldValue?.imageName == icon?.imageName { return }
            
            if let oldValue = oldValue {
                node.childNode(withName: oldValue.imageName)?.removeFromParent()
            }
            
            if let icon = icon {
                let iconSprite = icon.makeIconSprite()
                iconSprite.name = icon.imageName
                iconSprite.zPosition = node.zPosition + 1
                iconSprite.anchorPoint = node.anchorPoint
                node.addChild(iconSprite)
            }
        }
    }
    
    /// The text to display alongside the icon.
    ///
    var text: String? {
        didSet {
            uiText.text = text
        }
    }
    
    /// The wait time to display alongside the icon.
    ///
    var waitTime: TimeInterval? {
        didSet {
            waitTimeText.text = waitTime != nil ? "\(Int(waitTime!.rounded(.up)))" : nil
        }
    }
    
    /// Creates a new instance from the given icon node.
    ///
    /// - Parameter node: The icon node.
    ///
    private init(node: SKSpriteNode) {
        self.node = node
        uiText = UIText(rect: node.frame, style: .icon, text: nil, alignment: .topRight)
        uiText.node.zPosition = node.zPosition + 3
        node.addChild(uiText.node)
        waitTimeText = UIText(rect: node.frame, style: .waitTime, text: nil, alignment: .center)
        waitTimeText.node.zPosition = node.zPosition + 6
        node.addChild(waitTimeText.node)
        
        let color = NSColor(red: 0.73, green: 0.73, blue: 0.7, alpha: 1.0)
        
        flashNode = SKSpriteNode(color: color, size: IconSet.size)
        flashNode.zPosition = node.zPosition + 4
        
        circularFlashNode = SKShapeNode(circleOfRadius: min(IconSet.size.width, IconSet.size.height) / 2.0)
        circularFlashNode.strokeColor = color
        circularFlashNode.glowWidth = 5.0
        circularFlashNode.zPosition = node.zPosition + 4
        
        highlightNode = SKShapeNode(rectOf: IconSet.size)
        highlightNode.strokeColor = color
        highlightNode.glowWidth = 1.0
        highlightNode.zPosition = node.zPosition + 5
        
        circularHighlightNode = SKShapeNode(circleOfRadius: min(IconSet.size.width, IconSet.size.height) / 2.0)
        circularHighlightNode.strokeColor = color
        circularHighlightNode.glowWidth = 2.0
        circularHighlightNode.zPosition = node.zPosition + 5
    }
    
    /// Creates a new instance with the given empty icon image.
    ///
    /// - Parameter emptyIconImage: The image to display below the icon, which will fully appears
    ///   when no icon is set.
    ///
    convenience init(emptyIconImage: String) {
        self.init(node: SKSpriteNode(texture: TextureSource.createTexture(imageNamed: emptyIconImage)))
    }
    
    /// Creates a new instance with the given size.
    ///
    /// - Parameter iconSize: The size of the icon.
    ///
    convenience init(iconSize: CGSize) {
        self.init(node: SKSpriteNode(color: .clear, size: iconSize))
    }
    
    /// Makes the icon darker.
    ///
    func darken() {
        guard let icon = icon else { return }
        node.childNode(withName: icon.imageName)?.run(UIIcon.darkenAction)
    }
    
    /// Removes the darken effect.
    ///
    func undarken() {
        guard let icon = icon else { return }
        node.childNode(withName: icon.imageName)?.run(UIIcon.undarkenAction)
    }
    
    /// Makes the icon flash in an intermittent way.
    ///
    /// - Parameter circularShape: A flag stating whether or not the flash aimation must take
    ///   a circular shape. The default value is `false`.
    ///
    func flash(circularShape: Bool = false) {
        let flashNode = circularShape ? circularFlashNode : self.flashNode
        guard flashNode.parent == nil else { return }
        
        flashNode.run(UIIcon.flashAction)
        flashNode.alpha = 0.5
        node.addChild(flashNode)
    }
    
    /// Causes the icon to stop flashing.
    ///
    func unflash() {
        if flashNode.parent != nil {
            flashNode.removeFromParent()
            flashNode.removeAllActions()
        } else if circularFlashNode.parent != nil {
            circularFlashNode.removeFromParent()
            circularFlashNode.removeAllActions()
        }
    }
    
    /// Highlights the icon.
    ///
    /// - Parameter circularShape: A flag stating whether or not the highlight must have
    ///   a circular shape. The default value is `false`.
    ///
    func highlight(circularShape: Bool = false) {
        let highlightNode = circularShape ? circularHighlightNode : self.highlightNode
        if highlightNode.parent == nil { node.addChild(highlightNode) }
    }
    
    /// Removes the icon's highlight.
    ///
    func unhighlight() {
        if highlightNode.parent != nil {
            highlightNode.removeFromParent()
        } else if circularHighlightNode.parent != nil {
            circularHighlightNode.removeFromParent()
        }
    }
    
    /// Conceals the whole icon.
    ///
    func conceal() {
        node.alpha = 0
    }
    
    /// Reveals the whole icon.
    ///
    func reveal() {
        node.alpha = 1.0
    }
}
