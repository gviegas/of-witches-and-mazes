//
//  DisarmDeviceComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/29/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol defining a disarmable device, a type that can be affected by the `DisarmDeviceComponent`.
///
protocol Disarmable: AnyObject {
    
    /// The flag stating the current state of the device.
    ///
    var isDisarmed: Bool { get }
    
    /// Informs that the device was disarmed.
    ///
    /// - Parameter agent: The entity that disarmed the device.
    ///
    func didDisarm(agent: Entity)
}

/// A component that enables an entity to disarm devices.
///
class DisarmDeviceComponent: Component, ActionDelegate {
    
    private var stateComponent: StateComponent {
        guard let component = entity?.component(ofType: StateComponent.self) else {
            fatalError("An entity with a DisarmDeviceComponent must also have a StateComponent")
        }
        return component
    }
    
    private var actionComponent: ActionComponent {
        guard let component = entity?.component(ofType: ActionComponent.self) else {
            fatalError("An entity with a DisarmDeviceComponent must also have an ActionComponent")
        }
        return component
    }
    
    /// The flag stating whether a disarm action is taking place.
    ///
    private var isDisarming = false
    
    /// The current device being disarmed.
    ///
    private weak var device: Disarmable?
    
    /// Disarms the given device.
    ///
    /// - Parameter device: The `Disarmable` type to disarm.
    /// - Returns: `true` on success, `false` if a disarming action is happening, the provided device
    ///   is already disarmed or the entity cannot enter its `.use` state to disarm the device.
    ///
    @discardableResult
    func disarm(device: Disarmable) -> Bool {
        guard !isDisarming, !device.isDisarmed, stateComponent.canEnter(namedState: .use) else { return false }
        
        isDisarming = true
        self.device = device
        actionComponent.action = Action(delay: 1.6, duration: 0, conclusion: 0.4, sfx: nil)
        actionComponent.subject = device as? Entity
        actionComponent.delegate = self
        stateComponent.enter(namedState: .use)
        return true
    }
    
    func didAct(_ action: Action, entity: Entity) {
        guard entity === self.entity else { return }
        
        isDisarming = false
        device?.didDisarm(agent: entity)
        device = nil
    }
}
