//
//  OvalShieldItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Oval Shield, a shield.
///
class OvalShieldItem: PassiveItem, TradableItem, AlterationItem, LevelItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.ovalShield.imageName]
    }
    
    let name: String = "Oval Shield"
    let icon: Icon = IconSet.Item.ovalShield
    let category: ItemCategory = .shield
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 36) }
    
    var alteration: Alteration
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: OvalShieldItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let guaranteedValues: [AlterableStat: (value: ProgressionValue, ratio: Double)] = [
            .defense: (ProgressionValue(initialValue: 8, rate: 0), 0.5),
            .ability(.strength): (ProgressionValue(initialValue: 1, rate: 0.3), 0.15)]
        
        let possibleValues: [AlterableStat: (value: ProgressionValue, ratio: Double)] = [
            .ability(.agility): (ProgressionValue(initialValue: 1, rate: 0.1), 0.15),
            .ability(.intellect): (ProgressionValue(initialValue: 1, rate: 0.1), 0.15),
            .ability(.faith): (ProgressionValue(initialValue: 1, rate: 0.1), 0.15)]
        
        alteration = Alteration(guaranteedValues: guaranteedValues, possibleValues: possibleValues,
                                rolls: 0...1, level: level)
    }
    
    func copy() -> Item {
        return OvalShieldItem(other: self)
    }
    
    func didEquip(onEntity entity: Entity) {
        alteration.apply(to: entity)
    }
    
    func didUnequip(onEntity entity: Entity) {
        alteration.remove(from: entity)
    }
}
