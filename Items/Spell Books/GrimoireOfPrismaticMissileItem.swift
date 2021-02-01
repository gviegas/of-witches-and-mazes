//
//  GrimoireOfPrismaticMissileItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/25/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Grimoire of Prismatic Missile, used to cast the Prismatic Missile spell.
///
class GrimoireOfPrismaticMissileItem: UsableItem, TradableItem, DescribableItem, ResourceItem, DamageItem,
LevelItem, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return PrismaticMissileAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return PrismaticMissileAnimation.textureNames.union([IconSet.Item.greenGrimoire.imageName])
    }

    let name: String = "Grimoire of Prismatic Missile"
    let icon: Icon = IconSet.Item.greenGrimoire
    let category: ItemCategory = .spellBook
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 43) }
    
    let resourceName = "Spell Components"
    let resourceCost = 4
    
    let missile: Missile
    var damage: Damage { return missile.damage! }
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: GrimoireOfPrismaticMissileItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        missile = other.missile
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let damage = Damage(scale: 1.0, ratio: 0.25, level: level,
                            modifiers: [.intellect: 0.5],
                            type: .magical, sfx: SoundFXSet.FX.magicalHit)
        
        let animation = PrismaticMissileAnimation().animation
        
        missile = Missile(medium: .spell, range: 630.0, speed: 224.0,
                          size: CGSize(width: 32.0, height: 32.0),
                          delay: 0, conclusion: 0, dissipateOnHit: false,
                          damage: damage, conditions: nil,
                          animation: animation,
                          sfx: SoundFXSet.FX.magicalAttack)
    }
    
    func copy() -> Item {
        return GrimoireOfPrismaticMissileItem(other: self)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("GrimoireOfPrismaticMissileItem can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("GrimoireOfPrismaticMissileItem can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = Spell(kind: .missile, effect: missile, castTime: (0.75, 0, 0.5))
        castComponent.spellBook = self
        stateComponent.enter(namedState: .cast)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a prismatic missile capable of hitting multiple targets.
        """
    }
}

/// The struct that defines the animations for the `GrimoireOfPrismaticMissileItem`'s missile.
///
fileprivate struct PrismaticMissileAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Orbital_Projectile_Beginning_", first: 1, last: 6)
        let standard = ImageArray.createFrom(baseName: "Orbital_Projectile_", first: 1, last: 6)
        let end = ImageArray.createFrom(baseName: "Orbital_Projectile_End_", first: 1, last: 6)
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
        static let key = "PrismaticMissileAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Orbital_Projectile_Beginning_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.083, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
            
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "PrismaticMissileAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Orbital_Projectile_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.083, replaceable: true, flipped: false, repeatForever: true)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: TextureAnimation {
        static let key = "PrismaticMissileAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Orbital_Projectile_End_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.083, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
    }
}
