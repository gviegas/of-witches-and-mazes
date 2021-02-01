//
//  Interaction.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/1/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An enum that specifies the available groups to interact with.
///
enum InteractionGroup: UInt32 {
    case none = 0
    case protagonist = 0x01
    case monster = 0x02
    case npc = 0x04
    case companion = 0x08
    case destructible = 0x10
    case trap = 0x20
    case obstacle = 0x40
    case loot = 0x80
    case effect = 0x100
    case all = 0xffffffff
}

/// A class that defines which collisions and contacts should be considered for a group
/// of related objects.
///
class Interaction {
    
    /// The interaction for a protagonist entity.
    ///
    static let protagonist = Interaction(category: .protagonist,
                                         collisionGroups: [.monster, .npc, .destructible, .trap, .obstacle],
                                         contactGroups: [.monster, .destructible])
    
    /// The interaction for a monster entity.
    ///
    static let monster = Interaction(category: .monster,
                                     collisionGroups: [.protagonist, .companion, .npc, .destructible,
                                                       .trap, .obstacle],
                                     contactGroups: [.protagonist, .companion, .destructible])
    
    /// The interaction for a npc entity.
    ///
    static let npc = Interaction(category: .npc,
                                 collisionGroups: [.none],
                                 contactGroups: [.none])
    
    /// The interaction for a companion entity.
    ///
    static let companion = Interaction(category: .companion,
                                     collisionGroups: [.monster, .npc, .destructible, .trap, .obstacle],
                                     contactGroups: [.monster, .destructible])

    /// The interaction for things that can be destroyed.
    ///
    static let destructible = Interaction(category: .destructible,
                                          collisionGroups: [.npc, .destructible, .trap, .obstacle],
                                          contactGroups: [.none])
    
    /// The interaction for impassable/immovable traps.
    ///
    static let trap = Interaction(category: .trap,
                                  collisionGroups: [.none],
                                  contactGroups: [.none])
    
    /// The interaction for impassable/immovable things, like obstacle tiles and some inanimate object entities.
    ///
    static let obstacle = Interaction(category: .obstacle,
                                      collisionGroups: [.none],
                                      contactGroups: [.none])
    
    /// The interaction for dropped loot.
    ///
    static let loot = Interaction(category: .loot,
                                  collisionGroups: [.none],
                                  contactGroups: [.none])
    
    /// The interaction for protagonist's effects.
    ///
    static let protagonistEffect = Interaction(category: .effect,
                                               contactGroups: [.monster, .destructible])
    
    /// The interaction for protagonist's effects that must contact obstacles.
    ///
    static let protagonistEffectOnObstacle = Interaction(category: .effect,
                                                         contactGroups: [.monster, .destructible, .trap, .obstacle])
    
    /// The interaction for protagonist's effects that must contact other effects.
    ///
    static let protagonistEffectOnEffect = Interaction(category: .effect,
                                                       contactGroups: [.monster, .destructible, .effect])
    
    /// The interaction for protagonist's effects that must contact other effects and obstacles.
    ///
    static let protagonistEffectOnEffectAndObstacle = Interaction(category: .effect,
                                                                  contactGroups: [.monster, .destructible, .trap,
                                                                                  .effect, .obstacle])
    
    /// The interaction for monster's effects.
    ///
    static let monsterEffect = Interaction(category: .effect,
                                           contactGroups: [.protagonist, .companion, .destructible])
    
    /// The interaction for monster's effects that must contact obstacles.
    ///
    static let monsterEffectOnObstacle = Interaction(category: .effect,
                                                     contactGroups: [.protagonist, .companion, .destructible,
                                                                     .trap, .obstacle])
    
    /// The interaction for companion's effects.
    ///
    static let companionEffect = Interaction(category: .effect,
                                             contactGroups: [.monster, .destructible])
    
    /// The interaction for companion's effect that must contact obstacles.
    ///
    static let companionEffectOnObstacle = Interaction(category: .effect,
                                                       contactGroups: [.monster, .destructible, .trap, .obstacle])
    
