//
//  PickUpOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 1/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Overlay` type that displays a info about an acquired thing.
///
class PickUpOverlay: Overlay, TextureUser {
    
    static var textureNames: Set<String> {
        return PickUpOverlayData.textureNames
    }
    
    let node: SKNode
    
    /// The `UIPickUpElement` instance.
    ///
    private let pickUpElement: UIPickUpElement
    
    /// The size of the overlay.
    ///
    var size: CGSize {
        return pickUpElement.size
    }
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - icon: The icon to appear on the slot.
    ///   - text: The text to appear on the label.
    ///   - iconText: An optional text to set for the `icon`.
    ///
    init(rect: CGRect, icon: Icon, text: String, iconText: String?) {
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound + 8
        
        // Create the PickUp element
        pickUpElement = UIPickUpElement(text: text,
                                        contentOffset: PickUpOverlayData.PickUp.contentOffset,
                                        maxLabelLength: PickUpOverlayData.PickUp.maxLabelLength,
                                        backgroundImage: PickUpOverlayData.PickUp.backgroundImage,
                                        backgroundBorder: PickUpOverlayData.PickUp.backgroundBorder,
                                        backgroundOffset: PickUpOverlayData.PickUp.backgroundOffset)
        
        // Set contents
        pickUpElement.slot.icon = icon
        pickUpElement.slot.text = iconText
        
        // The pick up overlay will be placed in the left side of the rect
        let offsetX: CGFloat = 8.0
        let overlayRect = CGRect(x: rect.width - size.width - offsetX, y: rect.midY - size.height / 2.0,
                                 width: size.width, height: size.height)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(pickUpElement)
        let tree = UITree(rect: overlayRect, root: container)
        if let treeNode = tree.generate() {
            treeNode.zPosition = 1
            node.addChild(treeNode)
        }
    }
    
    func update(deltaTime seconds: TimeInterval) {
        
    }
}

/// A struct that defines the data associated with the `PickUpOverlay` class.
///
fileprivate struct PickUpOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [PickUp.backgroundImage]
    }
    
    private init() {}
    
    /// The `UIPickUpElement` data.
    ///
    struct PickUp {
        private init() {}
        static let contentOffset: CGFloat = 6.0
        static let maxLabelLength: CGFloat = 250.0
        static let backgroundImage = "UI_Window_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat =  1.0
    }
}
