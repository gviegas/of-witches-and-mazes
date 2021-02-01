//
//  HypnotismCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/4/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `QuellCondition` subclass defining the condition applied by the Hypnotism spell.
///
class HypnotismCondition: QuellCondition {
    
    /// Creates a new instance from the given entity.
    ///
    /// - Parameter source: The entity to be identified as the source of the condition.
    ///
    init(source: Entity) {
        super.init(quelling: HypnotismSkill.quelling, source: source, color: nil,
                   sfx: SoundFXSet.FX.conjuration)
    }
    
    override func applyEffects(onEntity entity: Entity, applicationNumber: Int) -> Bool {
        guard let hypnotismComponent = source?.component(ofType: HypnotismComponent.self) else { return false }
        hypnotismComponent.victim = entity
        return super.applyEffects(onEntity: entity, applicationNumber: applicationNumber)
    }
    
    override func removeEffects(fromEntity entity: Entity, applications: Int) -> Bool {
        if let hypnotismComponent = source?.component(ofType: HypnotismComponent.self) {
            if hypnotismComponent.victim == entity { hypnotismComponent.victim = nil }
        }
        return super.removeEffects(fromEntity: entity, applications: applications)
    }
}