    /// The interaction for neutral effects.
    ///
    static let neutralEffect = Interaction(category: .effect,
                                           contactGroups: [.protagonist, .companion, .monster, .destructible])
    
    /// The interaction for neutral effects that must contact obstacles.
    ///
    static let neutralEffectOnObstacle = Interaction(category: .effect,
                                                     contactGroups: [.protagonist, .companion, .monster,
                                                                     .destructible, .trap, .obstacle])
    
    /// The interaction for neutral effects that must contact other effects.
    ///
    static let neutralEffectOnEffect = Interaction(category: .effect,
                                                   contactGroups: [.protagonist, .companion, .monster,
                                                                   .destructible, .effect])
    
    /// The interaction for neutral effects that must contact obstacles but not traps.
    ///
    static let neutralEffectOnObstacleExcludingTrap = Interaction(category: .effect,
                                                                  contactGroups: [.protagonist, .companion, .monster,
                                                                                  .destructible, .obstacle])
    
    /// The category to which the object belongs.
    ///
    let category: InteractionGroup
    
    /// The groups which the object wants to collide with.
    ///
    let collisionGroups: Set<InteractionGroup>
    
    /// The groups which the object wants to contact.
    ///
    let contactGroups: Set<InteractionGroup>
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - category: The `InteractionGroup` that the interaction belongs to. The default value is `.none`.
    ///   - collisionGroups: A set of `InteractionGroup`s to collide with. The default value is `[.none]`.
    ///   - contactGroups: A set of `InteractionGroup`s to contact. The default value is `[.none]`.
    ///
    init(category: InteractionGroup = .none, collisionGroups: Set<InteractionGroup> = [.none],
         contactGroups: Set<InteractionGroup> = [.none]) {
        
        self.category = category
        self.collisionGroups = collisionGroups
        self.contactGroups = contactGroups
    }
    
    /// Applies the current interaction configuration on a physics body.
    ///
    /// - Parameter physicsBody: The physics body to update.
    ///
    func updateInteractions(onPhysicsBody physicsBody: SKPhysicsBody) {
        let convert = { (groups: Set<InteractionGroup>) -> UInt32 in
            var bitmask: UInt32 = 0
            for group in groups {
                bitmask |= group.rawValue
            }
            return bitmask
        }
        physicsBody.categoryBitMask = category.rawValue
        physicsBody.collisionBitMask = convert(collisionGroups)
        physicsBody.contactTestBitMask = convert(contactGroups)
    }
    
    /// Checks if a given physics body is an obstacle.
    ///
    /// - Parameter physicsBody: The `PhysicsBody` to check.
    /// - Returns: `true` if the physics body is an obstacle, `false` otherwise.
    ///
    static func isObstacle(physicsBody: SKPhysicsBody) -> Bool {
        return (physicsBody.categoryBitMask & InteractionGroup.obstacle.rawValue) != 0
    }
    
    /// Checks if a given physics body is an effect.
    ///
    /// - Parameter physicsBody: The `PhysicsBody` to check.
    /// - Returns: `true` if the physics body is an effect, `false` otherwise.
    ///
    static func isEffect(physicsBody: SKPhysicsBody) -> Bool {
        return (physicsBody.categoryBitMask & InteractionGroup.effect.rawValue) != 0
    }
    
    /// Checks if a given physics body has interest in another one.
    ///
    /// This method checks if the `otherBody`s category is presented in the `physicsBody`'s
    /// contact groups, which can be useful when deciding to who a contact notification must be sent.
    ///
    /// - Parameters:
    ///   - physicsBody: The physics body whose interest must be checked.
    ///   - otherBody: The physics body to check as a possible source of interest.
    /// - Returns: `true` if `physicsBody` has interest in `otherBody`, `false` otherwise.
    ///
    static func hasInterest(_ physicsBody: SKPhysicsBody, in otherBody: SKPhysicsBody) -> Bool {
        return (physicsBody.contactTestBitMask & otherBody.categoryBitMask) != 0
    }
}
