//
//  DepthComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/22/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that provides an entity with dynamic depth for drawing order.
///
class DepthComponent: Component {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity?.component(ofType: NodeComponent.self) else {
            fatalError("An entity with a DepthComponent must also have a NodeComponent")
        }
        return component
    }
    
    private var physicsComponent: PhysicsComponent {
        guard let component = entity?.component(ofType: PhysicsComponent.self) else {
            fatalError("An entity with a DepthComponent must also have a PhysicsComponent")
        }
        return component
    }
    
    /// The fixed depth value, which will take precedence over the dynamic `depth` property.
    ///
    /// When this property is set to a non-nil value, further accesses to the `depth` getter will forgo
    /// any computations and just return the fixed depth instead.
    ///
    var fixedDepth: CGFloat?
    
    /// The depth value.
    ///
    /// This property computes its value from the entity's physics body position - entities near
    /// the bottom of the scene will be draw last, while entities near the top will be draw first.
    ///
    /// - Note: The depth position is first adjusted to comply with the `over` entity's - the `under`
    ///   entity is adjusted afterwards. Thus, if both are set, it's only guaranteed that this entity
    ///   will be draw below the `under` entity.
    ///
    var depth: CGFloat {
        guard fixedDepth == nil else { return fixedDepth! }
        
        let nodePosition = nodeComponent.node.position
        let minY: CGFloat
        
        switch physicsComponent.physicsShape {
        case .circle(let radius, let center):
            minY = nodePosition.y + (center.y - radius)
        case .rectangle(let size, let center):
            minY = nodePosition.y + (center.y - size.height / 2.0)
        }
        
        var finalDepth = max(DepthLayer.contents.upperBound - 1 - minY, DepthLayer.contents.lowerBound)
        
        if let over = over {
            let overDepth = over.component(ofType: DepthComponent.self)?.depth
            if let overDepth = overDepth, overDepth >= finalDepth { finalDepth = overDepth + 1 }
        }
        if let under = under {
            let underDepth = under.component(ofType: DepthComponent.self)?.depth
            if let underDepth = underDepth, underDepth <= finalDepth { finalDepth = underDepth - 1 }
        }
        
        return finalDepth
    }
    
    /// The reference entity of which this one should always be draw above.
    ///
    /// - Note: This property won't allow cross references. Also, if the `under` entity is the same
    ///   as the one to be set on this property, the `under` property will be set to `nil`.
    ///
    weak var over: Entity? {
        didSet {
            guard let _ = over else { return }
            if over?.component(ofType: DepthComponent.self)?.over == entity { over = nil }
            else if over === under { under = nil }
        }
    }
    
    /// The reference entity of which this one should always be draw below.
    ///
    /// - Note: This property won't allow cross references. Also, if the `over` entity is the same
    ///   as the one to be set on this property, the `over` property will be set to `nil`.
    ///
    weak var under: Entity? {
        didSet {
            guard let _ = under else { return }
            if under?.component(ofType: DepthComponent.self)?.under == entity { under = nil }
            else if under === over { over = nil }
        }
    }
}
