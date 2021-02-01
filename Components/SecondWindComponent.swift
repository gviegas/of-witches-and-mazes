//
//  SecondWindComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that provides the healing over time condition for an entity that has the
/// Second Wind skill or a similar power.
///
class SecondWindComponent: Component {
    
    private var healthComponent: HealthComponent {
        guard let component = entity?.component(ofType: HealthComponent.self) else {
            fatalError("An entity with a SecondWindComponent must also have a HealthComponent")
        }
        return component
    }
    
    private var conditionComponent: ConditionComponent {
        guard let component = entity?.component(ofType: ConditionComponent.self) else {
            fatalError("An entity with a SecondWindComponent must also have a ConditionComponent")
        }
        return component
    }
    
    /// The `SecondWindCondition` instance that the component applies.
    ///
    private let condition = SecondWindCondition(source: nil)
    
    /// Applies the healing over time condition.
    ///
    func apply() {
        guard Double(healthComponent.currentHP) / Double(healthComponent.totalHp) <= 0.25 else { return }
        condition.source = entity as? Entity
        let _ = conditionComponent.applyCondition(condition)
    }
}
