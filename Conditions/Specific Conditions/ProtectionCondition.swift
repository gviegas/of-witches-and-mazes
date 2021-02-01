//
//  ProtectionCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `Condition` type that improves an entity's defense and resistance, defining the
/// protection provided by the `GuardSkill`.
///
class ProtectionCondition: Condition {
    
    /// The defense bonus provided.
    ///
    let defenseBonus = 0.9
    
    /// The resistance bonus provided.
    ///
    let resistanceBonus = 0.5
    
    let isExclusive: Bool = true
    let isResettable: Bool = false
    let duration: TimeInterval? = nil
    weak var source: Entity?
    let color: ColorAnimation? = nil
    let sfx: SoundFX? = nil
    
    func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool {
        guard applicationNumber == 1,
            let defenseComponent = entity.component(ofType: DefenseComponent.self),
            let resistanceComponent = entity.component(ofType: ResistanceComponent.self)
            else { return false }
        
        defenseComponent.modifyDefense(by: defenseBonus)
        resistanceComponent.modifyResistance(by: resistanceBonus)
        return true
    }
    
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        guard let defenseComponent = entity.component(ofType: DefenseComponent.self),
            let resistanceComponent = entity.component(ofType: ResistanceComponent.self)
            else { return false }
        
        defenseComponent.modifyDefense(by: -defenseBonus)
        resistanceComponent.modifyResistance(by: -resistanceBonus)
        return true
    }
    
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval) {
        
    }
}
