//
//  AquamarineRingItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Aquamarine Ring, a jewel.
///
class AquamarineRingItem: PassiveItem, TradableItem, AlterationItem, LevelItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.aquamarineRing.imageName]
    }
    
    let name: String = "Aquamarine Ring"
    let icon: Icon = IconSet.Item.aquamarineRing
    let category: ItemCategory = .jewel
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 63) }
    
    var alteration: Alteration
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: AquamarineRingItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let possibleScales: [AlterableStat: (scale: Double, ratio: Double)] = [
            .health: (1.65, 0.15),
            .mitigation: (0.45, 0.15),
            .critical(.melee): (0.175, 0.15),
            .critical(.ranged): (0.175, 0.15),
            .critical(.spell): (0.175, 0.15),
            .damageCaused(.physical): (0.175, 0.15),
            .damageCaused(.magical): (0.175, 0.15),
            .damageCaused(.spiritual): (0.175, 0.15),
            .damageCaused(.natural): (0.175, 0.15),]
        
        alteration = Alteration(guaranteedScales: [:], possibleScales: possibleScales,
                                rolls: 1...3, level: level)
    }
    
    func copy() -> Item {
        return AquamarineRingItem(other: self)
    }
    
    func didEquip(onEntity entity: Entity) {
        alteration.apply(to: entity)
    }
    
    func didUnequip(onEntity entity: Entity) {
        alteration.remove(from: entity)
    }
}
