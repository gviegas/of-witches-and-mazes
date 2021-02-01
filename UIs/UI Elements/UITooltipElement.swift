//
//  UITooltipElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/24/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that creates tooltips.
///
class UITooltipElement: UIElement {
    
    /// An enum that defines what kinds of entries are available for the tooltip.
    ///
    enum Entry {
        case label(style: UITextStyle, text: String)
        case space(CGFloat)
    }
    
    /// The node that groups the contents of the element.
    ///
    private let contents: SKNode
    
    /// The labels, in reverse order (bottom to top).
    ///
    private var labels: [UIText]
    
    /// The amount of labels in the tooltip.
    ///
    var labelCount: Int {
        return labels.count
    }
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - entries: An array containing the kinds of entries to add in the tooltip.
    ///   - contentOffset: The offset to apply between element contents.
    ///   - minLabelSize: The minimum size of the labels.
    ///   - maxLabelSize: The maximum size of the labels.
    ///   - backgroundImage: An optional background image to enclose the contents. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(entries: [Entry], contentOffset: CGFloat, minLabelSize: CGSize, maxLabelSize: CGSize,
         backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        contents = SKNode()
        labels = []
        
        let node = SKNode()
        node.zPosition = 1
        
        var dimensions = CGSize(width: minLabelSize.width, height: 0)
        
        // Create the entries bottom up
        for entry in entries.reversed() {
            switch entry {
            case .label(let style, let text):
                let label = UIText(maxWidth: maxLabelSize.width, style: style, text: text)
                let frame = label.node.frame
                label.node.position.y += frame.height / 2.0 + dimensions.height
                
                dimensions.height = label.node.position.y + frame.height / 2.0 + contentOffset
                if frame.width > dimensions.width { dimensions.width = frame.width }
                
                labels.append(label)
                node.addChild(label.node)
            
            case .space(let value):
                dimensions.height += value
            }
        }
        
        for label in labels {
            label.node.position.x += dimensions.width / 2.0
        }
        
        dimensions.height -= contentOffset
        
        dimensions.height = max(dimensions.height, minLabelSize.height)
        
        // Scale down to maxLabelSize
        let currentSize = node.calculateAccumulatedFrame().size
        var scale = CGFloat(1.0)
        scale = min(scale, maxLabelSize.width / currentSize.width)
        scale = min(scale, maxLabelSize.height / currentSize.height)
        node.setScale(scale)
        dimensions.width *= scale
        dimensions.height *= scale
        
        // The background, if set, must be large enough to enclose the whole contents
        let frame = CGRect(origin: CGPoint.zero, size: dimensions)
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
                                y: rect.minY + (rect.height - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
