//
//  Icon.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/25/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that defines a game icon, used as a visual representation of specific things,
/// like items and skills.
///
class Icon {
    
    /// The name of the image representing the icon.
    ///
    let imageName: String
    
    /// The size of the icon.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given image name and size values.
    ///
    /// - Parameters:
    ///   - imageName: The name of the icon's image.
    ///   - size: The size of the icon to create.
    ///
    init(imageName: String, size: CGSize) {
        self.imageName = imageName
        self.size = size
        TextureSource.createTexture(imageNamed: imageName)
    }
    
    /// Creates a new sprite representing the icon.
    ///
    /// - Returns: A sprite that represents the icon.
    ///
    func makeIconSprite() -> SKSpriteNode {
        let texture = TextureSource.getTexture(forKey: imageName)
        return SKSpriteNode(texture: texture, size: size)
    }
}
