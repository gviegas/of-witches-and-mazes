//
//  UIKeyboardShortcut.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/30/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that displays a keyboard shortcut in the UI.
///
class UIKeyboardShortcut {
    
    /// The `UIText` that manages the shortcut text.
    ///
    private let uiText: UIText
    
    /// The shortcut node.
    ///
    let node: SKSpriteNode
    
    /// The input button representing the keyboard shortcut.
    ///
    var key: InputButton? {
        didSet {
            uiText.text = key?.symbolFromMapping
        }
    }
    
    /// Creates a new instance from the given empty shortcut image.
    ///
    /// - Parameters:
    ///   - shortcutImage: The image to enclose the keyboard shortcut text.
    ///   - maxTextSize: The maximum size for the shortcut text. If set to `nil`, the image's size is used.
    ///
    init(shortcutImage: String, maxTextSize: CGSize?) {
        node = SKSpriteNode(texture: TextureSource.createTexture(imageNamed: shortcutImage))
        
        let size: CGSize
        if let textSize = maxTextSize {
            size = CGSize(width: min(textSize.width, node.size.width), height: min(textSize.height, node.size.height))
        } else {
            size = node.size
        }
        let rect = CGRect(x: -size.width / 2.0, y: -size.height / 2.0, width: size.width, height: size.height)
        
        uiText = UIText(rect: rect, style: .shortcut)
        uiText.node.zPosition = node.zPosition + 1
        node.addChild(uiText.node)
    }
}
