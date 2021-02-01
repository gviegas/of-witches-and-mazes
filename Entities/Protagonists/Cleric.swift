//
//  Cleric.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// The Cleric entity, a protagonist.
///
class Cleric: Protagonist, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        let animationSet = ClericAnimationSet.animationKeys
        var skills = Set<String>()
        skills.formUnion(DivineBarrierSkill.animationKeys)
        return animationSet.union(skills)
    }
    
    static var textureNames: Set<String> {
        let animations = ClericAnimationSet.textureNames
        let portrait = Set<String>([PortraitSet.cleric.imageName])
        let shadow = Set<String>(["Shadow"])
        var skills = Set<String>()
        skills.formUnion(CureWoundsSkill.textureNames)
        skills.formUnion(InflictWoundsSkill.textureNames)
        skills.formUnion(FanaticismSkill.textureNames)
        skills.formUnion(DivineBarrierSkill.textureNames)
        skills.formUnion(SecondWindSkill.textureNames)
        skills.formUnion(RebukeSkill.textureNames)
        skills.formUnion(SacrificeSkill.textureNames)
        skills.formUnion(AuraOfCastigationSkill.textureNames)
        skills.formUnion(TranscendenceSkill.textureNames)
        skills.formUnion(EntombSkill.textureNames)
        return animations.union(portrait).union(shadow).union(skills)
    }
    
    /// Creates a new instance with the given level of experience and persona name.
    ///
    /// - Parameters:
    ///   - levelOfExperience: The entity's level of experience.
    ///   - personaName: The name to set for the persona component.
    ///
    init(levelOfExperience: Int, personaName: String) {
        let data = ClericData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience, personaName: personaName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `ProtagonistData` defining the data associated with the `Cleric` entity.
///
fileprivate class ClericData: ProtagonistData {
    
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
        name = "Cleric"
        progressionValues = ClericProgressionValues.instance
        animationSet = ClericAnimationSet()
        portrait = PortraitSet.cleric
        extraStates = []
        skillSet = [CureWoundsSkill(), InflictWoundsSkill(), FanaticismSkill(), DivineBarrierSkill(),
                    SecondWindSkill(), RebukeSkill(), SacrificeSkill(), AuraOfCastigationSkill(),
                    TranscendenceSkill(), EntombSkill()]
        pack = VicarsPack(levelOfExperience: levelOfExperience)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Cleric` entity.
///
fileprivate class ClericProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = ClericProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 5, rate: 0.5),
            Ability.agility: ProgressionValue(initialValue: 3, rate: 0.4),
            Ability.intellect: ProgressionValue(initialValue: 2, rate: 0.2),
            Ability.faith: ProgressionValue(initialValue: 10, rate: 0.9)]
        
        let healthPointsValue = ProgressionValue(initialValue: 16, rate: 8.0)
        
        let skillPointsValue = ProgressionValue(initialValue: 1, rate: 1.0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue,
                   skillPointsValue: skillPointsValue)
    }
}
