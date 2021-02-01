//
//  IntroEnemy.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/3/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The `Monster` used in the intro.
///
class IntroEnemy: Rat {
    
    /// The `Item` types associated with this entity.
    ///
    static let itemTypes: [Item.Type] = [HauberkItem.self, GoldRingItem.self, GoldPiecesItem.self]
    
    /// The original perception intereaction.
    ///
    private var perceptionInteraction: Interaction?
    
    /// Creates a new instance from the given level of experience and able or unable to detect
    /// targets at first.
    ///
    /// - Parameters:
    ///   - levelOfExperience: The entity's level of experience.
    ///   - unaware: A flag stating whether or not the entity is able to perceive others at first.
    ///
    init(levelOfExperience: Int, unaware: Bool) {
        super.init(levelOfExperience: levelOfExperience)
        
        let lootTable: LootTable
        if unaware {
            makeUnaware()
            lootTable = CustomizedLootTable(
                items: [(HauberkItem(level: Game.levelOfExperience ?? levelOfExperience), nil)],
                rolls: 1...1, noDropChance: 0)
        } else {
            let level = Game.levelOfExperience ?? levelOfExperience
            lootTable = CustomizedLootTable(
                items: [(GoldPiecesItem(quantity: Int.random(in: 1...6)), 1.0), (GoldRingItem(level: level), 0.1)],
                rolls: 1...1, noDropChance: 0.5)
        }
        component(ofType: LootComponent.self)?.lootTable = lootTable
        component(ofType: MovementComponent.self)?.modifyMultiplier(by: -0.35)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Makes the entity unable to perceive targets.
    ///
    func makeUnaware() {
        guard perceptionInteraction == nil,
            let perceptionComponent = component(ofType: PerceptionComponent.self)
            else { return }
        
        perceptionInteraction = perceptionComponent.interaction
        let unawareInteraction = Interaction(category: perceptionInteraction!.category,
                                             collisionGroups: perceptionInteraction!.collisionGroups,
                                             contactGroups: [])
        perceptionComponent.interaction = unawareInteraction
    }
    
    /// Makes the entity able to perceive targets.
    ///
    func makeAware() {
        guard let perceptionInteraction = perceptionInteraction,
            let perceptionComponent = component(ofType: PerceptionComponent.self)
            else { return }
        
        perceptionComponent.interaction = perceptionInteraction
        self.perceptionInteraction = nil
    }
}
