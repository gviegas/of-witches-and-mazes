//
//  ShadowComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/21/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that provides shadow for an entity.
///
class ShadowComponent: Component {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a ShadowComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity?.component(ofType: SpriteComponent.self) else {
            fatalError("An entity with a ShadowComponent must also have a SpriteComponent")
        }
        return component
    }
    
    /// The detach animation.
    ///
    private static let detachAnimation = SKAction.sequence([.fadeOut(withDuration: 1.0), .removeFromParent()])
    
    /// The shadow node.
    ///
    private let node: SKSpriteNode
    
    /// Creates a new instance from the given size and texture.
    ///
    /// - Parameters:
    ///   - size: The size of the shadow node.
    ///   - texture: The texture to use for the shadow node.
    ///
    init(size: CGSize, texture: SKTexture) {
        node = SKSpriteNode(texture: texture, size: size)
        node.zPosition = DepthLayer.shadows.lowerBound
        super.init()
    }
    
    /// Creates a new instance from the given size and image.
    ///
    /// - Parameters:
    ///   - size: The size of the shadow node.
    ///   - imageName: The name of the image to create the shadow texture from.
    ///
    convenience init(size: CGSize, imageName: String) {
        let texture = TextureSource.createTexture(imageNamed: imageName)
        self.init(size: size, texture: texture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Attaches the shadow node to the entity's node.
    ///
    /// If the shadow node is already attached, this method has no effect.
    ///
    func attach() {
        node.removeAllActions()
        node.alpha = 1.0
        if node.parent == nil {
            let rangeX = SKRange(constantValue: 0)
            let rangeY = SKRange(constantValue: min(-spriteComponent.size.height / 2.0 + node.size.height / 3.0, 0))
            let constraint = SKConstraint.positionX(rangeX, y: rangeY)
            constraint.referenceNode = nodeComponent.node
            node.constraints = [constraint]
            nodeComponent.node.addChild(node)
        }
    }
    
    /// Detaches the shadow node from the entity's node.
    ///
    /// If the shadow node is not attached, this method has no effect.
    ///
    /// - Parameter withFadeEffect: A flag stating whether the node should play a fade out animation
    ///   before detaching itself from the entity. The default value is `false`.
    ///
    func detach(withFadeEffect: Bool = false) {
        guard node.parent != nil else { return }
        
        if withFadeEffect {
            node.run(ShadowComponent.detachAnimation) { [unowned self] in self.node.constraints = nil }
        } else {
            node.removeFromParent()
            node.constraints = nil
        }
    }
    
    override func didAddToEntity() {
        node.entity = entity
        attach()
    }
    
    override func willRemoveFromEntity() {
        node.entity = nil
        detach()
    }
    
    deinit {
        node.removeFromParent()
        node.constraints = nil
    }
}
