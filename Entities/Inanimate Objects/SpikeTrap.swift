//
//  SpikeTrap.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/24/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Spike Trap entity, an inanimate object.
///
class SpikeTrap: InanimateObject, InteractionDelegate, Disarmable, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return SpikeTrapAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return SpikeTrapAnimationSet.textureNames
    }
    
    /// The level and grade values defining the difficult of the trap.
    ///
    private let difficult: (level: Int, grade: Double)
    
    var isDisarmed: Bool {
        return component(ofType: StateComponent.self)?.currentState is SpikeTrapDisarmedState
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        difficult = (levelOfExperience, 1.0)
        let data = SpikeTrapData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let texture = TextureSource.createTexture(imageNamed: "Spike_Trap_1")
        component(ofType: SpriteComponent.self)!.texture = texture
        
        // StateComponent
        let standardState = SpikeTrapStandardState(entity: self)
        standardState.triggerDelay = .random(in: 1.0...5.0)
        addComponent(StateComponent(initialState: SpikeTrapStandardState.self,
                                    states: [(standardState, .standard),
                                             (SpikeTrapDisarmedState(entity: self), nil)]))
        
        // InteractionComponent
        addComponent(InteractionComponent(interaction: Interaction(contactGroups: [.protagonist]),
                                          radius: 24.0, text: "Disarm", delegate: self))
        
        // BlastComponent
        let damage = Damage(scale: 3.5, ratio: 0.3, level: levelOfExperience, modifiers: [:],
                            type: .physical, sfx: SoundFXSet.FX.hit)
        let blast = Blast(medium: .none,
                          initialSize: CGSize(width: 20.0, height: 20.0),
                          finalSize: CGSize(width: 20.0, height: 20.0),
                          range: 32.0,
                          delay: 0, duration: 1.0, conclusion: 0,
                          damage: damage, conditions: nil,
                          animation: nil, sfx: nil)
        addComponent(BlastComponent(interaction: .neutralEffect, blast: blast))
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
        if component(ofType: StateComponent.self)?.enter(stateClass: SpikeTrapDisarmedState.self) ?? false {
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

/// The `InanimateObjectdData` of the `SpikeTrap` entity.
///
fileprivate class SpikeTrapData: InanimateObjectData {
    
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
        name = "Spike Trap"
        size = CGSize(width: 32.0, height: 32.0)
        physicsShape = .rectangle(size: CGSize(width: 24.0, height: 1.0), center: CGPoint(x: 0, y: 4.0))
        interaction = .init()
        progressionValues = nil
        animationSet = SpikeTrapAnimationSet()
    }
}
