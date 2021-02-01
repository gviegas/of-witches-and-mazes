//
//  Rogue.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/21/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// The Rogue entity, a protagonist.
///
class Rogue: Protagonist, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        let animationSet = RogueAnimationSet.animationKeys
        return animationSet
    }
    
    static var textureNames: Set<String> {
        let animations = RogueAnimationSet.textureNames
        let portrait = Set<String>([PortraitSet.rogue.imageName])
        let shadow = Set<String>(["Shadow"])
        var skills = Set<String>()
        skills.formUnion(StealthSkill.textureNames)
        skills.formUnion(PoisonUseSkill.textureNames)
        skills.formUnion(SleightOfHandSkill.textureNames)
        skills.formUnion(CripplingThrowSkill.textureNames)
        skills.formUnion(MeleeWeaponExpertiseSkill.textureNames)
        skills.formUnion(RangedWeaponExpertiseSkill.textureNames)
        skills.formUnion(SneakAttackSkill.textureNames)
        skills.formUnion(DisableDeviceSkill.textureNames)
        skills.formUnion(VolleySkill.textureNames)
        skills.formUnion(IntimidateSkill.textureNames)
        return animations.union(portrait).union(shadow).union(skills)
    }
    
    /// Creates a new instance with the given level of experience and persona name.
    ///
    /// - Parameters:
    ///   - levelOfExperience: The entity's level of experience.
    ///   - personaName: The name to set for the persona component.
    ///
    init(levelOfExperience: Int, personaName: String) {
        let data = RogueData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience, personaName: personaName)
        
        // StealthComponent
        addComponent(StealthComponent(detectionInteraction: Interaction(contactGroups: [.monster]),
                                      detectionRadius: 24.0))
        
        // StealComponent
        addComponent(StealComponent(range: 56.0, detectionChance: 0.15))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didSufferDamage(amount: Int, source: Entity?) {
        if component(ofType: StealthComponent.self)?.isActive ?? false {
            component(ofType: StateComponent.self)?.enter(namedState: .standard)
        }
        super.didSufferDamage(amount: amount, source: source)
    }
}

/// The `ProtagonistData` defining the data associated with the `Rogue` entity.
///
fileprivate class RogueData: ProtagonistData {
    
    let name: String
    let progressionValues: EntityProgressionValues
    let animationSet: DirectionalAnimationSet
    let portrait: Portrait
    let extraStates: [(EntityState.Type, StateName?)]
    let skillSet: [Skill]
    let pack: Pack
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        name = "Rogue"
        progressionValues = RogueProgressionValues.instance
        animationSet = RogueAnimationSet()
        portrait = PortraitSet.rogue
        extraStates = [(RogueStealthState.self, nil), (RogueStealState.self, nil),
                       (RogueSneakAttackState.self, nil), (RogueVolleyState.self, nil)]
        skillSet = [StealthSkill(), PoisonUseSkill(), SleightOfHandSkill(), CripplingThrowSkill(),
                    MeleeWeaponExpertiseSkill(), RangedWeaponExpertiseSkill(), SneakAttackSkill(),
                    DisableDeviceSkill(), VolleySkill(), IntimidateSkill()]
        pack = ThiefsPack(levelOfExperience: levelOfExperience)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Rogue` entity.
///
fileprivate class RogueProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = RogueProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 5, rate: 0.5),
            Ability.agility: ProgressionValue(initialValue: 9, rate: 0.85),
            Ability.intellect: ProgressionValue(initialValue: 4, rate: 0.4),
            Ability.faith: ProgressionValue(initialValue: 1, rate: 0.15)]
        
        let healthPointsValue = ProgressionValue(initialValue: 16, rate: 8.0)
        
        let skillPointsValue = ProgressionValue(initialValue: 1, rate: 1.0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue,
                   skillPointsValue: skillPointsValue)
    }
}
