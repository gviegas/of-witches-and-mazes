//
//  UIBackpackElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/10/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that defines a backpack, able to display items.
///
class UIBackpackElement: UIElement {
    
    /// The node to group the contents of the element.
    ///
    private let contents: SKNode
    
    /// The slots in the backpack.
    ///
    private var slots: [UIIcon]
    
    /// The number of columns in the backpack.
    ///
    let columns: Int
    
    /// The number of rows in the backpack.
    ///
    let rows: Int
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - columns: The number of columns in the backpack.
    ///   - rows: The number of rows in the backpack
    ///   - slotOffset: The gap to apply between adjacent slots of the backpack.
    ///   - backpackImage: The backpack image, which will enclose the slots.
    ///   - emptyIconImage: The slot image to display when no icon is set.
    ///   - backgroundImage: An optional background image to enclose the backpack. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(columns: Int, rows: Int, slotOffset: CGFloat, backpackImage: String, emptyIconImage: String,
         backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        assert(columns > 0 && rows > 0)
        
        self.columns = columns
        self.rows = rows
        slots = [UIIcon]()
        contents = SKNode()
        
        let backpack = SKSpriteNode(texture: TextureSource.createTexture(imageNamed: backpackImage))
        
        // Create the icon slots in row-major order, from top-left to bottom-right
        let offset = slotOffset
        for i in 0..<rows {
            for j in 0..<columns {
                let uiIcon = UIIcon(emptyIconImage: emptyIconImage)
                let width = uiIcon.node.size.width
                let height = uiIcon.node.size.height
                uiIcon.node.position = CGPoint(x: offset + (CGFloat(j) * (width + offset)) + (width / 2.0),
                                               y: offset + (CGFloat(rows - i - 1) * (height + offset)) + (height / 2.0))
                slots.append(uiIcon)
                backpack.addChild(uiIcon.node)
            }
        }
        
        // Set the backpack node to enclose all slots plus offset
        backpack.anchorPoint = CGPoint.zero
        backpack.size = CGSize(width: offset + (CGFloat(columns) * (slots.first!.node.size.width + offset)),
                               height: offset + (CGFloat(rows) * (slots.first!.node.size.height + offset)))
        
        // The background, if set, must be large enough to enclose the backpack node plus its own border
        if let image = backgroundImage {
            var background: UIBackground
            if let border = backgroundBorder {
                let rect = CGRect(x: 0, y: 0,
                                  width: backpack.size.width + border.left + border.right + backgroundOffset * 2.0,
                                  height: backpack.size.height + border.top + border.bottom + backgroundOffset * 2.0)
                background = UIBackground(image: image, rect: rect, border: border)
                backpack.position.x -= background.node.size.width / 2.0 - border.left - backgroundOffset
                backpack.position.y -= background.node.size.height / 2.0 - border.bottom - backgroundOffset
            } else {
                let rect = CGRect(x: 0, y: 0,
                                  width: backpack.size.width + backgroundOffset * 2.0,
                                  height: backpack.size.height + backgroundOffset * 2.0)
                background = UIBackground(image: image, rect: rect)
                backpack.position.x -= background.node.size.width / 2.0 - backgroundOffset
                backpack.position.y -= background.node.size.height / 2.0 - backgroundOffset
            }
            // Set the element to have the same dimensions as the background
            size = CGSize(width: background.node.size.width, height: background.node.size.height)
            background.node.addChild(backpack)
            contents.addChild(background.node)
        } else {
            // Set the element to have the same dimensions as the backpack
            size = backpack.size
            contents.addChild(backpack)
        }
    }
    
    /// Retrieves the `UIIcon` instance that represents the slot at the given `column` and `row`.
    ///
    /// The slots are indexed in row-major order, from top-left to bottom-right, starting at `(0, 0)`.
    ///
    /// - Parameters:
    ///   - column: The column index.
    ///   - row: The row index.
    /// - Returns: The `UIIcon` instance that represents the slot, or `nil` if out of range.
    ///
    func slotAt(column: Int, row: Int) -> UIIcon? {
        guard column < columns && row < rows else { return nil }
        return slots[row * columns + column]
    }
    
    /// Adds tracking data for a given slot.
    ///
    /// The slots are indexed in row-major order, from top-left to bottom-right, starting at `(0, 0)`.
    ///
    /// - Parameters:
    ///   - column: The column index.
    ///   - row: The row index.
    ///   - data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackingDataForSlotAt(column: Int, row: Int, data: Any) -> Bool {
        guard let node = slotAt(column: column, row: row)?.node else { return false }
        return addTrackingDataForNode(node, data: data)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
