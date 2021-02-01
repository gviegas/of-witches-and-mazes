//
//  UITitleElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/13/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays a section title.
///
class UITitleElement: UIElement {
    
    /// The maximum size of the element.
    ///
    private let maxSize: CGSize
    
    /// The name of the background image.
    ///
    private let backgroundImage: String?
    
    /// The background border.
    ///
    private let backgroundBorder: UIBorder?
    
    /// The title label.
    ///
    private var label: UIText?
    
    /// The stored dimensions of the element.
    ///
    private var _size: CGSize
    
    /// The dimensions of the element.
    ///
    /// - Note: This is a dynamic element. Its `size` is only available after calling
    ///   `provideNodeFor(rect:)`, and may change after each subsequent call.
    ///
    var size: CGSize {
        return _size
    }
    
    /// The title text.
    ///
    var title: String {
        didSet { label?.text = title }
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - title: The title to set.
    ///   - maxSize: The maximum size of the element.
    ///   - backgroundImage: An optional background image to enclose the equipment set. The default value is `nil`.
    ///   - backgroundBorder: An optional border for the background. The default value is `nil`.
    ///
    init(title: String, maxSize: CGSize, backgroundImage: String? = nil, backgroundBorder: UIBorder? = nil) {
        self.title = title
        self.maxSize = maxSize
        self.backgroundImage = backgroundImage
        self.backgroundBorder = backgroundBorder
        self._size = maxSize
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        
        // Shrunk the provided rect if it is larger than maxSize
        var finalRect = rect
        if rect.width > maxSize.width {
            let offset = (rect.width - maxSize.width) / 2.0
            finalRect.origin.x = rect.origin.x + offset
            finalRect.size.width = maxSize.width
        }
        if rect.height > maxSize.height {
            let offset = (rect.height - maxSize.height) / 2.0
            finalRect.origin.y = rect.origin.y + offset
            finalRect.size.height = maxSize.height
        }
        
        // Update the size of the element
        _size = finalRect.size
        
        // The background, if set, must enclose the label
        if let image = backgroundImage {
            if let border = backgroundBorder {
                let background = UIBackground(image: image, rect: finalRect, border: border)
                let labelRect = CGRect(x: -finalRect.width / 2.0 + border.left,
                                       y: -finalRect.height / 2.0 + border.bottom,
                                       width: finalRect.width - border.left - border.right,
                                       height: finalRect.height - border.top - border.bottom)
                label = UIText(rect: labelRect, style: .title, text: title)
                background.node.addChild(label!.node)
                node.addChild(background.node)
                // Update the element size to background size
                _size = CGSize(width: background.node.size.width, height: background.node.size.height)
            } else {
                let background = UIBackground(image: image, rect: finalRect)
                let labelRect = CGRect(x: -finalRect.width / 2.0, y: -finalRect.height / 2.0,
                                       width: finalRect.width, height: finalRect.height)
                label = UIText(rect: labelRect, style: .title, text: title)
                background.node.addChild(label!.node)
                node.addChild(background.node)
            }
        } else {
            label = UIText(rect: finalRect, style: .title, text: title)
            node.addChild(label!.node)
        }
        label?.node.zPosition = 1
        
        return node
    }
}
