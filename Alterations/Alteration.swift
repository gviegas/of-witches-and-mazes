//
//  Alteration.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/26/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An enum defining the available alterable stats.
///
enum AlterableStat: Hashable, Comparable {
    case ability(Ability)
    case critical(Medium?)
    case damageCaused(DamageType?)
    case damageTaken(DamageType?)
    case defense
    case resistance
    case mitigation
    case health
    
    static func < (lhs: AlterableStat, rhs: AlterableStat) -> Bool {
        switch lhs {
        case .ability(let ability):
            switch rhs {
            case .ability(let otherAbility):
                return ability < otherAbility
            case .health:
                return false
            default:
                return true
            }
            
        case .critical(let medium):
            switch rhs {
            case .critical(let otherMedium):
                if medium == nil && otherMedium != nil { return true }
                if medium != nil && otherMedium == nil { return false }
                if medium == nil && otherMedium == nil { return false }
                return medium! < otherMedium!
            case .health, .ability:
                return false
            default:
                return true
            }
        
        case .damageCaused(let type):
            switch rhs {
            case .damageCaused(let otherType):
                if type == nil && otherType != nil { return true }
                if type != nil && otherType == nil { return false }
                if type == nil && otherType == nil { return false }
                return type! < otherType!
            case .health, .ability, .critical:
                return false
            default:
                return true
            }
            
        case .damageTaken(let type):
            switch rhs {
            case .damageTaken(let otherType):
                if type == nil && otherType != nil { return true }
                if type != nil && otherType == nil { return false }
                if type == nil && otherType == nil { return false }
                return type! < otherType!
            case .defense, .resistance, .mitigation:
                return true
            default:
                return false
            }
            
        case .defense:
            switch rhs {
            case .resistance, .mitigation:
                return true
            default:
                return false
            }
            
        case .resistance:
            return rhs == .mitigation
            
        case .mitigation:
            return false
            
        case .health:
            return rhs != .health
        }
    }
    
    /// Retrieves the string that represents the alterable stats.
    ///
    /// - Parameter value: The numeric value to represent with the stat.
    /// - Returns: A string that represents the stat.
    ///
    func asString(with value: Int) -> String {
        let sign = value < 0 ? "-" : "+"
        let num = "\(sign)\(abs(value))"
        switch self {
        case .ability(let ability):
            return "\(num) \(ability.rawValue)"
        case .critical(let medium):
            return medium == nil ? "\(num)% Critical" : "\(num)% \(medium!.rawValue) Critical"
        case .damageCaused(let type):
            return type == nil ? "\(num)% Damage Caused" : "\(num)% \(type!.rawValue) Damage Caused"
        case .damageTaken(let type):
            return type == nil ? "\(num)% Damage Taken" : "\(num)% \(type!.rawValue) Damage Taken"
        case .defense:
            return "\(num)% Defense"
        case .resistance:
            return "\(num)% Resistance"
        case .mitigation:
            return "\(num) Mitigation"
        case .health:
            return "\(num) Health Points"
        }
    }
}

/// A class that defines the alteration, used by instances that can alter the stats of entities.
///
class Alteration {
    
    /// The maximum number of `AlterableStats` allowed.
    ///
    static let maxStats = 10
    
    /// The dictionary that defines the alterable stats and their alteration values.
    ///
    /// - Note: For stats that take normalized percentage as values (`0` to `1.0`), the integral range
    ///   (`0` to `100`) must be used instead.
    ///
    let stats: [AlterableStat: Int]
    
    /// Creates a new instance from the given stats.
    ///
    /// - Parameter stats: A dictionary that defines the alterable stats and their alteration values.
    ///
    init(stats: [AlterableStat: Int]) {
        assert(stats.count <= Alteration.maxStats)
        self.stats = stats
    }
    
    /// Creates a new instance from the given ranges.
    ///
    /// - Parameter ranges: A dictionary that defines the alterable stats and their ranges of alteration values.
    ///   A random value within each range will be chosen as the alteration value for the given stat.
    ///
    init(ranges: [AlterableStat: ClosedRange<Int>]) {
        self.stats = Alteration.map(ranges: ranges)
    }
    
