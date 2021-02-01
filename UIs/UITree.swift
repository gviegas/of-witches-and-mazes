//
//  UITree.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/8/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that defines an UI tree.
///
/// This class manages a hierarchy of related `UIContainer` instances. Calling the
/// `generate()` method will cause the tree to traverse its hierarchy, creating a
/// group of nodes from each 'UIElement' found inside of a container.
///
class UITree {

    /// The real dimensions of the UI.
    ///
    var rect: CGRect
    
    /// The root container.
    ///
    weak var root: UIContainer?
    
    /// Creates a new instance from the given rect and optional root values.
    ///
    /// - Parameters:
    ///   - rect: The real dimensions of the UI.
    ///   - root: An optional root container to start with.
    ///
    init(rect: CGRect, root: UIContainer? = nil) {
        self.rect = rect
        self.root = root
    }
    
    /// Generates the tree.
    ///
    /// - Returns: A node containing all the element nodes of the tree, or `nil` if no
    ///   root container is set.
    ///
    func generate() -> SKNode? {
        guard let root = root else { return nil }
        
        var nodes = [SKNode]()
        root.generateSubtree(rect: rect, nodes: &nodes)
        let node = SKNode()
        for n in nodes { node.addChild(n) }
        return node
    }
}
