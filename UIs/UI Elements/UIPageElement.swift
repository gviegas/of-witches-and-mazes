//
//  UIPageElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/2/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that creates pages.
///
class UIPageElement: UIElement {
    
    /// An enum that defines what kinds of entries are available for the page's body.
    ///
    enum Entry {
        case label(style: UITextStyle, text: String)
        case attributedLabel(text: NSAttributedString)
        case space(CGFloat)
    }
    
    /// The node that groups the contents of the element.
    ///
    private let contents: SKNode
    
    /// The bottom-left option background.
    ///
    private let leftOptionBackground: UIBackground
    
    /// The bottom-right option background.
    ///
    private let rightOptionBackground: UIBackground
    
    /// The labels in the page's body, in reverse order (bottom to top).
    ///
    private var labels: [UIText]
    
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
    ///   - entries: An array containing the kinds of entries to add in the page.
    ///   - leftOption: An optional text for the selectable left option.
    ///   - rightOption: An optional text for the selectable right option.
    ///   - entryOffset: The offset to apply between the two option entries.
    ///   - contentOffset: The offset to apply between element contents.
    ///   - minLabelSize: The minimum size of the title/body labels.
    ///   - maxLabelSize: The maximum size of the title/body labels.
    ///   - optionLabelSize: The size for each of the two option text labels.
    ///   - backgroundImage: An optional background image to enclose the contents. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///   - backgroundOffset: The offset to apply between the background's border and the element contents.
    ///     The default value is `0`.
    ///
    init(entries: [Entry], leftOption: String?, rightOption: String?, entryOffset: CGFloat, contentOffset: CGFloat,
         minLabelSize: CGSize, maxLabelSize: CGSize, optionLabelSize: CGSize,
         backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil, backgroundOffset: CGFloat = 0) {
        
        contents = SKNode()
        labels = []
        
        let mainNode = SKNode()
        mainNode.zPosition = 1
        var dimensions = CGSize(width: minLabelSize.width, height: 0)
        
        // Create the entries bottom up
        for entry in entries.reversed() {
            switch entry {
            case .label(let style, let text):
                let label = UIText(maxWidth: maxLabelSize.width, style: style, text: text)
                let frame = label.node.frame
                label.node.position.y += frame.height / 2.0 + dimensions.height
                
                dimensions.height = label.node.position.y + frame.height / 2.0 + contentOffset
                if frame.width > dimensions.width { dimensions.width = frame.width }
                
                labels.append(label)
                mainNode.addChild(label.node)
                
            case .attributedLabel(let text):
                let label = UIText(maxWidth: maxLabelSize.width, style: .text, text: nil)
                label.attributedText = text
                let frame = label.node.frame
                label.node.position.y += frame.height / 2.0 + dimensions.height
                
                dimensions.height = label.node.position.y + frame.height / 2.0 + contentOffset
                if frame.width > dimensions.width { dimensions.width = frame.width }
                
                labels.append(label)
                mainNode.addChild(label.node)
                
            case .space(let value):
                dimensions.height += value
            }
        }
        
        for label in labels {
            label.node.position.x += dimensions.width / 2.0
        }
        
        dimensions.height -= contentOffset
        
        // Calculate the total width for each section
        let mainWidth = dimensions.width
        let optionsWidth = optionLabelSize.width * 2.0 + entryOffset
        
        // Calculate the total width
        let width = max(mainWidth, optionsWidth)
        
        // Calculate the total height
        let height = dimensions.height + optionLabelSize.height + contentOffset
        
        // Calculate the x position of main labels
        let mainX = mainWidth >= optionsWidth ? 0 : (optionsWidth - mainWidth) / 2.0
        
        // Create the option labels
        let leftOptionRect: CGRect
        let rightOptionRect: CGRect
        if leftOption == nil || rightOption == nil {
            // Place the options in the corners if either is nil
            leftOptionRect = CGRect(x: 0, y: 0,
                                    width: optionLabelSize.width, height: optionLabelSize.height)
            rightOptionRect = CGRect(x: width - optionLabelSize.width, y: 0,
                                     width: optionLabelSize.width, height: optionLabelSize.height)
        } else {
            // Place the options in the center if neither is nil
            leftOptionRect = CGRect(x: width / 2.0 - (optionLabelSize.width + entryOffset / 2.0), y: 0,
                                    width: optionLabelSize.width, height: optionLabelSize.height)
            rightOptionRect = CGRect(x: width / 2.0 + entryOffset / 2.0, y: 0,
                                     width: optionLabelSize.width, height: optionLabelSize.height)
        }
        let optionRect = CGRect(x: 0, y: 0, width: optionLabelSize.width, height: optionLabelSize.height)
        leftOptionLabel = UIText(rect: optionRect, style: .subtitle, text: leftOption, alignment: .center)
        rightOptionLabel = UIText(rect: optionRect, style: .subtitle, text: rightOption, alignment: .center)
        
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
        
        // Correct the mainNode position
        mainNode.position = CGPoint(x: mainX, y: height - dimensions.height)
        
        // Group the contents on a single node
        let node = SKNode()
        node.zPosition = 1
        node.addChild(mainNode)
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
