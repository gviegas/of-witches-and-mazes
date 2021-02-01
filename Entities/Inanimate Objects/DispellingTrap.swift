//
//  DispellingTrap.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Dispelling Trap entity, an inanimate object.
///
class DispellingTrap: InanimateObject, PerceptionDelegate, TextureUser {
    
    static var textureNames: Set<String> {
        return ["Dispelling_Trap"]
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = DispellingTrapData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let texture = TextureSource.createTexture(imageNamed: "Dispelling_Trap")
        component(ofType: SpriteComponent.self)!.texture = texture
        
        // PerceptionComponent
        addComponent(PerceptionComponent(interaction: .neutralEffectOnEffect, radius: 24.0, delegate: self))
        
        // InfluenceComponent
        addComponent(InfluenceComponent())
        component(ofType: InfluenceComponent.self)!.influence = DispelMagic()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didPerceiveTarget(_ target: Entity) {
        guard let nodeComponent = component(ofType: NodeComponent.self),
            let physicsComponent = component(ofType: PhysicsComponent.self),
            let perceptionComponent = component(ofType: PerceptionComponent.self),
            let influenceComponent = component(ofType: InfluenceComponent.self),
            influenceComponent.influence != nil
            else { return }
        
        // Detach perception node, remove physics body, cause influence and nullify influence instance
        perceptionComponent.detach()
        physicsComponent.remove()
        influenceComponent.causeInfluence(at: nodeComponent.node.position)
        influenceComponent.influence = nil
        
        // Fade out the main node and remove self from level
        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
        let removeSelf = SKAction.run {
            [unowned self] in
            self.level?.removeFromSublevel(entity: self)
        }
        nodeComponent.node.run(SKAction.sequence([fadeOut, removeSelf]))
    }
}

/// The `InanimateObjectdData` of the `DispellingTrap` entity.
///
fileprivate class DispellingTrapData: InanimateObjectData {
    
    let name: String
    let size: CGSize
    let physicsShape: PhysicsShape
    let interaction: Interaction
    let progressionValues: EntityProgressionValues?
    let animationSet: DirectionalAnimationSet?
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        name = "Dispelling Trap"
        size = CGSize(width: 32.0, height: 32.0)
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 24.0), center: CGPoint(x: 0, y: -4.0))
        interaction = .trap
        progressionValues = nil
        animationSet = nil
    }
}

/// An `Influence` type representing the Dispel Magic effect.
///
fileprivate class DispelMagic: Influence {
    
    let interaction: Interaction = Interaction(category: .effect, contactGroups: [.effect, .protagonist,
                                                                                  .monster, .companion])
    let radius: CGFloat = 525.0
    let range: CGFloat = 0
    let delay: TimeInterval = 0
    let duration: TimeInterval = 1.5
    let conclusion: TimeInterval = 0
    let animation: Animation? = nil
    let sfx: SoundFX? = SoundFXSet.FX.magnet
    
    func didInfluence(node: SKNode, source: Entity?) {
        if let node = node as? MissileNode {
            node.wasAffectedByDispel()
        } else if let node = node as? BlastNode {
            node.wasAffectedByDispel()
        } else if let node = node as? RayNode {
            node.wasAffectedByDispel()
        } else if let targetEntity = node.entity {
            if targetEntity.component(ofType: BarrierComponent.self)?.barrier?.affectedByDispel == true {
                targetEntity.component(ofType: BarrierComponent.self)!.barrier = nil
            }
            if targetEntity.component(ofType: AuraComponent.self)?.aura?.affectedByDispel == true {
                targetEntity.component(ofType: AuraComponent.self)!.aura = nil
            }
        }
    }
}
