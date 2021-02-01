//
//  UISkillElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/16/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays a set of skills.
///
class UISkillElement: UIElement {
    
    /// A class that defines a single skill contained in a skill set.
    ///
    class SkillEntry {
        
        /// The `UIIcon` instance that holds the skill icon.
        ///
        let slot: UIIcon
        
        /// The `UIText` instance that holds the skill name.
        ///
        let label: UIText
        
        /// The `UIImage` instance that holds the skill lock image.
        ///
        let image: UIImage
        
        /// The `UIBackground` instance.
        ///
        let background: UIBackground
        
        /// Creates a new instance from the given values.
        ///
        /// - Parameters:
        ///   - slot: An `UIIcon` for the skill.
        ///   - label: An `UIText` for the skill.
        ///   - image: An `UIImage` for the skill.
        ///   - background: An `UIBackground` for the skill.
        ///
        init(slot: UIIcon, label: UIText, image: UIImage, background: UIBackground) {
            self.slot = slot
            self.label = label
            self.image = image
            self.background = background
        }
    }
    
    /// The node to group the contents of the element.
    ///
    private let contents: SKNode

    /// The entries in the skill set.
    ///
    private var entries: [SkillEntry]
    
    /// The subtitle label.
    ///
    let subtitleLabel: UIText
    
    /// The points labels.
    ///
    let pointsLabels: (left: UIText, right: UIText)
    
    /// The number of entries in the skill set.
    ///
    let entryCount: Int
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - entryCount: The number of entries in the skill set.
    ///   - entryOffset: The offset to apply between adjacent entries of the skill set.
    ///   - contentOffset: The offset to apply between adjacent contents of the same entry.
    ///   - subtitleLabelSize: The size of the text label for the subtitle.
    ///   - entryLabelSize: The size of the text label for the skill entries.
    ///   - pointsLabelSize: The size of the text label for the skill points.
    ///   - separatorImage: The image to use when separating sections of content.
    ///   - emptyIconImage: The slot image to display when no icon is set.
    ///   - lockImage: The lock image to display for locked skills.
    ///   - backgroundImage: An optional background image to enclose the skill set. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(entryCount: Int, entryOffset: CGFloat, contentOffset: CGFloat,
         subtitleLabelSize: CGSize, entryLabelSize: CGSize, pointsLabelSize: CGSize,
         separatorImage: String, emptyIconImage: String, lockImage: String,
         backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        assert(entryCount > 0)
        
        self.entryCount = entryCount
        contents = SKNode()
        entries = []
        
        let separatorHeight: CGFloat = 6.0
        
        let groupNode = SKNode()
        groupNode.zPosition = 1
        
        var accumulatedSize = CGSize.zero
        accumulatedSize.height += subtitleLabelSize.height + separatorHeight + contentOffset * 2.0
        accumulatedSize.height += pointsLabelSize.height + separatorHeight + contentOffset * 2.0
        
        // Create the entries
        for i in 0..<entryCount {
                
            var labelY: CGFloat
            
            // Place the slot in the left side
            let slot = UIIcon(emptyIconImage: emptyIconImage)
            if slot.node.size.height < entryLabelSize.height {
                slot.node.position = CGPoint(x: slot.node.size.width / 2.0, y: entryLabelSize.height / 2.0)
                labelY = 0
            } else {
                slot.node.position = CGPoint(x: slot.node.size.width / 2.0, y: slot.node.size.height / 2.0)
                labelY = (slot.node.size.height - entryLabelSize.height) / 2.0
            }
            
            // Place the label in the slot's right side
            let labelRect = CGRect(x: slot.node.size.width + contentOffset,
                                   y: labelY,
                                   width: entryLabelSize.width,
                                   height: entryLabelSize.height)
            let label = UIText(rect: labelRect, style: .subtitle, text: nil, alignment: .left)
            
            // Place the lock image in the label's right side
            let imageRect = CGRect(origin: CGPoint(x: labelRect.maxX + contentOffset,
                                                   y: slot.node.position.y - slot.node.size.height / 2.0),
                                   size: slot.node.size)
            let image = UIImage(rect: imageRect, image: lockImage, alignment: .center, textStyle: .lock)
            
            // Create the entry's background
            let backgroundSize = CGSize(width: imageRect.maxX, height: max(slot.node.size.height, labelRect.maxY))
            let background = UIBackground.defaultBlackBackground(rect: CGRect(origin: CGPoint.zero,
                                                                              size: backgroundSize))
            
            // Create the entry
            let entry = SkillEntry(slot: slot, label: label, image: image, background: background)
            entries.append(entry)
        
            // Group the entry contents
            let node = SKNode()
            node.zPosition = 1
            node.addChild(slot.node)
            node.addChild(label.node)
            node.addChild(image.node)
            node.position.x -= backgroundSize.width / 2.0
            node.position.y -= backgroundSize.height / 2.0
            background.node.addChild(node)
            
            // Set the entry node's position relative to its index in the set
            background.node.position.y = CGFloat(entryCount - i - 1) * (backgroundSize.height + entryOffset)
            background.node.position.y += backgroundSize.height / 2.0
            
            // Add the entry node as a child of the group node
            groupNode.addChild(background.node)
            
            // Update the element size
            if i == 0 {
                accumulatedSize.width = backgroundSize.width
                accumulatedSize.height += backgroundSize.height * CGFloat(entryCount) +
                    contentOffset * CGFloat(entryCount - 1)
            }
        }
        
