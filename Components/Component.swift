//
//  Component.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/4/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The base class for all components of the game.
///
class Component: GKComponent, Observable {
    
    /// The observers.
    ///
    private var observers = [ObjectIdentifier: Observer]()
    
    func register(observer: Observer) {
        let key = ObjectIdentifier(observer)
        observers[key] = observer
    }
    
    func remove(observer: Observer) {
        let key = ObjectIdentifier(observer)
        observers[key] = nil
    }
    
    func broadcast() {
        for (_, observer) in observers {
            observer.didChange(observable: self)
        }
    }
}
