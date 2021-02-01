//
//  Web.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/26/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Web entity, an inanimate object.
///
class Web: InanimateObject, TextureUser {
    
    static var textureNames: Set<String> {
        return ["Web_Medium"]
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = WebData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let texture = TextureSource.createTexture(imageNamed: "Web_Medium")
        component(ofType: SpriteComponent.self)!.texture = texture
        
        // Set the DepthComponent
        component(ofType: DepthComponent.self)!.fixedDepth = DepthLayer.contents.lowerBound
        
        // AuraComponent
        let slow = HamperCondition(slowFactor: 0.8, isExclusive: false, isResettable: true, duration: 1.3,
                                   source: self, color: nil, sfx: nil)
        let aura = Aura(radius: 28.0, refreshTime: 0.1, alwaysInFront: false, affectedByDispel: false,
                        duration: nil, damage: nil, conditions: [slow], animation: nil, sfx: nil)
        addComponent(AuraComponent(interaction: .neutralEffect, aura: aura))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `InanimateObjectdData` of the `Web` entity.
///
fileprivate class WebData: InanimateObjectData {
    
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
        name = "Web"
        size = CGSize(width: 64.0, height: 64.0)
        physicsShape = .rectangle(size: CGSize(width: 64.0, height: 64.0), center: .zero)
        interaction = .init()
        progressionValues = nil
        animationSet = nil
    }
}
