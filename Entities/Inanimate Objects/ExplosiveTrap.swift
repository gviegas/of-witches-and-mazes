//
//  ExplosiveTrap.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Explosive Trap entity, an inanimate object.
///
class ExplosiveTrap: InanimateObject, PerceptionDelegate, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return ExplosiveTrapAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return ExplosiveTrapAnimation.textureNames.union(["Explosive_Trap"])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = ExplosiveTrapData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let texture = TextureSource.createTexture(imageNamed: "Explosive_Trap")
        component(ofType: SpriteComponent.self)!.texture = texture
        
        // PerceptionComponent
        addComponent(PerceptionComponent(interaction: .neutralEffectOnEffect, radius: 24.0, delegate: self))
        
        // BlastComponent
        let damage = Damage(scale: 7.35, ratio: 0.25, level: levelOfExperience, modifiers: [:],
                            type: .physical, sfx: SoundFXSet.FX.hit)
        let animation = ExplosiveTrapAnimation().animation
        let blast = Blast(medium: .gadget,
                          initialSize: CGSize(width: 64.0, height: 64.0),
                          finalSize: CGSize(width: 128.0, height: 128.0),
                          range: 0,
                          delay: 0, duration: animation.1!.duration!, conclusion: 0,
                          damage: damage, conditions: nil,
                          animation: animation, sfx: SoundFXSet.FX.explosion)
        addComponent(BlastComponent(interaction: .neutralEffect, blast: blast))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didPerceiveTarget(_ target: Entity) {
        guard let nodeComponent = component(ofType: NodeComponent.self),
            let physicsComponent = component(ofType: PhysicsComponent.self),
            let perceptionComponent = component(ofType: PerceptionComponent.self),
            let blastComponent = component(ofType: BlastComponent.self),
            blastComponent.blast != nil
            else { return }
        
        // Detach perception node, remove physics body, cause blast and nullify blast instance
        perceptionComponent.detach()
        physicsComponent.remove()
        blastComponent.causeBlast(at: nodeComponent.node.position)
        blastComponent.blast = nil
        
        // Fade out the main node and remove self from level
        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
        let removeSelf = SKAction.run {
            [unowned self] in
            self.level?.removeFromSublevel(entity: self)
        }
        nodeComponent.node.run(SKAction.sequence([fadeOut, removeSelf]))
    }
}

/// The `InanimateObjectdData` of the `ExplosiveTrap` entity.
///
fileprivate class ExplosiveTrapData: InanimateObjectData {
    
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
        name = "Explosive Trap"
        size = CGSize(width: 32.0, height: 32.0)
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 24.0), center: CGPoint(x: 0, y: -4.0))
        interaction = .trap
        progressionValues = nil
        animationSet = nil
    }
}

/// The struct defining the `ExplosiveTrap`'s explosion animation.
///
fileprivate struct ExplosiveTrapAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key]
    }
    
    static var textureNames: Set<String> {
        let standard = ImageArray.createFrom(baseName: "Explosion_", first: 1, last: 12)
        return Set<String>(standard)
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        animation = (nil, standard, nil)
    }
    
    private class Standard: TextureAnimation {
        static let key = "ExplosiveTrapAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Explosion_", first: 1, last: 12)
            super.init(images: images, timePerFrame: 0.067, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
}
