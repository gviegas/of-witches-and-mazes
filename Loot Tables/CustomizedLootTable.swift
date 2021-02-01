//
//  CustomizedLootTable.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/18/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `LootTable` type that defines a customized loot table.
///
/// - Note: Users of this class are responsible for declaring the animations and textures used by the items
///   on a `TextureUser`/`AnimationUser` type.
///
class CustomizedLootTable: LootTable {
    
    /// The number of rools to make.
    ///
    private let rolls: ClosedRange<Int>
    
    /// The probability of nothing being dropped.
    ///
    private let noDropChance: Double
    
    /// The weighted ditribution.
    ///
    private let distribution: WeightedDistribution<Item>?
    
    /// The list of items that must always be generated.
    ///
    private let guaranteedItems: [Item]?
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - items: A list of `(Item, Double?)` pairs that defines the probability of a given item dropping.
    ///     Setting the probability of a given item to `nil` guarantees the generation of said item in
    ///     every call to `generateLoot()`, regardless of `rolls`/`noDropChance` values.
    ///   - rolls: A closed range that defines the amount of drop rolls to make.
    ///   - noDropChance: A value between 0.0 and 1.0 indicating the probability of nothing being dropped.
    ///
    init(items: [(item: Item, weight: Double?)], rolls: ClosedRange<Int>, noDropChance: Double) {
        self.rolls = rolls
        self.noDropChance = noDropChance
        
        var itemsToRoll: [(Item, Double)] = []
        var itemsToGive: [Item] = []
        for (item, weight) in items {
            if let weight = weight {
                itemsToRoll.append((item, weight))
            } else {
                itemsToGive.append(item)
            }
        }
        distribution = itemsToRoll.isEmpty ? nil : WeightedDistribution(values: itemsToRoll)
        guaranteedItems = itemsToGive.isEmpty ? nil : itemsToGive
    }
    
    /// Generates loot.
    ///
    /// This method first checks if anything dropped, based on the `noDropChance` property.
    /// Then, a random value in the `rolls` range is chosen as the amount of drop rolls to make,
    /// and each unique roll will cause an item to be added to the resulting loot list.
    ///
    /// It is worth noting that each `Item` entry in the table can be chosen no more than once.
    /// Thus, if the same instance is chosen twice, the repeating roll is lost.
    ///
    /// - Returns: A list containing the generated loot.
    ///
    func generateLoot() -> [Item] {
        var items = [Item]()
        
        if let distribution = distribution, Double.random(in: 0...1.0) > noDropChance {
            var chosen: Set<ObjectIdentifier> = []
            let quantity = max(1, Int.random(in: rolls))
            for _ in 1...quantity {
                let next = distribution.nextValue()
                guard chosen.insert(ObjectIdentifier(next)).inserted else { continue }
                items.append(next.copy())
            }
        }
        
        if let guaranteedItems = guaranteedItems {
            for item in guaranteedItems { items.append(item.copy()) }
        }
        
        return items
    }
}
