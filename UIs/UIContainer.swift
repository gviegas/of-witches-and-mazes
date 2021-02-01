//
//  UIContainer.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/8/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A class that defines an UI container, able to contain other containers and
/// `UIElement` instances.
///
class UIContainer {
    
    /// An enum that identifies either the horizontal or vertical planes.
    ///
    enum Plane {
        case horizontal, vertical
    }
    
    /// The containers held.
    ///
    private var containers = [UIContainer]()
    
    /// The elements held.
    ///
    private var elements = [UIElement]()
    
    /// The plane to use for the containers held.
    ///
    /// This property determines how to lay the children containers. If set as `horizontal`,
    /// the containers will be placed from left to rigth, and if set as `vertical`, from
    /// top to bottom.
    ///
    let plane: Plane
    
    /// The extent relative to the `parent` container.
    ///
    /// The ratio determines the extent, on the given plane, that was made available from the
    /// container's parent. If `plane` was set as `horizontal`, then it means the width ratio.
    /// Otherwise, it means the height ratio.
    ///
    let ratio: CGFloat
    
    /// The parent of the container.
    ///
    weak var parent: UIContainer?
    
    /// Creates a new instance from the given plane and ratio values.
    ///
    /// - Parameters:
    ///   - plane: The plane for this container, indicating how to lay its children containers.
    ///   - ratio: The ratio for this container, relative to its parent.
    ///
    init(plane: Plane, ratio: CGFloat) {
        self.plane = plane
        self.ratio = ratio
    }
    
    /// Appends the given container as child of the container.
    ///
    /// Note that the containers will be arranged in the order that they are appended.
    ///
    /// - Parameter container: The child container to append.
    /// - Returns: `true` if the element was appended, `false` if there are not enough area for
    ///   the new container.
    ///
    func appendContainer(_ container: UIContainer) -> Bool {
        let total = containers.reduce(CGFloat(0), { $0 + $1.ratio })
        guard (total + container.ratio) <= 1.0001 else { return false }
        
        containers.append(container)
        return true
    }
    
    /// Adds the given element to the container.
    ///
    /// - Parameter element: The element to add.
    ///
    func addElement(_ element: UIElement) {
        elements.append(element)
    }
    
    /// Generates the subtree of the container.
    ///
    /// - Parameters:
    ///   - rect: The rect representing the real dimensions of the parent's container.
    ///   - nodes: An array where the element nodes must be appended.
    ///
    func generateSubtree(rect: CGRect, nodes: inout [SKNode]) {
        // Add each element node to the nodes array
        for element in elements {
            nodes.append(element.provideNodeFor(rect: rect))
        }
        
        // Recursively call this method for each child container
        switch plane {
        case .horizontal:
            var x = rect.minX
            for container in containers {
                let r = CGRect(x: x, y: rect.minY, width: rect.width * container.ratio, height: rect.height)
                container.generateSubtree(rect: r, nodes: &nodes)
                x += rect.width * container.ratio
            }
        case .vertical:
            var y = rect.maxY
            for container in containers {
                y -= rect.height * container.ratio
                let r = CGRect(x: rect.minX, y: y, width: rect.width, height: rect.height * container.ratio)
                container.generateSubtree(rect: r, nodes: &nodes)
            }
        }
    }
}
