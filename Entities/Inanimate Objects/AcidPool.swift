//
//  AcidPool.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/25/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Acid Pool entity, an inanimate object.
///
class AcidPool: InanimateObject, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return AcidPoolAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return AcidPoolAnimationSet.textureNames
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = AcidPoolData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        component(ofType: SpriteComponent.self)!.animate(name: .trigger)
        
        // Set the DepthComponent
        component(ofType: DepthComponent.self)!.fixedDepth = DepthLayer.contents.lowerBound
        
        // AuraComponent
        let damage = Damage(scale: 1.05, ratio: 0.15, level: levelOfExperience, modifiers: [:], type: .natural,
                            sfx: SoundFXSet.FX.naturalHit)
        let soften = SoftenCondition(damageTakenIncrease: 0.35, isExclusive: true, isResettable: false,
                                     duration: 8.0, source: self, color: nil, sfx: nil)
        let aura = Aura(radius: 28.0, refreshTime: 0.3, alwaysInFront: false, affectedByDispel: false,
                        duration: nil, damage: damage, conditions: [soften], animation: nil, sfx: nil)
        addComponent(AuraComponent(interaction: .neutralEffect, aura: aura))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `InanimateObjectdData` of the `AcidPool` entity.
///
fileprivate class AcidPoolData: InanimateObjectData {
    
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
        name = "Acid Pool"
        size = CGSize(width: 64.0, height: 64.0)
        physicsShape = .rectangle(size: CGSize(width: 64.0, height: 64.0), center: .zero)
        interaction = .init()
        progressionValues = nil
        animationSet = AcidPoolAnimationSet()
    }
}
