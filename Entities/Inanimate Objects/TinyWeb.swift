//
//  TinyWeb.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Tiny Web entity, an inanimate object.
///
class TinyWeb: InanimateObject, TextureUser {
    
    static var textureNames: Set<String> {
        return ["Web_Small"]
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = TinyWebData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let texture = TextureSource.createTexture(imageNamed: "Web_Small")
        component(ofType: SpriteComponent.self)!.texture = texture
        
        // Set the DepthComponent
        component(ofType: DepthComponent.self)!.fixedDepth = DepthLayer.contents.lowerBound
        
        // AuraComponent
        let slow = HamperCondition(slowFactor: 0.5, isExclusive: false, isResettable: true, duration: 1.0,
                                   source: self, color: nil, sfx: nil)
        let aura = Aura(radius: 14.0, refreshTime: 0.1, alwaysInFront: false, affectedByDispel: false,
                        duration: nil, damage: nil, conditions: [slow], animation: nil, sfx: nil)
        addComponent(AuraComponent(interaction: .neutralEffect, aura: aura))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `InanimateObjectdData` of the `TinyWeb` entity.
///
fileprivate class TinyWebData: InanimateObjectData {
    
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
        name = "TinyWeb"
        size = CGSize(width: 32.0, height: 32.0)
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 32.0), center: .zero)
        interaction = .init()
        progressionValues = nil
        animationSet = nil
    }
}
