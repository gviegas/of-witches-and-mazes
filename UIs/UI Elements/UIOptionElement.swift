//
//  UIOptionElement.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/17/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UIElement` type that displays a set of options, spread horizontally.
///
class UIOptionElement: UIElement {
    
    /// An enum that defines the types of option buttons.
    ///
    enum OptionButton: Hashable {
        case primaryButton, secondaryButton, key(InputButton), keyCode(KeyboardKeyCode)
    }
    
    /// The node to group the contents of the element.
    ///
    private let contents: SKNode
    
    /// The entry offset.
    ///
    private let entryOffset: CGFloat
    
    /// The content offset.
    ///
    private let contentOffset: CGFloat
    
    /// The primary button image.
    ///
    private let primaryButtonImage: String
    
    /// The secondary button image.
    ///
    private let secondaryButtonImage: String
    
    /// The regular key image.
    ///
    private let regularKeyImage: String
    
    /// The wide key image.
    ///
    private let wideKeyImage: String
    
    /// The nodes for each option entry.
    ///
    private var optionNodes: [SKNode]
    
    /// The dimensions of the element.
    ///
    let size: CGSize
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - size: The size of the element.
    ///   - entryOffset: The offset to apply between adjacent options.
    ///   - contentOffset: The offset to apply between element contents.
    ///   - primaryButtonImage: The primary button image.
    ///   - secondaryButtonImage: The secondary button image.
    ///   - regularKeyImage: The regular key image.
    ///   - wideKeyImage: The wide key image.
    ///
    init(size: CGSize, entryOffset: CGFloat, contentOffset: CGFloat, primaryButtonImage: String,
         secondaryButtonImage: String, regularKeyImage: String, wideKeyImage: String) {
        
        self.size = size
        self.entryOffset = entryOffset
        self.contentOffset = contentOffset
        self.primaryButtonImage = primaryButtonImage
        self.secondaryButtonImage = secondaryButtonImage
        self.regularKeyImage = regularKeyImage
        self.wideKeyImage = wideKeyImage
        contents = SKNode()
        optionNodes = []
        
        TextureSource.createTexture(imageNamed: primaryButtonImage)
        TextureSource.createTexture(imageNamed: secondaryButtonImage)
        TextureSource.createTexture(imageNamed: regularKeyImage)
        TextureSource.createTexture(imageNamed: wideKeyImage)
    }
    
    /// Replaces the current options with the given ones, possibly changing the number
    /// of entries displayed.
    ///
    /// - Parameter options: An array of (optionButton, optionText) tuples containing the
    ///   data for the new options.
    ///
    func replaceWith(options: [(optionButton: OptionButton, optionText: String)]) {
        contents.removeAllChildren()
        contents.setScale(1.0)
        
        let groupNode = SKNode()
        groupNode.zPosition = 1
        var rect = CGRect(origin: CGPoint.zero, size: size)
        
        for (button, text) in options {
            let buttonImage: UIImage
            switch button {
            case .primaryButton:
                buttonImage = UIImage(rect: rect, image: primaryButtonImage, alignment: .left)
            case .secondaryButton:
                buttonImage = UIImage(rect: rect, image: secondaryButtonImage, alignment: .left)
            case .key(let inputButton):
                let symbol = inputButton.firstSymbolFromMapping
                let image = symbol.count < 4 ? regularKeyImage : wideKeyImage
                buttonImage = UIImage(rect: rect, image: image, alignment: .left, textStyle: .button)
                buttonImage.text = symbol
            case .keyCode(let keyboardKeyCode):
                let symbol = keyboardKeyCode.asString
                let image = symbol.count < 4 ? regularKeyImage : wideKeyImage
                buttonImage = UIImage(rect: rect, image: image, alignment: .left, textStyle: .button)
                buttonImage.text = symbol
            }
            
            let buttonNode = buttonImage.node
            let optionLabel = UIText(maxWidth: size.width, style: .option, text: text)
            let optionNode = optionLabel.node
            optionNode.position.x = buttonNode.frame.maxX + contentOffset + optionNode.frame.size.width / 2.0
            optionNode.position.y = rect.midY
            rect.origin.x = optionNode.frame.maxX + entryOffset
            
            groupNode.addChild(buttonNode)
            groupNode.addChild(optionNode)
        }
        
        var frame = groupNode.calculateAccumulatedFrame()
        if frame.size.width > size.width || frame.size.height > size.height {
            var scale = CGFloat(1.0)
            scale = min(scale, size.width / frame.size.width)
            scale = min(scale, size.height / frame.size.height)
            groupNode.setScale(scale)
            frame = groupNode.calculateAccumulatedFrame()
        }
        
        groupNode.position.x = (size.width - frame.width) / 2.0
        contents.addChild(groupNode)
    }
    
    func provideNodeFor(rect: CGRect) -> SKNode {
        let node = SKNode()
        node.position = CGPoint(x: rect.minX + (rect.width - size.width) / 2.0,
                                y: rect.minY + (rect.height  - size.height) / 2.0)
        node.addChild(contents)
        return node
    }
}
