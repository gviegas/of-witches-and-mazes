//
//  Chest.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/18/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Chest entity, an inanimate object.
///
class Chest: InanimateObject, InteractionDelegate, ActionDelegate, Disarmable, TextureUser {
    
    static var textureNames: Set<String> {
        return ["Chest", "Chest_Open"]
    }
    
    var isDisarmed: Bool {
        return !isLocked
    }
    
    /// The flag stating whether the chest is locked.
    ///
    private var isLocked = true
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = ChestData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // Set the SpriteComponent
        let texture = TextureSource.createTexture(imageNamed: "Chest")
        component(ofType: SpriteComponent.self)!.texture = texture
        
        // InteractionComponent
        addComponent(InteractionComponent(interaction: Interaction(contactGroups: [.protagonist]),
                                          radius: 20.0, text: "Unlock", delegate: self))
        
        // LootComponent
        addComponent(LootComponent(lootTable: UniversalLootTable(quality: .superior,
                                                                 level: levelOfExperience)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Unlocks the chest.
    ///
    private func unlock() {
        guard isLocked else { return }
        isLocked = false
        
        // Remove interaction node
        component(ofType: InteractionComponent.self)?.detach()
        
        // Change to Chest Open texture
        component(ofType: SpriteComponent.self)?.texture = TextureSource.getTexture(forKey: "Chest_Open")
        
        // Drop Loot
        let _ = component(ofType: LootComponent.self)?.drop()
        
        // Play sound effect
        if let nodeComponent = component(ofType: NodeComponent.self) {
            SoundFXSet.FX.preciousItem.play(at: nodeComponent.node.position, sceneKind: .level)
        }
        
        // Present note
        if let scene = SceneManager.levelScene {
            let note = NoteOverlay(rect: scene.frame, text: "Unlocked")
            scene.presentNote(note)
        }
    }
    
    func didInteractWith(entity: Entity) {
        guard isLocked else { return }
        guard let inventoryComponent = entity.component(ofType: InventoryComponent.self) else { return }
        guard let stateComponent = entity.component(ofType: StateComponent.self) else { return }
        guard let actionComponent = entity.component(ofType: ActionComponent.self) else { return }
        guard stateComponent.canEnter(namedState: .use) else { return }
        
        if let disarmDeviceComponent = entity.component(ofType: DisarmDeviceComponent.self) {
            disarmDeviceComponent.disarm(device: self)
        } else if inventoryComponent.removeItem(named: "Key") {
            actionComponent.action = Action(delay: 1.0, duration: 0, conclusion: 0.4, sfx: nil)
            actionComponent.subject = self
            actionComponent.delegate = self
            stateComponent.enter(namedState: .use)
        } else {
            // No key in the inventory, present note
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "No keys")
                scene.presentNote(note)
            }
        }
    }
    
    func didAct(_ action: Action, entity: Entity) {
        unlock()
    }
    
    func didDisarm(agent: Entity) {
        unlock()
    }
}

/// The `InanimateObjectdData` of the `Chest` entity.
///
fileprivate class ChestData: InanimateObjectData {
    
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
        name = "Chest"
        size = CGSize(width: 32.0, height: 32.0)
        physicsShape = .rectangle(size: CGSize(width: 32.0, height: 24.0), center: CGPoint(x: 0, y: -4.0))
        interaction = .obstacle
        progressionValues = nil
        animationSet = nil
    }
}
