//
//  UIPromptElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/23/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays a piece of text, a text prompt and two options.
///
class UIPromptElement: UIElement {
    
    /// The node that holds all the element contents.
    ///
    private let contents: SKNode
    
    /// The prompt background.
    ///
    private let promptBackground: UIBackground
    
    /// The bottom-left option background.
    ///
    private let leftOptionBackground: UIBackground
    
    /// The bottom-right option background.
    ///
    private let rightOptionBackground: UIBackground
    
    /// The input marker node.
    ///
    private let marker: SKSpriteNode
    
    /// The top label.
    ///
    let topLabel: UIText
    
    /// The prompt label.
    ///
    let promptLabel: UIText
    
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
    ///   - contentOffset: The offset to apply between element contents.
    ///   - topLabelSize: The size of the top text label.
    ///   - middleLabelSize: The size of the middle text label.
    ///   - bottomLabelSize: The size for each of the two bottom text labels.
    ///   - backgroundImage: An optional background image to enclose the contents. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(contentOffset: CGFloat, topLabelSize: CGSize, middleLabelSize: CGSize, bottomLabelSize: CGSize,
         backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        contents = SKNode()
        
        // Calculate dimensions/offsets
        let minBottomWidth = bottomLabelSize.width * 2.0 + contentOffset
        let width: CGFloat
        let topX: CGFloat
        let middleX: CGFloat
        if topLabelSize.width >= middleLabelSize.width && topLabelSize.width >= minBottomWidth {
            width = topLabelSize.width
            topX = 0
            middleX = (width - middleLabelSize.width) / 2.0
        } else if middleLabelSize.width >= topLabelSize.width && middleLabelSize.width > minBottomWidth {
            width = middleLabelSize.width
            topX = (width - topLabelSize.width) / 2.0
            middleX = 0
        } else {
            width = minBottomWidth
            topX = (width - topLabelSize.width) / 2.0
            middleX = (width - middleLabelSize.width) / 2.0
        }
        let height = topLabelSize.height + middleLabelSize.height + bottomLabelSize.height + contentOffset * 2.0
        
        // Create the top label
        let topLabelRect = CGRect(x: topX, y: height - topLabelSize.height,
                                  width: topLabelSize.width, height: topLabelSize.height)
        topLabel = UIText(rect: topLabelRect, style: .text, text: nil, alignment: .center)
        
        // Create the middle label
        let promptRect = CGRect(x: middleX, y: bottomLabelSize.height + contentOffset,
                                width: middleLabelSize.width, height: middleLabelSize.height)
        let middleRect = CGRect(origin: CGPoint.zero, size: promptRect.size)
        promptLabel = UIText(rect: middleRect, style: .emphasis, text: nil, alignment: .center)
        
        // Create the prompt background
        promptBackground = UIBackground.defaultBlackBackground(rect: promptRect)
        let promptNode = SKNode()
        promptNode.zPosition = 1
        promptNode.addChild(promptLabel.node)
        promptNode.position.x -= promptBackground.node.size.width / 2.0
        promptNode.position.y -= promptBackground.node.size.height / 2.0
        promptBackground.node.addChild(promptNode)
        
        // Create the bottom labels
        let leftOptionRect = CGRect(origin: CGPoint.zero, size: bottomLabelSize)
        let rightOptionRect = CGRect(x: width - bottomLabelSize.width, y: 0,
                                     width: bottomLabelSize.width, height: bottomLabelSize.height)
        let bottomRect = leftOptionRect
        leftOptionLabel = UIText(rect: bottomRect, style: .subtitle, text: nil, alignment: .center)
        rightOptionLabel = UIText(rect: bottomRect, style: .subtitle, text: nil, alignment: .center)
        
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
        
        /// Group the contents on a single node
        ///
        let node = SKNode()
        node.zPosition = 1
        node.addChild(topLabel.node)
        node.addChild(promptBackground.node)
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
        
        // Create the marker node
        marker = SKSpriteNode(color: .white, size: CGSize(width: 1.0, height: promptLabel.node.fontSize))
        promptLabel.node.addChild(marker)
        let waitAction = SKAction.wait(forDuration: 0.5)
        let sequenceAction = SKAction.sequence([waitAction, SKAction.hide(), waitAction, SKAction.unhide()])
        marker.run(SKAction.repeatForever(sequenceAction))
    }
    
    /// Updates the input marker, moving it to the end of the prompt label's text.
    ///
    func updateMarker() {
        marker.size.height = promptLabel.node.fontSize
        marker.position = CGPoint(x: promptLabel.node.frame.size.width / 2.0 + marker.size.width / 2.0, y: 0)
    }
    
    /// Shows the input marker.
    ///
    func showMarker() {
        guard marker.parent == nil else { return }
        promptLabel.node.addChild(marker)
    }
    
    /// Hides the input marker.
    ///
    func hideMarker() {
        marker.removeFromParent()
    }
    
    /// Adds tracking data for the prompt label.
    ///
    /// - Parameter data: The data to add.
    /// - Returns: `true` if the data was added, false otherwise.
    ///
    @discardableResult
    func addTrackinDataForPrompt(data: Any) -> Bool {
        return addTrackingDataForNode(promptBackground.node, data: data)
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

