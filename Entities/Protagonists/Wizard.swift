//
//  Wizard.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// The Wizard entity, a protagonist.
///
class Wizard: Protagonist, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        let animationSet = WizardAnimationSet.animationKeys.union(WraithAnimationSet.animationKeys)
        var skills = Set<String>()
        skills.formUnion(FlamesSkill.animationKeys)
        skills.formUnion(DisintegrateSkill.animationKeys)
        return animationSet.union(skills)
    }
    
    static var textureNames: Set<String> {
        let animations = WizardAnimationSet.textureNames.union(WraithAnimationSet.textureNames)
        let portrait = Set<String>([PortraitSet.wizard.imageName, PortraitSet.wraith.imageName])
        let shadow = Set<String>(["Shadow"])
        var skills = Set<String>()
        skills.formUnion(FlamesSkill.textureNames)
        skills.formUnion(ArcaneMethodsSkill.textureNames)
        skills.formUnion(HypnotismSkill.textureNames)
        skills.formUnion(DisintegrateSkill.textureNames)
        skills.formUnion(BlackMagicSkill.textureNames)
        skills.formUnion(DestructiveMagicSkill.textureNames)
        skills.formUnion(SlowSkill.textureNames)
        skills.formUnion(CounterspellSkill.textureNames)
        skills.formUnion(ShatterSkill.textureNames)
        skills.formUnion(DiscarnateSkill.textureNames)
        return animations.union(portrait).union(shadow).union(skills)
    }
    
    /// Creates a new instance with the given level of experience and persona name.
    ///
    /// - Parameters:
    ///   - levelOfExperience: The entity's level of experience.
    ///   - personaName: The name to set for the persona component.
    ///
    init(levelOfExperience: Int, personaName: String) {
        let data = WizardData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience, personaName: personaName)
        
        // HypnotismComponent
        addComponent(HypnotismComponent())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/// The `ProtagonistData` defining the data associated with the `Wizard` entity.
///
fileprivate class WizardData: ProtagonistData {
    
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
        name = "Wizard"
        progressionValues = WizardProgressionValues.instance
        animationSet = WizardAnimationSet()
        portrait = PortraitSet.wizard
        extraStates = [(WizardDiscarnateState.self, nil)]
        skillSet = [FlamesSkill(), ArcaneMethodsSkill(), HypnotismSkill(), DisintegrateSkill(), BlackMagicSkill(),
                    DestructiveMagicSkill(), SlowSkill(), CounterspellSkill(), ShatterSkill(), DiscarnateSkill()]
        pack = MagesPack(levelOfExperience: levelOfExperience)
    }
}

/// The `EntityProgressionValues` subclass defining the progression values of the `Wizard` entity.
///
fileprivate class WizardProgressionValues: EntityProgressionValues {
    
    /// The instance of the class.
    ///
    static let instance = WizardProgressionValues()
    
    private init() {
        let abilityValues = [
            Ability.strength: ProgressionValue(initialValue: 4, rate: 0.4),
            Ability.agility: ProgressionValue(initialValue: 4, rate: 0.4),
            Ability.intellect: ProgressionValue(initialValue: 10, rate: 0.9),
            Ability.faith: ProgressionValue(initialValue: 1, rate: 0.2)]
        
        let healthPointsValue = ProgressionValue(initialValue: 12, rate: 6.0)
        
        let skillPointsValue = ProgressionValue(initialValue: 1, rate: 1.0)
        
        super.init(abilityValues: abilityValues, healthPointsValue: healthPointsValue,
                   skillPointsValue: skillPointsValue)
    }
}
