//
//  HauberkItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Hauberk, an armor.
///
class HauberkItem: PassiveItem, TradableItem, AlterationItem, LevelItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.hauberk.imageName]
    }
    
    let name: String = "Hauberk"
    let icon: Icon = IconSet.Item.hauberk
    let category: ItemCategory = .armor
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 48) }
    
    var alteration: Alteration
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: HauberkItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let guaranteedRanges: [AlterableStat: ClosedRange<Int>] = [.defense: 10...15, .resistance: 5...10]
        
        let possibleScales: [AlterableStat: (scale: Double, ratio: Double)] = [
            .ability(.agility): (0.2, 0.15),
            .ability(.faith): (0.2, 0.15)]
        
        alteration = Alteration(guaranteedRanges: guaranteedRanges, possibleScales: possibleScales,
                                rolls: 1...1, level: level)    }
    
    func copy() -> Item {
        return HauberkItem(other: self)
    }
    
    func didEquip(onEntity entity: Entity) {
        alteration.apply(to: entity)
    }
    
    func didUnequip(onEntity entity: Entity) {
        alteration.remove(from: entity)
    }
}
