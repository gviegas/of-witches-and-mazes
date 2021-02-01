//
//  UIDoublePortraitElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays a portrait on the left and another on the right, meant to
/// be used as a separator between similar sections that belongs to two different things.
///
class UIDoublePortraitElement: UIElement {
    
    /// The node used to group the contents.
    ///
    private let contents: SKNode
    
    /// The portrait on the left.
    ///
    let leftPortrait: UIPortrait
    
    /// The portrait on the right.
    ///
    let rightPortrait: UIPortrait
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - leftEmptyImage: The empty portrait image to use for the left portrait.
    ///   - rightEmptyImage: The empty portrait image to use for the right portrait.
    ///   - contentOffset: The offset to apply between the portraits, away from the middle and
    ///     towards the left/right sides.
    ///   - boundaryOffset: The offset to apply between each portrait and the left/right bounds.
    ///
    init(leftEmptyImage: String, rightEmptyImage: String, contentOffset: CGFloat, boundaryOffset: CGFloat) {
        contents = SKNode()
        contents.zPosition = 1
        
        leftPortrait = UIPortrait(emptyPortraitImage: leftEmptyImage)
        rightPortrait = UIPortrait(emptyPortraitImage: rightEmptyImage)
        
        let leftSize = leftPortrait.node.size
        let rightSize = rightPortrait.node.size
        
        leftPortrait.node.position = CGPoint(x: boundaryOffset + leftSize.width / 2.0,
                                             y: leftSize.height / 2.0)
        
        let leftX = leftPortrait.node.position.x
        rightPortrait.node.position = CGPoint(x: leftX + leftSize.width / 2.0 + contentOffset + rightSize.width / 2.0,
                                              y: rightSize.height / 2.0)
        
        if leftSize.height < rightSize.height {
            leftPortrait.node.position.y += (rightSize.height - leftSize.height) / 2.0
        } else if leftSize.height > rightSize.height {
            rightPortrait.node.position.y += (leftSize.height - rightSize.height) / 2.0
        }
        
        contents.addChild(leftPortrait.node)
        contents.addChild(rightPortrait.node)
        
        size = CGSize(width: rightPortrait.node.position.x + rightSize.width / 2.0 + boundaryOffset,
                      height: max(leftSize.height, rightSize.height))
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
