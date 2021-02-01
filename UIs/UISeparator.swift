//
//  UISeparator.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/13/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that defines a separator, able to separate sections of contents in an UI.
///
class UISeparator {
    
    /// The separator node.
    ///
    let node: SKSpriteNode
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - image: The image to fill the bounding rect with.
    ///   - rect: A rect defining the enclosing area.
    ///   - zRotation: An optional value to rotate around the z-axis. The default value is `0`.
    ///
    init(image: String, rect: CGRect, zRotation: CGFloat = 0) {
        let texture = TextureSource.createTexture(imageNamed: image)
        node = SKSpriteNode(texture: texture, size: rect.size)
        node.position = CGPoint(x: rect.midX, y: rect.midY)
        node.zRotation = zRotation
    }
}
