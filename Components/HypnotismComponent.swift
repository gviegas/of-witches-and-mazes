//
//  HypnotismComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/4/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component holding a reference to the current target affected by the entity's Hypnotism spell.
///
class HypnotismComponent: Component {
    
    /// The current entity affected by Hypnotism.
    ///
    /// - Note: Setting a new victim will cause the previous one to leave QuelledState.
    ///
    weak var victim: Entity? {
        didSet {
            guard
                let stateComponent = oldValue?.component(ofType: StateComponent.self),
                let conditionComponent = oldValue?.component(ofType: ConditionComponent.self),
                conditionComponent.hasCondition(ofType: HypnotismCondition.self)
                else { return }
            
            switch oldValue! {
            case is Protagonist where stateComponent.currentState is ProtagonistQuelledState:
                stateComponent.enter(stateClass: ProtagonistStandardState.self)
            case is Monster where stateComponent.currentState is MonsterQuelledState:
                stateComponent.enter(stateClass: MonsterStandardState.self)
            case is Companion where stateComponent.currentState is CompanionQuelledState:
                stateComponent.enter(stateClass: CompanionQuelledState.self)
            default:
                break
            }
        }
    }
}
