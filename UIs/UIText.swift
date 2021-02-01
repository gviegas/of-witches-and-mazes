//
//  UIText.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/9/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that represents a piece of text for the UI.
///
class UIText {
    
    /// An enum that specifies the alignment of the text, relative to its rect.
    ///
    enum Alignment {
        case center, left, right, bottom, top
        case bottomLeft, bottomRight, topRight, topLeft
    }
    
    /// The flash action.
    ///
    private static let action: SKAction = .repeatForever(.sequence([.fadeAlpha(to: 0.5, duration: 0.45),
                                                                    .fadeAlpha(to: 1.0, duration: 0.45)]))
    
    /// The name that identifies the flash action.
    ///
    private static let actionName = "UIText.flash"
    
    /// The flag stating whether or not the dull effect is active.
    ///
    private var isDull = false
    
    /// The text label.
    ///
    let node: SKLabelNode
    
    /// The style of the text.
    ///
    var style: UITextStyle {
        didSet { style.applyStyle(label: node) }
    }
    
    /// The text to display.
    ///
    var text: String? {
        didSet { node.text = text }
    }
    
    /// The attributed text to display.
    ///
    var attributedText: NSAttributedString? {
        didSet { node.attributedText = attributedText }
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - rect: The limits of the text.
    ///   - style: The `UITextStyle` to apply in the text.
    ///   - text: An optional text to display. The default value is `nil`.
    ///   - alignment: The horizontal alignment of the text on the rect. The default value is `.center`.
    ///
    init(rect: CGRect, style: UITextStyle, text: String? = nil, alignment: Alignment = .center) {
        self.style = style
        self.text = text
        
        node = SKLabelNode(text: text)
        style.applyStyle(label: node)
        
        node.preferredMaxLayoutWidth = rect.width
        node.lineBreakMode = .byWordWrapping
        node.numberOfLines = 0
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .center
        
        switch alignment {
        case .center:
            node.position = CGPoint(x: rect.midX, y: rect.midY)
            node.horizontalAlignmentMode = .center
        case .left:
            node.position = CGPoint(x: rect.minX, y: rect.midY)
            node.horizontalAlignmentMode = .left
        case .right:
            node.position = CGPoint(x: rect.maxX, y: rect.midY)
            node.horizontalAlignmentMode = .right
        case .top:
            node.position = CGPoint(x: rect.midX, y: rect.maxY)
            node.verticalAlignmentMode = .top
        case .bottom:
            node.position = CGPoint(x: rect.midX, y: rect.minY)
            node.verticalAlignmentMode = .bottom
        case .bottomLeft:
            node.position = CGPoint(x: rect.minX, y: rect.minY)
            node.horizontalAlignmentMode = .left
            node.verticalAlignmentMode = .bottom
        case .bottomRight:
            node.position = CGPoint(x: rect.maxX, y: rect.minY)
            node.horizontalAlignmentMode = .right
            node.verticalAlignmentMode = .bottom
        case .topRight:
            node.position = CGPoint(x: rect.maxX, y: rect.maxY)
            node.horizontalAlignmentMode = .right
            node.verticalAlignmentMode = .top
        case .topLeft:
            node.position = CGPoint(x: rect.minX, y: rect.maxY)
            node.horizontalAlignmentMode = .left
            node.verticalAlignmentMode = .top
        }
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - maxWidth: The maximum width of the text before breaking to a new line.
    ///   - style: The `UITextStyle` to apply in the text.
    ///   - text: An optional text to display. The default value is `nil`.
    ///
    init(maxWidth: CGFloat, style: UITextStyle, text: String? = nil) {
        self.style = style
        self.text = text
        
        node = SKLabelNode(text: text)
        style.applyStyle(label: node)
        
        node.preferredMaxLayoutWidth = maxWidth
        node.lineBreakMode = .byWordWrapping
        node.numberOfLines = 0
        node.horizontalAlignmentMode = .center
        node.verticalAlignmentMode = .center
    }
    
    /// Restores the text to its original style.
    ///
    func restore() {
        style.applyStyle(label: node)
    }
    
    /// Makes the text appears less prominently.
    ///
    func dull() {
        node.alpha = 0.25
        isDull = true
    }
    
    /// Removes the `dull` effect.
    ///
    func undull() {
        node.alpha = 1.0
        isDull = false
    }
    
    /// Makes the label flash in an intermittent way.
    ///
    func flash() {
        guard node.action(forKey: UIText.actionName) == nil else { return }
        
        node.alpha = 1.0
        node.run(UIText.action, withKey: UIText.actionName)
    }

    /// Causes the label to stop flashing.
    ///
    func unflash() {
        node.removeAction(forKey: UIText.actionName)
        if isDull {
            dull()
        } else {
            node.alpha = 1.0
        }
    }
    
    /// Enlarges the text.
    ///
    func enlarge() {
        node.fontSize *= 1.25
    }
    
    /// Shrinks the text.
    ///
    func shrink() {
        node.fontSize *= 0.75
    }
    
    /// Inverts the color of the text.
    ///
    func invert() {
        guard let color = node.fontColor else { return }
        
        node.fontColor = NSColor(red: 1.0 - color.redComponent,
                                 green: 1.0 - color.greenComponent,
                                 blue: 1.0 - color.blueComponent,
                                 alpha: color.alphaComponent)
    }
    
    /// Whitens the text.
    ///
    func whiten() {
        node.fontColor = NSColor.white
    }
    
    /// Blackens the text.
    ///
    func blacken() {
        node.fontColor = NSColor.black
    }
}
