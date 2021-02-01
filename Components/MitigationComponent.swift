//
//  MitigationComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/17/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

/// A component that provides an entity with a mitigation value to mitigate damage taken.
///
class MitigationComponent: Component {
    
    private var barrierComponent: BarrierComponent? {
        return entity?.component(ofType: BarrierComponent.self)
    }
    
    /// The private backing for the `mitigation` property.
    ///
    private var _mitigation = 0
    
    /// The mitigation bounds.
    ///
    let bounds = 0...10_000
    
    /// The mitigation value.
    ///
    var mitigation: Int {
        return max(bounds.lowerBound, min(bounds.upperBound, _mitigation))
    }
    
    /// The current barrier, from the `BarrierComponent`.
    ///
    var barrier : Barrier? {
        return barrierComponent?.barrier
    }
    
    /// The total amount of mitigation, considering the current barrier.
    ///
    var mitigationPlusBarrier: Int {
        return mitigation + (barrierComponent?.remainingMitigation ?? 0)
    }
    
    /// Modifies the mitigation value.
    ///
    /// - Parameter value: The mitigation value to add to the current one.
    ///
    func modifyMitigation(by value: Int) {
        _mitigation += value
    }
    
    /// Applies mitigation.
    ///
    /// - Parameter damage: The amount of damage to be modified.
    /// - Returns: A tuple where the first value states whether or not the whole damage was absorbed,
    ///   and the second value holds the new amount of damage.
    ///
    func applyMitigationTo(damage: Int) -> (fullyAbsorbed: Bool, damage: Int) {
        var newDmg = barrierComponent?.applyBarrierTo(damage: damage) ?? damage
        newDmg -= mitigation
        return (newDmg <= 0, max(0, newDmg))
    }
}
