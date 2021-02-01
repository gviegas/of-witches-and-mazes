//
//  SleightOfHandSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` that enables an entity to steal loot from enemies while `StealthSkill` is active.
///
class SleightOfHandSkill: UsableSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.steal.imageName]
    }
    
    let name: String = "Sleight of Hand"
    let icon: Icon = IconSet.Skill.steal
    let cost: Int = 2
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Attempts to steal from the selected target.
        Can only be used when Stealth is active.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("SleightOfHandSkill can only be used by an entity that has a StateComponent")
        }
        
        guard stateComponent.currentState is RogueStealthState else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "Requires Stealth")
                scene.presentNote(note)
            }
            return
        }
        
        stateComponent.enter(stateClass: RogueStealState.self)
    }
}
