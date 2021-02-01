//
//  TradingLootTable.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/21/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `LootTable` type that generates loot for trading.
///
class TradingLootTable: LootTable, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return LootGenerator.animationKeys
    }
    
    static var textureNames: Set<String> {
        return LootGenerator.textureNames
    }
    
    /// The parameters for generation of melee weapon loot.
    ///
    private static var meleeWeaponLoot: (rolls: Int, chance: Double) {
        return (Int.random(in: 2...3), 1.0)
    }
    
    /// The parameters for generation of ranged weapon loot.
    ///
    private static var rangedWeaponLoot: (rolls: Int, chance: Double) {
        return (Int.random(in: 1...3), 1.0)
    }
    
    /// The parameters for generation of armor loot.
    ///
    private static var armorLoot: (rolls: Int, chance: Double) {
        return (Int.random(in: 3...4), 1.0)
    }
    
    /// The parameters for generation of shield loot.
    ///
    private static var shieldLoot: (rolls: Int, chance: Double) {
        return (Int.random(in: 1...3), 1.0)
    }
    
    /// The parameters for generation of jewel loot.
    ///
    private static var jewelLoot: (rolls: Int, chance: Double) {
        return (Int.random(in: 0...1), 0.6)
    }
    
    /// The parameters for generation of spell book loot.
    ///
    private static var spellBookLoot: (rolls: Int, chance: Double) {
        return (Int.random(in: 1...2), 0.7)
    }
    
    /// The parameters for generation of rare consumable loot.
    ///
    private static var rareConsumableLoot: (rolls: Int, chance: Double) {
        return (Int.random(in: 1...2), 0.8)
    }
    
    /// The level of experience range for which the table generates loot.
    ///
    private let levelRange: ClosedRange<Int>
    
    /// Creates a new instance from the given level of experience.
    ///
    /// - Parameter level: The level of experience for which to create the loot table.
    ///
    init(level: Int) {
        let lowerBound = max(EntityProgression.levelRange.lowerBound, level - 1)
        let upperBound = min(EntityProgression.levelRange.upperBound, level + 1)
        levelRange = lowerBound...upperBound
    }
    
    func generateLoot() -> [Item] {
        return LootGenerator.lootFor(levelRange: levelRange,
                                     meleeWeaponLoot: TradingLootTable.meleeWeaponLoot,
                                     rangedWeaponLoot: TradingLootTable.rangedWeaponLoot,
                                     armorLoot: TradingLootTable.armorLoot,
                                     shieldLoot: TradingLootTable.shieldLoot,
                                     jewelLoot: TradingLootTable.jewelLoot,
                                     spellBookLoot: TradingLootTable.spellBookLoot,
                                     rareConsumableLoot: TradingLootTable.rareConsumableLoot)
    }
}

