//
//  GrimoireOfPoisonOrbItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/8/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Grimoire of Poison Orb, used to cast the Poison Orb spell.
///
class GrimoireOfPoisonOrbItem: UsableItem, TradableItem, DescribableItem, ResourceItem, DamageOverTimeItem,
LevelItem, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return PoisonOrbAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return PoisonOrbAnimation.textureNames.union([IconSet.Item.greenBook.imageName])
    }
    
    let name: String = "Grimoire of Poison Orb"
    let icon: Icon = IconSet.Item.greenBook
    let category: ItemCategory = .spellBook
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 60) }
    
    let resourceName = "Spell Components"
    let resourceCost = 6
    
    let missile: Missile
    let damageOverTime: DamageOverTimeCondition
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: GrimoireOfPoisonOrbItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        missile = other.missile
        damageOverTime = other.damageOverTime
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let damage = Damage(scale: 1.0, ratio: 0.1, level: level,
                            modifiers: [.intellect: 0.1],
                            type: .natural, sfx: nil)
        
        damageOverTime = PoisonCondition(tickTime: 3.0, tickDamage: damage, isExclusive: false,
                                         isResettable: true, duration: 21.1, source: nil)
        
        let animation = PoisonOrbAnimation().animation
        
        missile = Missile(medium: .spell, range: 630.0, speed: 224.0,
                          size: CGSize(width: 32.0, height: 32.0),
                          delay: 0, conclusion: 0, dissipateOnHit: true,
                          damage: nil, conditions: [damageOverTime],
                          animation: animation,
                          sfx: SoundFXSet.FX.boiling)
    }
    
    func copy() -> Item {
        return GrimoireOfPoisonOrbItem(other: self)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("GrimoireOfPoisonOrbItem can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("GrimoireOfPoisonOrbItem can only be used by an entity that has a CastComponent")
        }
        
        damageOverTime.source = entity
        castComponent.spell = Spell(kind: .missile, effect: missile, castTime: (0.75, 0, 0.5))
        castComponent.spellBook = self
        stateComponent.enter(namedState: .cast)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a noxious orb that poisons the victim.
        """
    }
}

/// The struct that defines the animations for the `GrimoireOfPoisonOrbItem`'s missile.
///
fileprivate struct PoisonOrbAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Spherical_Projectile_Beginning_", first: 1, last: 6)
        let standard = ImageArray.createFrom(baseName: "Spherical_Projectile_", first: 1, last: 6)
        let end = ImageArray.createFrom(baseName: "Spherical_Projectile_End_", first: 1, last: 6)
        return Set<String>(beginning + standard + end)
    }

    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let beginning = AnimationSource.getAnimation(forKey: Beginning.key) ?? Beginning()
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        let end = AnimationSource.getAnimation(forKey: End.key) ?? End()
        animation = (beginning, standard, end)
    }

    private class Beginning: TextureAnimation {
        static var key = "PoisonOrbAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Spherical_Projectile_Beginning_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.067, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
        }
    }
    
    private class Standard: TextureAnimation {
        static var key = "PoisonOrbAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Spherical_Projectile_", first: 1, last: 6, reversing: true)
            super.init(images: images, timePerFrame: 0.067, replaceable: true, flipped: false, repeatForever: true)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }

    private class End: TextureAnimation {
        static var key = "PoisonOrbAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Spherical_Projectile_End_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.067, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
    }
}
