//
//  HealthComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/8/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A protocol that defines the health delegate, used by the `HealthComponent` when its
/// entity takes damage or restores health.
///
protocol HealthDelegate: AnyObject {
    
    /// Informs the delegate that the entity was damaged.
    ///
    /// - Parameters:
    ///   - amount: The amount of damage suffered.
    ///   - source: An optional `Entity` instance to be identified as the source of damage.
    ///
    func didSufferDamage(amount: Int, source: Entity?)
    
    /// Informs the delegate that the entity was healed.
    ///
    /// - Parameters:
    ///   - amount: The amount of healing received.
    ///   - source: An optional `Entity` instance to be identified as the source of healing.
    ///
    func didRestoreHP(amount: Int, source: Entity?)
    
    /// Informs the delegate that the entity has died.
    ///
    /// - Parameter source: An optional `Entity` instance to be identified as the source of the killing.
    ///
    func didDie(source: Entity?)
}

/// A component that provides an entity with health points, enabling it to be damaged.
///
class HealthComponent: Component {
    
    /// The range of valid values of health points.
    ///
    static let hpRange = 1...100_000
    
    /// The total damage taken by the entity.
    ///
    private var damageTaken = 0 {
        didSet {
            damageTaken = min(totalHp, max(0, damageTaken))
            if isImmortal { damageTaken = min(totalHp - 1, damageTaken) }
            broadcast()
        }
    }
    
    /// The private backing for the multiplier property.
    ///
    private var _multiplier: Double = 1.0
    
    /// The multiplier bounds.
    ///
    let bounds = 0.0...3.0
    
    /// The flag stating whether the entity can die.
    ///
    /// When this property is `true`, damage that would otherwise kill the entity cause its current health
    /// points to become equal to `1` instead.
    ///
    var isImmortal = false
    
    /// The base health points of the entity.
    ///
    var baseHP: Int {
        didSet {
            baseHP = min(HealthComponent.hpRange.upperBound, max(HealthComponent.hpRange.lowerBound, baseHP))
            broadcast()
        }
    }
    
    /// The temporary health points of the entity.
    ///
    /// This value is added to the entity's base HP to compute the total HP. Items, conditions
    /// and other temporary modifications should be applied to this property.
    ///
    var temporaryHP = 0 {
        didSet {
            damageTaken = min(damageTaken, totalHp - 1)
            broadcast()
        }
    }
    
    /// The multiplier applied when computing the total health points.
    ///
    var multiplier: Double {
        return max(bounds.lowerBound, min(bounds.upperBound, _multiplier))
    }
    
    /// The total health points of the entity, ignoring damage taken.
    ///
    var totalHp: Int {
        let hp = Int((Double(baseHP + temporaryHP) * multiplier).rounded())
        return min(HealthComponent.hpRange.upperBound, max(HealthComponent.hpRange.lowerBound, hp))
    }
    
    /// The current health points of the entity, considering damage taken.
    ///
    var currentHP: Int {
        return max(0, totalHp - damageTaken)
    }
    
    /// A flag stating whether or not the entity is dead.
    ///
    var isDead: Bool {
        return currentHP == 0
    }
    
    /// The assigned HealthDelegate.
    ///
    weak var delegate: HealthDelegate?
    
    /// Creates a new instance with the given health points and delegate.
    ///
    /// - Parameters:
    ///   - baseHP: The base health points of the entity.
    ///   - delegate: An optional `HealthDelegate` instance to be called when suffering damage.
    ///
    init(baseHP: Int, delegate: HealthDelegate?) {
        assert(baseHP > 0)
        self.baseHP = baseHP
        self.delegate = delegate
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Causes damage to the entity.
    ///
    /// - Parameters:
    ///   - amount: The amount of damage to cause.
    ///   - source: An optional `Entity` instance to be identified as the source of damage.
    ///     The default value is `nil`.
    /// - Returns: The amount of damage inflicted.
    ///
    @discardableResult
    func causeDamage(_ amount: Int, source: Entity? = nil) -> Int {
        guard !isDead else { return  0 }
        damageTaken += amount
        isDead ? delegate?.didDie(source: source) : delegate?.didSufferDamage(amount: amount, source: source)
        return amount
    }
    
    /// Restores health points.
    ///
    /// - Parameters:
    ///   - amount: The amount of health points to restore.
    ///   - source: An optional `Entity` instance to be identified as the source of healing.
    /// - Returns: The amount of health points restored.
    ///
    @discardableResult
    func restoreHP(_ amount: Int, source: Entity? = nil) -> Int {
        let previousHP = currentHP
        damageTaken -= amount
        let restored = currentHP - previousHP
        delegate?.didRestoreHP(amount: restored, source: source)
        return restored
    }
    
    /// Modifies the health multiplier by the given amount.
    ///
    /// - Parameter amount: The amount to be summed with the current value.
    ///
    func modifyMultiplier(by amount: Double) {
        _multiplier += amount
        if isDead { delegate?.didDie(source: nil) }
        broadcast()
    }
    
    /// Checks if the health multiplier is capped towards its lower bound (i.e., it cannot be
    /// decreased any further).
    ///
    /// - Returns: `true` if capped, `false` otherwise.
    ///
    func isMultiplierLowerCapped() -> Bool {
        return _multiplier <= bounds.lowerBound
    }
    
    /// Checks if the health multiplier is capped towards its upper bound (i.e., it cannot be
    /// increased any further).
    ///
    /// - Returns: `true` if capped, `false` otherwise.
    ///
    func isMultiplierUpperCapped() -> Bool {
        return _multiplier >= bounds.upperBound
    }
}
