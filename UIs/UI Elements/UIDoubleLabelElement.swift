//
//  UIDoubleLabelElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays a label on the left and another on the right, meant to
/// be used as a separator between similar sections that belongs to two different things.
///
class UIDoubleLabelElement: UIElement {
    
    /// The node used to group the contents.
    ///
    private let contents: SKNode
    
    /// The label on the left.
    ///
    let leftLabel: UIText
    
    /// The label on the right.
    ///
    let rightLabel: UIText
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - leftLabelSize: The size of the left label.
    ///   - rightLabelSize: The size of the right label.
    ///   - contentOffset: The offset to apply between the labels, away from the middle and
    ///     towards the left/right sides.
    ///   - boundaryOffset: The offset to apply between each label and the left/right bounds.
    ///
    init(leftLabelSize: CGSize, rightLabelSize: CGSize, contentOffset: CGFloat, boundaryOffset: CGFloat) {
        contents = SKNode()
        contents.zPosition = 1
        
        let leftY: CGFloat
        let rightY: CGFloat
        if leftLabelSize.height > rightLabelSize.height {
            leftY = 0
            rightY = (leftLabelSize.height - rightLabelSize.height) / 2.0
        } else {
            leftY = (rightLabelSize.height - leftLabelSize.height) / 2.0
            rightY = 0
        }
        
        let leftRect = CGRect(x: boundaryOffset, y: leftY, width: leftLabelSize.width, height: leftLabelSize.height)
        leftLabel = UIText(rect: leftRect, style: .emphasis, text: nil, alignment: .center)
        
        let rightX = leftRect.maxX + contentOffset
        let rightRect = CGRect(x: rightX, y: rightY, width: rightLabelSize.width, height: rightLabelSize.height)
        rightLabel = UIText(rect: rightRect, style: .emphasis, text: nil, alignment: .center)
        
        contents.addChild(leftLabel.node)
        contents.addChild(rightLabel.node)
        
        size = CGSize(width: rightRect.maxX + boundaryOffset,
                      height: max(leftLabelSize.height, rightLabelSize.height))
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}

