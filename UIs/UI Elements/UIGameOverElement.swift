//
//  UIGameOverElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/3/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type to present on game over.
///
class UIGameOverElement: UIElement {
    
    /// The node that holds all the contents of the element.
    ///
    private let contents: SKNode
    
    /// The left option background.
    ///
    let leftOptionBackground: UIBackground
    
    /// The right option background.
    ///
    let rightOptionBackground: UIBackground
    
    /// The main label for the game over text.
    ///
    let mainLabel: UIText
    
    /// The option label on the left.
    ///
    let leftOptionLabel: UIText
    
    /// The option label on the right.
    ///
    let rightOptionLabel: UIText
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - entryOffset: The offset to apply between the two option entries.
    ///   - contentOffset: The offset to apply between element contents.
    ///   - mainLabelSize: The size of the main text label.
    ///   - optionLabelSize: The size for each of the two option text labels.
    ///   - backgroundImage: An optional background image to enclose the contents. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(entryOffset: CGFloat, contentOffset: CGFloat, mainLabelSize: CGSize, optionLabelSize: CGSize,
         backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
     
        contents = SKNode()
        
        let node = SKNode()
        node.zPosition = 1
        
        // Calculate the dimensions
        let mainWidth = mainLabelSize.width
        let optionsWidth = optionLabelSize.width * 2.0 + entryOffset
        let width = max(mainWidth, optionsWidth)
        let height = mainLabelSize.height + optionLabelSize.height + contentOffset
        
        // Create the contents
        var mainRect: CGRect
        var leftOptionRect: CGRect
        var rightOptionRect: CGRect
        if mainWidth > optionsWidth {
            mainRect = CGRect(x: 0, y: height - mainLabelSize.height, width: mainLabelSize.width, height: mainLabelSize.height)
            leftOptionRect = CGRect(x: mainWidth / 2.0 - (optionLabelSize.width + entryOffset / 2.0), y: 0,
                                    width: optionLabelSize.width, height: optionLabelSize.height)
            rightOptionRect = leftOptionRect
            rightOptionRect.origin.x = mainWidth / 2.0 + entryOffset / 2.0
        } else {
            mainRect = CGRect(x: (optionsWidth - mainWidth) / 2.0, y: height - mainLabelSize.height,
                              width: mainLabelSize.width, height: mainLabelSize.height)
            leftOptionRect = CGRect(x: 0, y: 0, width: optionLabelSize.width, height: optionLabelSize.height)
            rightOptionRect = leftOptionRect
            rightOptionRect.origin.x = optionsWidth / 2.0 + entryOffset / 2.0
        }
        let optionRect = CGRect(x: 0, y: leftOptionRect.minY,
                                width: leftOptionRect.width, height: leftOptionRect.height)
        mainLabel = UIText(rect: mainRect, style: .gameOver, text: nil, alignment: .center)
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
        
        node.addChild(mainLabel.node)
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
            // Set the element to have the same dimensions as the background
            size = CGSize(width: background.node.size.width, height: background.node.size.height)
            background.node.addChild(node)
            contents.addChild(background.node)
        } else {
            size = frame.size
            contents.addChild(node)
        }
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
