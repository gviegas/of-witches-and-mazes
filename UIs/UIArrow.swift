//
//  UIArrow.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/8/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that defines an UI arrow, used to represent a next or previous option, section, etc.
///
class UIArrow {
    
    /// The name of the pulsate action.
    ///
    private static let actionName = "Pulsate"
    
    /// The pulsate action.
    ///
    private let action: SKAction
    
    /// The size of the arrow on creation.
    ///
    private let originalSize: CGSize
    
    /// The arrow node.
    ///
    let node: SKSpriteNode
    
    /// Creates a new instance from the given image and rotation values.
    ///
    /// - Parameters:
    ///   - image: The name of the image resource.
    ///   - zRotation: The rotation in the z axis.
    ///
    init(image: String, zRotation: CGFloat) {
        let texture = TextureSource.createTexture(imageNamed: image)
        node = SKSpriteNode(texture: texture)
        node.zRotation = zRotation
        
        originalSize = node.size
        
        action = .repeatForever(.sequence([.resize(toWidth: originalSize.width * 0.9,
                                                   height: originalSize.height * 0.9, duration: 0.65),
                                           .resize(toWidth: originalSize.width,
                                                   height: originalSize.height, duration: 0.65)]))
    }
    
    /// Makes the arrow appears less prominently.
    ///
    func dull() {
        node.alpha = 0.4
    }
    
    /// Removes the `dull` effect.
    ///
    func undull() {
        node.alpha = 1.0
    }
    
    /// Conceals the arrow.
    ///
    func conceal() {
        node.alpha = 0
    }
    
    /// Reveals the arrow.
    ///
    func reveal() {
        node.alpha = 1.0
    }
    
    /// Makes the arrow pulsate.
    ///
    func pulsate() {
        guard node.action(forKey: UIArrow.actionName) == nil else { return }
        node.run(action, withKey: UIArrow.actionName)
    }
    
    /// Makes the arrow stop pulsating.
    ///
    func steady() {
        guard let _ = node.action(forKey: UIArrow.actionName) else { return }
        node.removeAction(forKey: UIArrow.actionName)
        node.size = originalSize
    }
}
