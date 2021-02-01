//
//  HuntingBowItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 3/5/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` that defines the Hunting Bow, a ranged weapon.
///
class HuntingBowItem: UsableItem, PassiveItem, TradableItem, ResourceItem, DamageItem, AlterationItem,
LevelItem, TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.huntingBow.imageName]
    }
    
    let name: String = "Hunting Bow"
    let icon: Icon = IconSet.Item.huntingBow
    let category: ItemCategory = .rangedWeapon
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 34) }
    
    let resourceName = "Arrow"
    let resourceCost = 1
    
    let missile: Missile
    var damage: Damage { return missile.damage! }
    
    var alteration: Alteration
    
    let itemLevel: Int
    let requiredLevel: Int
    
    /// Creates a new instance from another's data.
    ///
    /// - Parameter other: The other item from which to get the data.
    ///
    private init(other: HuntingBowItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        missile = other.missile
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let damage = Damage(scale: 1.1, ratio: 0.25, level: level,
                            modifiers: [.agility: 0.35],
                            type: .physical, sfx: SoundFXSet.FX.genericHit)
        
        missile = Missile(medium: .ranged,
                          range: 840.0, speed: 512.0,
                          size: CGSize(width: 32.0, height: 16.0),
                          delay: 0.65, conclusion: 0.2, dissipateOnHit: true,
                          damage: damage, conditions: nil,
                          animation: (nil, ArrowItem.animation, nil),
                          sfx: SoundFXSet.FX.genericRangedAttack)
        
        let possibleScales: [AlterableStat: (scale: Double, ratio: Double)] = [
            .ability(.agility): (0.2, 0.15),
            .critical(.ranged): (0.1, 0.15),
            .damageCaused(.physical): (0.1, 0.15)]
        
        alteration = Alteration(guaranteedScales: [:], possibleScales: possibleScales,
                                rolls: 1...2, level: level)
    }
    
    func copy() -> Item {
        return HuntingBowItem(other: self)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("HuntingBowItem can only be used by an entity that has a StateComponent")
        }
        guard let missileComponent = entity.component(ofType: MissileComponent.self) else {
            fatalError("HuntingBowItem can only be used by an entity that has a MissileComponent")
        }
        
        guard consumeResources(from: entity) else {
            if let scene = SceneManager.levelScene {
                let note = NoteOverlay(rect: scene.frame, text: "No arrows")
                scene.presentNote(note)
            }
            return
        }
        
        missileComponent.missile = missile
        stateComponent.enter(namedState: .shot)
    }
    
    func didEquip(onEntity entity: Entity) {
        alteration.apply(to: entity)
    }
    
    func didUnequip(onEntity entity: Entity) {
        alteration.remove(from: entity)
    }
}
