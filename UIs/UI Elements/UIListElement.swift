//
//  UIListElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/5/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElementType` that displays a vertical list of labels.
///
class UIListElement: UIElement {
    
    /// The node to group the contents of the element.
    ///
    private let contents: SKNode
    
    /// The label entries.
    ///
    private var labels: [String: (label: UIText, background: UIBackground)]
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - entries: The text for each entry in the list, in the order that they should be listed.
    ///   - entryOffset: The offset to apply between adjacent entries.
    ///   - labelSize: The size of the text label.
    ///   - backgroundImage: An optional background image to enclose the list. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(entries: [String], entryOffset: CGFloat, labelSize: CGSize,
         backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        assert(!entries.isEmpty)
        
        labels = [:]
        contents = SKNode()
        
        let groupNode = SKNode()
        groupNode.zPosition = 1
        
        var position = CGPoint(x: 0, y: (labelSize.height + entryOffset) * CGFloat(entries.count - 1))
        let height = position.y + labelSize.height
        let labelRect = CGRect(origin: CGPoint.zero, size: labelSize)
        
        for entry in entries {
            let label = UIText(rect: labelRect, style: .text, text: entry, alignment: .center)
            let background = UIBackground.defaultBlackBackground(rect: CGRect(origin: position, size: labelSize))
            
            let node = SKNode()
            node.zPosition = 1
            node.addChild(label.node)
            node.position.x -= background.node.size.width / 2.0
            node.position.y -= background.node.size.height / 2.0
            
            background.node.addChild(node)
            groupNode.addChild(background.node)
            
            labels[entry] = (label, background)
            
            position.y -= labelSize.height + entryOffset
        }
        
        // The background, if set, must be large enough to enclose the whole contents
        let frame = CGRect(x: 0, y: 0, width: labelSize.width, height: height)
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
    
    /// Retrieves the `UIText` for the given entry.
    ///
    /// - Parameter name: The `String` that names the entry.
    /// - Returns: The `UIText` for the entry, or `nil` if not found.
    ///
    func entryNamed(_ name: String) -> UIText? {
        return labels[name]?.label
    }
    
    /// Retrieves the `UIBackground` for the given entry.
    ///
    /// - Parameter name: The `String` that names the entry.
    /// - Returns: The `UIBackground` for the entry, or `nil` if not found.
    ///
    func backgroundOfEntry(named name: String) -> UIBackground? {
        return labels[name]?.background
    }
    
    /// Adds tracking data for the given entry.
    ///
    /// - Parameters:
    ///   - name: The `String` that names the entry.
    ///   - data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackindDataForEntry(named name: String, data: Any) -> Bool {
        guard let node = labels[name]?.background.node else { return false }
        return addTrackingDataForNode(node, data: data)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height  - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
