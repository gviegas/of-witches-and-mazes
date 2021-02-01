//
//  Portrait.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that represents a game portrait, used to display the appearance of something in the UI.
///
class Portrait {
    
    /// The name of the image representing the portrait.
    ///
    let imageName: String
    
    /// The size of the portrait.
    ///
    let size: CGSize
    
    /// A flag stating whether or not the portrait can be flipped vertically.
    ///
    let canFlip: Bool
    
    /// A flag stating whether or not the portrait must be flipped vertically.
    ///
    /// When this flag is set to `true`, calling `makePortraitSprite()` will create a flipped portrait.
    /// If `canFlip` is `false`, setting this property has no effect.
    ///
    var flipped: Bool
    
    /// Creates a new instance from the given image name and size values.
    ///
    /// - Parameters:
    ///   - imageName: The name of the portrait's image.
    ///   - size: The size of the portrait to create.
    ///   - canFlip: A flag stating whether or not the portrait can be flipped vertically.
    ///
    init(imageName: String, size: CGSize, canFlip: Bool) {
        self.imageName = imageName
        self.size = size
        self.canFlip = canFlip
        flipped = false
        TextureSource.createTexture(imageNamed: imageName)
    }
    
    /// Creates a new sprite representing the portrait.
    ///
    /// - Returns: A sprite that represents the portrait.
    ///
    func makePortraitSprite() -> SKSpriteNode {
        let texture = TextureSource.getTexture(forKey: imageName)
        let sprite = SKSpriteNode(texture: texture, size: size)
        if canFlip && flipped {
            sprite.xScale = -1.0
        }
        return sprite
    }
}
