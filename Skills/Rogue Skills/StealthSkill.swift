//
//  StealthSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to sneak around unnoticed.
///
class StealthSkill: UsableSkill, WaitTimeSkill, ActiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.faceHiding.imageName]
    }
    
    let name: String = "Stealth"
    let icon: Icon = IconSet.Skill.faceHiding
    let cost: Int = 0
    var unlocked: Bool = true
    var waitTime: TimeInterval = 10.0
    var isActive: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Enables the rogue to walk around undetected.
        Taking damage or getting too close to hostile creatures will cancel Stealth.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("StealthSkill can only be used by an entity that has a StateComponent")
        }
        
        if stateComponent.currentState is RogueStealthState {
            // Leave stealth mode
            stateComponent.enter(stateClass: ProtagonistStandardState.self)
        } else {
            // Enter stealth mode
            stateComponent.enter(stateClass: RogueStealthState.self)
        }
    }
}
