//
//  LavaPool.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Lava Pool entity, an inanimate object.
///
class LavaPool: InanimateObject, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return LavaPoolAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return LavaPoolAnimationSet.textureNames
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = LavaPoolData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        component(ofType: SpriteComponent.self)!.animate(name: .trigger)
        
        // Set the DepthComponent
        component(ofType: DepthComponent.self)!.fixedDepth = DepthLayer.contents.lowerBound
        
        // AuraComponent
        let damage = Damage(scale: 1.75, ratio: 0.15, level: levelOfExperience, modifiers: [:], type: .natural,
                            sfx: SoundFXSet.FX.naturalHit)
        let aura = Aura(radius: 28.0, refreshTime: 0.3, alwaysInFront: false, affectedByDispel: false,
                        duration: nil, damage: damage, conditions: nil, animation: nil, sfx: nil)
        addComponent(AuraComponent(interaction: .neutralEffect, aura: aura))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `InanimateObjectdData` of the `LavaPool` entity.
///
fileprivate class LavaPoolData: InanimateObjectData {
    
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
        name = "Lava Pool"
        size = CGSize(width: 64.0, height: 64.0)
        physicsShape = .rectangle(size: CGSize(width: 64.0, height: 64.0), center: .zero)
        interaction = .init()
        progressionValues = nil
        animationSet = LavaPoolAnimationSet()
    }
}
