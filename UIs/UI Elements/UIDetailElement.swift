//
//  UIDetailElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/26/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays details about the character.
///
class UIDetailElement: UIElement {
    
    /// A class that defines a middle entry.
    ///
    class MiddleEntry {
        
        /// The name label.
        ///
        let nameLabel: UIText
        
        /// The value label.
        ///
        let valueLabel: UIText
        
        /// The background.
        ///
        let background: UIBackground
        
        /// Creates a new instance from the given name and value labels.
        ///
        /// - Parameters:
        ///   - nameLabel: The name label.
        ///   - valueLabel: The value label.
        ///   - background: The background.
        ///
        init(nameLabel: UIText, valueLabel: UIText, background: UIBackground) {
            self.nameLabel = nameLabel
            self.valueLabel = valueLabel
            self.background = background
        }
    }
    
    /// The node to group the contents of the element.
    ///
    private let contents: SKNode
    
    /// The middle label entries.
    ///
    private var middleEntries: [MiddleEntry]
    
    /// The portrait.
    ///
    let portrait: UIPortrait
    
    /// The top labels.
    ///
    let topLabels: (upper: UIText, middle: UIText, lower: UIText)
    
    /// The bottom labels.
    ///
    let bottomLabels: (left: UIText, right: UIText)
    
    /// The top labels background.
    ///
    let topLabelsBackground: UIBackground
    