    /// Creates a new instance from predefined scales.
    ///
    /// - Parameters:
    ///   - scales: A dictionary that defines the alterable stats and tuples of scale and ratio values.
    ///   The `scale` value is used to scale up the stat to the given level, and the `ratio` value defines
    ///   the deviation when constructing the range of possible alteration values, of which one is randomly
    ///   selected. It is worth noting that the minimum value for any stat is `1` - scales that produce
    ///   smaller values will be set to this minimum.
    ///   - level: The level to which the alteration values should be scaled up.
    ///
    init(scales: [AlterableStat: (scale: Double, ratio: Double)], level: Int) {
        self.stats = Alteration.map(scales: scales, level: level)
    }
    
    /// Creates a new instance from both predefined ranges and random ranges.
    ///
    /// - Parameters:
    ///   - guaranteedRanges: A dictionary that defines the alterable stats and their ranges of alteration values.
    ///   A random value within each range will be chosen as the alteration value for the given stat.
    ///   It is worth noting that the minimum value for any stat is `1` - scales that produce smaller
    ///   values will be set to this minimum.
    ///   - possibleRanges: Like `guaranteedRanges`, but a number of ranges in this dictionary are
    ///   randomly chosen to form, together with `guaranteedRanges`, the stats of the alteration.
    ///   - rolls: The number of possible ranges to randomly select.
    ///
    convenience init(guaranteedRanges: [AlterableStat: ClosedRange<Int>],
                     possibleRanges: [AlterableStat: ClosedRange<Int>],
                     rolls: ClosedRange<Int>) {
        
        var ranges = guaranteedRanges
        var randomSet = possibleRanges
        let rolls = max(1, Int.random(in: rolls))
        for _ in 1...rolls {
            guard let element = randomSet.randomElement() else { break }
            if ranges[element.key] == nil { ranges[element.key] = element.value }
            randomSet[element.key] = nil
        }
        self.init(ranges: ranges)
    }
    
    /// Creates a new instance from both predefined scales and random scales.
    ///
    /// - Parameters:
    ///   - guaranteedScales: A dictionary that defines the alterable stats and tuples of scale
    ///   and ratio values. The `scale` value is used to scale up the stat to the given level, and
    ///   the `ratio` value defines the deviation when constructing the range of possible alteration
    ///   values, of which one is randomly selected. It is worth noting that the minimum value for
    ///   any stat is `1` - scales that produce smaller values will be set to this minimum.
    ///   - possibleScales: Like `guaranteedScales`, but a number of scales in this dictionary are
    ///   randomly chosen to form, together with `guaranteedScales`, the stats of the alteration.
    ///   - rolls: The number of possible scales to randomly select.
    ///   - level: The level to which the alteration values should be scaled up.
    ///
    convenience init(guaranteedScales: [AlterableStat: (scale: Double, ratio: Double)],
                     possibleScales: [AlterableStat: (scale: Double, ratio: Double)],
                     rolls: ClosedRange<Int>, level: Int) {
        
        var scales = guaranteedScales
        var randomSet = possibleScales
        let rolls = max(1, Int.random(in: rolls))
        for _ in 1...rolls {
            guard let element = randomSet.randomElement() else { break }
            if scales[element.key] == nil { scales[element.key] = element.value }
            randomSet[element.key] = nil
        }
        self.init(scales: scales, level: level)
    }
    
