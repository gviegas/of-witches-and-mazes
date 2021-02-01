//
//  FlamesSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/31/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to cast the Flames spell.
///
class FlamesSkill: UsableSkill, DamageSkill, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return FlamesAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return FlamesAnimation.textureNames.union([IconSet.Skill.spellFlame.imageName])
    }
    
    let name: String = "Flames"
    let icon: Icon = IconSet.Skill.spellFlame
    let cost: Int = 0
    var unlocked: Bool = true
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a blast of fire at the target location.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("FlamesSkill can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("FlamesSkill can only be used by an entity that has a CastComponent")
        }
        
        castComponent.spell = Flames(entity: entity).spell
        castComponent.spellBook = nil
        stateComponent.enter(namedState: .cast)
    }
    
    func damageFor(entity: Entity) -> Damage {
        return Flames.damageFor(entity: entity)
    }
}

/// The struct defining the Flames spell.
///
fileprivate struct Flames {
    
    /// The `Spell` instance to use when casting the spell.
    ///
    let spell: Spell
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter entity: The entity that will cast the spell.
    ///
    init(entity: Entity) {
        let animation = FlamesAnimation().animation
        
        let blast = Blast(medium: .spell, initialSize: CGSize(width: 32.0, height: 32.0),
                          finalSize: CGSize(width: 32.0, height: 32.0), range: 525.0,
                          delay: 0, duration: animation.1?.duration ?? 0.5, conclusion: 0,
                          damage: Flames.damageFor(entity: entity), conditions: nil,
                          animation: animation, sfx: SoundFXSet.FX.spell)
        
        spell = Spell(kind: .targetBlast, effect: blast, castTime: (0.75, 0, 0.5))
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
        
        return Damage(scale: 1.0, ratio: 0.25, level: progressionComponent.levelOfExperience,
                      modifiers: [.intellect: 0.5], type: .magical, sfx: nil)
    }
}

/// The struct defining the `Flames`' animations.
///
fileprivate struct FlamesAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key]
    }
    
    static var textureNames: Set<String> {
        let standard = ImageArray.createFrom(baseName: "Flames_", first: 1, last: 10)
        return Set<String>(standard)
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        animation = (nil, standard, nil)
    }
    
    private class Standard: TextureAnimation {
        static let key = "FlamesAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Flames_", first: 1, last: 10)
            super.init(images: images, timePerFrame: 0.05, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
}