    /// The bottom labels background.
    ///
    let bottomLabelsBackground: UIBackground
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// The amount of middle label entries.
    ///
    var entryCount: Int {
        return middleEntries.count
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - entryCount: The number of entries in the center of the element.
    ///   - contentOffset: The offset to apply between element contents.
    ///   - topLabelSize: The size of the top text labels.
    ///   - middleLabelSize: The size for the middle text labels.
    ///   - bottomLabelSize: The size for the bottom text labels.
    ///   - emptyPortraitImage: The empty portrait image to display.
    ///   - separatorImage: The image to use when separating sections of content.
    ///   - backgroundImage: An optional background image to enclose the contents. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(entryCount: Int, contentOffset: CGFloat,
         topLabelSize: CGSize, middleLabelSize: CGSize, bottomLabelSize: CGSize,
         emptyPortraitImage: String, separatorImage: String, backgroundImage: String? = nil,
         backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        contents = SKNode()
        middleEntries = []
        
        let entryCount = CGFloat(entryCount)
        let nameLabelRatio: CGFloat = 0.65
        let leftBottomLabelRatio: CGFloat = 0.35
        let separatorHeight: CGFloat = 6.0
        
        // Create the portrait
        portrait = UIPortrait(emptyPortraitImage: emptyPortraitImage)
        
        // Calculate the dimensions for each section
        let topLabelTotalHeight = topLabelSize.height * 3.0 + contentOffset * 2.0
        let topWidth = portrait.node.size.width + topLabelSize.width + contentOffset
        let topHeight = max(portrait.node.size.height, topLabelTotalHeight)
        let middleWidth = middleLabelSize.width + contentOffset
        let middleHeight = middleLabelSize.height * entryCount + (entryCount - 1.0) * contentOffset
        let bottomWidth = bottomLabelSize.width + contentOffset
        let bottomHeight = bottomLabelSize.height
        
        // Calculate the total width without background
        let width = max(topWidth, max(middleWidth, bottomWidth))
        
        // Calculate the total height without background
        let height = topHeight + middleHeight + bottomHeight + separatorHeight * 2.0 + contentOffset * 4.0
        
        // Calculate the x position for each section
        var topX: CGFloat = 0
        var middleX: CGFloat = 0
        var bottomX: CGFloat = 0
        if topWidth >= middleWidth && topWidth >= bottomWidth {
            middleX = (topWidth - middleWidth) / 2.0
            bottomX = (topWidth - bottomWidth) / 2.0
        } else if middleWidth >= topWidth && middleWidth >= bottomWidth {
            topX = (middleWidth - topWidth) / 2.0
            bottomX = (middleWidth - bottomWidth) / 2.0
        } else {
            topX = (bottomWidth - topWidth) / 2.0
            middleX = (bottomWidth - middleWidth) / 2.0
        }
        
        // Positon the portrait
        portrait.node.position.x = topX + portrait.node.size.width / 2.0
        
        // Create the top labels at the portrait's right side
        let topBackgroundRect = CGRect(x: portrait.node.frame.maxX + contentOffset,
                                       y: 0,
                                       width: topLabelSize.width,
                                       height: topLabelTotalHeight)
        topLabelsBackground = UIBackground.defaultBlackBackground(rect: topBackgroundRect)
        
        if portrait.node.size.height < topLabelTotalHeight {
            topLabelsBackground.node.position.y = height - topLabelTotalHeight + topBackgroundRect.height / 2.0
            portrait.node.position.y = height - topLabelTotalHeight / 2.0
        } else {
            portrait.node.position.y = height - portrait.node.size.height / 2.0
            topLabelsBackground.node.position.y = portrait.node.position.y
        }
        
        let upperTopRect = CGRect(x: -topLabelsBackground.node.size.width / 2.0,
                                  y: topLabelsBackground.node.size.height / 2.0 - topLabelSize.height,
                                  width: topLabelSize.width,
                                  height: topLabelSize.height)
        let middleTopRect = CGRect(x: -topLabelsBackground.node.size.width / 2.0,
                                   y: -topLabelSize.height / 2.0,
                                   width: topLabelSize.width,
                                   height: topLabelSize.height)
        let lowerTopRect = CGRect(x: -topLabelsBackground.node.size.width / 2.0,
                                  y: -topLabelsBackground.node.size.height / 2.0,
                                  width: topLabelSize.width,
                                  height: topLabelSize.height)
        topLabels = (UIText(rect: upperTopRect, style: .subtitle, text: nil, alignment: .left),
                     UIText(rect: middleTopRect, style: .text, text: nil, alignment: .left),
                     UIText(rect: lowerTopRect, style: .value, text: nil, alignment: .left))
        
        let topNode = SKNode()
        topNode.zPosition = 1
        topNode.addChild(topLabels.upper.node)
        topNode.addChild(topLabels.middle.node)
        topNode.addChild(topLabels.lower.node)
        topLabelsBackground.node.addChild(topNode)
        
        // Create the middle labels
        let middleNode = SKNode()
        middleNode.position.x = middleX
        middleNode.position.y = bottomHeight + separatorHeight + contentOffset * 2.0
        
        let firstLabelRect = CGRect(x: 0,
                                    y: 0,
                                    width: middleLabelSize.width * nameLabelRatio,
                                    height: middleLabelSize.height)
        let secondLabelRect = CGRect(x: firstLabelRect.maxX + contentOffset,
                                     y: 0,
                                     width: middleLabelSize.width - firstLabelRect.width,
                                     height: middleLabelSize.height)
        
        var middleY = middleHeight - middleLabelSize.height
        for _ in 0..<Int(entryCount) {
            let firstLabel = UIText(rect: firstLabelRect, style: .text, text: nil, alignment: .left)
            let secondLabel = UIText(rect: secondLabelRect, style: .value, text: nil, alignment: .right)
            
            let node = SKNode()
            node.zPosition = 1
            node.addChild(firstLabel.node)
            node.addChild(secondLabel.node)
            
            let backgroundRect = CGRect(x: 0, y: middleY,
                                        width: secondLabelRect.maxX, height: middleLabelSize.height)
            let background = UIBackground.defaultBlackBackground(rect: backgroundRect)
            node.position.x -= backgroundRect.width / 2.0
            node.position.y -= backgroundRect.height / 2.0
            background.node.addChild(node)
            middleNode.addChild(background.node)
            
            let entry = MiddleEntry(nameLabel: firstLabel, valueLabel: secondLabel, background: background)
            middleEntries.append(entry)
            
            middleY -= middleLabelSize.height + contentOffset
        }
        
        // Create the bottom labels
        let bottomBackgroundRect = CGRect(x: bottomX,
                                          y: 0,
                                          width: bottomLabelSize.width,
                                          height: bottomLabelSize.height)
        bottomLabelsBackground = UIBackground.defaultBlackBackground(rect: bottomBackgroundRect)
        
        let leftBottomRect = CGRect(x: -bottomLabelsBackground.node.size.width / 2.0,
                                    y: -bottomLabelsBackground.node.size.height / 2.0,
                                    width: bottomLabelSize.width * leftBottomLabelRatio,
                                    height: bottomLabelSize.height)
        let rightBottomRect = CGRect(x: leftBottomRect.maxX + contentOffset,
                                     y: leftBottomRect.minY,
                                     width: bottomLabelSize.width - leftBottomRect.width,
                                     height: bottomLabelSize.height)

        bottomLabels = (UIText(rect: leftBottomRect, style: .emphasis, text: nil, alignment: .center),
                        UIText(rect: rightBottomRect, style: .value, text: nil, alignment: .center))
        
        let bottomNode = SKNode()
        bottomNode.zPosition = 1
        bottomNode.addChild(bottomLabels.left.node)
        bottomNode.addChild(bottomLabels.right.node)
        bottomLabelsBackground.node.addChild(bottomNode)
        
        // Create the separators
        let separatorSize = CGSize(width: width, height: separatorHeight)
        let topMinY = min(portrait.node.frame.minY, topLabelsBackground.node.frame.minY)
        let firstSeparatorOrigin = CGPoint(x: 0, y: topMinY - contentOffset - separatorHeight)
        let secondSeparatorOrigin = CGPoint(x: 0, y: bottomHeight + separatorHeight)
        
        let firstSeparator = UISeparator(image: separatorImage, rect: CGRect(origin: firstSeparatorOrigin,
                                                                             size: separatorSize))
        let secondSeparator = UISeparator(image: separatorImage, rect: CGRect(origin: secondSeparatorOrigin,
                                                                              size: separatorSize))
        
        // Group the contents on a single node
        //
        let node = SKNode()
        node.zPosition = 1
        node.addChild(portrait.node)
        node.addChild(topLabelsBackground.node)
        node.addChild(firstSeparator.node)
        node.addChild(middleNode)
        node.addChild(secondSeparator.node)
        node.addChild(bottomLabelsBackground.node)
        
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
    
    /// Retrieves the `MiddleEntry` instance identified by index.
    ///
    /// The entries are indexed from `0` to `entryCount - 1`, ordered from top to bottom.
    ///
    /// - Parameter index: The index of the middle entry.
    /// - Returns: The `MiddleEntry` found at the given index, or `nil` if out of bounds.
    ///
    func middleEntryAt(index: Int) -> MiddleEntry? {
        guard index >= 0 && index < entryCount else { return nil }
        return middleEntries[index]
    }
    
    /// Adds tracking data for the portrait.
    ///
    /// - Parameter data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackingDataForPortrait(data: Any) -> Bool {
        return addTrackingDataForNode(portrait.node, data: data)
    }
    
    /// Adds tracking data for the top label.
    ///
    /// - Parameter data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackingDataForTopLabel(data: Any) -> Bool {
        return addTrackingDataForNode(topLabelsBackground.node, data: data)
    }
    
    /// Adds tracking data for the bottom label.
    ///
    /// - Parameter data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackingDataForBottomLabel(data: Any) -> Bool {
        return addTrackingDataForNode(bottomLabelsBackground.node, data: data)
    }
    
    /// Adds tracking data for a given middle entry.
    ///
    /// The entries are indexed from `0` to `entryCount - 1`, ordered from top to bottom.
    ///
    /// - Parameters:
    ///   - index: The index.
    ///   - data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackingDataForMiddleEntryAt(index: Int, data: Any) -> Bool {
        guard let node = middleEntryAt(index: index)?.background.node else { return false }
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
