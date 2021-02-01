//
//  Npc.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/10/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A protocol that defines the data associated with a `Npc` instance, used to create
/// its components.
///
protocol NpcData {
    
    /// The name of the entity, expected to be unique.
    ///
    var name: String { get }
    
    /// The size.
    ///
    var size: CGSize { get }
    
    /// The speed.
    ///
    var speed: MovementSpeed { get }
    
    /// The `PhysicsShape`.
    ///
    var physicsShape: PhysicsShape { get }
    
    /// The `DirectionalAnimationSet`.
    ///
    var animationSet: DirectionalAnimationSet { get }
    
    /// The portrait.
    ///
    var portrait: Portrait { get }
    
    /// The size and file name of the shadow image.
    ///
    var shadow: (size: CGSize, image: String)? { get }
    
    /// The sound and volubleness of the entity's voice.
    ///
    var voice: (sound: SoundFX, volubleness: VoiceComponent.Volubleness)? { get }
}

extension NpcData {
    
    var size: CGSize {
        return CGSize(width: 64.0, height: 64.0)
    }
    
    var speed: MovementSpeed {
        return .normal
    }
    
    var physicsShape: PhysicsShape {
        return PhysicsShape.rectangle(size: CGSize(width: 32.0, height: 32.0), center: CGPoint(x: 0, y: -16.0))
    }
    
    var shadow: (size: CGSize, image: String)? {
        return (CGSize(width: 24.0, height: 16.0), "Shadow")
    }
}

/// The `Npc` entity.
///
class Npc: Entity {
    
    /// Creates a new instance from the given data and level.
    ///
    /// - Parameters:
    ///   - data: The `NpcData` associated with the entity.
    ///   - levelOfExperience: The entity's level of experience.
    ///
    init(data: NpcData, levelOfExperience: Int) {
        super.init(name: data.name)
        
        // NodeComponent
        addComponent(NodeComponent())
        
        // CursorResponderComponent
        addComponent(CursorResponderComponent(size: data.size))
        
        // SpriteComponent
        addComponent(SpriteComponent(size: data.size, animationSet: data.animationSet))
        
        // MovementComponent
        addComponent(MovementComponent(baseSpeed: data.speed.numericValue))
        
        // DirectionComponent
        let direction = [Direction.north, Direction.south, Direction.east, Direction.west].randomElement()!
        addComponent(DirectionComponent(direction: direction))
        
        // PhysicsComponent
        addComponent(PhysicsComponent(physicsShape: data.physicsShape, interaction: Interaction.npc))
        
        // DepthComponent
        addComponent(DepthComponent())
        
        // PortraitComponent
        addComponent(PortraitComponent(portrait: data.portrait))
        
        // SpeechComponent
        addComponent(SpeechComponent())
        
        // StatusBarComponent
        addComponent(StatusBarComponent(hidden: false))
        
        if let shadow = data.shadow {
            // ShadowComponent
            addComponent(ShadowComponent(size: shadow.size, imageName: shadow.image))
        }
        
        if let voice = data.voice {
            // VoiceComponent
            addComponent(VoiceComponent(voice: voice.sound, volubleness: voice.volubleness))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didAddToLevel(_ level: Level) {
        super.didAddToLevel(level)
        
        component(ofType: StateComponent.self)?.enterInitialState()
        component(ofType: SpriteComponent.self)?.animate(name: .idle)
    }
    
    override func willRemoveFromLevel(_ level: Level) {
        super.willRemoveFromLevel(level)
        
        component(ofType: NodeComponent.self)?.node.removeFromParent()
        willRemoveFromGame()
    }
}
