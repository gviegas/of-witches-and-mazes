//
//  GoldRingItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/27/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Gold Ring, a jewel.
///
class GoldRingItem: PassiveItem, TradableItem, AlterationItem, LevelItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.goldRing.imageName]
    }
    
    let name: String = "Gold Ring"
    let icon: Icon = IconSet.Item.goldRing
    let category: ItemCategory = .jewel
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 100) }
    
    var alteration: Alteration
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: GoldRingItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let possibleScales: [AlterableStat: (scale: Double, ratio: Double)] = [
            .health: (1.65, 0.15),
            .critical(nil): (0.125, 0.15),
            .damageCaused(nil): (0.125, 0.15),
            .ability(.strength): (0.25, 0.15),
            .ability(.agility): (0.25, 0.15),
            .ability(.intellect): (0.25, 0.15),
            .ability(.faith): (0.25, 0.15),
            .mitigation: (0.45, 0.15)]
        
        alteration = Alteration(guaranteedScales: [:], possibleScales: possibleScales,
                                rolls: 3...3, level: level)
    }
    
    func copy() -> Item {
        return GoldRingItem(other: self)
    }
    
    func didEquip(onEntity entity: Entity) {
        alteration.apply(to: entity)
    }
    
    func didUnequip(onEntity entity: Entity) {
        alteration.remove(from: entity)
    }
}
