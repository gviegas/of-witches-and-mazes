//
//  UINoteElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/3/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays an immutable single piece of text.
///
class UINoteElement: UIElement {
    
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
    ///   - text: The note's text.
    ///   - maxLabelLength: The maximum length of the text label.
    ///   - backgroundImage: An optional background image to enclose the contents. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(text: String, maxLabelLength: CGFloat, backgroundImage: String? = nil,
         backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        contents = SKNode()
        
        label = UIText(maxWidth: maxLabelLength, style: .text, text: text)
        let width = label.node.frame.width
        let height = label.node.frame.height
        label.node.position = CGPoint(x: label.node.frame.width / 2.0, y: label.node.frame.height / 2.0)
        
        let node = SKNode()
        node.zPosition = 1
        node.addChild(label.node)
        
        // The background, if set, must be large enough to enclose the whole contents
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        if let image = backgroundImage {
            var background: UIBackground
            if let border = backgroundBorder {
                let rect = CGRect(x: 0, y: 0,
                                  width: frame.width + border.left + border.right + backgroundOffset * 2.0,
                                  height: frame.height + border.top + border.bottom + backgroundOffset * 2.0)
                background = UIBackground(image: image, rect: rect, border: border)
                node.position.x -= background.node.size.width / 2.0 - border.left - backgroundOffset
                node.position.y -= background.node.size.height / 2.0 - border.bottom - backgroundOffset
            } else {
                let rect = CGRect(x: 0, y: 0,
                                  width: frame.width + backgroundOffset * 2.0,
                                  height: frame.height + backgroundOffset * 2.0)
                background = UIBackground(image: image, rect: rect)
                node.position.x -= background.node.size.width / 2.0 - backgroundOffset
                node.position.y -= background.node.size.height / 2.0 - backgroundOffset
            }
            // Set the element to have the same dimensions as the background
            size = CGSize(width: background.node.size.width, height: background.node.size.height)
            background.node.addChild(node)
            contents.addChild(background.node)
            
        } else {
            size = frame.size
            contents.addChild(node)
        }
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height  - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
