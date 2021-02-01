//
//  MinimapOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Overlay` type that displays a minimap.
///
class MinimapOverlay: Overlay, TextureUser {
    
    static var textureNames: Set<String> {
        return MinimapOverlayData.textureNames
    }
    
    let node: SKNode
    
    /// The `UIMinimapElement` instance.
    ///
    private let minimapElement: UIMinimapElement
    
    /// The minimap.
    ///
    private let minimap: Minimap
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - minimap: The `Minimap` to display.
    ///
    init(rect: CGRect, minimap: Minimap) {
        self.minimap = minimap
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound
        
        // Create the minimap element
        minimapElement = UIMinimapElement(minimapSize: minimap.size,
                                          backgroundImage: MinimapOverlayData.Minimap.backgroundImage,
                                          backgroundBorder: MinimapOverlayData.Minimap.backgroundBorder,
                                          backgroundOffset: MinimapOverlayData.Minimap.backgroundOffset)
        
        // Set the minimap element
        minimapElement.minimap = minimap
        
        // The minimap overlay will be placed at the top-right corner of the rect
        let offset = CGPoint(x: 8.0, y: 8.0)
        let overlayRect = CGRect(origin: CGPoint(x: rect.maxX - minimapElement.size.width - offset.x,
                                                 y: rect.maxY - minimapElement.size.height - offset.y),
                                 size: minimapElement.size)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(minimapElement)
        let tree = UITree(rect: overlayRect, root: container)
        if let treeNode = tree.generate() {
            treeNode.zPosition = 1
            node.addChild(treeNode)
        }
    }
    
    func update(deltaTime seconds: TimeInterval) {
        minimap.update(deltaTime: seconds)
    }
}

/// A struct that defines the data associated with the `MinimapOverlay` class.
///
fileprivate struct MinimapOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Minimap.backgroundImage]
    }
    
    private init() {}
    
    /// The `UIMinimapElement` data.
    ///
    struct Minimap {
        private init() {}
        static let backgroundImage = "UI_Window_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat = 0
    }
}
