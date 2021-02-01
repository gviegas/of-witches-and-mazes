//
//  WraithComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/4/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component tha enables an entity to become a Wraith.
///
class WraithComponent: Component {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a WraithComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity?.component(ofType: SpriteComponent.self) else {
            fatalError("An entity with a WraithComponent must also have a SpriteComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a WraithComponent must also have a PhysicsComponent")
        }
        return component
    }
    
    private var stateComponent: StateComponent {
        guard let component = entity?.component(ofType: StateComponent.self) else {
            fatalError("An entity with a WraithComponent must also have a StateComponent")
        }
        return component
    }
    
    private var healthComponent: HealthComponent {
        guard let component = entity?.component(ofType: HealthComponent.self) else {
            fatalError("An entity with a WraithComponent must also have a HealthComponent")
        }
        return component
    }
    
    private var portraitComponent: PortraitComponent {
        guard let component = entity?.component(ofType: PortraitComponent.self) else {
            fatalError("An entity with a WraithComponent must also have a PortraitComponent")
        }
        return component
    }
    
    /// The private backing for the `isWraith` getter.
    ///
    private var _isWraith: Bool
    
    /// The flag stating whether the enity has turned into a wraith.
    ///
    var isWraith: Bool { return _isWraith }
    
    /// The class of the state to enter after becoming a Wraith.
    ///
    let wraithStateClass: AnyClass
    
    /// Creates a new instance from the given state.
    ///
    /// - Parameter wraithStateClass: The class of the state to enter after becoming a Wraith.
    ///
    init(wraithStateClass: AnyClass) {
        self.wraithStateClass = wraithStateClass
        _isWraith = false
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Transforms the entity into a Wraith.
    ///
    /// - Returns: `true` if the entity became a Wraith, `false` if the entity is a Wraith already
    ///   or the provided state cannot be entered.
    ///
    func turnIntoWraith() -> Bool {
        guard !_isWraith, stateComponent.enter(stateClass: wraithStateClass) else { return false }
        
        _isWraith = true
        healthComponent.restoreHP(healthComponent.totalHp)
        healthComponent.modifyMultiplier(by: -0.75)
        portraitComponent.portrait = PortraitSet.wraith
        spriteComponent.reset()
        spriteComponent.animationSet = WraithAnimationSet()
        spriteComponent.animate(name: .idle)
        SoundFXSet.Voice.dreadfulBeing.play(at: nil, sceneKind: .level)
        return true
    }
}
