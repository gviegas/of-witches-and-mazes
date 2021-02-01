//
//  Combat.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 6/2/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A protocol that enables an `Entity` to be notified about combat actions made against itself.
///
protocol CombatResponder: Entity {
    
    /// Informs the entity that it was targeted by a hostile action.
    ///
    /// - Parameters:
    ///   - source: The `Entity` instance that caused the action.
    ///   - outcome: The `CombatOutcome` value defining the outcome of the action.
    ///
    func didReceiveHostileAction(from source: Entity?, outcome: CombatOutcome)
    
    /// Informs the entity that it was targeted by a friendly action.
    ///
    /// - Parameters:
    ///   - source: The `Entity` instance that caused the action.
    ///   - outcome: The `CombatOutcome` value defining the outcome of the action.
    ///
    func didReceiveFriendlyAction(from source: Entity?, outcome: CombatOutcome)
}

/// An enum representing the possible outcomes of combat actions.
///
enum CombatOutcome {
    case damage(Int)
    case healing(Int)
    case defense
    case resistance
}

/// A struct that manages combat actions.
///
struct Combat {
    
    private init() {}
    
    /// Performs a hostile combat action.
    ///
    /// - Parameters:
    ///   - medium: The `Medium` type used to carry out the action.
    ///   - target: The `Entity` instance that was targeted by the action.
    ///   - source: The `Entity` instance that caused the action.
    ///   - damage: The `Damage` instance for the action.
    ///   - conditions: The `Condition` list holding the conditions for the action.
    ///   - unavoidable: The flag stating whether the action is unavoidable. If set to `true`,
    ///     no hit checks (defense, resistance) are performed. The default value is `false`.
    /// - Returns: A `CombatOutcome` value defining the outcome of the combat action.
    ///
    @discardableResult
    static func carryOutHostileAction(using medium: Medium, on target: Entity, as source: Entity?,
                                      damage: Damage?, conditions: [Condition]?,
                                      unavoidable: Bool = false) -> CombatOutcome {
        
        let outcome: CombatOutcome
        var defended = false
        var resisted = false
        
        let vulnerable = target.component(ofType: VulnerabilityComponent.self)?.isVulnerable ?? false
        if !unavoidable && !vulnerable {
            switch medium {
            case .melee, .ranged:
                guard let defenseComponent = target.component(ofType: DefenseComponent.self) else { break }
                defended = defenseComponent.defend()
            case .spell, .power:
                guard let resistanceComponent = target.component(ofType: ResistanceComponent.self) else { break }
                resisted = resistanceComponent.resist()
            default:
                break
            }
        }
        
        if defended {
            didDefend(medium: medium, target: target, source: source, damage: damage, conditions: conditions)
            outcome = .defense
        } else if resisted {
            didResist(medium: medium, target: target, source: source, damage: damage, conditions: conditions)
            outcome = .resistance
        } else {
            let damageCaused = damage?.inflict(using: medium, on: target, from: source) ?? 0
            outcome = .damage(damageCaused)
            if target.component(ofType: HealthComponent.self)?.isDead != true {
                if let conditions = conditions, !conditions.isEmpty {
                    if let conditionComponent = target.component(ofType: ConditionComponent.self) {
                        conditions.forEach { let _ = conditionComponent.applyCondition($0) }
                    }
                }
            }
        }
        
        (target as? CombatResponder)?.didReceiveHostileAction(from: source, outcome: outcome)
        return outcome
    }
    
    /// Performs a friendly combat action.
    ///
    /// - Parameters:
    ///   - medium: The `Medium` type used to carry out the action.
    ///   - target: The `Entity` instance that was targeted by the action.
    ///   - source: The `Entity` instance that caused the action.
    ///   - healing: The `Healing` instance for the action.
    ///   - conditions: The `Condition` list holding the conditions for the action.
    /// - Returns: A `CombatOutcome` value defining the outcome of the combat action.
    ///
    @discardableResult
    static func carryOutFriendlyAction(using medium: Medium, on target: Entity, as source: Entity?,
                                       healing: Healing?, conditions: [Condition]?) -> CombatOutcome {
        
        let healingApplied = healing?.heal(target: target, source: source) ?? 0
        if target.component(ofType: HealthComponent.self)?.isDead != true {
            if let conditions = conditions, !conditions.isEmpty {
                if let conditionComponent = target.component(ofType: ConditionComponent.self) {
                    conditions.forEach { let _ = conditionComponent.applyCondition($0) }
                }
            }
        }
        
        let outcome = CombatOutcome.healing(healingApplied)
        (target as? CombatResponder)?.didReceiveFriendlyAction(from: source, outcome: outcome)
        return outcome
    }
    
    /// Applies defense-related procedures.
    ///
    /// - Parameters:
    ///   - medium: The `Medium` type used to carry out the action.
    ///   - target: The `Entity` instance that was targeted by the action and was able to defend.
    ///   - source: The `Entity` instance that caused the action.
    ///   - damage: The `Damage` instance for the action.
    ///   - conditions: The `Condition` list holding the conditions for the action.
    ///
    private static func didDefend(medium: Medium, target: Entity, source: Entity?, damage: Damage?,
                                  conditions: [Condition]?) {
        
        if let nodeComponent = target.component(ofType: NodeComponent.self) {
            SoundFXSet.FX.defense.play(at: nodeComponent.node.position, sceneKind: .level)
        }
        target.component(ofType: LogComponent.self)?.writeEntry(content: "Defended", style: .emphasis)
        
        guard let source = source  else { return }
        
        // Apply target's stunning defense
        target.component(ofType: StunningDefenseComponent.self)?.stun(target: source)
        
        // Apply target's counter
        target.component(ofType: CounterComponent.self)?.counter(medium: medium, target: source,
                                                                 damage: damage, conditions: conditions)
    }
    
    /// Applies resistance-related procedures.
    ///
    /// - Parameters:
    ///   - medium: The `Medium` type used to carry out the action.
    ///   - target: The `Entity` instance that was targeted by the action and was able to resist.
    ///   - source: The `Entity` instance that caused the action.
    ///   - damage: The `Damage` instance for the action.
    ///   - conditions: The `Condition` list holding the conditions for the action.
    ///
    private static func didResist(medium: Medium, target: Entity, source: Entity?, damage: Damage?,
                                  conditions: [Condition]?) {
        
        if let nodeComponent = target.component(ofType: NodeComponent.self) {
            SoundFXSet.FX.evade.play(at: nodeComponent.node.position, sceneKind: .level)
        }
        target.component(ofType: LogComponent.self)?.writeEntry(content: "Resisted", style: .emphasis)
        
        guard let source = source  else { return }
        
        // Apply target's counter
        target.component(ofType: CounterComponent.self)?.counter(medium: medium, target: source,
                                                                 damage: damage, conditions: conditions)
    }
}
