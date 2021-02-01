//
//  UniversalLootTable.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/18/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A `LootTable` type that defines an universal loot table.
///
class UniversalLootTable: LootTable, TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        return LootGenerator.animationKeys
    }
    
    static var textureNames: Set<String> {
        return LootGenerator.textureNames
    }
    
    /// A struct that defines table parameters to use on loot generation.
    ///
    private struct TableParameters {
        
        /// The number of rolls for both common and rare loot.
        ///
        let rolls: (common: ClosedRange<Int>, rare: ClosedRange<Int>)
        
        /// The drop chance for both common and rare loot and also for gold.
        ///
        let dropChance: (common: Double, rare: Double, gold: Double)
        
        /// The factors for gold quantity.
        ///
        let goldFactors: (scale: Double, deviationRatio: Double, extra: Int)
    }
    
    /// An enum that defines the quality of generated loot.
    ///
    enum Quality {
        case typical, inferior, superior
    }
    
    /// The table parameters for typical loot.
    ///
    private static let typicalParameters = TableParameters(rolls: (common: 1...3, rare: 1...1),
                                                           dropChance: (common: 0.1, rare: 0.01, gold: 0.2),
                                                           goldFactors: (scale: 0.15, deviationRatio: 0.3, extra: 1))
    
    /// The table parameters for inferior loot.
    ///
    private static let inferiorParameters = TableParameters(rolls: (common: 1...2, rare: 0...1),
                                                            dropChance: (common: 0.05, rare: 0.002, gold: 0.1),
                                                            goldFactors: (scale: 0.05, deviationRatio: 0.3, extra: 1))
    
    /// The table parameters for superior loot.
    ///
    private static let superiorParameters = TableParameters(rolls: (common: 3...4, rare: 1...2),
                                                            dropChance: (common: 0.65 , rare: 0.5, gold: 1.0),
                                                            goldFactors: (scale: 0.5, deviationRatio: 0.3, extra: 10))
    
    /// The `UniversalLootTable.Quality` dictating the quality of generated loot.
    ///
    private let quality: Quality

    /// The level of experience range for which the table generates loot.
    ///
    private let levelRange: ClosedRange<Int>
    
    /// Creates a new instance from table quality and level of experience.
    ///
    /// - Parameters:
    ///   - quality: The `UniversalLootTable.Quality` dictating the quality of generated loot.
    ///   - level: The level of experience for which the table generates loot.
    ///
    init(quality: Quality, level: Int) {
        self.quality = quality
        let lowerBound = max(EntityProgression.levelRange.lowerBound, level - 1)
        let upperBound = min(EntityProgression.levelRange.upperBound, level + 1)
        levelRange = lowerBound...upperBound
    }
    
    func generateLoot() -> [Item] {
        let parameters: TableParameters
        switch quality {
        case .typical:
            parameters = UniversalLootTable.typicalParameters
        case .inferior:
            parameters = UniversalLootTable.inferiorParameters
        case . superior:
            parameters = UniversalLootTable.superiorParameters
        }
        let rolls = parameters.rolls
        let dropChance = parameters.dropChance
        let goldFactors = parameters.goldFactors
        let loot = LootGenerator.lootFor(levelRange: levelRange,
                                         commonLoot: (Int.random(in: rolls.common), dropChance.common),
                                         rareLoot: (Int.random(in: rolls.rare), dropChance.rare))
        let gold = LootGenerator.goldFor(levelRange: levelRange,
                                         scale: goldFactors.scale,
                                         deviationRatio: goldFactors.deviationRatio,
                                         extra: goldFactors.extra,
                                         dropChance: dropChance.gold)
        return loot + gold
    }
}

