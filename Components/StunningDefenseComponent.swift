//
//  StunningDefenseComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that enables an entity to stun its attacker after a successful defense.
///
class StunningDefenseComponent: Component {
    
    /// The quell condition representing the stun effect.
    ///
    private let quellCondition: QuellCondition
    
    /// Creates a new instance from the given duration.
    ///
    /// - Parameter duration: The stun duration.
    ///
    init(duration: TimeInterval) {
        let quelling = Quelling(breakOnDamage: false, makeVulnerable: true, duration: duration)
        quellCondition = QuellCondition(quelling: quelling, source: nil, color: nil, sfx: SoundFXSet.FX.hammer)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Stuns the given entity.
    ///
    /// - Parameter target: The target entity to be stunned.
    ///
    func stun(target: Entity) {
        guard let conditionComponent = target.component(ofType: ConditionComponent.self) else { return }
        let _ = conditionComponent.applyCondition(quellCondition)
    }
}
