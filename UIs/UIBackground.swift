//
//  UIBackground.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that defines a background of the UI, an enclosing area.
///
class UIBackground: TextureUser {
    
    static var textureNames: Set<String> {
        return [defaultBackgroundImage.alpha, defaultBackgroundImage.black]
    }
    
    /// The names of the default background textures.
    ///
    private static let defaultBackgroundImage = (alpha: "UI_Alpha_Background", black: "UI_Black_Background")
    
    /// The flash action.
    ///
    private static let flashAction: SKAction = .repeatForever(.sequence([.fadeAlpha(to: 0, duration: 0.45),
                                                                         .fadeAlpha(to: 0.5, duration: 0.45)]))
    
    /// The darken action.
    ///
    private static let darkenAction: SKAction = .colorize(with: .black, colorBlendFactor: 0.8, duration: 0)
    
    /// The undarken action.
    ///
    private static let undarkenAction: SKAction = .colorize(with: .black, colorBlendFactor: 0, duration: 0)
    
    /// The blend action.
    ///
    private static let blendAction: SKAction = .colorize(withColorBlendFactor: 0.5, duration: 0)
    
    /// The unblend action.
    ///
    private static let unblendAction: SKAction = .colorize(withColorBlendFactor: 0, duration: 0)
    
    /// The flash node.
    ///
    private let flashNode: SKShapeNode
    
    /// The background node.
    ///
    let node: SKSpriteNode
    
    /// The background border.
    ///
    let border: UIBorder?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - image: The image to fill the bounding rect with.
    ///   - rect: A rect defining the enclosing area.
    ///   - border: An optional border defining the dimensions of the `rect`'s border.
    ///     The optional value is `nil`, which means that the texture has no borders.
    ///
    init(image: String, rect: CGRect, border: UIBorder? = nil) {
        let texture = TextureSource.createTexture(imageNamed: image)
        node = SKSpriteNode(texture: texture)
        self.border = border
        
        node.position = CGPoint(x: rect.midX, y: rect.midY)
        node.size = rect.size
        
        if let border = border {
            let size = texture.size()
            let centerRect = CGRect(x: border.left / size.width,
                                    y: border.bottom / size.height,
                                    width: (size.width - (border.left + border.right)) / size.width,
                                    height: (size.height - (border.top + border.bottom)) / size.height)
           
            assert(centerRect.minX >= 0 && centerRect.maxX <= 1.0)
            assert(centerRect.minY >= 0 && centerRect.maxY <= 1.0)
            
            node.centerRect = centerRect
        }
        
        flashNode = SKShapeNode(rectOf: rect.size)
        flashNode.strokeColor = NSColor(red: 0.765, green: 0.765, blue: 0.725, alpha: 1.0)
        flashNode.glowWidth = 6.0
    }
    
    /// Makes the background flash in an intermittent way.
    ///
    func flash() {
        guard flashNode.parent == nil else { return }
        
        flashNode.run(UIBackground.flashAction)
        flashNode.alpha = 0.5
        flashNode.zPosition = node.zPosition + 1
        node.addChild(flashNode)
    }
    
    /// Causes the background to stop flashing.
    ///
    func unflash() {
        flashNode.removeFromParent()
        flashNode.removeAllActions()
    }
    
    /// Makes the background darker.
    ///
    func darken() {
        node.run(UIBackground.darkenAction)
    }
    
    /// Removes the darken effect.
    ///
    func undarken() {
        node.run(UIBackground.undarkenAction)
    }
    
    /// Blends the background color.
    ///
    func blend() {
        node.run(UIBackground.blendAction)
    }
    
    /// Removes the blend effect.
    ///
    func unblend() {
        node.run(UIBackground.unblendAction)
    }
    
    /// Creates a default alpha background with no borders.
    ///
    /// - Parameter rect: A rect defining the enclosing area.
    /// - Returns: A new `UIBackground` instance.
    ///
    class func defaultAlphaBackground(rect: CGRect) -> UIBackground {
        return UIBackground(image: defaultBackgroundImage.alpha, rect: rect)
    }
    
    /// Creates a default black background with no borders.
    ///
    /// - Parameter rect: A rect defining the enclosing area.
    /// - Returns: A new `UIBackground` instance.
    ///
    class func defaultBlackBackground(rect: CGRect) -> UIBackground {
        return UIBackground(image: defaultBackgroundImage.black, rect: rect)
    }
}
