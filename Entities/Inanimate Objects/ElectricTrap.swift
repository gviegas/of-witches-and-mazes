//
//  ElectricTrap.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Electric Trap entity, an inanimate object.
///
class ElectricTrap: InanimateObject, PerceptionDelegate, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return ElectricTrapAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return ElectricTrapAnimation.textureNames.union(["Electric_Trap"])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = ElectricTrapData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let texture = TextureSource.createTexture(imageNamed: "Electric_Trap")
        component(ofType: SpriteComponent.self)!.texture = texture
        
        // PerceptionComponent
        addComponent(PerceptionComponent(interaction: .neutralEffectOnEffect, radius: 24.0, delegate: self))
        
        // BlastComponent
        let damage = Damage(scale: 7.0, ratio: 0.25, level: levelOfExperience, modifiers: [:], type: .natural,
                            sfx: SoundFXSet.FX.energyHit)
        let animation = ElectricTrapAnimation().animation
        let blast = Blast(medium: .gadget,
                          initialSize: CGSize(width: 0, height: 0),
                          finalSize: CGSize(width: 72.0, height: 72.0),
                          range: 128.0,
                          delay: 0, duration: animation.1!.duration!, conclusion: 0,
                          damage: damage, conditions: nil,
                          animation: animation, sfx: nil)
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
        let (x, y) = (nodeComponent.node.position.x, nodeComponent.node.position.y)
        let (w, h) = (blastComponent.blast!.finalSize.width, blastComponent.blast!.finalSize.height)
        blastComponent.causeBlast(at: nodeComponent.node.position)
        blastComponent.causeBlast(at: CGPoint(x: x - w, y: y + h))
        blastComponent.causeBlast(at: CGPoint(x: x - w, y: y - h))
        blastComponent.causeBlast(at: CGPoint(x: x + w, y: y - h))
        blastComponent.causeBlast(at: CGPoint(x: x + w, y: y + h))
        blastComponent.blast = nil
        
        // Play sound effect only once
        SoundFXSet.FX.energy.play(at: nodeComponent.node.position, sceneKind: .level)
        
        // Fade out the main node and remove self from level
        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
        let removeSelf = SKAction.run {
            [unowned self] in
            self.level?.removeFromSublevel(entity: self)
        }
        nodeComponent.node.run(SKAction.sequence([fadeOut, removeSelf]))
    }
}

/// The `InanimateObjectdData` of the `ElectricTrap` entity.
///
fileprivate class ElectricTrapData: InanimateObjectData {
    
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
        name = "Electric Trap"
        size = CGSize(width: 32.0, height: 32.0)
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 24.0), center: CGPoint(x: 0, y: -4.0))
        interaction = .trap
        progressionValues = nil
        animationSet = nil
    }
}

/// The struct defining the `ElectricTrap`'s lightning animation.
///
fileprivate struct ElectricTrapAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Standard.key]
    }
    
    static var textureNames: Set<String> {
        let standard = ImageArray.createFrom(baseName: "Lightning_", first: 1, last: 10)
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
        static let key = "ElectricTrapAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Lightning_", first: 1, last: 10)
            super.init(images: images, timePerFrame: 0.05, replaceable: false, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
}
