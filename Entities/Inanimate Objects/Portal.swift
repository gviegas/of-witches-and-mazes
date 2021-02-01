//
//  Portal.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/11/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

import SpriteKit

/// The Portal entity, an inanimate object.
///
class Portal: InanimateObject, InteractionDelegate, ActionDelegate, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return PortalAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return PortalAnimationSet.textureNames
    }
    
    /// The flag stating whether the portal is being used.
    ///
    private var isUsing = false
    
    /// Creates a new instance.
    ///
    init() {
        let data = PortalData()
        super.init(data: data, levelOfExperience: 1)
        
        // Set SpriteComponent
        let spriteComponent = component(ofType: SpriteComponent.self)!
        spriteComponent.animate(name: .idle)
        
        // InteractionComponent
        addComponent(InteractionComponent(interaction: Interaction(contactGroups: [.protagonist]),
                                          radius: 72.0, text: "Enter Portal", delegate: self))
        
        // StatusBarComponent
        addComponent(StatusBarComponent(hidden: false))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func didInteractWith(entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else { return }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else { return }
        guard stateComponent.canEnter(namedState: .use) else { return }
        
        actionComponent.action = Action(delay: 1.3, duration: 0, conclusion: 0.4, sfx: nil)
        actionComponent.subject = self
        actionComponent.delegate = self
        stateComponent.enter(namedState: .use)
    }
    
    func didAct(_ action: Action, entity: Entity) {
        guard let scene = SceneManager.levelScene else { return }
        
        component(ofType: InteractionComponent.self)?.detach()
        scene.completeCurrentStage()
    }
}

/// The `InanimateObjectdData` of the `Portal` entity.
///
fileprivate class PortalData: InanimateObjectData {
    
    let name: String
    let size: CGSize
    let physicsShape: PhysicsShape
    let interaction: Interaction
    let progressionValues: EntityProgressionValues?
    let animationSet: DirectionalAnimationSet?
    
    /// Creates a new instance.
    ///
    init() {
        name = "Portal"
        size = CGSize(width: 96.0, height: 96.0)
        physicsShape = .rectangle(size: CGSize(width: 48.0, height: 32.0), center: CGPoint(x: 0, y: -32.0))
        interaction = .obstacle
        progressionValues = nil
        animationSet = PortalAnimationSet()
    }
}
