//
//  UIDialogElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/29/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays a dialog window.
///
class UIDialogElement: UIElement {
    
    /// The node that holds all the element contents.
    ///
    private let contents: SKNode
    
    /// The main label background.
    ///
    private let mainLabelBackground: UIBackground
    
    /// The bottom-left option background.
    ///
    private let leftOptionBackground: UIBackground
    
    /// The bottom-right option background.
    ///
    private let rightOptionBackground: UIBackground
    
    /// The dimensions of the main label mask.
    ///
    private var maskSize: CGSize {
        return mainLabelBackground.node.size
    }
    
    /// The portrait.
    ///
    let portrait: UIPortrait
    
    /// The main label.
    ///
    let mainLabel: UIText
    
    /// The bottom-left option label.
    ///
    let leftOptionLabel: UIText
    
    /// The bottom-right option label.
    ///
    let rightOptionLabel: UIText
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - text: The text to display in the main label.
    ///   - entryOffset: The offset to apply between the two option entries.
    ///   - contentOffset: The offset to apply between element contents.
    ///   - mainLabelSize: The size of the main text label.
    ///   - optionLabelSize: The size for each of the two option text labels.
    ///   - emptyPortraitImage: The empty portrait image to display.
    ///   - separatorImage: The image to use when separating sections of content.
    ///   - backgroundImage: An optional background image to enclose the contents. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(text: String, entryOffset: CGFloat, contentOffset: CGFloat, mainLabelSize: CGSize, optionLabelSize: CGSize,
         emptyPortraitImage: String, separatorImage: String, backgroundImage: String? = nil,
         backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        contents = SKNode()
        
        let separatorHeight: CGFloat = 6.0
        
        // Calculate the total width for each section
        let mainWidth = mainLabelSize.width
        let optionsWidth = optionLabelSize.width * 2.0 + entryOffset
        
        // Calculate the total width without background and portrait
        let width = max(mainWidth, optionsWidth)
        
        // Calculate the total height without background and portrait
        let height = mainLabelSize.height + optionLabelSize.height + separatorHeight + contentOffset * 2.0
        
        // Calculate the x position of main label
        let mainX = mainWidth >= optionsWidth ? 0 : (optionsWidth - mainWidth) / 2.0
        
        // Create the main label
        mainLabel = UIText(maxWidth: mainWidth, style: .text, text: text)
        
        // Create the main label crop node
        let mainCropNode = SKCropNode()
        let mainMaskNode = SKSpriteNode(color: .white, size: mainLabelSize)
        mainCropNode.maskNode = mainMaskNode
        mainCropNode.addChild(mainLabel.node)
        mainCropNode.position = CGPoint(x: mainX + mainLabelSize.width / 2.0, y: height - mainLabelSize.height / 2.0)
        mainCropNode.zPosition = 1
        
        // Create the main label background
        // Note: The main crop node is not made a child of the main label background on purpose -
        // doing so would make the tracking area greater than `mainLabelSize` when the text is cropped
        let mainRect = CGRect(x: mainX, y: height - mainLabelSize.height,
                              width: mainLabelSize.width, height: mainLabelSize.height)
        mainLabelBackground = UIBackground.defaultBlackBackground(rect: mainRect)
        
        // Adjust the main label position to show the beginning of the text
        let mainFinalSize = mainLabel.node.calculateAccumulatedFrame().size
        if mainFinalSize.height > mainLabelSize.height {
            mainLabel.node.position.y -= (mainFinalSize.height - mainLabelSize.height) / 2.0
        }
        
        // Create the separator
        let separatorRect = CGRect(x: 0, y: height - (mainLabelSize.height + contentOffset + separatorHeight),
                                   width: width, height: separatorHeight)
        let separator = UISeparator(image: separatorImage, rect: separatorRect)
        
        // Create the bottom labels
        let leftOptionRect = CGRect(x: width / 2.0 - (optionLabelSize.width + entryOffset / 2.0), y: 0,
                                    width: optionLabelSize.width, height: optionLabelSize.height)
        let rightOptionRect = CGRect(x: width / 2.0 + entryOffset / 2.0, y: 0,
                                     width: optionLabelSize.width, height: optionLabelSize.height)
        let optionRect = CGRect(x: 0, y: 0, width: optionLabelSize.width, height: optionLabelSize.height)
        leftOptionLabel = UIText(rect: optionRect, style: .subtitle, text: nil, alignment: .center)
        rightOptionLabel = UIText(rect: optionRect, style: .subtitle, text: nil, alignment: .center)
        
        // Create the option backgrounds
        leftOptionBackground = UIBackground.defaultBlackBackground(rect: leftOptionRect)
        rightOptionBackground = UIBackground.defaultBlackBackground(rect: rightOptionRect)
        let optionNodes = (SKNode(), SKNode())
        optionNodes.0.zPosition = 1
        optionNodes.1.zPosition = 1
        optionNodes.0.addChild(leftOptionLabel.node)
        optionNodes.1.addChild(rightOptionLabel.node)
        optionNodes.0.position.x -= leftOptionBackground.node.size.width / 2.0
        optionNodes.0.position.y -= leftOptionBackground.node.size.height / 2.0
        optionNodes.1.position.x -= rightOptionBackground.node.size.width / 2.0
        optionNodes.1.position.y -= rightOptionBackground.node.size.height / 2.0
        leftOptionBackground.node.addChild(optionNodes.0)
        rightOptionBackground.node.addChild(optionNodes.1)
        
