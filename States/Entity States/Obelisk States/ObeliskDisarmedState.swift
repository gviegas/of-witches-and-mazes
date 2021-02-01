//
//  ObeliskDisarmedState.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 8/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//
import GameplayKit

/// An `EntityState` subclass representing the state of a `Obelisk` when disarmed.
///
class ObeliskDisarmedState: EntityState {
    
    private var nodeComponent: NodeComponent {
        guard let component = entity.component(ofType: NodeComponent.self) else {
            fatalError("An entity assigned to ObeliskDisarmedState must have a NodeComponent")
        }
        return component
    }
    
    private var spriteComponent: SpriteComponent {
        guard let component = entity.component(ofType: SpriteComponent.self) else {
            fatalError("An entity assigned to ObeliskDisarmedState must have a SpriteComponent")
        }
        return component
    }
    
    private var interactionComponent: InteractionComponent {
        guard let component = entity.component(ofType: InteractionComponent.self) else {
            fatalError("An entity assigned to ObeliskDisarmedState must have an InteractionComponent")
        }
        return component
    }
    
    override func didEnter(from previousState: GKState?) {
        spriteComponent.texture = TextureSource.getTexture(forKey: "Obelisk_1")
        interactionComponent.detach()
        SoundFXSet.FX.disarm.play(at: nodeComponent.node.position, sceneKind: .level)
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
}
