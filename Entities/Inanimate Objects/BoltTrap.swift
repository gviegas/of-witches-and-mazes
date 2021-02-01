//
//  BoltTrap.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/27/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Bolt Trap entity, an inanimate object.
///
class BoltTrap: InanimateObject, InteractionDelegate, Disarmable, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return BoltAnimation.animationKeys
    }
    
    static var textureNames: Set<String> {
        return BoltAnimation.textureNames.union(["Bolt_Trap"])
    }
    
    /// The level and grade values defining the difficult of the trap.
    ///
    private let difficult: (level: Int, grade: Double)
    
    var isDisarmed: Bool {
        return component(ofType: StateComponent.self)?.currentState is BoltTrapDisarmedState
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        difficult = (levelOfExperience, 1.15)
        let data = BoltTrapData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let texture = TextureSource.createTexture(imageNamed: "Bolt_Trap")
        component(ofType: SpriteComponent.self)!.texture = texture
        
        // StateComponent
        addComponent(StateComponent(initialState: BoltTrapStandardState.self,
                                    states: [(BoltTrapStandardState(entity: self), .standard),
                                             (BoltTrapDisarmedState(entity: self), nil)]))
        
        // InteractionComponent
        addComponent(InteractionComponent(interaction: Interaction(contactGroups: [.protagonist]),
                                          radius: 48.0, text: "Disarm", delegate: self))
        
        // MissileComponent
        let damage = Damage(scale: 3.5, ratio: 0.3, level: levelOfExperience, modifiers: [:],
                            type: .physical, sfx: SoundFXSet.FX.genericHit)
        let missile = Missile(medium: .ranged, range: 735.0, speed: 512.0,
                              size: CGSize(width: 16.0, height: 6.0),
                              delay: .random(in: 1.0...5.0), conclusion: 0,
                              dissipateOnHit: true,
                              damage: damage, conditions: nil,
                              animation: (nil, BoltAnimation.instance, nil),
                              sfx: nil)
        addComponent(MissileComponent(interaction: .neutralEffectOnObstacleExcludingTrap, missile: missile))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didInteractWith(entity: Entity) {
        guard let disarmDeviceComponent = entity.component(ofType: DisarmDeviceComponent.self) else {
            // Entity is not able to disarm
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "Cannot disarm")
                scene.presentNote(note)
            }
            return
        }
        
        disarmDeviceComponent.disarm(device: self)
    }
    
    func didDisarm(agent: Entity) {
        if component(ofType: StateComponent.self)?.enter(stateClass: BoltTrapDisarmedState.self) ?? false {
            // Disarmed, present note
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "Disarmed")
                scene.presentNote(note)
            }
            // Award XP
            EntityProgression.awardXP(to: agent, rewardLevel: difficult.level, rewardGrade: difficult.grade)
        }
    }
}

/// The `InanimateObjectdData` of the `BoltTrap` entity.
///
fileprivate class BoltTrapData: InanimateObjectData {
    
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
        name = "Bolt Trap"
        size = CGSize(width: 64.0, height: 64.0)
        physicsShape = .rectangle(size: CGSize(width: 56.0, height: 56.0), center: .zero)
        interaction = .trap
        progressionValues = nil
        animationSet = nil
    }
}

/// An `Animation` type that defines the bolt animation.
///
fileprivate class BoltAnimation: Animation, TextureUser, AnimationUser {
    private static let key = "BoltAnimation"
    
    static var animationKeys: Set<String> {
        return [key]
    }
    
    static var textureNames: Set<String> {
        return ["Bolt"]
    }
    
    /// The instance of the class.
    ///
    static var instance: Animation {
        return AnimationSource.getAnimation(forKey: key) ?? BoltAnimation()
    }
    
    let replaceable: Bool = true
    let duration: TimeInterval? = nil
    
    private init() {
        AnimationSource.storeAnimation(self, forKey: BoltAnimation.key)
    }
    
    func play(node: SKNode) {
        guard let node = node as? SKSpriteNode else { return }
        
        let texture = TextureSource.createTexture(imageNamed: "Bolt")
        node.texture = texture
        node.size = texture.size()
    }
}
