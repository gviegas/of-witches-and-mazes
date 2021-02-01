//
//  OcherBow.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/12/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// An `Item` that defines the Ocher Bow, a ranged weapon.
///
class OcherBowItem: UsableItem, PassiveItem, TradableItem, ResourceItem, DamageItem, AlterationItem, LevelItem,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.brownRecurveBow.imageName]
    }
    
    let name: String = "Ocher Bow"
    let icon: Icon = IconSet.Item.brownRecurveBow
    let category: ItemCategory = .rangedWeapon
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    var price: Int { return calculatePrice(basePrice: 83) }
    
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
    private init(other: OcherBowItem) {
        itemLevel = other.itemLevel
        requiredLevel = other.requiredLevel
        missile = other.missile
        alteration = other.alteration
    }
    
    required init(level: Int) {
        itemLevel = level
        requiredLevel = level
        
        let damage = Damage(scale: 1.15, ratio: 0.35, level: level,
                            modifiers: [.strength: 0.1, .agility: 0.4],
                            type: .physical, sfx: SoundFXSet.FX.genericHit)
        
        missile = Missile(medium: .ranged,
                          range: 840.0, speed: 512.0,
                          size: CGSize(width: 32.0, height: 16.0),
                          delay: 0.65, conclusion: 0.2, dissipateOnHit: true,
                          damage: damage, conditions: nil,
                          animation: (nil, ArrowItem.animation, nil),
                          sfx: SoundFXSet.FX.genericRangedAttack)
        
        let possibleScales: [AlterableStat: (scale: Double, ratio: Double)] = [
            .ability(.strength): (0.25, 0.15),
            .ability(.agility): (0.25, 0.15),
            .critical(.melee): (0.125, 0.15)]
        
        alteration = Alteration(guaranteedScales: [:], possibleScales: possibleScales,
                                rolls: 2...3, level: level)
    }
    
    func copy() -> Item {
        return OcherBowItem(other: self)
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("OcherBowItem can only be used by an entity that has a StateComponent")
        }
        guard let missileComponent = entity.component(ofType: MissileComponent.self) else {
            fatalError("OcherBowItem can only be used by an entity that has a MissileComponent")
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
