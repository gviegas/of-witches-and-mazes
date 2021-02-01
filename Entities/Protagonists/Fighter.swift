//
//  Fighter.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/16/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// The Fighter entity, a protagonist.
///
class Fighter: Protagonist, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        let animationSet = FighterAnimationSet.animationKeys
        var skills = Set<String>()
        skills.formUnion(ThrowShieldSkill.animationKeys)
        return animationSet.union(skills)
    }
    
    static var textureNames: Set<String> {
        let animations = FighterAnimationSet.textureNames
        let portrait = Set<String>([PortraitSet.fighter.imageName])
        let shadow = Set<String>(["Shadow"])
        var skills = Set<String>()
        skills.formUnion(GuardSkill.textureNames)
        skills.formUnion(WeaponMasterySkill.textureNames)
        skills.formUnion(DefensiveCombatSkill.textureNames)
        skills.formUnion(ThrowShieldSkill.textureNames)
        skills.formUnion(FirstBloodSkill.textureNames)
        skills.formUnion(CoupDeGraceSkill.textureNames)
        skills.formUnion(DashSkill.textureNames)
        skills.formUnion(OverpowerSkill.textureNames)
        skills.formUnion(HeroicDisplaySkill.textureNames)
        skills.formUnion(UnstoppableSkill.textureNames)
        return animations.union(portrait).union(shadow).union(skills)
    }
    
    /// Creates a new instance with the given level of experience and persona name.
    ///
    /// - Parameters:
    ///   - levelOfExperience: The entity's level of experience.
    ///   - personaName: The name to set for the persona component.
    ///
    init(levelOfExperience: Int, personaName: String) {
        let data = FighterData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience, personaName: personaName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `ProtagonistData` defining the data associated with the `Fighter` entity.
///
fileprivate class FighterData: ProtagonistData {
    
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
        name = "Fighter"
        progressionValues = FighterProgressionValues.instance
        animationSet = FighterAnimationSet()
        portrait = PortraitSet.fighter
        extraStates = [(FighterGuardState.self, nil), (FighterDashState.self, nil)]
        skillSet = [GuardSkill(), WeaponMasterySkill(), DefensiveCombatSkill(), ThrowShieldSkill(),
                    FirstBloodSkill(), CoupDeGraceSkill(), DashSkill(), OverpowerSkill(), HeroicDisplaySkill(),
                    UnstoppableSkill()]
        pack = WarriorsPack(levelOfExperience: levelOfExperience)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Fighter` entity.
///
fileprivate class FighterProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = FighterProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 8, rate: 0.8),
            Ability.agility: ProgressionValue(initialValue: 6, rate: 0.55),
            Ability.intellect: ProgressionValue(initialValue: 2, rate: 0.2),
            Ability.faith: ProgressionValue(initialValue: 4, rate: 0.35)]
        
        let healthPointsValue = ProgressionValue(initialValue: 20, rate: 10.0)
        
        let skillPointsValue = ProgressionValue(initialValue: 1, rate: 1.0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue,
                   skillPointsValue: skillPointsValue)
    }
}
