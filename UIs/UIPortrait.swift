//
//  UIPortrait.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that displays a `Portrait` instance in the UI.
///
class UIPortrait {
    
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
    
    /// The flash node.
    ///
    private let flashNode: SKShapeNode
    
    /// The flag stating whether or not the empty portrait node is flipped vertically.
    ///
    private let emptyPortraitFlipped: Bool
    
    /// The portrait node.
    ///
    let node: SKSpriteNode
    
    /// The portrait to display.
    ///
    var portrait: Portrait? {
        didSet {
            if oldValue?.imageName == portrait?.imageName { return }
            
            if let oldValue = oldValue {
                node.childNode(withName: oldValue.imageName)?.removeFromParent()
            }
            
            if let portrait = portrait {
                let portraitSprite = portrait.makePortraitSprite()
                portraitSprite.name = portrait.imageName
                portraitSprite.zPosition = node.zPosition + 1
                portraitSprite.anchorPoint = node.anchorPoint
                if emptyPortraitFlipped { portraitSprite.xScale *= -1.0 }
                node.addChild(portraitSprite)
            }
        }
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - emptyPortraitImage: The image to display below the portrait, which will fully
    ///   appears when no portrait is set.
    ///   - emptyPortraitFlipped: An optional flag stating whether or not the empty image
    ///   should be flipped vertically. The default value is `false`.
    ///
    init(emptyPortraitImage: String, emptyPortraitFlipped: Bool = false) {
        node = SKSpriteNode(texture: TextureSource.createTexture(imageNamed: emptyPortraitImage))
        self.emptyPortraitFlipped = emptyPortraitFlipped
        if emptyPortraitFlipped { node.xScale = -1.0 }
        flashNode = SKShapeNode(circleOfRadius: min(PortraitSet.size.width, PortraitSet.size.height) / 2.0)
        flashNode.strokeColor = NSColor(red: 0.73, green: 0.73, blue: 0.7, alpha: 1.0)
        flashNode.glowWidth = 6.0
    }
    
    /// Makes the portrait darker.
    ///
    func darken() {
        guard let portrait = portrait else { return }
        node.childNode(withName: portrait.imageName)?.run(UIPortrait.darkenAction)
    }
    
    /// Removes the darken effect.
    ///
    func undarken() {
        guard let portrait = portrait else { return }
        node.childNode(withName: portrait.imageName)?.run(UIPortrait.undarkenAction)
    }
    
    /// Makes the portrait flash in an intermittent way.
    ///
    func flash() {
        guard flashNode.parent == nil else { return }
        
        flashNode.run(UIPortrait.flashAction)
        flashNode.alpha = 0.5
        flashNode.zPosition = node.zPosition + 3
        node.addChild(flashNode)
    }
    
    /// Causes the portrait to stop flashing.
    ///
    func unflash() {
        flashNode.removeFromParent()
        flashNode.removeAllActions()
    }
}
