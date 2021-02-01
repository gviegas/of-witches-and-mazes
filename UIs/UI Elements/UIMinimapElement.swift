//
//  UIMinimapElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that provides the display area for a `Minimap`.
///
class UIMinimapElement: UIElement {
    
    /// The node that holds all the element contents.
    ///
    private let contents: SKNode
    
    /// The node where the minimap will be placed.
    ///
    private let minimapArea: SKNode
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// The current minimap.
    ///
    weak var minimap: Minimap? {
        didSet {
            minimapArea.removeAllChildren()
            if let minimap = minimap { minimapArea.addChild(minimap.node) }
        }
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - minimapSize: The size of the minimap area.
    ///   - backgroundImage: The background image to enclose the contents.
    ///   - backgroundBorder: An optional border for the background.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///
    init(minimapSize: CGSize, backgroundImage: String, backgroundBorder: UIBorder?, backgroundOffset: CGFloat) {
        contents = SKNode()
        minimapArea = SKNode()
        minimapArea.zPosition = 1
        let frame = CGRect(origin: .zero, size: minimapSize)
        var background: UIBackground
        if let border = backgroundBorder {
            let rect = CGRect(x: 0, y: 0,
                              width: frame.width + border.left + border.right + backgroundOffset * 2.0,
                              height: frame.height + border.top + border.bottom + backgroundOffset * 2.0)
            background = UIBackground(image: backgroundImage, rect: rect, border: border)
        } else {
            let rect = CGRect(x: 0, y: 0,
                              width: frame.width + backgroundOffset * 2.0,
                              height: frame.height + backgroundOffset * 2.0)
            background = UIBackground(image: backgroundImage, rect: rect)
        }
        // Set the element to have the same dimensions as the background
        size = CGSize(width: background.node.size.width, height: background.node.size.height)
        background.node.addChild(minimapArea)
        contents.addChild(background.node)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}