    /// Creates a new instance from both predefined ranges and random scales.
    ///
    /// - Parameters:
    ///   - guaranteedRanges: A dictionary that defines the alterable stats and their ranges of alteration values.
    ///   A random value within each range will be chosen as the alteration value for the given stat.
    ///   It is worth noting that the minimum value for any stat is `1` - scales that produce smaller
    ///   values will be set to this minimum.
    ///   - possibleScales: A dictionary that defines the alterable stats and tuples of scale
    ///   and ratio values. The `scale` value is used to scale up the stat to the given level, and
    ///   the `ratio` value defines the deviation when constructing the range of possible alteration
    ///   values, of which one is randomly selected. A number of scales in this dictionary are randomly
    ///   chosen to form, together with `guaranteedRanges`, the stats of the alteration.
    ///   - rolls: The number of possible scales to randomly select.
    ///   - level: The level to which the alteration values should be scaled up.
    ///
    convenience init(guaranteedRanges: [AlterableStat: ClosedRange<Int>],
                     possibleScales: [AlterableStat: (scale: Double, ratio: Double)],
                     rolls: ClosedRange<Int>, level: Int) {
        
        var scales = [AlterableStat: (scale: Double, ratio: Double)]()
        var randomSet = possibleScales
        let rolls = max(1, Int.random(in: rolls))
        for _ in 1...rolls {
            guard let element = randomSet.randomElement() else { break }
            scales[element.key] = element.value
            randomSet[element.key] = nil
        }
        
        var stats = Alteration.map(ranges: guaranteedRanges)
        stats.merge(Alteration.map(scales: scales, level: level), uniquingKeysWith: { v, _ in v })
        self.init(stats: stats)
    }
    
    /// Creates a new instance from both predefined scales and random ranges.
    ///
    /// - Parameters:
    ///   - guaranteedScales: A dictionary that defines the alterable stats and tuples of scale
    ///   and ratio values. The `scale` value is used to scale up the stat to the given level, and
    ///   the `ratio` value defines the deviation when constructing the range of possible alteration
    ///   values, of which one is randomly selected. It is worth noting that the minimum value for
    ///   any stat is `1` - scales that produce smaller values will be set to this minimum.
    ///   - possibleRanges: A dictionary that defines the alterable stats and their ranges of alteration values.
    ///   A random value within each range will be chosen as the alteration value for the given stat. A number
    ///   of ranges in this dictionary are randomly chosen to form, together with `guaranteedScales`, the stats
    ///   of the alteration.
    ///   - rolls: The number of possible ranges to randomly select.
    ///   - level: The level to which the alteration values should be scaled up.
    ///
    convenience init(guaranteedScales: [AlterableStat: (scale: Double, ratio: Double)],
                     possibleRanges: [AlterableStat: ClosedRange<Int>],
                     rolls: ClosedRange<Int>, level: Int) {
        
        var ranges = [AlterableStat: ClosedRange<Int>]()
        var randomSet = possibleRanges
        let rolls = max(1, Int.random(in: rolls))
        for _ in 1...rolls {
            guard let element = randomSet.randomElement() else { break }
            ranges[element.key] = element.value
            randomSet[element.key] = nil
        }
        
        var stats = Alteration.map(scales: guaranteedScales, level: level)
        stats.merge(Alteration.map(ranges: ranges), uniquingKeysWith: { v, _ in v })
        self.init(stats: stats)
    }
    
    /// Creates a new instance from both predefined and random values.
    ///
    /// - Parameters:
    ///   - guaranteedValues: A dictionary that defines the alterable stats and tuples of `ProgressionValue`
    ///   values and ratio. The `value` is used to scale up the stat to the given level, and
    ///   the `ratio` value defines the deviation when constructing the range of possible alteration
    ///   values, of which one is randomly selected. It is worth noting that the minimum value for
    ///   any stat is `1` - progressions that produce smaller values will be set to this minimum.
    ///   - possibleValues: Like `guaranteedValues`, but a number of values in this dictionary are
    ///   randomly chosen to form, together with `guaranteedValues`, the stats of the alteration.
    ///   - rolls: The number of possible values to randomly select.
    ///   - level: The level to which the alteration values should be scaled up.
    ///
    convenience init(guaranteedValues: [AlterableStat: (value: ProgressionValue, ratio: Double)],
                     possibleValues: [AlterableStat: (value: ProgressionValue, ratio: Double)],
                     rolls: ClosedRange<Int>, level: Int) {
        
        var values = guaranteedValues
        var randomSet = possibleValues
        let rolls = max(1, Int.random(in: rolls))
        for _ in 1...rolls {
            guard let element = randomSet.randomElement() else { break }
            if values[element.key] == nil { values[element.key] = element.value }
            randomSet[element.key] = nil
        }
        
        let stats = Alteration.map(values: values, level: level)
        self.init(stats: stats)
    }
    
