//
//  UIItemElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/14/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays items owned and items being held.
///
class UIItemElement: UIElement {
    
    /// The node to group the contents of the element.
    ///
    private let contents: SKNode
    
    /// The equipment labels.
    ///
    private var equipmentLabels: [UIText]
    
    /// The slots of the items held.
    ///
    private var equipmentSlots: [UIIcon]
    
    /// The slots in the backpack.
    ///
    private var backpackSlots: [UIIcon]
    
    /// The bottom labels background.
    ///
    private let bottomLabelsBackground: UIBackground
    
    /// The subtitle label.
    ///
    let subtitleLabel: UIText
    
    /// The bottom labels.
    ///
    let bottomLabels: (left: UIText, right: UIText)
    
    /// The number of slots for the items being held.
    ///
    let equipmentCount: Int
    
    /// The number of columns in the backpack.
    ///
    let backpackColumns: Int
    
    /// The number of rows in the backpack.
    ///
    let backpackRows: Int
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - equipmentCount: The number of equipment slots.
    ///   - backpackColumns: The number of columns in the backpack.
    ///   - backpackRows: The number of rows in the backpack.
    ///   - equipmentSlotOffset: The gap to apply between adjacent equipment slots.
    ///   - backpackSlotOffset: The gap to apply between adjacent slots of the backpack.
    ///   - contentOffset: The offset to apply between element contents.
    ///   - subtitleLabelSize: The size of the subtitle text label.
    ///   - bottomLabelSize: The size of the bottom text labels.
    ///   - separatorImage: The image to use when separating sections of contents.
    ///   - backpackImage: The backpack image, which will enclose its slots.
    ///   - emptyIconImage: The slot image to display when no icon is set.
    ///   - backgroundImage: An optional background image to enclose the contents. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(equipmentCount: Int, backpackColumns: Int, backpackRows: Int, equipmentSlotOffset: CGFloat,
         backpackSlotOffset: CGFloat, contentOffset: CGFloat, subtitleLabelSize: CGSize, bottomLabelSize: CGSize,
         separatorImage: String, backpackImage: String, emptyIconImage: String, backgroundImage: String? = nil,
         backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        assert(equipmentCount > 0 && backpackColumns > 0 && backpackRows > 0)
        
        self.equipmentCount = equipmentCount
        self.backpackColumns = backpackColumns
        self.backpackRows = backpackRows
        equipmentLabels = []
        equipmentSlots = []
        backpackSlots = []
        contents = SKNode()
        
        let leftBottomLabelRatio: CGFloat = 0.5
        let separatorHeight: CGFloat = 6.0
        
        // Create the backpack node
        let backpack = SKSpriteNode(texture: TextureSource.createTexture(imageNamed: backpackImage))
        
        // Create the backpack slots in row-major order, from top-left to bottom-right
        let offset = backpackSlotOffset
        for i in 0..<backpackRows {
            for j in 0..<backpackColumns {
                let uiIcon = UIIcon(emptyIconImage: emptyIconImage)
                let width = uiIcon.node.size.width
                let height = uiIcon.node.size.height
                uiIcon.node.position = CGPoint(x: offset + (CGFloat(j) * (width + offset)) + (width / 2.0),
                                               y: offset + (CGFloat(backpackRows - i - 1) * (height + offset)) + (height / 2.0))
                backpackSlots.append(uiIcon)
                backpack.addChild(uiIcon.node)
            }
        }
        
        // Set the backpack node to enclose all its slots plus offset
        backpack.anchorPoint = CGPoint.zero
        backpack.size = CGSize(
            width: offset + (CGFloat(backpackColumns) * (backpackSlots.first!.node.size.width + offset)),
            height: offset + (CGFloat(backpackRows) * (backpackSlots.first!.node.size.height + offset)))
        
