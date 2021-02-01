//
//  HeroicDisplaySkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that temporary increases an entity's damage, defense and resistance.
///
class HeroicDisplaySkill: UsableSkill, WaitTimeSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.banner.imageName]
    }
    
    let name: String = "Heroic Display"
    let icon: Icon = IconSet.Skill.banner
    let cost: Int = 8
    var unlocked: Bool = false
    var waitTime: TimeInterval = 60.0
    
    /// The condition representing the bonuses provided by the skill.
    ///
    private let condition = HeroismCondition()
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Increases damage, defense and resistance by \(Int((condition.bonus * 100.0).rounded()))%.
        Lasts \(Int(condition.duration!.rounded())) seconds.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let conditionComponent = entity.component(ofType: ConditionComponent.self) else {
            fatalError("HeroicDisplaySkill can only be unlocked on an entity that has a ConditionComponent")
        }
        guard let skillComponent = entity.component(ofType: SkillComponent.self) else {
            fatalError("HeroicDisplaySkill can only be unlocked on an entity that has a SkillComponent")
        }
        
        let _ = conditionComponent.applyCondition(condition)
        skillComponent.triggerSkillWaitTime(self)
    }
}
