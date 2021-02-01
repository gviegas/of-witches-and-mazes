//
//  ThrowShieldSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `UsableSkill` type that enables an entity to throw its equipped shield as a missile weapon.
///
class ThrowShieldSkill: UsableSkill, WaitTimeSkill, DamageSkill, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return ShieldAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return ShieldAnimation.textureNames.union([IconSet.Skill.shieldThrowing.imageName])
    }
    
    let name: String = "Throw Shield"
    let icon: Icon = IconSet.Skill.shieldThrowing
    let cost: Int = 4
    var unlocked: Bool = false
    var waitTime: TimeInterval = 8.0
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Throws the equipped shield at the target location, damaging everything it hits.
        Projectiles hit by the shield will be destroyed.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let equipmentComponent = entity.component(ofType: EquipmentComponent.self) else {
            fatalError("ThrowShieldSkill can only be used by an entity that has an EquipmentComponent")
        }
        guard let throwingComponent = entity.component(ofType: ThrowingComponent.self) else {
            fatalError("ThrowShieldSkill can only be used by an entity that has a ThrowingComponent")
        }
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("ThrowShieldSkill can only be used by an entity that has a StateComponent")
        }
        guard let skillComponent = entity.component(ofType: SkillComponent.self) else {
            fatalError("ThrowShieldSkill can only be used by an entity that has a SkillComponent")
        }
        
        guard let _ = equipmentComponent.itemOf(category: .shield) else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "No shield equipped")
                scene.presentNote(note)
            }
            return
        }
        
        let throwing = Shield(entity: entity)
        throwingComponent.throwing = throwing
        stateComponent.enter(namedState: .toss)
        skillComponent.triggerSkillWaitTime(self)
    }
    
    func damageFor(entity: Entity) -> Damage {
        return Shield.damageFor(entity: entity)
    }
}

/// The `Throwing` type representing the `ThrowShieldSkill`'s shield.
///
fileprivate class Shield: Throwing {
    
    var interaction: Interaction = Interaction.protagonistEffectOnEffectAndObstacle
    var size: CGSize = CGSize(width: 32.0, height: 32.0)
    var speed: CGFloat = 384.0
    var range: CGFloat = 525.0
    var delay: TimeInterval = 0.55
    var duration: TimeInterval = 0
    var conclusion: TimeInterval = 0.3
    var completeOnContact: Bool = false
    var isRotational: Bool = true
    var animation: (initial: Animation?, main: Animation?, final: Animation?)? = ShieldAnimation().animation
    var sfx: SoundFX? = SoundFXSet.FX.throwShield
    
    /// The shield's damage.
    ///
    let damage: Damage
    
    /// Creates a new instance from the given `Damage`.
    ///
    /// - Parameter entity: The `Entity` that used the `ThrowShieldSkill`.
    ///
    init(entity: Entity) {
        damage = Shield.damageFor(entity: entity)
        damage.createDamageSnapshot(from: entity, using: .ranged)
    }
    
    func didContact(node: SKNode, location: CGPoint, source: Entity?) {
        guard let physicsBody = node.physicsBody, !Interaction.isEffect(physicsBody: physicsBody) else {
            // Complete if effect is a missile
            if let node = node as? MissileNode { node.complete() }
            return
        }
        
        guard let target = node.entity as? Entity else { return }
        
        Combat.carryOutHostileAction(using: .ranged, on: target, as: source, damage: damage, conditions: nil,
                                     unavoidable: true)
    }
    
    func didReachDestination(_ destination: CGPoint, totalContacts: Int, source: Entity?) {
        
    }
    
    /// Computes the `Damage` instance used by the shield.
    ///
    /// - Parameter entity: The entity that will use the `ThrowShieldSkill`.
    /// - Returns: The shield's `Damage`.
    ///
    static func damageFor(entity: Entity) -> Damage {
        guard let progressionComponent = entity.component(ofType: ProgressionComponent.self) else {
            fatalError("`damageFor(entity:)` requires an entity that has a ProgressionComponent")
        }
        
        return Damage(scale: 1.5, ratio: 0.2, level: progressionComponent.levelOfExperience,
                      modifiers: [.strength: 0.3, .agility: 0.2], type: .physical, sfx: SoundFXSet.FX.hit)
    }
}

/// The struct defining the `Shield`'s animations.
///
fileprivate struct ShieldAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key]
    }
    
    static var textureNames: Set<String> {
        return ["Shield"]
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        animation = (nil, standard, nil)
    }
    
    private class Standard: Animation {
        static let key = "ShieldAnimation.Standard"
    
        let replaceable: Bool = false
        var duration: TimeInterval? { return action.duration }
        private let action: SKAction
        
        init() {
            let texture = TextureSource.createTexture(imageNamed: "Shield")
            let textureAction = SKAction.setTexture(texture)
            let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 0.333, duration: 0.05)
            action = SKAction.sequence([textureAction, SKAction.repeatForever(rotateAction)])
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
        
        func play(node: SKNode) {
            node.run(action)
        }
    }
}