        // Calculate vertical alignment
        let slotSize = backpackSlots.first!.node.size
        let equipmentSize = CGSize(
            width: slotSize.width * CGFloat(equipmentCount) + equipmentSlotOffset * CGFloat(equipmentCount - 1),
            height: slotSize.height)
        let subtitleWidth = subtitleLabelSize.width
        let equipmentWidth = equipmentSize.width
        let backpackWidth = backpack.size.width
        let bottomWidth = bottomLabelSize.width + contentOffset
        var subtitleLabelX: CGFloat
        var equipmentX: CGFloat
        var backpackX: CGFloat
        var bottomLabelX: CGFloat
        if subtitleWidth >= equipmentWidth && subtitleWidth >= backpackWidth && subtitleWidth >= bottomWidth {
            subtitleLabelX = 0
            equipmentX = (subtitleWidth - equipmentWidth) / 2.0
            backpackX = (subtitleWidth - backpackWidth) / 2.0
            bottomLabelX = (subtitleWidth - bottomWidth) / 2.0
        } else if equipmentWidth >= subtitleWidth && equipmentWidth >= backpackWidth && equipmentWidth >= bottomWidth {
            subtitleLabelX = (equipmentWidth - subtitleWidth) / 2.0
            equipmentX = 0
            backpackX = (equipmentWidth - backpackWidth) / 2.0
            bottomLabelX = (equipmentWidth - bottomWidth) / 2.0
        } else if backpackWidth >= subtitleWidth && backpackWidth >= equipmentWidth && backpackWidth >= bottomWidth {
            subtitleLabelX = (backpackWidth - subtitleWidth) / 2.0
            equipmentX = (backpackWidth - equipmentWidth) / 2.0
            backpackX = 0
            bottomLabelX = (backpackWidth - bottomWidth) / 2.0
        } else {
            subtitleLabelX = (bottomWidth - subtitleWidth) / 2.0
            equipmentX = (bottomWidth - equipmentWidth) / 2.0
            backpackX = (bottomWidth - backpackWidth) / 2.0
            bottomLabelX = 0
        }
        
        // Calculate the dimensions
        let width = max(subtitleWidth, max(equipmentWidth, max(backpackWidth, bottomWidth)))
        let height = subtitleLabelSize.height + equipmentSize.height * 2.0 + backpack.size.height +
            bottomLabelSize.height + separatorHeight * 2.0 + contentOffset * 5.0
        
        // Create the label at the top
        let subtitleLabelRect = CGRect(x: subtitleLabelX, y: height - subtitleLabelSize.height,
                                       width: subtitleLabelSize.width, height: subtitleLabelSize.height)
        subtitleLabel = UIText(rect: subtitleLabelRect, style: .subtitle, text: "ITEMS")
        
        // Create the upper separator below the subtitle label
        let upperSeparatorRect = CGRect(x: 0, y: subtitleLabelRect.minY - contentOffset - separatorHeight,
                                        width: width, height: separatorHeight)
        let upperSeparator = UISeparator(image: separatorImage, rect: upperSeparatorRect)
        
        // Create the equipment slots below the upper separator
        for i in 0..<equipmentCount {
            let icon = UIIcon(emptyIconImage: emptyIconImage)
            icon.node.position = CGPoint(
                x: equipmentX + slotSize.width / 2.0 + CGFloat(i) * (slotSize.width + equipmentSlotOffset),
                y: upperSeparatorRect.minY - contentOffset - slotSize.height / 2.0)
            equipmentSlots.append(icon)
            
            // Create a label below each slot
            let labelRect = CGRect(x: icon.node.frame.minX, y: icon.node.frame.minY - icon.node.size.width,
                                   width: icon.node.size.width, height: icon.node.size.height)
            let label = UIText(rect: labelRect, style: .bar, text: nil, alignment: .center)
            equipmentLabels.append(label)
        }
        
        // Create the bottom labels
        let bottomBackgroundRect = CGRect(x: bottomLabelX,
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
                        UIText(rect: rightBottomRect, style: .gold, text: nil, alignment: .center))
        
