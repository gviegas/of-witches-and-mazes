//
//  EnfeeblementComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/1/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that enables an entity to weaken others.
///
class EnfeeblementComponent: Component {
    
    /// The weaken condition representing the enfeeblement effect.
    ///
    let weakenCondition: WeakenCondition
    
    /// Creates a new instance from the given weaken condition.
    ///
    /// - Parameter weakenCondition: The `WeakenCondition` instance to use.
    ///
    init(weakenCondition: WeakenCondition) {
        self.weakenCondition = weakenCondition
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Weakens the given entity.
    ///
    /// - Parameter target: The entity to be weakened.
    ///
    func weaken(target: Entity) {
        guard let conditionComponent = target.component(ofType: ConditionComponent.self) else { return }
        let _ = conditionComponent.applyCondition(weakenCondition)
    }
}
