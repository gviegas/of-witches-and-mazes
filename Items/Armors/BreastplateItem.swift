//
//  BreastplateItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Breastplate, an armor.
///
class BreastplateItem: PassiveItem, TradableItem, AlterationItem, LevelItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.cobaltCuirass.imageName]
    }
    
    let name: String = "Breastplate"
    let icon: Icon = IconSet.Item.cobaltCuirass
    let category: ItemCategory = .armor
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 58) }
    
    var alteration: Alteration
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: BreastplateItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let guaranteedRanges: [AlterableStat: ClosedRange<Int>] = [.defense: 15...20, .resistance: 5...10]
        
        let possibleScales: [AlterableStat: (scale: Double, ratio: Double)] = [
            .ability(.strength): (0.2, 0.15),
            .ability(.faith): (0.2, 0.15)]
        
        alteration = Alteration(guaranteedRanges: guaranteedRanges, possibleScales: possibleScales,
                                rolls: 1...1, level: level)
    }
    
    func copy() -> Item {
        return BreastplateItem(other: self)
    }
    
    func didEquip(onEntity entity: Entity) {
        alteration.apply(to: entity)
    }
    
    func didUnequip(onEntity entity: Entity) {
        alteration.remove(from: entity)
    }
}
