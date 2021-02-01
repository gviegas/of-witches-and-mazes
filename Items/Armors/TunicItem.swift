//
//  TunicItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/24/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` type that defines the Tunic, an armor.
///
class TunicItem: PassiveItem, TradableItem, AlterationItem, LevelItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.greyTunic.imageName]
    }
    
    let name: String = "Tunic"
    let icon: Icon = IconSet.Item.greyTunic
    let category: ItemCategory = .armor
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 40) }
    
    var alteration: Alteration
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: TunicItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let guaranteedRanges: [AlterableStat: ClosedRange<Int>] = [.defense: 5...10, .resistance: 5...10]
        
        let possibleScales: [AlterableStat: (scale: Double, ratio: Double)] = [
            .ability(.intellect): (0.2, 0.15),
            .ability(.faith): (0.2, 0.15)]
        
        alteration = Alteration(guaranteedRanges: guaranteedRanges, possibleScales: possibleScales,
                                rolls: 1...1, level: level)
    }
    
    func copy() -> Item {
        return TunicItem(other: self)
    }
    
    func didEquip(onEntity entity: Entity) {
        alteration.apply(to: entity)
    }
    
    func didUnequip(onEntity entity: Entity) {
        alteration.remove(from: entity)
    }
}
