//
//  CursorResponderComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to interact with the input cursor.
///
class CursorResponderComponent: Component, CursorResponder {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a CursorResponderComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var healthComponent: HealthComponent? {
        return entity?.component(ofType: HealthComponent.self)
    }
    
    private var targetComponent: TargetComponent? {
        return entity?.component(ofType: TargetComponent.self)
    }
    
    private var statusBarComponent: StatusBarComponent? {
        return entity?.component(ofType: StatusBarComponent.self)
    }
    
    /// The tracking node.
    ///
    private let node: SKSpriteNode
    
    /// Creates a new instance from the given size.
    ///
    init(size: CGSize) {
        node = SKSpriteNode(color: .clear, size: size)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Adds tracking data for the component's entity.
    ///
    private func addTrackingData() {
        guard let entity = entity as? Entity else { return }
        
        let data = EntityTrackingData(entity: entity)
        if nodeComponent.node.userData == nil {
            node.userData = NSMutableDictionary(dictionary: [TrackingKey.key: data])
        } else {
            node.userData!.addEntries(from: [TrackingKey.key: data])
        }
    }
    
    @discardableResult
    func cursorOver() -> Bool {
        guard Game.target !== entity else { return false }
        
        statusBarComponent?.showHealthBar()
        nodeComponent.node.alpha = 0.75
        return true
    }
    
    @discardableResult
    func cursorOut() -> Bool {
        guard Game.target !== entity else { return false }
        
        statusBarComponent?.hideHealthBar()
        nodeComponent.node.alpha = 1.0
        return true
    }
    
    @discardableResult
    func cursorSelected() -> Bool {
        guard targetComponent != nil else { return false }
        guard healthComponent?.isDead != true else { return false }
        
        Game.protagonist?.component(ofType: TargetComponent.self)?.source = entity as? Entity
        statusBarComponent?.showHealthBar()
        nodeComponent.node.alpha = 1.0
        if let scene = SceneManager.levelScene {
            scene.targetOverlay = TargetOverlay(rect: scene.frame)
        }
        return true
    }
    
    @discardableResult
    func cursorUnselected() -> Bool {
        guard Game.target === entity else { return false }
        
        Game.protagonist?.component(ofType: TargetComponent.self)?.source = nil
        statusBarComponent?.hideHealthBar()
        if let scene = SceneManager.levelScene {
            scene.targetOverlay = nil
        }
        return true
    }
    
    /// Attaches the tracking node to the entity's node.
    ///
    /// If the tracking node is already attached, this method has no effect.
    ///
    func attach() {
        if node.parent == nil {
            addTrackingData()
            nodeComponent.node.addChild(node)
        }
    }
    
    /// Detaches the tracking node from the entity's node.
    ///
    /// If the tracking node is not attached, this method has no effect.
    ///
    func detach() {
        node.userData = nil
        node.removeFromParent()
    }
    
    override func didAddToEntity() {
        node.entity = entity
        attach()
    }
    
    override func willRemoveFromEntity() {
        node.entity = nil
        detach()
    }
}
