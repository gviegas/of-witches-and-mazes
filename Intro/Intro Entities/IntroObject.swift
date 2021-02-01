//
//  IntroObject.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 4/6/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// The `InanimateObject` used in the intro.
///
class IntroObject: Barrel {
    
    /// The `Item` types associated with this entity.
    ///
    static let itemTypes: [Item.Type] = [GoldPiecesItem.self, CommonSwordItem.self, CutlassItem.self, TunicItem.self,
                                         HauberkItem.self, CuirassItem.self, CoralRingItem.self,
                                         AquamarineRingItem.self, AmethystRingItem.self]
    
    /// Creates a new instance with the given level of experience.
    ///
    /// - Parameter levelOfExperience: The entity's level of experience.
    ///
    init(levelOfExperience: Int) {
        super.init(levelOfExperience: levelOfExperience)
        
        // Set loot table
        component(ofType: LootComponent.self)?.lootTable = IntroObjectLootTable(levelOfExperience: levelOfExperience)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// The `CustomizedLootTable` subclass defining the loot table of the `IntroObject` entity.
///
fileprivate class IntroObjectLootTable: CustomizedLootTable {
    
    /// Creates a new instance from the given level of experience.
    ///
    /// - Parameter levelOfExperience: The level of experience for which to generate the loot table.
    ///
    init(levelOfExperience: Int) {
        let deviation = 1 + Int((Double(levelOfExperience) * 0.1).rounded())
        let range = EntityProgression.levelRange
        let level: () -> Int = {
            let rnd = Int.random(in: (levelOfExperience - deviation)...(levelOfExperience + deviation))
            return max(range.lowerBound, min(rnd, range.upperBound))
        }
        
        let items: [(Item, Double?)] = [
            (GoldPiecesItem(quantity: Int.random(in: 1...(1 + level() / 5))), 1.0),
            (CommonSwordItem(level: level()), 0.035),
            (CutlassItem(level: level()), 0.035),
            (TunicItem(level: level()), 0.035),
            (HauberkItem(level: level()), 0.035),
            (CuirassItem(level: level()), 0.035),
            (CoralRingItem(level: level()), 0.025),
            (AquamarineRingItem(level: level()), 0.025),
            (AmethystRingItem(level: level()), 0.025),
        ]
        
        super.init(items: items, rolls: 1...2, noDropChance: 0.6)
    }
}
