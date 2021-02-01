//
//  CurePool.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Cure Pool entity, an inanimate object.
///
class CurePool: InanimateObject, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return CurePoolAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return CurePoolAnimationSet.textureNames
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = CurePoolData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        component(ofType: SpriteComponent.self)!.animate(name: .trigger)
        
        // Set the DepthComponent
        component(ofType: DepthComponent.self)!.fixedDepth = DepthLayer.contents.lowerBound
        
        // AuraComponent
        let healing = Healing(scale: 1.85, ratio: 0.1, level: levelOfExperience, modifiers: [:],
                             sfx: SoundFXSet.FX.liquid)
        let aura = Aura(radius: 28.0, refreshTime: 0.6, alwaysInFront: false, affectedByDispel: false,
                        duration: nil, healing: healing, conditions: nil, animation: nil, sfx: nil)
        addComponent(AuraComponent(interaction: .neutralEffect, aura: aura))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `InanimateObjectdData` of the `CurePool` entity.
///
fileprivate class CurePoolData: InanimateObjectData {
    
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
        name = "Cure Pool"
        size = CGSize(width: 64.0, height: 64.0)
        physicsShape = .rectangle(size: CGSize(width: 64.0, height: 64.0), center: .zero)
        interaction = .init()
        progressionValues = nil
        animationSet = CurePoolAnimationSet()
    }
}