/// A struct that generates essential loot and loot from distributions based on item categories.
///
fileprivate struct LootGenerator: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        let values = essentialLoot + meleeWeaponDistribution.values + rangedWeaponDistribution.values +
            armorDistribution.values + shieldDistribution.values + jewelDistribution.values +
            spellBookDistribution.values
        
        return values.reduce(Set<String>()) { (result, value) in
            guard let animationUser = value.itemClass as? AnimationUser.Type else { return result }
            return result.union(animationUser.animationKeys)
        }
    }
    
    static var textureNames: Set<String> {
        let values = essentialLoot + meleeWeaponDistribution.values + rangedWeaponDistribution.values +
            armorDistribution.values + shieldDistribution.values + jewelDistribution.values +
            spellBookDistribution.values
        
        return values.reduce(Set<String>()) { (result, value) in
            guard let textureUser = value.itemClass as? TextureUser.Type else { return result }
            return result.union(textureUser.textureNames)
        }
    }
    
    /// A struct that defines a value for a loot distribution.
    ///
    private struct Value {
        
        /// The `Item` class type for this value.
        ///
        let itemClass: Item.Type
        
        /// The optional quantity range. This parameter only applies to `StackableItem` types.
        ///
        let quantityRange: ClosedRange<Int>?
        
        /// Creates a new instance from the given item class and optional quantity range.
        ///
        /// - Parameters:
        ///   - itemClass: The `Item` class type for this value.
        ///   - quantityRange: The optional quantity range. This parameter only applies to
        ///     `StackableItem` types.
        ///
        init(itemClass: Item.Type, quantityRange: ClosedRange<Int>?) {
            self.itemClass = itemClass
            self.quantityRange = quantityRange
        }
        
        /// Creates a new instance from the given item class and quantity.
        ///
        /// - Parameters:
        ///   - itemClass: The `Item` class type for this value.
        ///   - quantity: The quantity. This parameter only applies to `StackableItem` types.
        ///
        init(itemClass: Item.Type, quantity: Int) {
            self.init(itemClass: itemClass, quantityRange: quantity...quantity)
        }
    }
    
    private init() {}
    
    /// The list of essential loot that must always be made available.
    ///
    private static let essentialLoot = [
        Value(itemClass: HealingPotionItem.self, quantity: HealingPotionItem.capacity),
        Value(itemClass: HealingPotionItem.self, quantity: HealingPotionItem.capacity),
        Value(itemClass: HealingPotionItem.self, quantityRange: 1...HealingPotionItem.capacity),
        Value(itemClass: RestorativePotionItem.self, quantity: RestorativePotionItem.capacity),
        Value(itemClass: RestorativePotionItem.self, quantity: RestorativePotionItem.capacity),
        Value(itemClass: RestorativePotionItem.self, quantityRange: 1...RestorativePotionItem.capacity),
        Value(itemClass: AntidoteItem.self, quantity: AntidoteItem.capacity),
        Value(itemClass: AntidoteItem.self, quantityRange: 1...AntidoteItem.capacity),
        Value(itemClass: ElixirItem.self, quantity: ElixirItem.capacity),
        Value(itemClass: ElixirItem.self, quantityRange: 1...ElixirItem.capacity),
        Value(itemClass: ArrowItem.self, quantity: ArrowItem.capacity),
        Value(itemClass: ArrowItem.self, quantity: ArrowItem.capacity),
        Value(itemClass: ArrowItem.self, quantityRange: 1...ArrowItem.capacity),
        Value(itemClass: SpellComponentsItem.self, quantity: SpellComponentsItem.capacity),
        Value(itemClass: SpellComponentsItem.self, quantity: SpellComponentsItem.capacity),
        Value(itemClass: SpellComponentsItem.self, quantity: SpellComponentsItem.capacity),
        Value(itemClass: SpellComponentsItem.self, quantityRange: 1...SpellComponentsItem.capacity),
        Value(itemClass: KeyItem.self, quantityRange: 1...max(1, KeyItem.capacity / 10)),
        Value(itemClass: BombItem.self, quantityRange: 1...max(1, BombItem.capacity / 2)),
        Value(itemClass: DaggerItem.self, quantityRange: 1...DaggerItem.capacity),
        Value(itemClass: YarnItem.self, quantityRange: 1...max(1, YarnItem.capacity / 5)),
        Value(itemClass: ToyItem.self, quantityRange: 1...max(1, ToyItem.capacity / 5))]
    
    /// The distribution for melee weapons.
    ///
    private static let meleeWeaponDistribution = WeightedDistribution(values: [
        (Value(itemClass: CommonSwordItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: RapierItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: CutlassItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: SpathaItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: BastardSwordItem.self, quantityRange: nil), 0.05)])
    
    /// The distribution for ranged weapons.
    ///
    private static let rangedWeaponDistribution = WeightedDistribution(values: [
        (Value(itemClass: RecurveBowItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: LongBowItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: HuntingBowItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: AshenBowItem.self, quantityRange: nil), 0.05)])
    
    /// The distribution for armors.
    ///
    private static let armorDistribution = WeightedDistribution(values: [
        (Value(itemClass: TunicItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: LeatherVestItem.self, quantityRange:nil), 1.0),
        (Value(itemClass: HauberkItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: BrigandineItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: BreastplateItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: CuirassItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: NoblesAttireItem.self, quantityRange: nil), 0.025)])
    
    /// The distribution for shields.
    ///
    private static let shieldDistribution = WeightedDistribution(values: [
        (Value(itemClass: HeaterShieldItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: OvalShieldItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: RoundShieldItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: KnightsShieldItem.self, quantityRange: nil), 0.04)])
    
    /// The distribution for jewels.
    ///
    private static let jewelDistribution = WeightedDistribution(values: [
        (Value(itemClass: AmethystRingItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: AquamarineRingItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: CoralRingItem.self, quantityRange: nil), 1.0)])
    
    /// The distribution for spell books.
    ///
    private static let spellBookDistribution = WeightedDistribution(values: [
        (Value(itemClass: GrimoireOfPrismaticMissileItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: GrimoireOfColdRayItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: GrimoireOfPoisonOrbItem.self, quantityRange: nil), 0.667),
        (Value(itemClass: GrimoireOfEnergyBarrierItem.self, quantityRange: nil), 0.667),
        (Value(itemClass: GrimoireOfDazeItem.self, quantityRange: nil), 0.003),
        (Value(itemClass: GrimoireOfWeaknessItem.self, quantityRange: nil), 0.001)])
    
    /// The distribution for rare consumables.
    ///
    private static let rareConsumableDistribution = WeightedDistribution(values: [
        (Value(itemClass: PanaceaItem.self, quantityRange: 1...3), 1.0),
        (Value(itemClass: DeadlyDraughtItem.self, quantityRange: 1...2), 1.0),
        (Value(itemClass: PotionOfCelerityItem.self, quantityRange: 1...2), 0.3),
        (Value(itemClass: AntiMagicPotionItem.self, quantity: 1), 0.2),
        (Value(itemClass: PotionOfInvisibilityItem.self, quantity: 1), 0.1)])
    
    /// Generates loot.
    ///
    /// - Parameters:
    ///   - levelRange: The level of experience range for which to generate loot.
    ///   - meleeWeaponLoot: A `(Int, Double)` tuple defining the amount of rolls to make and chance of
    ///     each roll, respectively. This parameter is used when generating loot from the melee weapon
    ///     distribution.
    ///   - rangedWeaponLoot: A `(Int, Double)` tuple defining the amount of rolls to make and chance of
    ///     each roll, respectively. This parameter is used when generating loot from the ranged weapon
    ///     distribution.
    ///   - armorLoot: A `(Int, Double)` tuple defining the amount of rolls to make and chance of each
    ///     roll, respectively. This parameter is used when generating loot from the armor distribution.
    ///   - shieldLoot: A `(Int, Double)` tuple defining the amount of rolls to make and chance of each
    ///     roll, respectively. This parameter is used when generating loot from the shield distribution.
    ///   - jewelLoot: A `(Int, Double)` tuple defining the amount of rolls to make and chance of each
    ///     roll, respectively. This parameter is used when generating loot from the jewel distribution.
    ///   - spellBookLoot: A `(Int, Double)` tuple defining the amount of rolls to make and chance of each
    ///     roll, respectively. This parameter is used when generating loot from the spell book distribution.
    ///   - rareConsumableLoot: A `(Int, Double)` tuple defining the amount of rolls to make and chance
    ///     of each roll, respectively. This parameter is used when generating loot from the rare consumable
    ///     distribution.
    /// - Returns: A list containing the generated loot.
    ///
    static func lootFor(levelRange: ClosedRange<Int>,
                        meleeWeaponLoot: (rolls: Int, chance: Double),
                        rangedWeaponLoot: (rolls: Int, chance: Double),
                        armorLoot: (rolls: Int, chance: Double),
                        shieldLoot: (rolls: Int, chance: Double),
                        jewelLoot: (rolls: Int, chance: Double),
                        spellBookLoot: (rolls: Int, chance: Double),
                        rareConsumableLoot: (rolls: Int, chance: Double)) -> [Item] {
        
        assert(EntityProgression.levelRange.contains(levelRange.lowerBound))
        assert(EntityProgression.levelRange.contains(levelRange.upperBound))
        assert(meleeWeaponLoot.rolls >= 0)
        assert(rangedWeaponLoot.rolls >= 0)
        assert(armorLoot.rolls >= 0)
        assert(shieldLoot.rolls >= 0)
        assert(jewelLoot.rolls >= 0)
        assert(spellBookLoot.rolls >= 0)
        assert((0...1.0).contains(meleeWeaponLoot.chance))
        assert((0...1.0).contains(rangedWeaponLoot.chance))
        assert((0...1.0).contains(armorLoot.chance))
        assert((0...1.0).contains(shieldLoot.chance))
        assert((0...1.0).contains(jewelLoot.chance))
        assert((0...1.0).contains(spellBookLoot.chance))
        assert((0...1.0).contains(rareConsumableLoot.chance))
        
        var items = [Item]()
        
        // Generate essential loot
        for value in essentialLoot {
            let level = Int.random(in: levelRange)
            let quantity = value.quantityRange != nil ? Int.random(in: value.quantityRange!) : nil
            if let item = ItemMaker.makeItem(itemClass: value.itemClass, level: level, quantity: quantity) {
                items.append(item)
            }
        }
        
        let lootList = [(meleeWeaponLoot, meleeWeaponDistribution),
                        (rangedWeaponLoot, rangedWeaponDistribution),
                        (armorLoot, armorDistribution),
                        (shieldLoot, shieldDistribution),
                        (jewelLoot, jewelDistribution),
                        (spellBookLoot, spellBookDistribution),
                        (rareConsumableLoot, rareConsumableDistribution)]
        
        // Generate loot from item category distributions
        for (loot, distribution) in lootList {
            for _ in 0..<loot.rolls {
                guard loot.chance >= Double.random(in: 0...1.0) else { continue }
                let value = distribution.nextValue()
                let level = Int.random(in: levelRange)
                let quantity = value.quantityRange != nil ? Int.random(in: value.quantityRange!) : nil
                let item = ItemMaker.makeItem(itemClass: value.itemClass, level: level, quantity: quantity)
                if let item = item { items.append(item) }
            }
        }
        
        return items
    }
}