    /// Maps scales to absolute values.
    ///
    /// - Parameters:
    ///   - scales: A dictionary that defines the alterable stats and tuples of scale and ratio values.
    ///   The `scale` value is used to scale up the stat to the given level, and the `ratio` value defines
    ///   the deviation when constructing the range of possible alteration values, of which one is randomly
    ///   selected. It is worth noting that the minimum value for any stat is `1` - scales that produce
    ///   smaller values will be set to this minimum.
    ///   - level: The level to which the alteration values should be scaled up.
    /// - Returns: A dictionary containing the absolute values.
    ///
    class func map(scales: [AlterableStat: (scale: Double, ratio: Double)], level: Int) -> [AlterableStat: Int] {
        assert(scales.count <= Alteration.maxStats)
        
        return scales.mapValues { (scale: Double, ratio: Double) in
            assert(scale >= 0 && ratio >= 0)
            let average = scale * Double(level)
            let deviation = average * ratio
            let lowerBound = max(1, Int((average - deviation).rounded()))
            let upperBound = max(lowerBound, Int((average + deviation).rounded()))
            return Int.random(in: lowerBound...upperBound)
        }
    }
    
    /// Maps ranges to absolute values.
    ///
    /// - Parameter ranges: A dictionary that defines the alterable stats and their ranges of alteration values.
    ///   A random value within each range will be chosen as the alteration value for the given stats.
    /// - Returns: A dictionary containing the absolute values.
    ///
    class func map(ranges: [AlterableStat: ClosedRange<Int>]) -> [AlterableStat: Int] {
        assert(ranges.count <= Alteration.maxStats)
        assert(ranges.allSatisfy({ $0.value.lowerBound >= 0 }))
        return ranges.mapValues { max(1, Int.random(in: $0)) }
    }
    
    /// Maps scales to absolute values.
    ///
    /// - Parameters:
    ///   - values: A dictionary that defines the alterable stats and tuples of `ProgressionValue` values
    ///   and ratio. The `value` is used to scale up the stat to the given level, and the `ratio` defines
    ///   the deviation when constructing the range of possible alteration values, of which one is randomly
    ///   selected. It is worth noting that the minimum value for any stat is `1` - progressions that produce
    ///   smaller values will be set to this minimum.
    ///   - level: The level to which the alteration values should be scaled up.
    /// - Returns: A dictionary containing the absolute values.
    ///
    class func map(values: [AlterableStat: (value: ProgressionValue, ratio: Double)],
                   level: Int) -> [AlterableStat: Int] {
        
        assert(values.count <= Alteration.maxStats)
        
        return values.mapValues { (t) -> Int in
            let (value, ratio) = t
            assert(ratio >= 0)
            let average = value.forLevel(level)
            let deviation = Int((Double(average) * ratio).rounded())
            let lowerBound = max(1, average - deviation)
            let upperBound = max(lowerBound, average + deviation)
            return Int.random(in: lowerBound...upperBound)
        }
    }
    
