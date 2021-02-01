//
//  RoyalSwordItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/27/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` that defines the Royal Sword, a melee weapon.
///
class RoyalSwordItem: UsableItem, PassiveItem, TradableItem, DamageItem, AlterationItem, LevelItem,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.royalSword.imageName]
    }
    
    let name: String = "Royal Sword"
    let icon: Icon = IconSet.Item.royalSword
    let category: ItemCategory = .meleeWeapon
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 135) }
    
    let attack: Attack
    var damage: Damage { return attack.damage }
    
    var alteration: Alteration
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: RoyalSwordItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        attack = other.attack
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let damage = Damage(scale: 1.25, ratio: 0.2, level: level,
                            modifiers: [.strength: 0.3, .agility: 0.1, .faith: 0.1],
                            type: .physical, sfx: SoundFXSet.FX.hit)
        
        attack = Attack(medium: .melee, damage: damage,
                        reach: 48.0, broadness: 64.0,
                        delay: 0.15, duration: 0.1, conclusion: 0.15, conditions: nil,
                        sfx: SoundFXSet.FX.attack)
        
        let possibleScales: [AlterableStat: (scale: Double, ratio: Double)] = [
            .ability(.strength): (0.25, 0.15),
            .ability(.agility): (0.25, 0.15),
            .ability(.faith): (0.25, 0.15),
            .critical(.melee): (0.125, 0.15),
            .damageCaused(.physical): (0.125, 0.15)]
        
        alteration = Alteration(guaranteedScales: [:], possibleScales: possibleScales,
                                rolls: 3...3, level: level)
    }
    
    func copy() -> Item {
        return RoyalSwordItem(other: self)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("RoyalSwordItem can only be used by an entity that has a StateComponent")
        }
        guard let attackComponent = entity.component(ofType: AttackComponent.self) else {
            fatalError("RoyalSwordItem can only be used by an entity that has an AttackComponent")
        }
        
        attackComponent.attack = attack
        stateComponent.enter(namedState: .attack)
    }
    
    func didEquip(onEntity entity: Entity) {
        alteration.apply(to: entity)
    }
    
    func didUnequip(onEntity entity: Entity) {
        alteration.remove(from: entity)
    }
}
