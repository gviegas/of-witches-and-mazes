//
//  NoblesAttireItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Noble's Attire, an armor.
///
class NoblesAttireItem: PassiveItem, TradableItem, AlterationItem, LevelItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.whiteTunic.imageName]
    }
    
    let name: String = "Noble's Attire"
    let icon: Icon = IconSet.Item.whiteTunic
    let category: ItemCategory = .armor
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 74) }
    
    var alteration: Alteration
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: NoblesAttireItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let guaranteedRanges: [AlterableStat: ClosedRange<Int>] = [.defense: 5...10, .resistance: 15...20]
        
        let possibleScales: [AlterableStat: (scale: Double, ratio: Double)] = [
            .ability(.strength): (0.25, 0.15),
            .ability(.agility): (0.25, 0.15),
            .ability(.intellect): (0.25, 0.15),
            .ability(.faith): (0.25, 0.15)]
        
        alteration = Alteration(guaranteedRanges: guaranteedRanges, possibleScales: possibleScales,
                                rolls: 2...2, level: level)
    }
    
    func copy() -> Item {
        return NoblesAttireItem(other: self)
    }
    
    func didEquip(onEntity entity: Entity) {
        alteration.apply(to: entity)
    }
    
    func didUnequip(onEntity entity: Entity) {
        alteration.remove(from: entity)
    }
}
