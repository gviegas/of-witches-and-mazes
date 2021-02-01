//
//  UINameBar.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/30/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that displays a name bar in the UI.
///
class UINameBar {
    
    /// The bar.
    ///
    private let bar: SKSpriteNode
    
    /// The label.
    ///
    private let label: UIText
    
    /// The name bar node.
    ///
    let node: SKNode
    
    /// The size of the name bar.
    ///
    let size: CGSize
    
    /// The text displayed in the name bar.
    ///
    var text: String? {
        didSet {
            label.text = text
        }
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - barImage: The name of the bar image.
    ///   - textSize: An optional size to be used for the text area, centered
    ///     on the bar's node. If set to `nil`, the size of the bar node is used.
    ///   - flipped: A flag stating whether or not the bar should be flipped vertically.
    ///     The default value is `false`.
    ///
    init(barImage: String, textSize: CGSize?, flipped: Bool = false) {
        bar = SKSpriteNode(texture: TextureSource.createTexture(imageNamed: barImage))
        
        var labelRect: CGRect
        if let textSize = textSize {
            let frame = bar.frame
            let origin = CGPoint(x: frame.minX + (frame.width - textSize.width) / 2.0,
                                 y: frame.minY + (frame.height - textSize.height) / 2.0)
            labelRect = CGRect(origin: origin, size: textSize)
        } else {
            labelRect = bar.frame
        }
        label = UIText(rect: labelRect, style: .bar, text: nil, alignment: .center)
        label.node.zPosition = 1
        
        bar.addChild(label.node)
        
        node = SKNode()
        node.addChild(bar)
        
        size = CGSize(width: max(bar.size.width, labelRect.width), height: max(bar.size.height, labelRect.height))
        
        if flipped {
            node.xScale = -1.0
            label.node.xScale = -1.0
        }
    }
}
