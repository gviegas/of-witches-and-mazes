//
//  ToyItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Toy, used to summon a dog companion.
///
class ToyItem: UsableItem, TradableItem, StackableItem, DescribableItem, LevelItem, ActionDelegate,
TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return Hound.animationKeys
    }
    
    static var textureNames: Set<String> {
        return Hound.textureNames.union([IconSet.Item.toy.imageName])
    }
    
    static let capacity: Int = 15
    
    var name: String { return "Toy (Level \(itemLevel))" }
    let icon: Icon = IconSet.Item.toy
    let category: ItemCategory = .general
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 15) }
    var stack: ItemStack
    
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
        let capacity = ToyItem.capacity
        stack = ItemStack(capacity: capacity, count: min(capacity, max(1, quantity)))
        itemLevel = level
        requiredLevel = level
    }
    
    func copy() -> Item {
        return ToyItem(level: itemLevel, quantity: stack.count)
    }
    
    func copy(stackCount: Int) -> Item {
        return ToyItem(level: itemLevel, quantity: stackCount)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("ToyItem can only be used by an entity that has a StateComponent")
        }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else {
            fatalError("ToyItem can only be used by an entity that has an ActionComponent")
        }
        
        actionComponent.action = Action(delay: 0.6, duration: 0, conclusion: 0.4, sfx: nil)
        actionComponent.subject = nil
        actionComponent.delegate = self
        stateComponent.enter(namedState: .use)
    }
    
    func didAct(_ action: Action, entity: Entity) {
        guard let physicsComponent = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("ToyItem can only be used by an entity that has a PhysicsComponent")
        }
        guard let companionComponent = entity.component(ofType: CompanionComponent.self) else {
            fatalError("ToyItem can only be used by an entity that has a CompanionComponent")
        }
        guard let inventoryComponent = entity.component(ofType: InventoryComponent.self) else {
            fatalError("ToyItem can only be used by an entity that has an InventoryComponent")
        }
        
        let _ = inventoryComponent.removeItem(self)
        
        if let currentCompanion = companionComponent.companion {
            if currentCompanion.component(ofType: StateComponent.self)?.enter(namedState: .death) != true {
                LevelManager.currentLevel!.removeFromSublevel(entity: currentCompanion)
            }
        }
        let companion = Hound(levelOfExperience: itemLevel)
        let content = Content(type: .companion, isDynamic: true, isObstacle: false, entity: companion)
        companionComponent.companion = companion
        companion.component(ofType: CompanionComponent.self)?.companion = entity
        LevelManager.currentLevel!.addContent(content, at: physicsComponent.position)
    }
    
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Summons a dog companion.
        """
    }
}
