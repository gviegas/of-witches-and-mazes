//
//  DisintegrateSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to cast the Disintegrate spell.
///
class DisintegrateSkill: UsableSkill, DamageSkill, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return DisintegrateAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return DisintegrateAnimation.textureNames.union([IconSet.Skill.spellDisintegrating.imageName])
    }
    
    let name: String = "Disintegrate"
    let icon: Icon = IconSet.Skill.spellDisintegrating
    let cost: Int = 4
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a slow moving, powerful spell.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("DisintegrateSkill can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("DisintegrateSkill can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = Disintegrate(entity: entity).spell
        castComponent.spellBook = nil
        stateComponent.enter(namedState: .cast)
    }
    
    func damageFor(entity: Entity) -> Damage {
        return Disintegrate.damageFor(entity: entity)
    }
}

/// The struct defining the Disintegrate spell.
///
fileprivate struct Disintegrate {
    
    /// The `Spell` instance to use when casting the spell.
    ///
    let spell: Spell
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter entity: The entity that will cast the spell.
    ///
    init(entity: Entity) {
        let animation = DisintegrateAnimation().animation
        
        let missile = Missile(medium: .spell, range: 945.0, speed: 112.0,
                              size: CGSize(width: 32.0, height: 32.0),
                              delay: 0, conclusion: 0,
                              dissipateOnHit: true,
                              damage: Disintegrate.damageFor(entity: entity), conditions: nil,
                              animation: animation, sfx: SoundFXSet.FX.energy)
        
        spell = Spell(kind: .missile, effect: missile, castTime: (2.5, 0, 0.5))
    }
    
    /// Computes the `Damage` instance used by the spell.
    ///
    /// - Parameter entity: The entity that will use the spell.
    /// - Returns: The spell's `Damage`.
    ///
    static func damageFor(entity: Entity) -> Damage {
        guard let progressionComponent = entity.component(ofType: ProgressionComponent.self) else {
            fatalError("`damageFor(entity:)` requires an entity that has a ProgressionComponent")
        }
        
        return Damage(scale: 3.0, ratio: 0.25, level: progressionComponent.levelOfExperience,
                      modifiers: [.intellect: 0.7], type: .magical, sfx: SoundFXSet.FX.energyHit)
    }
}

/// The struct defining the `Disintegrate`'s animations.
///
fileprivate struct DisintegrateAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Magic_Projectile_Beginning_", first: 1, last: 6)
        let standard = ImageArray.createFrom(baseName: "Magic_Projectile_", first: 1, last: 6)
        let end = ImageArray.createFrom(baseName: "Magic_Projectile_End_", first: 1, last: 6)
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
        static let key = "DisintegrateAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Magic_Projectile_Beginning_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.067, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "DisintegrateAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Magic_Projectile_", first: 1, last: 6, reversing: true)
            super.init(images: images, timePerFrame: 0.067, replaceable: true, flipped: false, repeatForever: true)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: TextureAnimation {
        static let key = "DisintegrateAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Magic_Projectile_End_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.067, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
    }
}
