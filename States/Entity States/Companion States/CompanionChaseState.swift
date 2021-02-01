//
//  CompanionChaseState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An `EntityState` subclass representing the state of a `Companion` when pursuing a target.
///
class CompanionChaseState: EntityState {

    private var movementComponent: MovementComponent {
        guard let component = entity.component(ofType: MovementComponent.self) else {
            fatalError("An entity assigned to CompanionChaseState must have a MovementComponent")
        }
        return component
    }

    private var directionComponent: DirectionComponent {
        guard let component = entity.component(ofType: DirectionComponent.self) else {
            fatalError("An entity assigned to CompanionChaseState must have a DirectionComponent")
        }
        return component
    }

    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to CompanionChaseState must have a SpriteComponent")
        }
        return component
    }

    private var physicsComponent: PhysicsComponent {
        guard let component = entity.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity assigned to CompanionChaseState must have a PhysicsComponent")
        }
        return component
    }

    private var targetComponent: TargetComponent {
        guard let component = entity.component(ofType: TargetComponent.self) else {
            fatalError("An entity assigned to CompanionChaseState must have a TargetComponent")
        }
        return component
    }
    
    private var companionComponent: CompanionComponent {
        guard let component = entity.component(ofType: CompanionComponent.self) else {
            fatalError("An entity assigned to CompanionChaseState must have a CompanionComponent")
        }
        return component
    }

    private var attack: Attack? {
        return entity.component(ofType: AttackComponent.self)?.attack
    }

    /// The elapsed time since last delay time.
    ///
    private var elapsedTime: TimeInterval = 0

    /// The time to wait before evaluating a new path.
    ///
    private var evaluationDelay: TimeInterval = 1.0

    /// The path leading to the final goal.
    ///
    private var path: [CGPoint] = []

    /// The current position in the path array.
    ///
    private var nextPointIdx = 0

    /// The maximum offset from a point in the path to be considered within range.
    ///
    private let pointOffset: CGFloat = 4.0

    /// The reach of the Companion attack, used as an offset on range checks.
    ///
    private var reach: CGFloat {
        return attack?.reach ?? 1.0
    }

    /// The current goal of the chase.
    ///
    var goal: CGPoint?

    /// The previous goal of the chase.
    ///
    var previousGoal: CGPoint?

    /// Creates a new instance for the given entity, with the given evaluation delay.
    ///
    /// - Parameters:
    ///   - entity: The entity instance that owns the state.
    ///   - evaluationDelay: The `TimeInterval` that the entity should wait before evaluating a new path.
    ///
    init(entity: Entity, evaluationDelay: TimeInterval) {
        self.evaluationDelay = max(evaluationDelay, 0.0)
        super.init(entity: entity)
    }

    /// Creates a new instance for the given entity, with path evaluation delay of one second.
    ///
    /// - Parameter entity: The entity instance that owns the state.
    ///
    required init(entity: Entity) {
        super.init(entity: entity)
    }

    override func didEnter(from previousState: GKState?) {
        // Leave immediately if has no target
        guard targetComponent.target != nil else {
            stateMachine?.enter(CompanionStandardState.self)
            return
        }
        // Make sure a path is evaluated immediately upon entering the state
        elapsedTime = evaluationDelay
        goal = nil
        previousGoal = nil
    }

    override func willExit(to nextState: GKState) {
        
    }

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is CompanionStandardState.Type,
             is CompanionLiftedState.Type,
             is CompanionAttackState.Type,
             is CompanionDeathState.Type,
             is CompanionQuelledState.Type:
            return true
        default:
            return false
        }
    }

    /// The update starts by confirming that the entity is not too far away from the companion.
    /// Then, it checks if it is time to recalculate a new path. If so, and the goal has changed,
    /// a new path to the goal will be computed or, if it is within range of the goal, enter into
    /// the attack state. If the goal is still the same or not enough time has passed, it will continue
    /// following the current path. In this case, it will keep checking for three possible situations:
    ///
    /// 1. It is within range of the goal, in which case it will enter the attack state.
    /// 2. There are points to follow along the path, so stay on path.
    /// 3. The end of the path has been reached and it is not within range of the goal, because it did not enter
    /// into the attack state in (1). In this case, it must be adjacent to the goal but its attack range is not
    /// enough to reach it. Thus, it will instead moves towards the goal itself, and not along a path.
    ///
    /// It is worth noting that when recalculating a path for a new goal, an empty path may be found, which means it
    /// is visible to the goal but not within range (a situation similar to (3)). This is solved by appending the
    /// goal itself to the (previously empty) path, which creates a single point path that leads straight to the goal.
    ///
    override func update(deltaTime seconds: TimeInterval) {
        guard let newGoal = targetComponent.target, companionComponent.isFar != true else {
            stopPursuit()
            return
        }
        
        elapsedTime += seconds
        
        // Set the goal as the current target
        goal = newGoal
        
        if (elapsedTime >= evaluationDelay) /*&& (goal != previousGoal)*/ {
            // It is time to check if a different path is needed for the new goal
            elapsedTime = 0
            let origin = physicsComponent.position
            if withinRange(pointA: origin, pointB: goal!, offset: reach) {
                // Within range of the target, execute the attack
                executeAttackAction()
            } else {
                // Try to find a new path
                let _path = entity.level?.findPathFrom(origin, to: goal!)
                if _path == nil {
                    // No path could be found, stop the pursuit
                    stopPursuit()
                } else {
                    path = _path!
                    if path.isEmpty {
                        // The target is visible but out of range, move towards the goal
                        path.append(goal!)
                    }
                    // Move towards the first point of the path array
                    nextPointIdx = 0
                    movementComponent.movement = unitVectorFor(startPoint: origin, endPoint: path[nextPointIdx])
                    animateMovementTowards(target: path[nextPointIdx])
                }
            }
            // Set the previous goal as the one that was just evaluated
            previousGoal = goal
        } else {
            // The goal did not change or not enough time has passed, continue in the current path
            let origin = physicsComponent.position
            if withinRange(pointA: origin, pointB: goal!, offset: reach) {
                // Close enough, no need to keep following the path - just execute the attack
                executeAttackAction()
            } else if nextPointIdx < path.endIndex {
                // There are points to track in the path, so keep following the current point or,
                // if within range of it, move towards the next one
                if withinRange(pointA: origin, pointB: path[nextPointIdx], offset: pointOffset) {
                    // Reached the current point of the path array, move towards the next one
                    nextPointIdx += 1
                    if nextPointIdx >= path.endIndex {
                        // No more points to follow, move towards the goal
                        movementComponent.movement = unitVectorFor(startPoint: origin, endPoint: goal!)
                        animateMovementTowards(target: goal!)
                    } else {
                        // There are points to follow, move to the next one
                        movementComponent.movement = unitVectorFor(startPoint: origin, endPoint: path[nextPointIdx])
                        animateMovementTowards(target: path[nextPointIdx])
                    }
                } // Else not close enough to the current point in the path, nothing to do
            } else {
                // No more points to follow, continue moving towards the goal
                movementComponent.movement = unitVectorFor(startPoint: origin, endPoint: goal!)
                animateMovementTowards(target: goal!)
            }
        }
    }

    /// Stops the pursuit, leaving the chase state.
    ///
    private func stopPursuit() {
        stateMachine?.enter(CompanionStandardState.self)
    }

    /// Executes the attack action, leaving the chase state.
    ///
    private func executeAttackAction() {
        if let _ = attack {
            stateMachine?.enter(CompanionAttackState.self)
        } else {
            // Leave
            stopPursuit()
        }
    }

    /// Checks if two points are within range of each other.
    ///
    /// - Parameters:
    ///   - pointA: The first point.
    ///   - pointB: The second point.
    ///   - offset: The distance away from a point that still should be considered within range.
    /// - Returns: `true` if `pointB` is within range of `pointA`, `false` otherwise.
    ///
    private func withinRange(pointA: CGPoint, pointB: CGPoint, offset: CGFloat) -> Bool {
        let x = pointA.x - pointB.x
        let y = pointA.y - pointB.y
        let distance = (x * x + y * y).squareRoot()
        return distance - offset <= 0
    }

    /// Computes a direction vector from two other vectors.
    ///
    /// - Parameters:
    ///   - startPoint: The start point.
    ///   - endPoint: The end point.
    /// - Returns: The unit vector that represents the direction from `startPoint` to `endPoint`.
    ///
    private func unitVectorFor(startPoint: CGPoint, endPoint: CGPoint) -> CGVector {
        let x = endPoint.x - startPoint.x
        let y = endPoint.y - startPoint.y
        let distance = (x * x + y * y).squareRoot()
        return CGVector(dx: x / distance, dy: y / distance)
    }

    /// Adjusts the moster's direction towards the given `target` by updating its `DirectionComponent`.
    ///
    /// - Parameter target: The target point.
    /// - Returns: `true` if the direction did change, `false` otherwise.
    ///
    private func adjustFacingDirectionTowards(target: CGPoint) -> Bool {
        let origin = physicsComponent.position
        let x = target.x - origin.x
        let y = target.y - origin.y
        let direction = Direction.fromAngle(atan2(y, x))
        if direction != directionComponent.direction {
            directionComponent.direction = direction
            return true
        }
        return false
    }

    /// Animates movement towards the given target, adjusting its direction if needed.
    ///
    /// - Parameter target: The target point.
    ///
    private func animateMovementTowards(target: CGPoint) {
        if adjustFacingDirectionTowards(target: target) || spriteComponent.animationName != .walk {
            spriteComponent.animate(name: .walk)
        }
    }
}
