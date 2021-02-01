//
//  StateComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/5/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An enum that defines names of common states.
///
enum StateName {
    case standard
    case death
    case quelled
    case attack
    case toss
    case shot
    case cast
    case use
    case lift
    case hurl
    case lifted
    case hurled
}

/// A component that provides an entity with a state machine.
///
class StateComponent: Component {
    
    /// The first state to enter.
    ///
    private let initialState: AnyClass
    
    /// All the states available.
    ///
    private let states: [GKState]
    
    /// The names assigned to states.
    ///
    /// Each value in this dictionary corresponds to the class type of a state in the `states` list,
    /// identifying that given state instance as a common state. Nameless states are not present
    /// in this property.
    ///
    private let namedStates: [StateName: AnyClass]
    
    /// The state machine instance.
    ///
    private let stateMachine: GKStateMachine
    
    /// Returns the current state.
    ///
    var currentState: GKState? {
        return stateMachine.currentState
    }
    
    /// Creates a new instance from the given initial state and array of states.
    ///
    /// - Parameters:
    ///   - initialState: The class of the initial state to enter.
    ///   - states: An array containing all available states, alongside optional names that identifies
    ///     their purpose. Each state name cannot appear more than once.
    ///
    init(initialState: AnyClass, states: [(state: GKState, name: StateName?)]) {
        guard initialState is GKState.Type else {
            fatalError("Invalid initial state \(initialState)")
        }
        
        var instances = [GKState]()
        var names = [StateName: AnyClass]()
        for (state, name) in states {
            instances.append(state)
            if let name = name { names[name] = type(of: state) }
        }
        
        self.states = instances
        self.namedStates = names
        self.initialState = initialState
        stateMachine = GKStateMachine(states: self.states)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Enters the initial state.
    ///
    func enterInitialState() {
        stateMachine.enter(initialState)
    }
    
    /// Enters the given state.
    ///
    /// - Parameter stateClass: The class of the state to enter.
    /// - Returns: `true` if the given state could be entered, `false` otherwise.
    ///
    @discardableResult
    func enter(stateClass: AnyClass) -> Bool {
        return stateMachine.enter(stateClass)
    }
    
    /// Enters the given named state.
    ///
    /// - Parameter namedState: The name of the state to enter.
    /// - Returns: `true` if the given state could be entered, `false` otherwise.
    ///
    @discardableResult
    func enter(namedState: StateName) -> Bool {
        guard let stateClass = namedStates[namedState] else { return false }
        return stateMachine.enter(stateClass)
    }
    
    /// Checks if a given state can be entered.
    ///
    /// - Parameter stateClass: The class of the state to check.
    /// - Returns: `true` if can enter, `false` otherwise.
    ///
    func canEnter(stateClass: AnyClass) -> Bool {
        return stateMachine.canEnterState(stateClass)
    }
    
    /// Checks if a given named state can be entered.
    ///
    /// - Parameter namedState: The name of the state to check.
    /// - Returns: `true` if can enter, `false` otherwise.
    ///
    func canEnter(namedState: StateName) -> Bool {
        guard let stateClass = namedStates[namedState] else { return false }
        return stateMachine.canEnterState(stateClass)
    }
    
    /// Retrieves the state of the given metatype.
    ///
    /// - Parameter stateClass: The class of the state to retrieve.
    /// - Returns: The state of the given metatype, or `nil` if not present.
    ///
    func state(_ stateClass: AnyClass) -> GKState? {
        return states.first { type(of: $0) == stateClass }
    }
    
    /// Retrieves the state of the given name.
    ///
    /// - Parameter name: The name of the state to enter.
    /// - Returns: The state under the given name, or `nil` if not present.
    ///
    func state(named stateName: StateName) -> GKState? {
        guard let stateClass = namedStates[stateName] else { return nil }
        return states.first { type(of: $0) == stateClass }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        stateMachine.update(deltaTime: seconds)
    }
}
