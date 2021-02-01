//
//  LostLenore.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/15/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// The Lost Lenore entity, a NPC.
///
class LostLenore: Npc, InteractionDelegate, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return LostLenoreAnimationSet.animationKeys
    }
    
    static var textureNames: Set<String> {
        return LostLenoreAnimationSet.textureNames.union([PortraitSet.lostLenore.imageName])
    }
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        let data = LostLenoreData(levelOfExperience: levelOfExperience)
        super.init(data: data, levelOfExperience: levelOfExperience)
        
        // InventoryComponent
        let items: [Item] = TradingLootTable(level: levelOfExperience).generateLoot()
        addComponent(InventoryComponent(capacity: 90, items: items))
        
        // VendorComponent
        addComponent(VendorComponent(funds: levelOfExperience * 1000 * Int.random(in: 1...10),
                                     sellFactor: 2.3, buyFactor: 0.2, ceiling: 999_999))
        
        // InteractionComponent
        addComponent(InteractionComponent(interaction: Interaction(contactGroups: [.protagonist]),
                                          radius: 56.0, text: "Talk", delegate: self))
        
        // DialogComponent
        addComponent(DialogComponent(textSource: LostLenoreDialog.textSource))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didInteractWith(entity: Entity) {
        // Attempts to look towards the entity
        if let a = self.component(ofType: PhysicsComponent.self)?.position,
            let b = entity.component(ofType: PhysicsComponent.self)?.position {
            
            let p = CGPoint(x: b.x - a.x, y: b.y - a.y)
            component(ofType: DirectionComponent.self)?.direction = .fromAngle(atan2(p.y, p.x))
            component(ofType: SpriteComponent.self)?.animate(name: .idle)
        }
        
        // Enter dialog state
        entity.component(ofType: StateComponent.self)?.enter(stateClass: DialogState.self)
        
        // Utter
        component(ofType: VoiceComponent.self)?.utterByChance()
    }
}

/// The `NpcData` of the `LostLenore` entity.
///
fileprivate class LostLenoreData: NpcData {
    
    let name: String
    let animationSet: DirectionalAnimationSet
    let portrait: Portrait
    let voice: (sound: SoundFX, volubleness: VoiceComponent.Volubleness)?
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        name = "Lost Lenore"
        animationSet = LostLenoreAnimationSet()
        portrait = PortraitSet.lostLenore
        voice = (SoundFXSet.Voice.lonePrincess, .low)
    }
}

/// A struct holding the `WeightedDistribution` to use for the `LostLenore`'s `DialogComponent`.
///
fileprivate struct LostLenoreDialog {
    
    private init() {}
    
    /// The distribution.
    ///
    static let textSource = WeightedDistribution<String>(values: [
        ("...", 1.0),
        ("Greetings.", 0.01),
        ("Take your time.", 0.01),
        ("I believe in you.", 0.005),
        ("The next portal may be the last.", 0.005),
        ("Do not lose heart.", 0.005),
        ("I am different from other witches, and there is nothing wrong with that.", 0.005),
        ("We are both lost now.", 0.005),
        ("Leave my loneliness unbroken.", 0.005),
        ("You should stay clear of walls when tossing things.", 0.005),
        ("These gloomy pools are very unpleasant.", 0.005),
        ("Mushrooms are not capable of destroying objects, but they will try anyway.", 0.005),
        ("When you dispel the aura from a mushroom, it becomes inoffensive.", 0.005),
        ("There is a book that describes how to cast a curse, like witches do. It is very rare, though.", 0.005),
        ("I hope I am not repeating myself too much.", 0.005)])
}
