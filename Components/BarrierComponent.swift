//
//  BarrierComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A component tha enables an entity to use barriers.
///
class BarrierComponent: Component {
    
    /// An enum that defines the possible states for the barrier.
    ///
    private enum State {
        case beginning, standard, end
    }
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a BarrierComponent must also have a NodeComponent")
        }
        return component
    }
    
    /// The barrier node.
    ///
    private var node: SKNode?
    
    /// The amount of damage absorbed by the current barrier.
    ///
    /// - Note: If the barrier is not depletable, this value must be `0`.
    ///
    private var usedUp: Int = 0
    
    /// The elapsed time since last update.
    ///
    private var elapsedTime: TimeInterval = 0
    
    /// The current state of the barrier.
    ///
    private var state: State? {
        didSet { elapsedTime = 0 }
    }
    
    /// Checks if the barrier has used up all of its mitigation pool.
    ///
    private var isExhausted: Bool {
        guard let barrier = barrier else { return true }
        return usedUp >= barrier.mitigation
    }
    
    /// The remaining amount of mitigation to apply.
    ///
    /// For depletable barriers, this property holds the remaining amount of mitigation that can be
    /// applied to damage before the barrier is depleted. If the current barrier is not depletable,
    /// the value returned is the same as the barrier's `mitigation`. The `remainingMitigation` will
    /// be `0` when there is no barrier set.
    ///
    var remainingMitigation: Int {
        guard let barrier = barrier else { return 0 }
        return barrier.mitigation - usedUp
    }
    
    /// The current barrier.
    ///
    var barrier: Barrier? {
        didSet {
            node?.removeFromParent()
            usedUp = 0
            if let barrier = barrier {
                node = SKSpriteNode(color: .clear, size: barrier.size)
                node!.entity = entity
                barrier.animation?.initial?.play(node: node!)
                barrier.sfx?.play(at: nodeComponent.node.position, sceneKind: .level)
                nodeComponent.node.addChild(node!)
                state = .beginning
            } else {
                node = nil
                state = nil
            }
        }
    }
    
    /// Applies barrier.
    ///
    /// - Parameter damage: The amount of damage to be modified.
    /// - Returns: The new amount of damage.
    ///
    func applyBarrierTo(damage: Int) -> Int {
        guard let barrier = barrier else { return damage }
        
        let absorbed: Int
        if damage > remainingMitigation {
            absorbed = remainingMitigation
        } else {
            absorbed = damage
        }
        if barrier.isDepletable { usedUp += absorbed }
        return damage - absorbed
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let barrier = barrier else { return }
        
        node!.zPosition = max(DepthLayer.contents.upperBound - 1 - node!.position.y, DepthLayer.contents.lowerBound)
        
        if isExhausted && state != .end {
            barrier.animation?.final?.play(node: node!)
            state = .end
        }
        
        switch state {
        case .some(let state):
            switch state {
            case .beginning:
                let duration = barrier.animation?.initial?.duration ?? 0
                if elapsedTime >= duration {
                    barrier.animation?.main?.play(node: node!)
                    self.state = .standard
                }
            case .standard:
                guard let duration = barrier.duration else { break }
                if elapsedTime >= duration {
                    barrier.animation?.final?.play(node: node!)
                    self.state = .end
                }
            case .end:
                let duration = barrier.animation?.final?.duration ?? 0
                if elapsedTime >= duration {
                    self.barrier = nil
                }
            }
        default:
            break
        }
        
        elapsedTime += seconds
    }
}
