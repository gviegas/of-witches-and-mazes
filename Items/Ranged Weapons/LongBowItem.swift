//
//  LongBowItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 10/27/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` that defines the Long Bow, a ranged weapon.
///
class LongBowItem: UsableItem, PassiveItem, TradableItem, ResourceItem, DamageItem, AlterationItem, LevelItem,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.longBow.imageName]
    }
    
    let name: String = "Long Bow"
    let icon: Icon = IconSet.Item.longBow
    let category: ItemCategory = .rangedWeapon
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 35) }
    
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
    private init(other: LongBowItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        missile = other.missile
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let damage = Damage(scale: 1.05, ratio: 0.2, level: level,
                            modifiers: [.agility: 0.4],
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
        return LongBowItem(other: self)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("LongBowItem can only be used by an entity that has a StateComponent")
        }
        guard let missileComponent = entity.component(ofType: MissileComponent.self) else {
            fatalError("LongBowItem can only be used by an entity that has a MissileComponent")
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