        let bottomNode = SKNode()
        bottomNode.zPosition = 1
        bottomNode.addChild(bottomLabels.left.node)
        bottomNode.addChild(bottomLabels.right.node)
        bottomLabelsBackground.node.addChild(bottomNode)
        
        // Create the lower separator above the bottom labels
        let lowerSeparatorRect = CGRect(x: 0, y: bottomLabelSize.height + contentOffset,
                                        width: width, height: separatorHeight)
        let lowerSeparator = UISeparator(image: separatorImage, rect: lowerSeparatorRect)
        
        // Position the backpack
        backpack.position.x = backpackX
        backpack.position.y = lowerSeparatorRect.maxY + contentOffset
        
        // Group the contents on a single node
        let node = SKNode()
        node.zPosition = 1
        node.addChild(subtitleLabel.node)
        node.addChild(upperSeparator.node)
        for i in 0..<equipmentCount {
            node.addChild(equipmentSlots[i].node)
            node.addChild(equipmentLabels[i].node)
        }
        node.addChild(backpack)
        node.addChild(lowerSeparator.node)
        node.addChild(bottomLabelsBackground.node)
        
        // The background, if set, must be large enough to enclose the whole contents
        if let image = backgroundImage {
            var background: UIBackground
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
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
            size = CGSize(width: width, height: height)
            contents.addChild(node)
        }
    }
    
    /// Retrieves the `UIText` instance that represents the equipment label at the given index.
    ///
    /// The labels are indexed from left to right, starting at `0` and ending at `equipmentCount -1`.
    ///
    /// - Parameter index: The index of the label.
    /// - Returns: The `UIText` instance that represents the equipment label, or `nil` if out of range.
    ///
    func equipmentLabelAt(index: Int) -> UIText? {
        guard index >= 0 && index < equipmentLabels.count else { return nil }
        return equipmentLabels[index]
    }
    
    /// Retrieves the `UIIcon` instance that represents the equipment slot at the given index.
    ///
    /// The slots are indexed from left to right, starting at `0` and ending at `equipmentCount -1`.
    ///
    /// - Parameter index: The index of the slot.
    /// - Returns: The `UIIcon` instance that represents the equipment slot, or `nil` if out of range.
    ///
    func equipmentSlotAt(index: Int) -> UIIcon? {
        guard index >= 0 && index < equipmentSlots.count else { return nil }
        return equipmentSlots[index]
    }
    
    /// Retrieves the `UIIcon` instance that represents the slot at the given `column` and `row`
    /// of the backpack.
    ///
    /// The slots are indexed in row-major order, from top-left to bottom-right, starting at `(0, 0)`.
    ///
    /// - Parameters:
    ///   - column: The column index.
    ///   - row: The row index.
    /// - Returns: The `UIIcon` instance that represents the backpack slot, or `nil` if out of range.
    ///
    func backpackSlotAt(column: Int, row: Int) -> UIIcon? {
        guard column < backpackColumns && row < backpackRows else { return nil }
        return backpackSlots[row * backpackColumns + column]
    }
    
    /// Adds tracking data for a given equipment slot.
    ///
    /// The slots are indexed from left to right, starting at `0` and ending at `equipmentCount -1`.
    ///
    /// - Parameters:
    ///   - index: The index of the slot.
    ///   - data: The data to add.
    /// - Returns: `true` if the data could be added, `false` otherwise.
    ///
    @discardableResult
    func addTrackingDataForEquipmentSlotAt(index: Int, data: Any) -> Bool {
        guard let node = equipmentSlotAt(index: index)?.node else { return false }
        return addTrackingDataForNode(node, data: data)
    }
    
    /// Adds tracking data for a given backpack slot.
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
    func addTrackingDataForBackpackSlotAt(column: Int, row: Int, data: Any) -> Bool {
        guard let node = backpackSlotAt(column: column, row: row)?.node else { return false }
        return addTrackingDataForNode(node, data: data)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height - size.height) / 2.0)
        node.addChild(contents)
        return node
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
}
