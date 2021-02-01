//
//  LiftComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/19/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to lift another.
///
class LiftComponent: Component {
    
    private var stateComponent: StateComponent {
        guard let component = entity?.component(ofType: StateComponent.self) else {
            fatalError("An entity with a LiftComponent must also have a StateComponent")
        }
        return component
    }
    
    /// The flag stating whether or not the entity can lift another.
    ///
    var canLift: Bool {
        return liftSubject == nil
    }
    
    /// The hurl target.
    ///
    var hurlTarget: CGPoint? {
        return liftSubject?.component(ofType: LiftableComponent.self)?.hurlTarget
    }
    
    /// The hurl interaction.
    ///
    var hurlInteraction: Interaction
    
    /// The entity currently being lifted by this one.
    ///
    weak var liftSubject: Entity?
    
    /// Creates a new instance from the given interaction.
    ///
    /// - Parameter hurlInteraction: The `Interaction` to apply to the physics body of the
    ///   lifted entity when hurling it.
    ///
    init(hurlInteraction: Interaction) {
        self.hurlInteraction = hurlInteraction
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Lifts the given entity.
    ///
    /// - Parameter otherEntity: The entity to be lifted.
    /// - Returns: `true` if the given entity could be lifted, `false` otherwise.
    ///
    @discardableResult
    func lift(otherEntity: Entity) -> Bool {
        guard let otherLiftable = otherEntity.component(ofType: LiftableComponent.self),
            let otherState = otherEntity.component(ofType: StateComponent.self),
            canLift,
            otherLiftable.canBeLifted,
            stateComponent.canEnter(namedState: .lift),
            otherState.canEnter(namedState: .lifted)
            else { return false }
        
        liftSubject = otherEntity
        otherLiftable.liftSubject = entity as? Entity
        stateComponent.enter(namedState: .lift)
        otherState.enter(namedState: .lifted)
        return true
    }
    
    /// Hurls the current lifted entity.
    ///
    /// - Parameter position: The position to hurl at.
    /// - Returns: `true` if the given entity could be hurled, `false` otherwise.
    ///
    @discardableResult
    func hurl(at position: CGPoint) -> Bool {
        guard let otherLiftable = liftSubject?.component(ofType: LiftableComponent.self),
            let otherState = liftSubject?.component(ofType: StateComponent.self),
            stateComponent.canEnter(namedState: .hurl),
            otherState.canEnter(namedState: .hurled)
            else { return false }
        
        otherLiftable.hurlTarget = position
        stateComponent.enter(namedState: .hurl)
        otherState.enter(namedState: .hurled)
        return true
    }
    
    /// Drops the current lifted entity.
    ///
    /// - Parameter position: The position to drop at.
    /// - Returns: `true` if the given entity could be dropped, `false` otherwise.
    ///
    @discardableResult
    func drop(at position: CGPoint) -> Bool {
        guard let otherLiftable = liftSubject?.component(ofType: LiftableComponent.self),
            let otherState = liftSubject?.component(ofType: StateComponent.self),
            otherState.canEnter(namedState: .hurled)
            else { return false }
        
        liftSubject = nil
        otherLiftable.hurlTarget = position
        otherState.enter(namedState: .hurled)
        return true
    }
}
