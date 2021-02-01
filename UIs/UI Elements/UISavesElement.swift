//
//  UISavesElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/8/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays saved games, arranged in a list of entries.
///
class UISavesElement: UIElement {
    
    /// A class that defines an entry in the element for a saved game.
    ///
    class SaveEntry {
        
        /// The `UIPortrait` that holds the portrait of the class.
        ///
        let portrait: UIPortrait
        
        /// The `UIText` that holds the name of the class.
        ///
        let name: UIText
        
        /// The `UIText` that holds information about the save.
        ///
        let info: UIText
        
        /// The `UIText` that holds the save creation date.
        ///
        let creationDate: UIText
        
        /// The `UIText` that holds the most recent save date.
        ///
        let saveDate: UIText
        
        /// The `UIBackground` that encloses the entry contents.
        ///
        let background: UIBackground?
        
        /// Creates a new instance from the given values.
        ///
        /// - Parameters:
        ///   - portrait: The `UIPortrait` to use for the class portrait.
        ///   - name: The `UIText` to use for the class name.
        ///   - info: The `UIText` to use for the save information.
        ///   - creationDate: The `UIText` to use for the creation date.
        ///   - saveDate: The `UIText` to use for the save date.
        ///   - background: An optional `UIBackground` for the entry. The default value is `nil`.
        ///
        init(portrait: UIPortrait, name: UIText, info: UIText, creationDate: UIText, saveDate: UIText,
             background: UIBackground? = nil) {
            
            self.portrait = portrait
            self.name = name
            self.info = info
            self.creationDate = creationDate
            self.saveDate = saveDate
            self.background = background
        }
    }
    
    /// The node to group the contents of the element.
    ///
    private let contents: SKNode
    
    /// The save entries.
    ///
    private var entries: [SaveEntry]
    
    /// The `UIArrow` for the next list.
    ///
    let nextArrow: UIArrow
    
    /// The `UIArrow` for the previous list.
    ///
    let previousArrow: UIArrow
    
