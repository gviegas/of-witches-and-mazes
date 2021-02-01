//
//  BombItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/27/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Item` type that defines the bomb, which explodes after a short time.
///
class BombItem: UsableItem, TradableItem, StackableItem, DescribableItem, DamageItem, LevelItem, TextureUser,
AnimationUser {
    
    static var animationKeys: Set<String> {
        return BombAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return BombAnimation.textureNames.union([IconSet.Item.bomb.imageName])
    }
    
    static let capacity: Int = 15
    
    var name: String { return "Bomb (Level \(itemLevel))" }
    let icon: Icon = IconSet.Item.bomb
    let category: ItemCategory = .gadget
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 15) }
    var stack: ItemStack
    
    var damage: Damage { return (throwing as! Bomb).explosion.damage! }
    let throwing: Throwing
    
    let itemLevel: Int
    let requiredLevel: Int
    
    required convenience init(level: Int) {
        self.init(level: level, quantity: 1)
    }
    
    required convenience init(quantity: Int) {
        self.init(level: 1, quantity: quantity)
    }
    
    /// Creates a new instance with the given level and holding the given quantity.
    ///
    /// - Parameters:
    ///  - level: The level of experience.
    ///  - quantity: The quantity.
    ///
    init(level: Int, quantity: Int) {
        let capacity = BombItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
        itemLevel = level
        requiredLevel = level
        
        let damage = Damage(scale: 5.75, ratio: 0.5, level: itemLevel,
                            modifiers: [:], type: .physical, sfx: SoundFXSet.FX.hit)
        
        throwing = Bomb(damage: damage)
    }
    
    func copy() -> Item {
        return BombItem(level: itemLevel, quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return BombItem(level: itemLevel, quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("BombItem can only be used by an entity that has a StateComponent")
        }
        guard let throwingComponent = entity.component(ofType: ThrowingComponent.self) else {
            fatalError("BombItem can only be used by an entity that has a ThrowingComponent")
        }
        guard let inventoryComponent = entity.component(ofType: InventoryComponent.self) else {
            fatalError("BombItem can only be used by an entity that has an InventoryComponent")
        }
        
        let _ = inventoryComponent.removeItem(self)
        throwingComponent.throwing = throwing
        stateComponent.enter(namedState: .toss)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        A device that explodes on impact.
        """
    }
}

/// The `Throwing` type representing the bomb.
///
fileprivate class Bomb: Throwing {
    
    let interaction: Interaction = .protagonistEffectOnObstacle
    let size: CGSize = CGSize(width: 16.0, height: 16.0)
    let speed: CGFloat = 384.0
    let range: CGFloat = 525.0
    let delay: TimeInterval = 0.65
    let duration: TimeInterval = 0
    let conclusion: TimeInterval = 0.2
    let completeOnContact: Bool = true
    let isRotational: Bool = false
    let animation: (initial: Animation?, main: Animation?, final: Animation?)?
    let sfx: SoundFX? = SoundFXSet.FX.genericAttack
    
    /// The explosion.
    ///
    let explosion: Blast
    
    /// Creates a new instance from the given `Damage`.
    ///
    /// - Parameter damage: The damage to apply when exploding.
    ///
    init(damage: Damage) {
        let bombAnimation = BombAnimation()
        animation = bombAnimation.throwing
        explosion = Blast(medium: .gadget,
                          initialSize: CGSize(width: 64.0, height: 64.0),
                          finalSize: CGSize(width: 128.0, height: 128.0),
                          range: 0,
                          delay: 0, duration: bombAnimation.blast.1!.duration!, conclusion: 0,
                          damage: damage, conditions: nil,
                          animation: bombAnimation.blast, sfx: SoundFXSet.FX.explosion)
    }
    
    
    func didContact(node: SKNode, location: CGPoint, source: Entity?) {
        guard let level = source?.level ?? LevelManager.currentLevel else { return }
        level.addNode(BlastNode(blast: explosion, origin: location, interaction: .neutralEffect, source: nil))
    }
    
    func didReachDestination(_ destination: CGPoint, totalContacts: Int, source: Entity?) {
        guard totalContacts == 0, let level = source?.level ?? LevelManager.currentLevel else { return }
        level.addNode(BlastNode(blast: explosion, origin: destination, interaction: .neutralEffect, source: nil))
    }
}

/// The struct that defines the animations for the `Bomb`.
///
fileprivate struct BombAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Toss.key, Explosion.key]
    }
    
    static var textureNames: Set<String> {
        let explosion = ImageArray.createFrom(baseName: "Explosion_", first: 1, last: 12)
        return Set<String>(explosion + ["Bomb"])
    }
    
    /// The tuple containing the animations for the throwing.
    ///
    let throwing: (Animation?, Animation?, Animation?)
    
    /// The tuple containing the animations for the blast.
    ///
    let blast: (Animation?, Animation?, Animation?)
    
    init() {
        let toss = AnimationSource.getAnimation(forKey: Toss.key) ?? Toss()
        let explosion = AnimationSource.getAnimation(forKey: Explosion.key) ?? Explosion()
        throwing = (nil, toss, nil)
        blast = (nil, explosion, nil)
    }
    
    private class Toss: Animation {
        static let key = "BombAnimation.Toss"
        
        let replaceable = true
        let duration: TimeInterval? = nil
        
        init() {
            AnimationSource.storeAnimation(self, forKey: Toss.key)
        }
        
        func play(node: SKNode) {
            guard let node = node as? SKSpriteNode else { return }
            
            let texture = TextureSource.createTexture(imageNamed: "Bomb")
            node.texture = texture
            node.size = texture.size()
        }
    }
    
    private class Explosion: TextureAnimation {
        static let key = "BombItem.Explosion"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Explosion_", first: 1, last: 12)
            super.init(images: images, timePerFrame: 0.067, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Explosion.key)
        }
    }
}
