//
//  UIImage.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/5/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that represents a generic image in the UI.
///
class UIImage {
    
    /// An enum that specifies the alignment of the image, relative to its rect.
    ///
    enum Alignment {
        case center, left, right
    }
    
    /// The `UIText` that manages the image text.
    ///
    private let uiText: UIText
    
    /// The image.
    ///
    let node: SKSpriteNode
    
    /// The text to display alongside the image.
    ///
    var text: String? {
        didSet {
            uiText.text = text
        }
    }
    
    /// Creates a new ui image inside of a given rect.
    ///
    /// - Parameters:
    ///   - rect: The limits of the image.
    ///   - image: The name of the image to create.
    ///   - alignment: The alignment of the image on the rect. The default value is `.center`.
    ///   - textStyle: The style of the text on the image. The default value is `.emphasis`.
    ///
    init(rect: CGRect, image: String, alignment: Alignment = .center, textStyle: UITextStyle = .emphasis) {
        let texture = TextureSource.createTexture(imageNamed: image)
        node = SKSpriteNode(texture: texture)
        
        var scale = CGFloat(1.0)
        scale = min(scale, rect.size.width / node.size.width)
        scale = min(scale, rect.size.height / node.size.height)
        node.setScale(scale)
        
        uiText = UIText(rect: node.frame, style: textStyle, text: nil, alignment: .center)
        uiText.node.zPosition = node.zPosition + 1
        node.addChild(uiText.node)
        
        switch alignment {
        case .center:
            node.position = CGPoint(x: rect.midX, y: rect.midY)
        case .left:
            node.position = CGPoint(x: rect.minX + node.size.width / 2.0, y: rect.midY)
        case .right:
            node.position = CGPoint(x: rect.maxX - node.size.width / 2.0, y: rect.midY)
        }
    }
    
    /// Creates a new ui image at a given origin point.
    ///
    /// - Parameters:
    ///   - orgin: The origin point defining the image's placement.
    ///   - image: The name of the image to create.
    ///   - textStyle: The style of the text on the image. The default value is `.emphasis`.
    ///
    init(origin: CGPoint, image: String, textStyle: UITextStyle = .emphasis) {
        let texture = TextureSource.createTexture(imageNamed: image)
        node = SKSpriteNode(texture: texture)
        
        uiText = UIText(rect: node.frame, style: textStyle, text: nil, alignment: .center)
        uiText.node.zPosition = node.zPosition + 1
        node.addChild(uiText.node)
        node.position = origin
    }
    
    /// Makes the image appears less prominently.
    ///
    func dull() {
        node.alpha = 0.4
    }
    
    /// Removes the `dull` effect.
    ///
    func undull() {
        node.alpha = 1.0
    }
}
