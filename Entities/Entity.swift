//
//  Entity.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/10/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import GameplayKit

/// A struct that defines the tracking data for an `Entity` instance.
///
struct EntityTrackingData {
    
    /// The entity itself.
    ///
    weak var entity: Entity?
}

/// The base entity of which all others must be descendants.
///
class Entity: GKEntity, Identifiable {
    
    var identifier: String {
        return "\(ObjectIdentifier(self))"
    }
    
    /// The entity name, expected to be unique among all entities.
    ///
    let name: String
    
    /// The current `Level` instance that contains the entity.
    ///
    weak var level: Level?
    
    /// The current `Room` instance where the entity is located.
    ///
    weak var room: Room?
    
    /// Creates a new instance.
    ///
    /// - Parameter name: The name to use for the entity.
    ///
    init(name: String) {
        self.name = name
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Informs that the entity was just added to a 'Level' instance.
    ///
    /// `Entity` subclasses should override this method to apply any logic needed when entering
    /// into a level.
    ///
    /// - Note: Subclasses must call the superclass version of this method to keep the `level` property
    ///   updated.
    ///
    /// - Parameter level: The level that the entity was added to.
    ///
    func didAddToLevel(_ level: Level) {
        self.level = level
    }
    
    /// Informs that the entity is about to be removed from a `Level` instance.
    ///
    /// `Entity` subclasses should override this method to apply any logic needed before being removed
    /// from a level.
    ///
    /// - Note: Subclasses must call the superclass version of this method to keep the `level` property
    ///   updated.
    ///
    /// - Parameter level: The level that the entity is about to be removed from.
    ///
    func willRemoveFromLevel(_ level: Level) {
        self.level = nil
    }
    
    /// Informs that the entity is about to be removed from the game.
    ///
    func willRemoveFromGame() {
        components.forEach { component in
            if let contactable = component as? Contactable {
                ContactNotifier.removeAllRegistrationsFor(callback: contactable)
            }
            if let observer = component as? Observer {
                observer.removeFromAllObservables()
            }
        }
    }
}
