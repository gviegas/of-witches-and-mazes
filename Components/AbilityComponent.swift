//
//  AbilityComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/29/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// An enum that defines the names of the abilities.
///
enum Ability: String, Comparable {
    case strength = "Strength"
    case agility = "Agility"
    case intellect = "Intellect"
    case faith = "Faith"

    /// An array containing each ability name, in the order that they should be displayed.
    ///
    static let asArray: [Ability] = [.strength, .agility, .intellect, .faith]
    
    /// The textual description of the ability.
    ///
    var description: String {
        let desc: String
        switch self {
        case .strength:
            desc = "The character's strength. Controls the efficacy of melee weapons."
        case .agility:
            desc = "The character's agility. Controls the efficacy of ranged weapons."
        case.intellect:
            desc = "The character's intellect. Controls the efficacy of spells."
        case.faith:
            desc = "The character's faith. Controls the efficacy of spiritual powers."
        }
        return desc
    }
    
    static func < (lhs: Ability, rhs: Ability) -> Bool {
        let order: [Ability: Int] = [.strength: 1, .agility: 2, .intellect: 3, .faith: 4]
        return order[lhs]! < order[rhs]!
    }
}

/// A component that provides an entity with abilities.
///
class AbilityComponent: Component {
    
    /// The range of allowed values for an ability.
    ///
    static let valueRange = 0...1000
    
    /// The base values of the abilities.
    ///
    private var baseValues: [Ability: Int] {
        didSet { broadcast() }
    }
    
    /// The temporary values of the abilities.
    ///
    /// This values can be modified at will. They will be added to the base value of same name
    /// to compute the total value of an ability.
    ///
    var temporaryValues: [Ability: Int] {
        didSet { broadcast() }
    }
    
    /// Sets the base value of an ability.
    ///
    /// - Parameters:
    ///   - ability: The ability to set.
    ///   - value: The value to set.
    ///
    func setBaseValue(of ability: Ability, value: Int) {
        let range = AbilityComponent.valueRange
        baseValues[ability] = min(range.upperBound, max(range.lowerBound, value))
    }
    
    /// Retrieves the base value of an ability.
    ///
    /// - Parameter ability: The ability whose value is to be retrieved.
    /// - Returns: The value.
    ///
    func baseValue(of ability: Ability) -> Int {
        return baseValues[ability] ?? AbilityComponent.valueRange.lowerBound
    }
    
    /// Retrieves the total value of an ability.
    ///
    /// - Parameter ability: The ability whose value is to be retrieved.
    /// - Returns: The value.
    ///
    func totalValue(of ability: Ability) -> Int {
        let value = (baseValues[ability] ?? 0) + (temporaryValues[ability] ?? 0)
        let range = AbilityComponent.valueRange
        return min(range.upperBound, max(range.lowerBound, value))
    }
    
    /// Creates a new instance from the given dictionary of abilities.
    ///
    /// - Parameter abilities: A dictionary containing the base value of each ability.
    ///
    init(abilities: [Ability: Int]) {
        baseValues = abilities
        temporaryValues = [:]
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
