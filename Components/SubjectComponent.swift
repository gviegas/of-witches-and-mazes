//
//  SubjectComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/25/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that provides a subject for the entity's interactions.
///
class SubjectComponent: Component {
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a SubjectComponent must also have a PhysicsComponent")
        }
        return component
    }
    
    private var stateComponent: StateComponent {
        guard let component = entity?.component(ofType: StateComponent.self) else {
            fatalError("An entity with a SubjectComponent must also have a StateComponent")
        }
        return component
    }
    
    /// The time to wait before evaluating the subjects again.
    ///
    private let evaluationDelay: TimeInterval = 0.1
    
    /// The elapsed time since the last evaluation.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The set of subjects.
    ///
    private var subjects = Set<Entity>()
    
    /// The private backing for the `subject` getter.
    ///
    private weak var _subject: Entity?
    
    /// The current subject.
    ///
    var subject: Entity? {
        return _subject
    }
    
    /// Adds a subject.
    ///
    /// - Parameter subject: The entity subject to add.
    ///
    func addSubject(_ subject: Entity) {
        if subjects.insert(subject).inserted { evaluateSubjects() }
    }
    
    /// Removes a subject.
    ///
    /// - Parameter subject: The entity subject to remove.
    ///
    func removeSubject(_ subject: Entity) {
        guard let removed = subjects.remove(subject) else { return }
        
        if removed == _subject {
            removed.component(ofType: InteractionComponent.self)?.willRemoveCurrent()
            _subject = nil
        }
        evaluateSubjects()
    }
    
    /// Nullifies the current subject and resets the evaluation timer.
    ///
    func nullifyCurrent() {
        _subject?.component(ofType: InteractionComponent.self)?.willRemoveCurrent()
        _subject = nil
        elapsedTime = 0
    }
    
    /// Evaluates the set of subjects to choose one as current.
    ///
    private func evaluateSubjects() {
        elapsedTime = 0
        subjects = subjects.filter({ $0.level != nil })
        
        guard (stateComponent.currentState as? ControllableEntityState)?.canInteract() != false else { return }
        
        let startPoint = physicsComponent.position
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        var newSubject: Entity?
        
        for subject in subjects {
            let endPoint: CGPoint
            if let component = subject.component(ofType: PhysicsComponent.self) {
                endPoint = component.position
            } else if let component = subject.component(ofType: NodeComponent.self) {
                endPoint = component.node.position
            } else {
                continue
            }
            let position = CGPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
            let distance = (position.x * position.x + position.y * position.y).squareRoot()
            if distance < minDistance {
                minDistance = distance
                newSubject = subject
            }
        }
        
        if let newSubject = newSubject, newSubject != subject {
            subject?.component(ofType: InteractionComponent.self)?.willRemoveCurrent()
            newSubject.component(ofType: InteractionComponent.self)?.willBecomeCurrent()
        }
        
        _subject = newSubject
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        elapsedTime += seconds
        if elapsedTime >= evaluationDelay { evaluateSubjects() }
    }
}
