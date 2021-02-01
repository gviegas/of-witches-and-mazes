//
//  DivineBarrierSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UsableSkill` type tha enables an entity to cat the Divine Barrier spell.
///
class DivineBarrierSkill: UsableSkill, WaitTimeSkill, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return DivineBarrierAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return DivineBarrierAnimation.textureNames.union([IconSet.Skill.barrierHoly.imageName])
    }
    
    let name: String = "Divine Barrier"
    let icon: Icon = IconSet.Skill.barrierHoly
    let cost: Int = 3
    var unlocked: Bool = false
    var waitTime: TimeInterval = 10.0
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a spell that shields the caster against damage, absorbing \
        \(DivineBarrier.mitigationFor(entity: entity)) points of damage.
        Lasts until depleted.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("DivineBarrierSkill can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("DivineBarrierSkill can only be used by an entity that has a CastComponent")
        }
        guard let skillComponent = entity.component(ofType: SkillComponent.self) else {
            fatalError("DivineBarrierSkill can only be used by an entity that has a SkillComponent")
        }
        
        castComponent.spell = DivineBarrier(entity: entity).spell
        castComponent.spellBook = nil
        stateComponent.enter(namedState: .cast)
        skillComponent.triggerSkillWaitTime(self)
    }
}

/// The struct defining the Divine Barrier spell.
///
fileprivate struct DivineBarrier {
    
    /// The `Spell` instance to use when casting the spell.
    ///
    let spell: Spell
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter entity: The entity that will cast the spell.
    ///
    init(entity: Entity) {
        let mitigation = DivineBarrier.mitigationFor(entity: entity)
        
        let barrier = Barrier(mitigation: mitigation, isDepletable: true, affectedByDispel: true,
                              size: CGSize(width: 96.0, height: 96.0), duration: nil,
                              animation: DivineBarrierAnimation().animation, sfx: nil)
        
        spell = Spell(kind: .barrier, effect: barrier, castTime: (0.75, 0, 0.5))
    }
    
    /// Computes the amount of mitigation used by the spell.
    ///
    /// - Parameter entity: The entity that will use the spell.
    /// - Returns: The spell's mitigation.
    ///
    static func mitigationFor(entity: Entity) -> Int {
        guard let progressionComponent = entity.component(ofType: ProgressionComponent.self) else {
            fatalError("`mitigationFor(entity:)` requires an entity that has a ProgressionComponent")
        }
        
        return 5 + Int((Double(progressionComponent.levelOfExperience) * 5.33).rounded())
    }
}

/// The struct defining the `DivineBarrier`'s animations.
///
fileprivate struct DivineBarrierAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        return ["Yellow_Barrier"]
    }
    
    /// The tuple holding the `Animation` instances.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        let end = AnimationSource.getAnimation(forKey: End.key) ?? End()
        animation = (nil, standard, end)
    }
    
    private class Standard: TextureAnimation {
        static let key = "DivineBarrierAnimation.Standard"
        
        init() {
            super.init(images: ["Yellow_Barrier"], replaceable: true, flipped: false, repeatForever: true,
                       fadeInDuration: 2.0, fadeOutDuration: 2.0)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: Animation {
        static let key = "DivineBarrierAnimation.End"
        
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
