//
//  UIConfirmationElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/22/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays a piece of text plus two options.
///
class UIConfirmationElement: UIElement {
    
    /// The node that holds all the element contents.
    ///
    private let contents: SKNode
    
    /// The bottom-left option background.
    ///
    private let leftOptionBackground: UIBackground
    
    /// The bottom-right option background.
    ///
    private let rightOptionBackground: UIBackground
    
    /// The top label.
    ///
    let topLabel: UIText
    
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
    ///   - bottomLabelSize: The size for each of the two bottom text labels.
    ///   - backgroundImage: An optional background image to enclose the contents. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(contentOffset: CGFloat, topLabelSize: CGSize, bottomLabelSize: CGSize,
         backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        contents = SKNode()
        
        // Calculate dimensions/offsets
        let width: CGFloat
        let topX: CGFloat
        if topLabelSize.width >= (bottomLabelSize.width * 2.0 + contentOffset) {
            width = topLabelSize.width
            topX = 0
        } else {
            width = (bottomLabelSize.width * 2.0 + contentOffset)
            topX = (width - topLabelSize.width) / 2.0
        }
        let height = topLabelSize.height + bottomLabelSize.height + contentOffset
        
        // Create the top label
        let topLabelRect = CGRect(x: topX, y: height - topLabelSize.height,
                                  width: topLabelSize.width, height: topLabelSize.height)
        topLabel = UIText(rect: topLabelRect, style: .text, text: nil, alignment: .center)
        
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
