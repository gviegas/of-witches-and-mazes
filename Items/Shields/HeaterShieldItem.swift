//
//  HeaterShieldItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/27/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Heater Shield, a shield.
///
class HeaterShieldItem: PassiveItem, TradableItem, AlterationItem, LevelItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.heaterShield.imageName]
    }

    let name: String = "Heater Shield"
    let icon: Icon = IconSet.Item.heaterShield
    let category: ItemCategory = .shield
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 38) }
    
    var alteration: Alteration
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: HeaterShieldItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let guaranteedValues: [AlterableStat: (value: ProgressionValue, ratio: Double)] = [
            .defense: (ProgressionValue(initialValue: 8, rate: 0), 0.5)]
        
        let possibleValues: [AlterableStat: (value: ProgressionValue, ratio: Double)] = [
            .ability(.strength): (ProgressionValue(initialValue: 1, rate: 0.2), 0.15),
            .ability(.agility): (ProgressionValue(initialValue: 1, rate: 0.2), 0.15),
            .ability(.intellect): (ProgressionValue(initialValue: 1, rate: 0.2), 0.15),
            .ability(.faith): (ProgressionValue(initialValue: 1, rate: 0.2), 0.15)]
        
        alteration = Alteration(guaranteedValues: guaranteedValues, possibleValues: possibleValues,
                                rolls: 1...2, level: level)
    }
    
    func copy() -> Item {
        return HeaterShieldItem(other: self)
    }
    
    func didEquip(onEntity entity: Entity) {
        alteration.apply(to: entity)
    }
    
    func didUnequip(onEntity entity: Entity) {
        alteration.remove(from: entity)
    }
}
