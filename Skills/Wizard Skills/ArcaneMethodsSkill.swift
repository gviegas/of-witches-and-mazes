//
//  ArcaneMethodsSkill.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `PassiveSkill` type that reduces the resource cost of spell books.
///
class ArcaneMethodsSkill: PassiveSkill, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Skill.scroll.imageName]
    }
    
    let name: String = "Arcane Methods"
    let icon: Icon = IconSet.Skill.scroll
    let cost: Int = 2
    var unlocked: Bool = false
    
    /// The resource cost ratio that the skill provides.
    ///
    private let resourceCostRatio = 0.5
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Reduces the amount of spell components required to use spell books by \
        \(Int((resourceCostRatio * 100.0).rounded()))%.
        """
    }
    
    func didUnlock(onEntity entity: Entity) {
        if let resourceUsageComponent = entity.component(ofType: ResourceUsageComponent.self) {
            resourceUsageComponent.costRatios[.spellBook] = resourceCostRatio
        } else {
            entity.addComponent(ResourceUsageComponent(costRatios: [.spellBook: resourceCostRatio]))
        }
    }
}
