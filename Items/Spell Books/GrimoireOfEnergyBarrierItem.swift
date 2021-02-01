//
//  GrimoireOfEnergyBarrierItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/9/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Item` type that defines the Grimoire of Energy Barrier, used to cast the Energy Barrier spell.
///
class GrimoireOfEnergyBarrierItem: UsableItem, TradableItem, DescribableItem, ResourceItem, LevelItem,
TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return EnergyBarrierAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return EnergyBarrierAnimation.textureNames.union([IconSet.Item.brownBook.imageName])
    }
    
    let name: String = "Grimoire of Energy Barrier"
    let icon: Icon = IconSet.Item.brownBook
    let category: ItemCategory = .spellBook
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 80) }
    
    let resourceName = "Spell Components"
    let resourceCost = 12
    
    let barrier: Barrier
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: GrimoireOfEnergyBarrierItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        barrier = other.barrier
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let mitigation = 4 + Int((Double(level) * 4.83).rounded())
        
        let animation = EnergyBarrierAnimation().animation
        
        barrier = Barrier(mitigation: mitigation,
                          isDepletable: true,
                          affectedByDispel: true,
                          size: CGSize(width: 96.0, height: 96.0),
                          duration: nil,
                          animation: animation,
                          sfx: nil)
    }
    
    func copy() -> Item {
        return GrimoireOfEnergyBarrierItem(other: self)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("GrimoireOfEnergyBarrierItem can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("GrimoireOfEnergyBarrierItem can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = Spell(kind: .barrier, effect: barrier, castTime: (0.75, 0, 0.5))
        castComponent.spellBook = self
        stateComponent.enter(namedState: .cast)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a barrier of energy that absorbs \(barrier.mitigation) points of damage.
        Lasts until depleted.
        """
    }
}

/// The struct that defines the animations for the `GrimoireOfEnergyBarrierItem`'s barrier.
///
fileprivate struct EnergyBarrierAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        return ["White_Barrier"]
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        let end = AnimationSource.getAnimation(forKey: End.key) ?? End()
        animation = (nil, standard, end)
    }
    
    private class Standard: TextureAnimation {
        static let key = "EnergyBarrierAnimation.Standard"
        
        init() {
            super.init(images: ["White_Barrier"], replaceable: true, flipped: false, repeatForever: true,
                       fadeInDuration: 2.0, fadeOutDuration: 2.0)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: Animation {
        static let key = "EnergyBarrierAnimation.End"
        
        let replaceable = true
        let duration: TimeInterval?
        private let action: SKAction
        
        init() {
            let clear = SKAction.fadeAlpha(to: 0, duration: 0)
            let fadeIn = SKAction.fadeIn(withDuration: 1.0 / 6.0)
            let fadeOut = SKAction.fadeOut(withDuration: 1.0 / 6.0)
            let flicker = SKAction.repeat(SKAction.sequence([fadeIn, fadeOut]), count: 3)
            action = SKAction.sequence([clear, flicker])
            duration = action.duration
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
        
        func play(node: SKNode) { node.run(action) }
    }
}
