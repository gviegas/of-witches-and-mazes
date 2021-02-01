//
//  GrimoireOfDispelMagicItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 5/13/19.
//  Copyright © 2019 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Item` type that defines the Grimoire of Dispel Magic, used to cast the Dispel Magic spell.
///
class GrimoireOfDispelMagicItem: UsableItem, TradableItem, DescribableItem, ResourceItem, InitializableItem,
TextureUser {
    
    static var textureNames: Set<String> {
        return [IconSet.Item.orangeTome.imageName]
    }
    
    let name: String = "Grimoire of Dispel Magic"
    let icon: Icon = IconSet.Item.orangeTome
    let category: ItemCategory = .spellBook
    let isUnique: Bool = false
    let isDiscardable: Bool = true
    let isEquippable: Bool = true
    let price: Int = 3100
    
    let resourceName = "Spell Components"
    let resourceCost = 14
    
    let influence: Influence = DispelMagic()
    
    required init() {}
    
    func copy() -> Item {
        return GrimoireOfDispelMagicItem()
    }
    
    func didUse(onEntity entity: Entity) {
        guard let stateComponent = entity.component(ofType: StateComponent.self) else {
            fatalError("GrimoireOfDispelMagicItem can only be used by an entity that has a StateComponent")
        }
        guard let castComponent = entity.component(ofType: CastComponent.self) else {
            fatalError("GrimoireOfDispelMagicItem can only be used by an entity that has a CastComponent")
        }
        
        let spell = Spell(kind: .localInfluence, effect: influence,
                          castTime: (influence.delay, influence.duration, influence.conclusion))
        castComponent.spell = spell
        castComponent.spellBook = self
        stateComponent.enter(namedState: .cast)
    }
    
    func descriptionFor(entity: Entity) -> String {
        return """
        Casts a spell that causes magical effects to be dispelled.
        """
    }
}

/// An `Influence` type representing the Dispel Magic effect.
///
fileprivate class DispelMagic: Influence {
    
    let interaction: Interaction = Interaction(category: .effect, contactGroups: [.effect, .monster])
    let radius: CGFloat = 525.0
    let range: CGFloat = 0
    let delay: TimeInterval = 0.5
    let duration: TimeInterval = 1.5
    let conclusion: TimeInterval = 0.5
    let animation: Animation? = nil
    let sfx: SoundFX? = SoundFXSet.FX.magnet
    
    func didInfluence(node: SKNode, source: Entity?) {
        guard node.entity == nil || node.entity != source else { return }
        
        if let node = node as? MissileNode {
            node.wasAffectedByDispel()
        } else if let node = node as? BlastNode {
            node.wasAffectedByDispel()
        } else if let node = node as? RayNode {
            node.wasAffectedByDispel()
        } else if let targetEntity = node.entity {
            if targetEntity.component(ofType: BarrierComponent.self)?.barrier?.affectedByDispel == true {
               targetEntity.component(ofType: BarrierComponent.self)!.barrier = nil
            }
            if targetEntity.component(ofType: AuraComponent.self)?.aura?.affectedByDispel == true {
                targetEntity.component(ofType: AuraComponent.self)!.aura = nil
            }
        }
    }
}
