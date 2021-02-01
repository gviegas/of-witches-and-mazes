//
//  CastigationComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that manages the `Aura` associated with the Aura of Castigation skill.
///
class CastigationComponent: Component, Observer {
    
    private var auraComponent: AuraComponent {
        guard let component = entity?.component(ofType: AuraComponent.self) else {
            fatalError("An entity a with CastigationComponent must also have an AuraComponent")
        }
        return component
    }
    
    /// The current aura.
    ///
    private var aura: Aura!
    
    /// Adds the aura to the entity.
    ///
    private func addAura() {
        guard let entity = entity as? Entity else { return }
        
        aura = Aura(radius: 150.0, refreshTime: 1.0, alwaysInFront: true, affectedByDispel: false,
                    duration: nil, damage: nil, conditions: [CastigationCondition(source: entity)],
                    animation: nil, sfx: nil)
        auraComponent.aura = aura
    }
    
    /// Removes the aura from the entity.
    ///
    private func removeAura() {
        if auraComponent.aura === aura {
            aura = nil
            auraComponent.aura = nil
        }
    }
    
    func didChange(observable: Observable) {
        if observable is ProgressionComponent { addAura() }
    }
    
    func removeFromAllObservables() {
        entity?.component(ofType: ProgressionComponent.self)?.remove(observer: self)
    }
    
    override func didAddToEntity() {
        addAura()
        entity?.component(ofType: ProgressionComponent.self)?.register(observer: self)
    }
    
    override func willRemoveFromEntity() {
        removeAura()
        entity?.component(ofType: ProgressionComponent.self)?.remove(observer: self)
    }
}
