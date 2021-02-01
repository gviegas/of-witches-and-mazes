//
//  BlastComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/4/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to cause blast effects.
///
class BlastComponent: Component {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a BlastComponent must also have a NodeComponent")
        }
        return component
    }
    
    /// The interaction for the blasts.
    ///
    private var interaction: Interaction
    
    /// The blast to cause.
    ///
    var blast: Blast?
    
    /// Create a new instance from the given values.
    ///
    /// - Parameters:
    ///   - interaction: The `Interaction` instance that defines which targets should be hit.
    ///   - blast: An optional `Blast` instance to set on creation. The default value is `nil`.
    ///
    init(interaction: Interaction, blast: Blast? = nil) {
        self.interaction = interaction
        self.blast = blast
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Causes a blast.
    ///
    /// - Parameter origin: The origin of the blast.
    /// - Returns: `true` if the blast could be caused, `false` otherwise.
    ///
    @discardableResult
    func causeBlast(at origin: CGPoint) -> Bool {
        guard let blast = blast, let level = (entity as? Entity)?.level else { return false }
        
        let o: CGPoint
        let position = nodeComponent.node.position
        let point = CGPoint(x: origin.x - position.x, y: origin.y - position.y)
        let len = (point.x * point.x + point.y * point.y).squareRoot()
        if len > blast.range {
            let angle = atan2(point.y, point.x)
            o = CGPoint(x: position.x + blast.range * cos(angle), y: position.y + blast.range * sin(angle))
        } else {
            o = origin
        }
        
        let blastNode = BlastNode(blast: blast, origin: o, interaction: interaction, source: entity as? Entity)
        
        level.addNode(blastNode)
        
        return true
    }
}