        // Calculate vertical alignment
        var subtitleLabelX: CGFloat
        var pointsLabelX: CGFloat
        if subtitleLabelSize.width > accumulatedSize.width && subtitleLabelSize.width > pointsLabelSize.width {
            subtitleLabelX = 0
            pointsLabelX = (subtitleLabelSize.width - pointsLabelSize.width) / 2.0
            // Update the accumulated width too
            accumulatedSize.width = subtitleLabelSize.width
        } else if pointsLabelSize.width > accumulatedSize.width && pointsLabelSize.width > subtitleLabelSize.width {
            subtitleLabelX = (pointsLabelSize.width - subtitleLabelSize.width) / 2.0
            pointsLabelX = 0
            // Update the accumulated width too
            accumulatedSize.width = pointsLabelSize.width
        } else {
            subtitleLabelX = (accumulatedSize.width - subtitleLabelSize.width) / 2.0
            pointsLabelX = (accumulatedSize.width - pointsLabelSize.width) / 2.0
        }
        
        // Create the subtitle label
        let subtitleLabelRect = CGRect(x: subtitleLabelX, y: accumulatedSize.height - subtitleLabelSize.height,
                                       width: subtitleLabelSize.width, height: subtitleLabelSize.height)
        subtitleLabel = UIText(rect: subtitleLabelRect, style: .subtitle, text: "SKILLS")
        
        // Create the points labels
        let leftLabelRect = CGRect(x: pointsLabelX,
                                   y: 0,
                                   width: pointsLabelSize.width * 0.7,
                                   height: pointsLabelSize.height)
        let rightLabelRect = CGRect(x: leftLabelRect.maxX,
                                    y: 0,
                                    width: pointsLabelSize.width - leftLabelRect.width,
                                    height: pointsLabelSize.height)

        pointsLabels = (UIText(rect: leftLabelRect, style: .emphasis, text: nil, alignment: .center),
                        UIText(rect: rightLabelRect, style: .points, text: nil, alignment: .center))
        
        // Create the separators
        let separatorSize = CGSize(width: accumulatedSize.width, height: separatorHeight)
        let firstSeparatorOrigin = CGPoint(x: 0, y: subtitleLabelRect.minY - contentOffset - separatorHeight)
        let secondSeparatorOrigin = CGPoint(x: 0, y: pointsLabelSize.height + contentOffset)
        let firstSeparator = UISeparator(image: separatorImage,
                                         rect: CGRect(origin: firstSeparatorOrigin, size: separatorSize))
        let secondSeparator = UISeparator(image: separatorImage,
                                          rect: CGRect(origin: secondSeparatorOrigin, size: separatorSize))

        // Update groupNode y position
        groupNode.position.y = pointsLabelSize.height + separatorHeight + contentOffset * 2.0
        
        // Group the contents on a single node
        let node = SKNode()
        node.zPosition = 1
        node.addChild(subtitleLabel.node)
        node.addChild(firstSeparator.node)
        node.addChild(groupNode)
        node.addChild(secondSeparator.node)
        node.addChild(pointsLabels.left.node)
        node.addChild(pointsLabels.right.node)
        
        // The background, if set, must enclose the whole contents
        let frame = CGRect(origin: CGPoint.zero, size: accumulatedSize)
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
    
    /// Retrieves the `SkillEntry` instance that represents the skill at the given index.
    ///
    /// The entries are indexed from `0` to `entryCount - 1`, ordered from top to bottom.
    ///
    /// - Parameter index: The index of the skill entry.
    /// - Returns: The `SkillEntry` found at the given index, or `nil` if out of bounds.
    ///
    func entryAt(index: Int) -> SkillEntry? {
        guard (0..<entryCount).contains(index) else { return nil }
        return entries[index]
    }
    
    /// Adds tracking data for a given skill entry.
    ///
    /// The entries are indexed from `0` to `entryCount - 1`, ordered from top to bottom.
    ///
    /// - Parameters:
    ///   - index: The index.
    ///   - data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackingDataForEntryAt(index: Int, data: Any) -> Bool {
        guard let node = entryAt(index: index)?.background.node else { return false }
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
