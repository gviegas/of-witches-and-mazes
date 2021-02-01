//
//  UISpeechElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/14/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays an immutable piece of text alongside a pointer,
/// intended to represent speech.
///
class UISpeechElement: UIElement {
    
    /// The node to group the contents of the element.
    ///
    private let contents: SKNode
    
    /// The text label.
    ///
    private let label: UIText
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - text: The text to display.
    ///   - contentOffset: the offset to apply between the text and the pointer.
    ///   - maxLabelLength: The maximum length of the text label.
    ///   - pointerImage: The image that points at the speaker. It will appears below the text.
    ///   - backgroundImage: An optional background image to enclose the contents. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(text: String, contentOffset: CGFloat, maxLabelLength: CGFloat, pointerImage: String,
         backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        contents = SKNode()
        
        let pointer = SKSpriteNode(texture: TextureSource.createTexture(imageNamed: pointerImage))
        label = UIText(maxWidth: maxLabelLength, style: .text, text: text)
        
        let node = SKNode()
        node.zPosition = 1
        node.addChild(label.node)
        
        let width: CGFloat
        let height: CGFloat
        
        // The background, if set, must be large enough to enclose the label
        let background: UIBackground?
        if let image = backgroundImage {
            let frame = CGRect(x: 0, y: 0, width: label.node.frame.width, height: label.node.frame.height)
            if let border = backgroundBorder {
                let rect = CGRect(x: 0, y: 0,
                                  width: frame.width + border.left + border.right + backgroundOffset * 2.0,
                                  height: frame.height + border.top + border.bottom + backgroundOffset * 2.0)
                background = UIBackground(image: image, rect: rect, border: border)
            } else {
                let rect = CGRect(x: 0, y: 0,
                                  width: frame.width + backgroundOffset * 2.0,
                                  height: frame.height + backgroundOffset * 2.0)
                background = UIBackground(image: image, rect: rect)
            }
        } else {
            background = nil
        }
        
        // Position the elements
        if let background = background {
            pointer.position.y = pointer.size.height / 2.0
            background.node.position.y = pointer.size.height + contentOffset + background.node.size.height / 2.0
            
            if pointer.size.width >= background.node.size.width {
                pointer.position.x = pointer.size.width / 2.0
                background.node.position.x = pointer.position.x
            } else {
                background.node.position.x = background.node.size.width / 2.0
                pointer.position.x = background.node.position.x
            }
            
            width = max(pointer.size.width, background.node.size.width)
            height = pointer.size.height + background.node.size.height + contentOffset
            background.node.addChild(node)
            contents.addChild(background.node)
        } else {
            pointer.position.y = pointer.size.height / 2.0
            label.node.position.y = pointer.size.height + contentOffset + label.node.frame.size.height / 2.0
            
            if pointer.size.width >= label.node.frame.width {
                pointer.position.x = pointer.size.width / 2.0
                label.node.position.x = pointer.position.x
            } else {
                label.node.position.x = label.node.frame.size.width / 2.0
                pointer.position.x = label.node.position.x
            }
            
            width = max(pointer.size.width, label.node.frame.width)
            height = pointer.size.height + label.node.frame.height + contentOffset
            contents.addChild(node)
        }
        
        contents.addChild(pointer)
        size = CGSize(width: width, height: height)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height  - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
