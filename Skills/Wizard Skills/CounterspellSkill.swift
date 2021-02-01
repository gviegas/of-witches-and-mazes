//
//  CounterspellSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that causes resisted spells to affect the caster instead.
///
class CounterspellSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.spellMissile.imageName]
    }
    
    let name: String = "Counterspell"
    let icon: Icon = IconSet.Skill.spellMissile
    let cost: Int = 7
    var unlocked: Bool = false
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Resisted spells affect the enemy instead.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        if let counterComponent = entity.component(ofType: CounterComponent.self) {
            counterComponent.counterMedia.formUnion([.spell, .power])
        } else {
            entity.addComponent(CounterComponent(counterMedia: [.spell, .power]))
        }
    }
}