    /// Applies alterations to the given entity.
    ///
    /// - Parameter entity: The entity to alter.
    ///
    func apply(to entity: Entity) {
        for (key, value) in stats {
            switch key {
            case .ability(let ability):
                guard let abilityComponent = entity.component(ofType: AbilityComponent.self) else { continue }
                let currentValue = abilityComponent.temporaryValues[ability] ?? 0
                abilityComponent.temporaryValues[ability] = currentValue + value
            case .critical(let medium):
                guard let critComponent = entity.component(ofType: CriticalHitComponent.self) else { continue }
                switch medium {
                case .none:
                    critComponent.modifyCriticalChance(by: Double(value) * 0.01)
                case .some:
                    critComponent.modifyCriticalChanceFor(medium: medium!, by: Double(value) * 0.01)
                }
            case .damageCaused(let type):
                guard let dmgComponent = entity.component(ofType: DamageAdjustmentComponent.self) else { continue }
                switch type {
                case .none:
                    dmgComponent.modifyDamageCaused(by: Double(value) * 0.01)
                case .some:
                    dmgComponent.modifyDamageCausedFor(type: type!, by: Double(value) * 0.01)
                }
            case .damageTaken(let type):
                guard let dmgComponent = entity.component(ofType: DamageAdjustmentComponent.self) else { continue }
                switch type {
                case .none:
                    dmgComponent.modifyDamageTaken(by: Double(value) * 0.01)
                case .some:
                    dmgComponent.modifyDamageTakenFor(type: type!, by: Double(value) * 0.01)
                }
            case .defense:
                guard let defenseComponent = entity.component(ofType: DefenseComponent.self) else { continue }
                defenseComponent.modifyDefense(by: Double(value) * 0.01)
            case .resistance:
                guard let resistanceComponent = entity.component(ofType: ResistanceComponent.self) else { continue }
                resistanceComponent.modifyResistance(by: Double(value) * 0.01)
            case .mitigation:
                guard let mitigationComponent = entity.component(ofType: MitigationComponent.self) else { continue }
                mitigationComponent.modifyMitigation(by: value)
            case .health:
                guard let healthComponent = entity.component(ofType: HealthComponent.self) else { continue }
                healthComponent.temporaryHP += value
            }
        }
    }
    
    /// Removes alterations from the given entity.
    ///
    /// - Parameter entity: The entity to alter.
    ///
    func remove(from entity: Entity) {
        for (key, value) in stats {
            switch key {
            case .ability(let ability):
                guard let abilityComponent = entity.component(ofType: AbilityComponent.self) else { continue }
                let currentValue = abilityComponent.temporaryValues[ability] ?? 0
                abilityComponent.temporaryValues[ability] = currentValue - value
            case .critical(let medium):
                guard let critComponent = entity.component(ofType: CriticalHitComponent.self) else { continue }
                switch medium {
                case .none:
                    critComponent.modifyCriticalChance(by: -Double(value) * 0.01)
                case .some:
                    critComponent.modifyCriticalChanceFor(medium: medium!, by: -Double(value) * 0.01)
                }
            case .damageCaused(let type):
                guard let dmgComponent = entity.component(ofType: DamageAdjustmentComponent.self) else { continue }
                switch type {
                case .none:
                    dmgComponent.modifyDamageCaused(by: -Double(value) * 0.01)
                case .some:
                    dmgComponent.modifyDamageCausedFor(type: type!, by: -Double(value) * 0.01)
                }
            case .damageTaken(let type):
                guard let dmgComponent = entity.component(ofType: DamageAdjustmentComponent.self) else { continue }
                switch type {
                case .none:
                    dmgComponent.modifyDamageTaken(by: -Double(value) * 0.01)
                case .some:
                    dmgComponent.modifyDamageTakenFor(type: type!, by: -Double(value) * 0.01)
                }
            case .defense:
                guard let defenseComponent = entity.component(ofType: DefenseComponent.self) else { continue }
                defenseComponent.modifyDefense(by: -Double(value) * 0.01)
            case .resistance:
                guard let resistanceComponent = entity.component(ofType: ResistanceComponent.self) else { continue }
                resistanceComponent.modifyResistance(by: -Double(value) * 0.01)
            case .mitigation:
                guard let mitigationComponent = entity.component(ofType: MitigationComponent.self) else { continue }
                mitigationComponent.modifyMitigation(by: -value)
            case .health:
                guard let healthComponent = entity.component(ofType: HealthComponent.self) else { continue }
                healthComponent.temporaryHP -= value
            }
        }
    }
}
