//
//  PoisonComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that enables an entity to apply poison.
///
class PoisonComponent: Component, Observer {
    
    /// The `PoisonCondition` instance.
    ///
    private var poison: PoisonCondition!
    
    /// Computes the `PoisonCondition` that the component applies.
    ///
    /// - Parameter entity: The entity for which the condition must be computed.
    /// - Returns: A `PoisonCondition` representing the poison.
    ///
    static func poisonFor(entity: Entity) -> PoisonCondition {
        guard let progressionComponent = entity.component(ofType: ProgressionComponent.self) else {
            fatalError("PoisonComponent.poisonFor(entity:) requires an entity that has a ProgressionComponent")
        }
        
        let damage = Damage(scale: 1.0, ratio: 0, level: progressionComponent.levelOfExperience,
                            modifiers: [:], type: .natural, sfx: nil)
        let poison = PoisonCondition(tickTime: 2.0, tickDamage: damage, isExclusive: false,
                                     isResettable: true, duration: 10.1, source: entity)
        return poison
    }
    
    /// Applies poison to the given entity.
    ///
    /// - Parameter target: The target entity to be poisoned.
    ///
    func applyPoison(to target: Entity) {
        guard let conditionComponent = target.component(ofType: ConditionComponent.self) else { return }
        guard let entity = entity as? Entity else { return }
        
        if poison == nil { poison = PoisonComponent.poisonFor(entity: entity) }
        let _ = conditionComponent.applyCondition(poison)
    }
    
    func didChange(observable: Observable) {
        guard let entity = entity as? Entity, observable is ProgressionComponent else { return }
        poison = PoisonComponent.poisonFor(entity: entity)
    }
    
    func removeFromAllObservables() {
        entity?.component(ofType: ProgressionComponent.self)?.remove(observer: self)
    }
    
    override func didAddToEntity() {
        entity?.component(ofType: ProgressionComponent.self)?.register(observer: self)
    }
    
    override func willRemoveFromEntity() {
        entity?.component(ofType: ProgressionComponent.self)?.remove(observer: self)
    }
}