    /// The amount of save rows.
    ///
    let rows: Int
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Cretes a new instance from the given values.
    ///
    /// - Parameters:
    ///   - rows: The number of save entries to create.
    ///   - entryOffset: The offset to apply between adjacent entries.
    ///   - contentOffset: The offset to apply between element contents.
    ///   - labelSize: The size of the text labels.
    ///   - emptyPortraitImage: The empty portrait image to display.
    ///   - arrowImage: The arrow image to use when indicating next/previous entries.
    ///   - backgroundImage: An optional background image to enclose the saves. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(rows: Int, entryOffset: CGFloat, contentOffset: CGFloat, labelSize: CGSize, emptyPortraitImage: String,
         arrowImage: String, backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil,
         backgroundOffset: CGFloat = 0) {
        
        contents = SKNode()
        contents.zPosition = 1
        entries = []
        self.rows = rows
        
        let entriesNode = SKNode()
        entriesNode.zPosition = 1
        let labelsHeight = labelSize.height * 2.0 + contentOffset
        let arrowOffset: CGFloat = 40.0
        var entrySize = CGSize.zero
        
        // Create the save entries
        for i in 0..<rows {
            let portrait = UIPortrait(emptyPortraitImage: emptyPortraitImage)
            var nameOrigin: CGPoint
            var infoOrigin: CGPoint
            var creationOrigin: CGPoint
            var saveOrigin: CGPoint
            if labelsHeight > portrait.node.size.height {
                portrait.node.position = CGPoint(x: portrait.node.size.width / 2.0, y: labelsHeight / 2.0)
                nameOrigin = CGPoint(x: portrait.node.size.width + contentOffset, y: labelsHeight - labelSize.height)
                infoOrigin = CGPoint(x: portrait.node.size.width + contentOffset, y: 0)
                creationOrigin = CGPoint(x: nameOrigin.x + labelSize.width + contentOffset, y: nameOrigin.y)
                saveOrigin = CGPoint(x: infoOrigin.x + labelSize.width + contentOffset, y: infoOrigin.y)
            } else {
                portrait.node.position = CGPoint(x: portrait.node.size.width / 2.0, y: portrait.node.size.height / 2.0)
                nameOrigin = CGPoint(x: portrait.node.size.width + contentOffset,
                                     y: portrait.node.size.height - labelSize.height)
                infoOrigin = CGPoint(x: portrait.node.size.width + contentOffset, y: 0)
                creationOrigin = CGPoint(x: nameOrigin.x + labelSize.width + contentOffset, y: nameOrigin.y)
                saveOrigin = CGPoint(x: infoOrigin.x + labelSize.width + contentOffset, y: infoOrigin.y)
            }
            
            // Create the labels
            let name = UIText(rect: CGRect(origin: nameOrigin, size: labelSize), style: .subtitle, text: nil,
                              alignment: .bottomLeft)
            let info = UIText(rect: CGRect(origin: infoOrigin, size: labelSize), style: .text, text: nil,
                              alignment: .topLeft)
            let creationDate = UIText(rect: CGRect(origin: creationOrigin, size: labelSize), style: .text, text: nil,
                                      alignment: .bottomLeft)
            let saveDate = UIText(rect: CGRect(origin: saveOrigin, size: labelSize), style: .text, text: nil,
                                  alignment: .topLeft)
            
            // Group the entry contents
            let node = SKNode()
            node.zPosition = 1
            node.addChild(portrait.node)
            node.addChild(name.node)
            node.addChild(info.node)
            node.addChild(creationDate.node)
            node.addChild(saveDate.node)
            
            // The background, if set, must be large enough to enclose the whole entry contents
            var background: UIBackground?
            let frame = CGRect(x: 0, y: 0,
                               width: portrait.node.size.width + (labelSize.width + contentOffset) * 2.0,
                               height: max(portrait.node.size.height, labelsHeight))
            if let image = backgroundImage {
                if let border = backgroundBorder {
                    let rect = CGRect(x: 0, y: 0,
                                      width: frame.width + border.left + border.right + backgroundOffset * 2.0,
                                      height: frame.height + border.top + border.bottom + backgroundOffset * 2.0)
                    background = UIBackground(image: image, rect: rect, border: border)
                    node.position.x -= background!.node.size.width / 2.0 - border.left - backgroundOffset
                    node.position.y -= background!.node.size.height / 2.0 - border.bottom - backgroundOffset
                } else {
                    let rect = CGRect(x: 0, y: 0,
                                      width: frame.width + backgroundOffset * 2.0,
                                      height: frame.height + backgroundOffset * 2.0)
                    background = UIBackground(image: image, rect: rect)
                    node.position.x -= background!.node.size.width / 2.0 - backgroundOffset
                    node.position.y -= background!.node.size.height / 2.0 - backgroundOffset
                }
                // Set the entry node as child of the background
                background!.node.addChild(node)
                // Set the entry to have the same dimensions as the background
                if entrySize == CGSize.zero {
                    entrySize = CGSize(width: background!.node.size.width, height: background!.node.size.height)
                }
                // Position the background based on the entry's index
                background!.node.position.y = CGFloat(rows - i - 1) * (entrySize.height + entryOffset) + entrySize.height / 2.0
                // Add the background node as child of the entries node
                entriesNode.addChild(background!.node)
            } else {
                background = nil
                if entrySize == CGSize.zero { entrySize = frame.size }
                // Position the node based on the entry's index
                node.position.y = CGFloat(rows - i - 1) * (entrySize.height + entryOffset)
                // Add the entry node as child of the entries node
                entriesNode.addChild(node)
            }
            
            // Store the entry
            entries.append(SaveEntry(portrait: portrait, name: name, info: info, creationDate: creationDate,
                                     saveDate: saveDate, background: background))
        }
        
        // Create and position the arrows
        nextArrow = UIArrow(image: arrowImage, zRotation: 0)
        previousArrow = UIArrow(image: arrowImage, zRotation: CGFloat.pi)
        let height = CGFloat(rows) * entrySize.height + CGFloat(rows - 1) * entryOffset
        nextArrow.node.position = CGPoint(x: nextArrow.node.size.width * 1.5 + arrowOffset * 2.0 + entrySize.width,
                                          y: height / 2.0)
        previousArrow.node.position = CGPoint(x: previousArrow.node.size.width / 2.0, y: height / 2.0)
        
        // Position the entries node between the arrows
        entriesNode.position.x += previousArrow.node.size.width + arrowOffset
        
        // Add the entries and arrow to the contents node
        contents.addChild(entriesNode)
        contents.addChild(nextArrow.node)
        contents.addChild(previousArrow.node)
        
        // Set the final size of the element
        size = CGSize(width: nextArrow.node.position.x + nextArrow.node.size.width / 2.0, height: height)
    }
    
    /// Retrieves the `SaveEntry` at the given `index`, indexed from top to bottom, starting from `0`.
    ///
    /// - Parameter index: The index of the entry to retrieve.
    /// - Returns: The `SaveEntry` at the given `index`, or `nil` if out of range.
    ///
    func entryAt(index: Int) -> SaveEntry? {
        guard index >= 0 && index < entries.count else { return nil }
        return entries[index]
    }
    
    /// Adds tracking data for the given entry.
    ///
    /// - Parameters:
    ///   - index: The index of the entry.
    ///   - data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackindDataForEntry(at index: Int, data: Any) -> Bool {
        guard let node = entryAt(index: index)?.background?.node else { return false }
        return addTrackingDataForNode(node, data: data)
    }
    
    /// Adds tracking data for the next arrow.
    ///
    /// - Parameter data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackindDataForNextArrow(data: Any) -> Bool {
        return addTrackingDataForNode(nextArrow.node, data: data)
    }
    
    /// Adds tracking data for the previous arrow.
    ///
    /// - Parameter data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackindDataForPreviousArrow(data: Any) -> Bool {
        return addTrackingDataForNode(previousArrow.node, data: data)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
