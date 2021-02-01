//
//  UIPickUpElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElementType` that displays info about a single acquired thing, with an icon an a label.
///
class UIPickUpElement: UIElement {
    
    /// The node to group the contents of the element.
    ///
    private let contents: SKNode
    
    /// The icon slot.
    ///
    let slot: UIIcon
    
    /// The text label.
    ///
    let label: UIText
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - text: The text to display in the label.
    ///   - contentOffset: The offset to apply between contents.
    ///   - maxLabelLength: The maximum length of the text label.
    ///   - backgroundImage: An optional background image to enclose the contents. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(text: String, contentOffset: CGFloat, maxLabelLength: CGFloat,
         backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        contents = SKNode()
        
        slot = UIIcon(iconSize: IconSet.size)
        label = UIText(maxWidth: maxLabelLength, style: .text, text: text)
        let width = slot.node.size.width + contentOffset + label.node.frame.width
        let height = max(slot.node.size.height, label.node.frame.height)
        slot.node.position.x = slot.node.size.width / 2.0
        label.node.position.x = width - label.node.frame.width / 2.0
        if slot.node.size.height >= label.node.frame.height {
            slot.node.position.y = slot.node.size.height / 2.0
            label.node.position.y = slot.node.position.y
        } else {
            label.node.position.y = label.node.frame.height / 2.0
            slot.node.position.y = label.node.position.y
        }
        
        let groupNode = SKNode()
        groupNode.zPosition = 1
        groupNode.addChild(slot.node)
        groupNode.addChild(label.node)
        
        // The background, if set, must be large enough to enclose the whole contents
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        if let image = backgroundImage {
            var background: UIBackground
            if let border = backgroundBorder {
                let rect = CGRect(x: 0, y: 0,
                                  width: frame.width + border.left + border.right + backgroundOffset * 2.0,
                                  height: frame.height + border.top + border.bottom + backgroundOffset * 2.0)
                background = UIBackground(image: image, rect: rect, border: border)
                groupNode.position.x -= background.node.size.width / 2.0 - border.left - backgroundOffset
                groupNode.position.y -= background.node.size.height / 2.0 - border.bottom - backgroundOffset
            } else {
                let rect = CGRect(x: 0, y: 0,
                                  width: frame.width + backgroundOffset * 2.0,
                                  height: frame.height + backgroundOffset * 2.0)
                background = UIBackground(image: image, rect: rect)
                groupNode.position.x -= background.node.size.width / 2.0 - backgroundOffset
                groupNode.position.y -= background.node.size.height / 2.0 - backgroundOffset
            }
            // Set the element to have the same dimensions as the background
            size = CGSize(width: background.node.size.width, height: background.node.size.height)
            background.node.addChild(groupNode)
            contents.addChild(background.node)
            
        } else {
            size = frame.size
            contents.addChild(groupNode)
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