/// A struct that generates loot from both common and rare distributions, and also gold pieces.
///
fileprivate struct LootGenerator: TextureUser, AnimationUser {
    
    static var animationKeys: Set<String> {
        let common = commonDistribution.values.reduce(Set<String>()) { (result, value) in
            guard let animationUser = value.itemClass as? AnimationUser.Type else { return result }
            return result.union(animationUser.animationKeys)
        }
        let rare = rareDistribution.values.reduce(Set<String>()) { (result, value) in
            guard let animationUser = value.itemClass as? AnimationUser.Type else { return result }
            return result.union(animationUser.animationKeys)
        }
        return common.union(rare)
    }
    
    static var textureNames: Set<String> {
        let common = commonDistribution.values.reduce(Set<String>()) { (result, value) in
            guard let textureUser = value.itemClass as? TextureUser.Type else { return result }
            return result.union(textureUser.textureNames)
        }
        let rare = rareDistribution.values.reduce(Set<String>()) { (result, value) in
            guard let textureUser = value.itemClass as? TextureUser.Type else { return result }
            return result.union(textureUser.textureNames)
        }
        return common.union(rare).union(GoldPiecesItem.textureNames)
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
    }
    
    private init() {}
    
    /// The distribution for common loot.
    ///
    private static let commonDistribution = WeightedDistribution(values: [
        (Value(itemClass: KeyItem.self, quantityRange: 1...1), 0.02),
        (Value(itemClass: ArrowItem.self, quantityRange: 1...8), 1.0),
        (Value(itemClass: SpellComponentsItem.self, quantityRange: 2...12), 0.7),
        (Value(itemClass: BombItem.self, quantityRange: 1...3), 0.65),
        (Value(itemClass: DaggerItem.self, quantityRange: 1...5), 0.65),
        (Value(itemClass: YarnItem.self, quantityRange: 1...1), 0.1),
        (Value(itemClass: ToyItem.self, quantityRange: 1...1), 0.1),
        (Value(itemClass: HealingPotionItem.self, quantityRange: 1...2), 1.0),
        (Value(itemClass: RestorativePotionItem.self, quantityRange: 1...2), 1.0),
        (Value(itemClass: PanaceaItem.self, quantityRange: 1...1), 0.1),
        (Value(itemClass: AntidoteItem.self, quantityRange: 1...2), 0.25),
        (Value(itemClass: ElixirItem.self, quantityRange: 1...1), 0.05),
        (Value(itemClass: DeadlyDraughtItem.self, quantityRange: 1...1), 0.03),
        (Value(itemClass: AntiMagicPotionItem.self, quantityRange: 1...1), 0.01),
        (Value(itemClass: PotionOfCelerityItem.self, quantityRange: 1...1), 0.03),
        (Value(itemClass: PotionOfInvisibilityItem.self, quantityRange: 1...1), 0.01),
        (Value(itemClass: GrimoireOfPrismaticMissileItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: GrimoireOfColdRayItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: GrimoireOfPoisonOrbItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: GrimoireOfLightningBoltItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: GrimoireOfEnergyBarrierItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: HeaterShieldItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: OvalShieldItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: RoundShieldItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: TunicItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: LeatherVestItem.self, quantityRange:nil), 0.1),
        (Value(itemClass: HauberkItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: BrigandineItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: BreastplateItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: CuirassItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: ExoticOutfitItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: RecurveBowItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: LongBowItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: HuntingBowItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: CommonSwordItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: RapierItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: CutlassItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: SpathaItem.self, quantityRange: nil), 0.1)])
    
    /// The distribution for rare loot.
    ///
    private static let rareDistribution = WeightedDistribution(values: [
        (Value(itemClass: GrimoireOfDazeItem.self, quantityRange: nil), 0.65),
        (Value(itemClass: GrimoireOfWeaknessItem.self, quantityRange: nil), 0.3),
        (Value(itemClass: GrimoireOfDispelMagicItem.self, quantityRange: nil), 0.1),
        (Value(itemClass: GrimoireOfCurseItem.self, quantityRange: nil), 0.04),
        (Value(itemClass: GoldRingItem.self, quantityRange: nil), 0.45),
        (Value(itemClass: SilverRingItem.self, quantityRange: nil), 0.65),
        (Value(itemClass: CopperRingItem.self, quantityRange: nil), 0.9),
        (Value(itemClass: AmethystRingItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: AquamarineRingItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: CoralRingItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: KnightsShieldItem.self, quantityRange: nil), 1.0),
        (Value(itemClass: EmeraldShieldItem.self, quantityRange: nil), 0.8),
        (Value(itemClass: AncientShieldItem.self, quantityRange: nil), 0.6),
        (Value(itemClass: NoblesAttireItem.self, quantityRange: nil), 0.7),
        (Value(itemClass: ChainMailItem.self, quantityRange: nil), 0.85),
        (Value(itemClass: PlateArmorItem.self, quantityRange: nil), 0.55),
        (Value(itemClass: AshenBowItem.self, quantityRange: nil), 0.7),
        (Value(itemClass: OcherBowItem.self, quantityRange: nil), 0.7),
        (Value(itemClass: RoyalSwordItem.self, quantityRange: nil), 0.45),
        (Value(itemClass: BastardSwordItem.self, quantityRange: nil), 0.6),
        (Value(itemClass: UncommonSwordItem.self, quantityRange: nil), 0.7)])
    
    /// Generates loot.
    ///
    /// - Parameters:
    ///   - level: The level of experience range for which to generate loot.
    ///   - commonLoot: A `(Int, Double)` tuple defining the amount of rolls to make and drop chance of
    ///     each roll, respectively. This parameter is used when generating loot from the common distribution.
    ///   - rareLoot: A `(Int, Double)` tuple defining the amount of rolls to make and drop chance of
    ///     each roll, respectively. This parameter is used when generating loot from the rare distribution.
    /// - Returns: A list containing the generated loot.
    ///
    static func lootFor(levelRange: ClosedRange<Int>, commonLoot: (rolls: Int, dropChance: Double),
                        rareLoot: (rolls: Int, dropChance: Double)) -> [Item] {
        
        assert(EntityProgression.levelRange.contains(levelRange.lowerBound))
        assert(EntityProgression.levelRange.contains(levelRange.upperBound))
        assert(commonLoot.rolls >= 0 && rareLoot.rolls >= 0)
        assert((0...1.0).contains(commonLoot.dropChance) && (0...1.0).contains(rareLoot.dropChance))
        
        var items = [Item]()
        
        for _ in 0..<commonLoot.rolls {
            guard commonLoot.dropChance >= Double.random(in: 0...1.0) else { continue }
            let value = commonDistribution.nextValue()
            let level = Int.random(in: levelRange)
            let quantity = value.quantityRange != nil ? Int.random(in: value.quantityRange!) : nil
            if let item = ItemMaker.makeItem(itemClass: value.itemClass, level: level, quantity: quantity) {
                items.append(item)
            }
        }
        
        for _ in 0..<rareLoot.rolls {
            guard rareLoot.dropChance >= Double.random(in: 0...1.0) else { continue }
            let value = rareDistribution.nextValue()
            let level = Int.random(in: levelRange)
            let quantity = value.quantityRange != nil ? Int.random(in: value.quantityRange!) : nil
            if let item = ItemMaker.makeItem(itemClass: value.itemClass, level: level, quantity: quantity) {
                items.append(item)
            }
        }
        
        return items
    }
    
    /// Generates gold.
    ///
    /// - Parameters
    ///   - levelRange: The level of experience range for which to generate gold.
    ///   - scale: The quantity of gold per level, defining the average.
    ///   - deviationRatio: The ratio indicating the deviation from the average.
    ///   - extra: An absolute quantity to sum after computing the amount from scale and deviation.
    ///   - dropChance: The probability of generating gold.
    /// - Returns: A list containing the generated gold.
    ///
    static func goldFor(levelRange: ClosedRange<Int>, scale: Double, deviationRatio: Double,
                        extra: Int, dropChance: Double) -> [Item] {
        
        assert(EntityProgression.levelRange.contains(levelRange.lowerBound))
        assert(EntityProgression.levelRange.contains(levelRange.upperBound))
        assert((0...1.0).contains(scale) && (0...1.0).contains(deviationRatio) && (0...1.0).contains(dropChance))
        
        guard dropChance >= Double.random(in: 0...1.0) else { return [] }
        
        let level = Int.random(in: levelRange)
        let average = (scale * Double(level)).rounded()
        let deviation = (average * deviationRatio).rounded()
        let lowerBound = Int(average) - Int(deviation)
        let upperBound = Int(average) + Int(deviation)
        
        var quantity = Int.random(in: lowerBound...upperBound) + extra
        var items = [Item]()
        repeat {
            items.append(GoldPiecesItem(quantity: quantity))
            quantity -= GoldPiecesItem.capacity
        } while quantity > 0
        
        return items
    }
}
