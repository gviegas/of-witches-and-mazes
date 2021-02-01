//
//  UITargetElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/19/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays information about the entity that the
/// protagonist is targeting. It includes a portrait, a name bar and a health bar.
///
class UITargetElement: UIElement {
    
    /// The node that holds all the contents of the element.
    ///
    let contents: SKNode
    
    /// The portrait.
    ///
    let portrait: UIPortrait
    
    /// The name bar.
    ///
    let nameBar: UINameBar
    
    /// The health bar.
    ///
    let healthBar: UIHealthBar
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - flipped: A flag stating whether or not the contents should be flipped vertically.
    ///   - emptyPortraitImage: The empty portrait image to use.
    ///   - nameBarImage: The name bar image to use.
    ///   - healthBarImage: The health bar image to use.
    ///   - healthImage: The health image to use for the health bar.
    ///   - healthWidth: The width of the health bar's health.
    ///   - nameSize: An optional size for the text in the name bar. If set to `nil`,
    ///     the `nameBarImage` size is used.
    ///
    init(flipped: Bool, emptyPortraitImage: String, nameBarImage: String, healthBarImage: String,
         healthImage: String, healthWidth: CGFloat, nameSize: CGSize?) {
        
        contents = SKNode()
        
        let node = SKNode()
        node.zPosition = 1
        
        // Create the contents
        nameBar = UINameBar(barImage: nameBarImage, textSize: nameSize, flipped: flipped)
        healthBar = UIHealthBar(healthWidth: healthWidth, healthImage: healthImage,
                                barImage: healthBarImage, flipped: flipped)
        portrait = UIPortrait(emptyPortraitImage: emptyPortraitImage, emptyPortraitFlipped: flipped)
        
        // Calculate the size
        size = CGSize(width: portrait.node.size.width + max(nameBar.size.width, healthBar.size.width),
                      height: max(portrait.node.size.height, nameBar.size.height + healthBar.size.height))
        
        // Position the contents
        let barsHeight = nameBar.size.height + healthBar.size.height
        let barsWidth = max(nameBar.size.width, healthBar.size.width)
        if portrait.node.size.height > barsHeight {
            nameBar.node.position = CGPoint(x: nameBar.size.width / 2.0,
                                            y: portrait.node.size.height / 2.0 + nameBar.size.height / 2.0)
            healthBar.node.position = CGPoint(x: healthBar.size.width / 2.0,
                                              y: portrait.node.size.height / 2.0 - healthBar.size.height / 2.0)
            portrait.node.position = CGPoint(x: barsWidth + portrait.node.size.width / 2.0,
                                             y: portrait.node.size.height / 2.0)
        } else {
            nameBar.node.position = CGPoint(x: nameBar.size.width / 2.0,
                                            y: barsHeight / 2.0 + nameBar.size.height / 2.0)
            healthBar.node.position = CGPoint(x: healthBar.size.width / 2.0,
                                              y: barsHeight / 2.0 - healthBar.size.height / 2.0)
            portrait.node.position = CGPoint(x: barsWidth + portrait.node.size.width / 2.0,
                                             y: barsHeight / 2.0)
        }
        
        node.addChild(nameBar.node)
        node.addChild(healthBar.node)
        node.addChild(portrait.node)
        
        contents.addChild(node)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}

