//
//  StatusBarComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/24/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that provides an entity with a status bar to display information
/// about itself.
///
class StatusBarComponent: Component, Observer, TextureUser {
    
    static var textureNames: Set<String> {
        return [healthImage, healthBarImage]
    }
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a StatusBarComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity?.component(ofType: SpriteComponent.self) else {
            fatalError("An entity with a StatusBarComponent must also have a SpriteComponent")
        }
        return component
    }
    
    private var healthComponent: HealthComponent? {
        return entity?.component(ofType: HealthComponent.self)
    }
    
    /// The width of the health.
    ///
    private static let healthWidth: CGFloat = 30.0
    
    /// The name of the health texture.
    ///
    private static let healthImage = "UI_Health"
    
    /// The name of the health bar texture.
    ///
    private static let healthBarImage = "UI_Health_Bar"
    
    /// The status bar node.
    ///
    private let node: SKNode
    
    /// The condition symbols.
    ///
    private var conditionSymbols: SKNode?
    
    /// The health bar.
    ///
    private var healthBar: UIHealthBar?
    
    /// The name label.
    ///
    private var nameLabel: UIText?
    
    /// The tuple stating whether the health bar and/or name label are hidden.
    ///
    private var hidden: (healthBar: Bool, nameLabel: Bool)
    
    /// Creates a new instance.
    ///
    /// - Parameter hidden: A flag stating whether or not to hide status bar.
    ///
    init(hidden: Bool) {
        node = SKNode()
        node.zPosition = DepthLayer.decorators.lowerBound
        self.hidden = (hidden, hidden)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Attaches the status bar node to the entity's node.
    ///
    /// If the status bar is already attached, this method has no effect.
    ///
    func attach() {
        guard node.parent == nil else { return }
        
        if let healthComponent = healthComponent {
            healthComponent.register(observer: self)
            if let healthBar = healthBar, healthBar.node.parent == nil { node.addChild(healthBar.node) }
        } else {
            healthBar?.node.removeFromParent()
        }
        if let entity = entity as? Entity { nameLabel?.text = entity.name }
        nodeComponent.node.addChild(node)
    }
    
    /// Detaches the status bar node from the entity's node.
    ///
    /// If the status bar is not attached, this method has no effect.
    ///
    func detach() {
        if let _ = node.parent {
            healthComponent?.remove(observer: self)
            node.removeFromParent()
        }
    }
    
    /// Adds a new condition symbols's node to the status bar, replacing the current one.
    ///
    /// - Parameters:
    ///   - node: The condition symbols's node to add.
    ///   - size: The dimensions of the node.
    ///
    func addConditionSymbols(node: SKNode, size: CGSize) {
        node.position.y = -(size.height / 2.0 + spriteComponent.size.height / 2.0 + 4.0)
        conditionSymbols?.removeFromParent()
        conditionSymbols = node
        self.node.addChild(node)
    }
    
    /// Removes the current condition symbols from the status bar.
    ///
    /// If no condition symbols are set, calling this method has no effect.
    ///
    func removeConditionSymbols() {
        conditionSymbols?.removeFromParent()
    }
    
    /// Shows the health bar.
    ///
    func showHealthBar() {
        healthBar?.node.isHidden = false
    }
    
    /// Hides the health bar.
    ///
    func hideHealthBar() {
        healthBar?.node.isHidden = true
    }
    
    /// Shows the name label.
    ///
    func showNameLabel() {
        nameLabel?.node.isHidden = false
    }
    
    /// Hides the name label.
    ///
    func hideNameLabel() {
        nameLabel?.node.isHidden = true
    }
    
    func didChange(observable: Observable) {
        switch observable {
        case is HealthComponent:
            let totalHp = CGFloat(healthComponent!.totalHp)
            let currentHp = CGFloat(healthComponent!.currentHP)
            healthBar?.resizeTo(normalizedValue: currentHp / totalHp)
        default:
            break
        }
    }
    
    func removeFromAllObservables() {
        entity?.component(ofType: HealthComponent.self)?.remove(observer: self)
    }
    
    override func didAddToEntity() {
        node.entity = entity
        
        healthBar = UIHealthBar(healthWidth: StatusBarComponent.healthWidth,
                                healthImage: StatusBarComponent.healthImage,
                                barImage: StatusBarComponent.healthBarImage)
        healthBar!.node.position.y = spriteComponent.size.height / 2.0 + healthBar!.size.height / 2.0 + 1.0
        node.addChild(healthBar!.node)
        
        let rect = CGRect(x: -64.0, y: healthBar!.size.height / 2.0 + healthBar!.node.position.y + 1.0,
                          width: 128.0, height: 12.0)
        nameLabel = UIText(rect: rect, style: .bar)
        node.addChild(nameLabel!.node)
        
        if hidden.healthBar { hideHealthBar() }
        if hidden.nameLabel { hideNameLabel() }
        
        attach()
    }
    
    override func willRemoveFromEntity() {
        node.entity = nil
        detach()
    }
}
