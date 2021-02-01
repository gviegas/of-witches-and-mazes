//
//  DaggerItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/7/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Item` type that defines the Dagger, a throwing weapon.
///
class DaggerItem: UsableItem, TradableItem, StackableItem, DescribableItem, DamageItem, LevelItem, TextureUser,
AnimationUser {
    
    static var animationKeys: Set<String> {
        return DaggerAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return DaggerAnimation.textureNames.union([IconSet.Item.dagger.imageName])
    }
    
    static let capacity: Int = 30
    
    var name: String { return "Dagger (Level \(itemLevel))" }
    let icon: Icon = IconSet.Item.dagger
    let category: ItemCategory = .throwingWeapon
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 10) }
    var stack: ItemStack
    
    var damage: Damage { return (throwing as! Dagger).damage }
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
        let capacity = DaggerItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
        itemLevel = level
        requiredLevel = level
        
        let damage = Damage(scale: 1.0, ratio: 0.35, level: level,
                            modifiers: [.strength: 0.2, .agility: 0.3],
                            type: .physical, sfx: SoundFXSet.FX.rangedHit)
        
        throwing = Dagger(damage: damage, itemLevel: level)
    }
    
    func copy() -> Item {
        return DaggerItem(level: itemLevel, quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return DaggerItem(level: itemLevel, quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("DaggerItem can only be used by an entity that has a StateComponent")
        }
        guard let throwingComponent = entity.component(ofType: ThrowingComponent.self) else {
            fatalError("DaggerItem can only be used by an entity that has a ThrowingComponent")
        }
        guard let inventoryComponent = entity.component(ofType: InventoryComponent.self) else {
            fatalError("DaggerItem can only be used by an entity that has an InventoryComponent")
        }
        
        let _ = inventoryComponent.removeItem(self)
        damage.createDamageSnapshot(from: entity, using: .ranged)
        throwingComponent.throwing = throwing
        stateComponent.enter(namedState: .toss)
    }
    
    /// Inform that the entity has used the `DaggerItem` through the `CripplingThrowSkill`.
    ///
    /// - Parameter entity: The entity that used the item to perform a crippling throw.
    ///
    func didUseCripplingThrowSkill(onEntity entity: Entity) {
        // Set crippling condition if the entity is a Rogue with the CripplingThrowSkill unlocked
        if let skill = entity.component(ofType: SkillComponent.self)?.skillOfClass(CripplingThrowSkill.self) {
            if skill.unlocked { (throwing as! Dagger).nextCondition = (skill as! CripplingThrowSkill).condition }
        }
        didUse(onEntity: entity)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        A throwing weapon.
        """
    }
}

/// The `Throwing` type representing the dagger.
///
fileprivate class Dagger: Throwing {
    
    let interaction: Interaction = .protagonistEffectOnObstacle
    let size: CGSize = CGSize(width: 32.0, height: 16.0)
    let speed: CGFloat = 384.0
    let range: CGFloat = 525.0
    let delay: TimeInterval = 0.4
    let duration: TimeInterval = 0
    let conclusion: TimeInterval = 0.2
    let completeOnContact: Bool = true
    let isRotational: Bool = true
    let animation: (initial: Animation?, main: Animation?, final: Animation?)? = DaggerAnimation().animation
    let sfx: SoundFX? = SoundFXSet.FX.rangedAttack
    
    /// The dagger's damage.
    ///
    let damage: Damage
    
    /// The item level.
    ///
    let itemLevel: Int
    
    /// The optional condition to apply on next throw.
    ///
    /// - Note: This value is automatically cleared upon conclusion.
    ///
    var nextCondition: Condition?
    
    /// Creates a new instance from the given `Damage` and item level.
    ///
    /// - Parameters
    ///   - damage: The damage to apply on hit.
    ///   - itemLevel: The level of the `DaggerItem` that this instance will represent.
    ///
    init(damage: Damage, itemLevel: Int) {
        self.damage = damage
        self.itemLevel = itemLevel
    }
    
    func didContact(node: SKNode, location: CGPoint, source: Entity?) {
        guard let target = node.entity as? Entity else { return }
        
        let outcome = Combat.carryOutHostileAction(using: .ranged, on: target, as: source,
                                                   damage: damage, conditions: nil)
        if let condition = nextCondition {
            switch outcome {
            case .damage(let amount):
                guard amount > 0 else { break }
                // The target suffered some damage, apply next condition
                let _ = target.component(ofType: ConditionComponent.self)?.applyCondition(condition)
            default:
                break
            }
        }
        
        guard let level = source?.level else { return }
        
        // Randomly choose whether or not to drop a dagger after a hit
        if Double.random(in: 0...1.0) > 0.667 {
            let lootNode = LootNode(droppedItems: [DaggerItem(level: itemLevel)], position: location)
            level.addNode(lootNode)
        }
    }
    
    func didReachDestination(_ destination: CGPoint, totalContacts: Int, source: Entity?) {
        guard let level = source?.level else { return }
        
        // Drop one dagger if the throw didn't hit anything
        if totalContacts == 0 {
            let lootNode = LootNode(droppedItems: [DaggerItem(level: itemLevel)], position: destination)
            level.addNode(lootNode)
        }
        
        nextCondition = nil
    }
}

/// The struct that defines the animation for the `Dagger`.
///
fileprivate struct DaggerAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key]
    }
    
    static var textureNames: Set<String> {
        return ["Dagger"]
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        animation = (nil, standard, nil)
    }
    
    private class Standard: Animation {
        static let key = "DaggerAnimation"
        
        let replaceable: Bool = false
        let duration: TimeInterval? = nil
        
        init() {
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
        
        func play(node: SKNode) {
            guard let node = node as? SKSpriteNode else { return }
            
            let texture = TextureSource.createTexture(imageNamed: "Dagger")
            node.texture = texture
            node.size = texture.size()
        }
    }
}