        // Create the portrait
        portrait = UIPortrait(emptyPortraitImage: emptyPortraitImage)
        portrait.node.position.x = portrait.node.size.width / 2.0
        
        // Group the contents on a single node (the portrait will be added later)
        let node = SKNode()
        node.zPosition = 1
        node.addChild(mainLabelBackground.node)
        node.addChild(mainCropNode)
        node.addChild(separator.node)
        node.addChild(leftOptionBackground.node)
        node.addChild(rightOptionBackground.node)
        
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
            size = CGSize(width: background.node.size.width + portrait.node.size.width,
                          height: max(background.node.size.height, portrait.node.size.height))
            background.node.addChild(node)
            background.node.position.x += portrait.node.size.width
            portrait.node.position.y = background.node.frame.maxY - portrait.node.size.height / 2.0
            contents.addChild(portrait.node)
            contents.addChild(background.node)
        } else {
            size = CGSize(width: frame.size.width + portrait.node.size.width,
                          height: max(frame.size.height, portrait.node.size.height))
            node.position.x += portrait.node.size.width
            portrait.node.position.y = height > portrait.node.size.height ?
                (height - portrait.node.size.height / 2.0) : (portrait.node.size.height / 2.0)
            contents.addChild(portrait.node)
            contents.addChild(node)
        }
    }
    
    /// Sets the main label to display the first part of the text.
    ///
    /// If the text is not being cropped, this method does nothing.
    ///
    func setMainLabelToBeginning() {
        let labelSize = mainLabel.node.calculateAccumulatedFrame().size
        if labelSize.height > maskSize.height {
            mainLabel.node.position.y = -(labelSize.height - maskSize.height) / 2.0
        }
    }
    
    /// Sets the main label to display the last part of the text.
    ///
    /// If the text is not being cropped, this method does nothing.
    ///
    func setMainLabelToEnd() {
        let labelSize = mainLabel.node.calculateAccumulatedFrame().size
        if labelSize.height > maskSize.height {
            mainLabel.node.position.y = (labelSize.height - maskSize.height) / 2.0
        }
    }
    
    /// Scrolls the main label text.
    ///
    /// - Parameter amount: The amount to scroll. Negative values scrolls up, positive scrolls down.
    ///
    func scrollMainLabelBy(amount: CGFloat) {
        let labelSize = mainLabel.node.calculateAccumulatedFrame().size
        guard labelSize.height > maskSize.height else { return }
        
        let position = mainLabel.node.position.y
        if amount < 0 {
            let minimum = -(labelSize.height - maskSize.height) / 2.0
            mainLabel.node.position.y = max(minimum, position + amount)
        } else {
            let maximum = (labelSize.height - maskSize.height) / 2.0
            mainLabel.node.position.y = min(maximum, position + amount)
        }
    }
    
    /// Checks if the main label text is set to the beginning.
    ///
    /// - Returns: `true` if the main label text is at the beginning, `false` otherwise.
    ///
    func isMainLabelAtBeggining() -> Bool {
        let labelSize = mainLabel.node.calculateAccumulatedFrame().size
        return mainLabel.node.position.y <= -(labelSize.height - maskSize.height) / 2.0
    }
    
    /// Checks if the main label text is set to the end.
    ///
    /// - Returns: `true` if the main label text is at the end, `false` otherwise.
    ///
    func isMainLabelAtEnd() -> Bool {
        let labelSize = mainLabel.node.calculateAccumulatedFrame().size
        return mainLabel.node.position.y >= (labelSize.height - maskSize.height) / 2.0
    }
    
    /// Adds tracking data for the main text label.
    ///
    /// - Parameter data: The data to add.
    /// - Returns: `true` if the data was added, false otherwise.
    ///
    @discardableResult
    func addTrackinDataForMainLabel(data: Any) -> Bool {
        return addTrackingDataForNode(mainLabelBackground.node, data: data)
    }
    
    /// Adds tracking data for the left option label.
    ///
    /// - Parameter data: The data to add.
    /// - Returns: `true` if the data was added, false otherwise.
    ///
    @discardableResult
    func addTrackinDataForLeftOption(data: Any) -> Bool {
        return addTrackingDataForNode(leftOptionBackground.node, data: data)
    }
    
    /// Adds tracking data for the right option label.
    ///
    /// - Parameter data: The data to add.
    /// - Returns: `true` if the data was added, false otherwise.
    ///
    @discardableResult
    func addTrackinDataForRightOption(data: Any) -> Bool {
        return addTrackingDataForNode(rightOptionBackground.node, data: data)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
