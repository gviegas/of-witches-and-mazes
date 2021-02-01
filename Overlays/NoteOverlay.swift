//
//  NoteOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/3/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Overlay` type that displays a simple textual note.
///
class NoteOverlay: Overlay, TextureUser {
    
    static var textureNames: Set<String> {
        return NoteOverlayData.textureNames
    }
    
    let node: SKNode
    
    /// The `UINoteElement` instance.
    ///
    private let noteElement: UINoteElement
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - rect: The bounding rect.
    ///   - text: The note's text.
    ///
    init(rect: CGRect, text: String) {
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound + 16
        
        // Create the note element
        noteElement = UINoteElement(text: text,
                                    maxLabelLength: NoteOverlayData.Note.maxLabelLength,
                                    backgroundImage: NoteOverlayData.Note.backgroundImage,
                                    backgroundBorder: NoteOverlayData.Note.backgroundBorder,
                                    backgroundOffset: NoteOverlayData.Note.backgroundOffset)
        
        // The note overlay will be placed at the upper-center of the rect
        let overlayRect = CGRect(origin: CGPoint(x: rect.midX - noteElement.size.width / 2.0,
                                                 y: rect.midY + rect.height / 3.0  + noteElement.size.height),
                                 size: noteElement.size)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(noteElement)
        let tree = UITree(rect: overlayRect, root: container)
        if let treeNode = tree.generate() {
            treeNode.zPosition = 1
            node.addChild(treeNode)
        }
    }
    
    func update(deltaTime seconds: TimeInterval) {
        
    }
}

/// A struct that defines the data associated with the `NoteOverlay` class.
///
fileprivate struct NoteOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Note.backgroundImage]
    }
    
    private init() {}
    
    /// The `UINoteElement` data.
    ///
    struct Note {
        private init() {}
        static let maxLabelLength: CGFloat = 600.0
        static let backgroundImage = "UI_Alpha_Background"
        static let backgroundBorder: UIBorder? = nil
        static let backgroundOffset: CGFloat = 4.0
    }
}
