//
//  HeroismCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `Condition` type that improves an entity's damage, defense and resistance, defining
/// the temporary bonuses granted by the `HeroicDisplaySkill`.
///
class HeroismCondition: Condition {
    
    /// The bonus provided.
    ///
    let bonus = 0.5
    
    let isExclusive: Bool = true
    let isResettable: Bool = false
    let duration: TimeInterval? = 10.0
    weak var source: Entity?
    let color: ColorAnimation? = .heroized
    let sfx: SoundFX? = SoundFXSet.FX.flurryAttack
    
    func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool {
        guard applicationNumber == 1,
            let damageAdjustmentComponent = entity.component(ofType: DamageAdjustmentComponent.self),
            let defenseComponent = entity.component(ofType: DefenseComponent.self),
            let resistanceComponent = entity.component(ofType: ResistanceComponent.self)
            else { return false }
        
        damageAdjustmentComponent.modifyDamageCaused(by: bonus)
        defenseComponent.modifyDefense(by: bonus)
        resistanceComponent.modifyResistance(by: bonus)
        return true
    }
    
    func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        guard let damageAdjustmentComponent = entity.component(ofType: DamageAdjustmentComponent.self),
            let defenseComponent = entity.component(ofType: DefenseComponent.self),
            let resistanceComponent = entity.component(ofType: ResistanceComponent.self)
            else { return false }
        
        damageAdjustmentComponent.modifyDamageCaused(by: -bonus)
        defenseComponent.modifyDefense(by: -bonus)
        resistanceComponent.modifyResistance(by: -bonus)
        entity.component(ofType: SpriteComponent.self)?.colorize(colorAnimation: .cleared)
        return true
    }
    
    func update(onEntity entity: Entity, deltaTime seconds: TimeInterval) {
        
    }
}
