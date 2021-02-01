//
//  ComponentSystem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import GameplayKit

/// A class that manages the update of `Component` subclasses in an ordered manner.
///
class ComponentSystem {
    
    /// The types of components managed, in the order that they are updated.
    ///
    static let componentTypes = [
        StateComponent.self,
        MovementComponent.self,
        ConditionComponent.self,
        AttackComponent.self,
        AuraComponent.self,
        SubjectComponent.self,
        TargetComponent.self,
        PickUpComponent.self,
        SpeechComponent.self,
        LogComponent.self,
        SpriteComponent.self,
        BarrierComponent.self,
        PerceptionComponent.self,
        StealthComponent.self,
        TouchComponent.self,
        SkillComponent.self
    ]
    
    /// The systems.
    ///
    private let systems = ComponentSystem.componentTypes.map { GKComponentSystem(componentClass: $0) }
    
    /// The identifiers of the entities whose components were added to the system.
    ///
    private var managedEntities: Set<String> = []
    
    /// Adds the components of the given entity to the system.
    ///
    /// - Parameter entity: The entity whose components should be managed by the system.
    /// - Returns: `true` if successful, `false` if the entity's components are already being managed.
    ///
    @discardableResult
    func addEntity(_ entity: Entity) -> Bool {
        guard managedEntities.insert(entity.identifier).inserted else { return false }
        
        for t in ComponentSystem.componentTypes {
            if let component = entity.component(ofType: t) {
                systems.first(where: { $0.componentClass == t })!.addComponent(component)
            }
        }
        return true
    }
    
    /// Removes the components of the given entity from the system.
    ///
    /// - Parameter entity: The entity whose components should be removed from the system.
    ///
    func removeEntity(_ entity: Entity) {
        guard let _ = managedEntities.remove(entity.identifier) else { return }
        systems.forEach { $0.removeComponent(foundIn: entity) }
    }
    
    /// Updates the component system, causing each managed component to be updated in order.
    ///
    /// - Parameter seconds: The time since the last call of this method.
    ///
    func update(deltaTime seconds: TimeInterval) {
        systems.forEach { $0.update(deltaTime: seconds) }
    }
}
