//
//  Feralon.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/2/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Feralon entity, a monster.
///
class Feralon: Monster, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return FeralonAnimationSet.animationKeys.union(FeralonRangedAttackAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return FeralonAnimationSet.textureNames
            .union(FeralonRangedAttackAnimation.textureNames)
            .union([PortraitSet.feralon.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = FeralonData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        component(ofType: ProgressionComponent.self)?.grade = 2.0
        
        // StateComponent
        addComponent(StateComponent(initialState: MonsterInitialState.self,
                                    states: [(MonsterInitialState(entity: self), nil),
                                             (MonsterStandardState(entity: self), .standard),
                                             (MonsterDeathState(entity: self), .death),
                                             (MonsterChaseState(entity: self), nil),
                                             (MonsterRangedAttackState(entity: self), nil),
                                             (MonsterQuelledState(entity: self), .quelled)]))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .superior,
                                                                 level: levelOfExperience)))
        
        // MissileComponent
        let rangedDamage = Damage(scale: 4.05, ratio: 0.4, level: levelOfExperience,
                                  modifiers: [:], type: .natural, sfx: SoundFXSet.FX.naturalHit)
        let rangedAnimation = FeralonRangedAttackAnimation().animation
        let rangedAttack = Missile(medium: .power, range: 420.0, speed: 192.0,
                                   size: CGSize(width: 24.0, height: 24.0),
                                   delay: 0.1, conclusion: 1.65, dissipateOnHit: true,
                                   damage: rangedDamage, conditions: nil,
                                   animation: rangedAnimation, sfx: nil)
        addComponent(MissileComponent(interaction: Interaction.monsterEffectOnObstacle, missile: rangedAttack))
        
        // Set the MonsterRangedAttackState
        let state = component(ofType: StateComponent.self)!.state(MonsterRangedAttackState.self)
        (state as! MonsterRangedAttackState).onExecution = { [unowned self] target in
            guard let missileComponent = self.component(ofType: MissileComponent.self),
                let origin = self.component(ofType: PhysicsComponent.self)?.position
                else { return }
            
            let p = CGPoint(x: target.x - origin.x, y: target.y - origin.y)
            let len = (p.x * p.x + p.y * p.y).squareRoot()
            let angle = atan2(p.y, p.x)
            let offset = CGFloat.pi / 6.0
            let targets = [target,
                           CGPoint(x: origin.x + len * cos(angle + offset), y: origin.y + len * sin(angle + offset)),
                           CGPoint(x: origin.x + len * cos(angle - offset), y: origin.y + len * sin(angle - offset))]
            targets.forEach { missileComponent.propelMissile(towards: $0) }
            
            SoundFXSet.FX.naturalAttack.play(at: origin, sceneKind: .level)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `MonsterData` defining the data associated with the `Feralon` entity.
///
fileprivate class FeralonData: MonsterData {
    
    let name: String
    let size: CGSize
    let speed: MovementSpeed
    let physicsShape: PhysicsShape
    let progressionValues: EntityProgressionValues
    let animationSet: DirectionalAnimationSet
    let portrait: Portrait
    let shadow: (size: CGSize, image: String)?
    let voice: (sound: SoundFX, volubleness: VoiceComponent.Volubleness)?
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        name = "Feralon"
        size = CGSize(width: 64.0, height: 64.0)
        speed = .slow
        physicsShape = .rectangle(size: CGSize(width: 36.0, height: 36.0), center: CGPoint(x: 0, y: -14.0))
        progressionValues = FeralonProgressionValues.instance
        animationSet = FeralonAnimationSet()
        portrait = PortraitSet.feralon
        shadow = (CGSize(width: 30.0, height: 20.0), "Shadow")
        voice = (SoundFXSet.Voice.feral, .high)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Feralon` entity.
///
fileprivate class FeralonProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = FeralonProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 10, rate: 0.95),
            Ability.agility: ProgressionValue(initialValue: 3, rate: 0.35),
            Ability.intellect: ProgressionValue(initialValue: 2, rate: 0.2),
            Ability.faith: ProgressionValue(initialValue: 1, rate: 0.1)]
        
        let healthPointsValue = ProgressionValue(initialValue: 37, rate: 18.55)
        
        let defenseValue = ProgressionValue(initialValue: 10, rate: 0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue, skillPointsValue: nil,
                   criticalHitValues: nil, damageCausedValues: nil, damageTakenValues: nil,
                   defenseValue: defenseValue, resistanceValue: nil, mitigationValue: nil)
    }
}

/// The struct defining the animations for the `Feralon`'s ranged attack.
///
fileprivate struct FeralonRangedAttackAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Caustic_Projectile_Beginning_", first: 1, last: 10)
        let standard = ImageArray.createFrom(baseName: "Caustic_Projectile_", first: 1, last: 12)
        let end = ImageArray.createFrom(baseName: "Caustic_Projectile_End_", first: 1, last: 10)
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
        static let key = "FeralonRangedAttackAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Caustic_Projectile_Beginning_", first: 1, last: 10)
            super.init(images: images, timePerFrame: 0.05, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "FeralonRangedAttackAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Caustic_Projectile_", first: 1, last: 12)
            super.init(images: images, timePerFrame: 0.05, replaceable: true, flipped: false, repeatForever: true)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: TextureAnimation {
        static let key = "FeralonRangedAttackAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Caustic_Projectile_End_", first: 1, last: 10)
            super.init(images: images, timePerFrame: 0.05, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
    }
}

