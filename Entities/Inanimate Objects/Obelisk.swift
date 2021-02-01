//
//  Obelisk.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/28/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Obelisk entity, an inanimate object.
///
class Obelisk: InanimateObject, InteractionDelegate, Disarmable, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return ObeliskAnimationSet.animationKeys.union(PrismaticMissileAnimation.animationKeys)
    }
    
    static var textureNames: Set<String> {
        return ObeliskAnimationSet.textureNames.union(PrismaticMissileAnimation.textureNames)
    }
    
    /// The level and grade values defining the difficult of the trap.
    ///
    private let difficult: (level: Int, grade: Double)
    
    var isDisarmed: Bool {
        return component(ofType: StateComponent.self)?.currentState is ObeliskDisarmedState
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        difficult = (levelOfExperience, 1.3)
        let data = ObeliskData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let texture = TextureSource.createTexture(imageNamed: "Obelisk_1")
        component(ofType: SpriteComponent.self)!.texture = texture
        
        // StateComponent
        addComponent(StateComponent(initialState: ObeliskStandardState.self,
                                    states: [(ObeliskStandardState(entity: self), .standard),
                                             (ObeliskDisarmedState(entity: self), nil)]))
        
        // InteractionComponent
        addComponent(InteractionComponent(interaction: Interaction(contactGroups: [.protagonist]),
                                          radius: 48.0, text: "Disarm", delegate: self))
        
        // MissileComponent
        let damage = Damage(scale: 5.4, ratio: 0.2, level: levelOfExperience, modifiers: [:], type: .magical,
                            sfx: SoundFXSet.FX.magicalHit)
        let missile = Missile(medium: .spell, range: 630.0, speed: 224.0,
                              size: CGSize(width: 32.0, height: 32.0),
                              delay: .random(in: 2.0...7.0), conclusion: 0, dissipateOnHit: false,
                              damage: damage, conditions: nil,
                              animation: PrismaticMissileAnimation().animation,
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
        if component(ofType: StateComponent.self)?.enter(stateClass: ObeliskDisarmedState.self) ?? false {
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

/// The `InanimateObjectdData` of the `Obelisk` entity.
///
fileprivate class ObeliskData: InanimateObjectData {
    
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
        name = "Obelisk"
        size = CGSize(width: 32.0, height: 64.0)
        physicsShape = .rectangle(size: CGSize(width: 24.0, height: 16.0), center: CGPoint(x: 0, y: -24))
        interaction = .trap
        progressionValues = nil
        animationSet = ObeliskAnimationSet()
    }
}

/// The struct that defines the animations for the `Obelisk`'s missile.
///
fileprivate struct PrismaticMissileAnimation: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return [Beginning.key, Standard.key, End.key]
    }
    
    static var textureNames: Set<String> {
        let beginning = ImageArray.createFrom(baseName: "Orbital_Projectile_Beginning_", first: 1, last: 6)
        let standard = ImageArray.createFrom(baseName: "Orbital_Projectile_", first: 1, last: 6)
        let end = ImageArray.createFrom(baseName: "Orbital_Projectile_End_", first: 1, last: 6)
        return Set<String>(beginning + standard + end)
    }
    
    /// The tuple containing the animations.
    ///
    let animation: (Animation?, Animation?, Animation?)
    
    init() {
        let beginning = AnimationSource.getAnimation(forKey: Beginning.key) ?? Beginning()
        let standard = AnimationSource.getAnimation(forKey: Standard.key) ?? Standard()
        let end = AnimationSource.getAnimation(forKey: End.key) ?? End()
        animation = (beginning, standard, end)
    }
    
    private class Beginning: TextureAnimation {
        static let key = "PrismaticMissileAnimation.Beginning"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Orbital_Projectile_Beginning_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.083, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: Beginning.key)
            
        }
    }
    
    private class Standard: TextureAnimation {
        static let key = "PrismaticMissileAnimation.Standard"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Orbital_Projectile_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.083, replaceable: true, flipped: false, repeatForever: true)
            AnimationSource.storeAnimation(self, forKey: Standard.key)
        }
    }
    
    private class End: TextureAnimation {
        static let key = "PrismaticMissileAnimation.End"
        
        init() {
            let images = ImageArray.createFrom(baseName: "Orbital_Projectile_End_", first: 1, last: 6)
            super.init(images: images, timePerFrame: 0.083, replaceable: true, flipped: false, repeatForever: false)
            AnimationSource.storeAnimation(self, forKey: End.key)
        }
    }
}
