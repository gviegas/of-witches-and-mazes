//
//  OptionOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/19/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Overlay` type that displays options.
///
class OptionOverlay: Overlay, Observer, TextureUser {
    
    static var textureNames: Set<String> {
        return OptionOverlayData.textureNames
    }
    
    let node: SKNode
    
    /// The `UIOptionElement` instance.
    ///
    private let optionElement: UIOptionElement
    
    /// The options array.
    ///
    private let options: [(optionButton: UIOptionElement.OptionButton, optionText: String)]
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - options: An array of `(UIOptionElement.optionButton, String)` tuples containing the data
    ///     for the options.
    ///
    init(rect: CGRect, options: [(optionButton: UIOptionElement.OptionButton, optionText: String)]) {
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound + 16
        self.options = options
        
        // Create the option element
        optionElement = UIOptionElement(size: OptionOverlayData.Option.size,
                                        entryOffset: OptionOverlayData.Option.entryOffset,
                                        contentOffset: OptionOverlayData.Option.contentOffset,
                                        primaryButtonImage: OptionOverlayData.Option.primaryButtonImage,
                                        secondaryButtonImage: OptionOverlayData.Option.secondaryButtonImage,
                                        regularKeyImage: OptionOverlayData.Option.regularKeyImage,
                                        wideKeyImage: OptionOverlayData.Option.wideKeyImage)
        
        // Set the option element
        optionElement.replaceWith(options: options)
        
        // The option overlay will be placed at the lower-center of the rect
        let offsetY = CGFloat(8.0)
        let overlayRect = CGRect(origin: CGPoint(x: rect.midX - optionElement.size.width / 2.0,
                                                 y: rect.minY + offsetY),
                                 size: optionElement.size)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(optionElement)
        let tree = UITree(rect: overlayRect, root: container)
        if let treeNode = tree.generate() {
            treeNode.zPosition = 1
            node.addChild(treeNode)
        }
        
        // Register self as observer
        KeyboardMapping.KeyboardMappingObservable.instance.register(observer: self)
    }
    
    func update(deltaTime seconds: TimeInterval) {
        
    }
    
    func didChange(observable: Observable) {
        switch observable {
        case is KeyboardMapping.KeyboardMappingObservable:
            optionElement.replaceWith(options: options)
        default:
            break
        }
    }
    
    func removeFromAllObservables() {
        KeyboardMapping.KeyboardMappingObservable.instance.remove(observer: self)
    }
}

/// A struct that defines the data associated with the `OptionOverlay` class.
///
fileprivate struct OptionOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Option.primaryButtonImage,
                Option.secondaryButtonImage,
                Option.regularKeyImage,
                Option.wideKeyImage]
    }
    
    private init() {}
    
    /// The `UIOptionElement` data.
    ///
    struct Option {
        private init() {}
        static let size = CGSize(width: 1280.0, height: 60.0)
        static let entryOffset: CGFloat = 38.0
        static let contentOffset: CGFloat = 6.0
        static let primaryButtonImage = "UI_Primary_Mouse_Button"
        static let secondaryButtonImage = "UI_Secondary_Mouse_Button"
        static let regularKeyImage = "UI_Keyboard_Key"
        static let wideKeyImage = "UI_Wide_Keyboard_Key"
    }
}
