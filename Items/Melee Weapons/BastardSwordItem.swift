//
//  BastardSwordItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` that defines the Bastard Sword, a melee weapon.
///
class BastardSwordItem: UsableItem, PassiveItem, TradableItem, DamageItem, AlterationItem, LevelItem,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.bastardSword.imageName]
    }
    
    let name: String = "Bastard Sword"
    let icon: Icon = IconSet.Item.bastardSword
    let category: ItemCategory = .meleeWeapon
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 100) }
    
    let attack: Attack
    var damage: Damage { return attack.damage }
    
    var alteration: Alteration
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: BastardSwordItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        attack = other.attack
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let damage = Damage(scale: 1.25, ratio: 0.2, level: level,
                            modifiers: [.strength: 0.35, .agility: 0.15],
                            type: .physical, sfx: SoundFXSet.FX.hit)
        
        attack = Attack(medium: .melee, damage: damage,
                        reach: 48.0, broadness: 64.0,
                        delay: 0.15, duration: 0.1, conclusion: 0.15, conditions: nil,
                        sfx: SoundFXSet.FX.attack)
        
        let possibleScales: [AlterableStat: (scale: Double, ratio: Double)] = [
            .ability(.strength): (0.25, 0.15),
            .ability(.agility): (0.25, 0.15),
            .critical(.melee): (0.125, 0.15),
            .damageCaused(.physical): (0.125, 0.15)]
        
        alteration = Alteration(guaranteedScales: [:], possibleScales: possibleScales,
                                rolls: 2...3, level: level)
    }
    
    func copy() -> Item {
        return BastardSwordItem(other: self)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("BastardSwordItem can only be used by an entity that has a StateComponent")
        }
        guard let attackComponent = entity.component(ofType: AttackComponent.self) else {
            fatalError("BastardSwordItem can only be used by an entity that has an AttackComponent")
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
