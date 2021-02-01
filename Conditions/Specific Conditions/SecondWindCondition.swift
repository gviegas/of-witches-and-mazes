//
//  SecondWindCondition.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `HealingOverTimeCondition` subclass defining the condition applied by Second Wind.
///
class SecondWindCondition: HealingOverTimeCondition {
    
    init(source: Entity?) {
        let healing = Healing(percentage: 0.1...0.125, sfx: nil)
        super.init(tickTime: 1.5, tickHealing: healing, isExclusive: true, isResettable: false, duration: 5.0,
                   source: source, color: nil, sfx: nil)
    }
}
