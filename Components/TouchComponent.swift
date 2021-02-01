//
//  TouchComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/2/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A component that enables an entity to cause `Touch`.
///
class TouchComponent: Component {
    
    /// An enum defining the possible states of the touch effect.
    ///
    private enum State {
        case beginning, standard, end
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a TouchComponent must also have a PhysicsComponent.")
        }
        return component
    }
    
    /// The elapsed time since last state change.
    ///
    private var elapsedTime: TimeInterval
    
    /// The current state.
    ///
    private var state: State? {
        didSet { elapsedTime = 0 }
    }
    
    /// The target to affect.
    ///
    private weak var target: Entity?
    
    /// The current touch.
    ///
    /// - Note: Setting this property will cancel the current touch effect, if one is occuring.
    ///
    var touch: Touch? {
        didSet {
            state = nil
            target = nil
        }
    }
    
    /// The flag stating whether a touch effect is occuring.
    ///
    var isOccurring: Bool {
        return state != nil
    }
    
    /// Creates anew instance from an optional `Touch` instance.
    ///
    /// - Parameter touch: An optional `Touch` instance to set on creation. The defaul value is `nil`.
    ///
    init(touch: Touch? = nil) {
        elapsedTime = 0
        state = nil
        self.touch = touch
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Causes the touch effect on the given target.
    ///
    /// - Parameters:
    ///   - target: The entity to affect.
    ///   - suppressNotes: The flag stating whether informational notes should be suppressed.
    ///     The default value is `false`.
    /// - Returns: `true` if the touch effect could be caused, `false` otherwise.
    ///
    @discardableResult
    func causeTouch(on target: Entity, suppressNotes: Bool = false) -> Bool {
        guard !isOccurring, let touch = touch else { return false }
        
        if target != entity {
            guard let targetPoint = target.component(ofType: PhysicsComponent.self)?.position else {
                if !suppressNotes, let scene = SceneManager.levelScene {
                    let note = NoteOverlay(rect: scene.frame, text: "Cannot affect this target")
                    scene.presentNote(note)
                }
                return false
            }
            let origin = physicsComponent.position
            let point = CGPoint(x: targetPoint.x - origin.x, y: targetPoint.y - origin.y)
            let len = (point.x * point.x + point.y * point.y).squareRoot()
            guard (len * 0.95) <= touch.range else {
                if !suppressNotes, let scene = SceneManager.levelScene {
                    let note = NoteOverlay(rect: scene.frame, text: "Target is too far away")
                    scene.presentNote(note)
                }
                return false
            }
        }
        
        state = .beginning
        self.target = target
        return true
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard isOccurring, let touch = touch else { return }
        
        elapsedTime += seconds
        switch state! {
        case .beginning:
            if elapsedTime >= touch.delay {
                if let target = target {
                    touch.didTouch(target: target, source: entity as? Entity)
                    // ToDo: Target-based animation logic
                    if let sfx = touch.sfx, let node = target.component(ofType: NodeComponent.self)?.node {
                        sfx.play(at: node.position, sceneKind: .level)
                    }
                    state = .standard
                } else {
                    // Target has been deinitialized, cancel effect
                    state = nil
                }
            }
        case .standard:
            if elapsedTime >= touch.duration { state = .end }
        case .end:
            if elapsedTime >= touch.conclusion { state = nil }
        }
    }
}
