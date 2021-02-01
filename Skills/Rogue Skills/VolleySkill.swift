//
//  VolleySkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `UsableSkill` type that enables an entity to execute a ranged attack that shoots multiple arrows.
///
class VolleySkill: UsableSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.arrows.imageName]
    }
    
    let name: String = "Volley"
    let icon: Icon = IconSet.Skill.arrows
    let cost: Int = 9
    var unlocked: Bool = false
    
    /// The resource cost to use the skill.
    ///
    private let resourceCost = 5
    
    /// The skill damage.
    ///
    /// - Note: This property must only be accessed after calling `didUse(onEntity:).`
    ///
    var damage: Damage!
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Executes a ranged attack that shoots a barrage of arrows using the equipped bow.
        """
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("VolleySkill can only be used by an entity that has a StateComponent")
        }
        guard let equipmentComponent = entity.component(ofType: EquipmentComponent.self) else {
            fatalError("VolleySkill can only be used by an entity that has an EquipmentComponent")
        }
        
        guard let item = equipmentComponent.itemOf(category: .rangedWeapon) else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "No ranged weapon equipped")
                scene.presentNote(note)
            }
            return
        }
        
        guard (item as! ResourceItem).consumeResources(from: entity, cost: resourceCost) else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "Not enough arrows")
                scene.presentNote(note)
            }
            return
        }
        
        damage = (item as! DamageItem).damage
        stateComponent.enter(stateClass: RogueVolleyState.self)
    }
}
