//
//  TooltipOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/24/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Overlay` type that creates tooltips.
///
class TooltipOverlay: Overlay, TextureUser {
    
    static var textureNames: Set<String> {
        return TooltipOverlayData.textureNames
    }
    
    var node: SKNode
    
    /// The `UITooltipElement` instance.
    ///
    private let tooltipElement: UITooltipElement
    
    /// Creates a new instance from the given values.
    ///
    /// - Parameters:
    ///   - boundingRect: The bounding rect. The tooltip will be positioned inside this rect.
    ///   - referenceRect: The reference rect, which must be contained in the `boundingRect`.
    ///     The tooltip will be positioned close to this rect.
    ///   - entries: An array of `UITooltipElement.Entry` holding the tooltip contents.
    ///
    private init(boundingRect: CGRect, referenceRect: CGRect, entries: [UITooltipElement.Entry]) {
        assert(boundingRect.contains(referenceRect))
        
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound + 12
        
        // Create the tooltip element
        tooltipElement = UITooltipElement(entries: entries,
                                          contentOffset: TooltipOverlayData.Tooltip.contentOffset,
                                          minLabelSize: TooltipOverlayData.Tooltip.minLabelSize,
                                          maxLabelSize: TooltipOverlayData.Tooltip.maxLabelSize,
                                          backgroundImage: TooltipOverlayData.Tooltip.backgroundImage,
                                          backgroundBorder: TooltipOverlayData.Tooltip.backgroundBorder,
                                          backgroundOffset: TooltipOverlayData.Tooltip.backgroundOffset)
        
        // Compute the element's rect
        let origin: CGPoint
        let size = tooltipElement.size
        if referenceRect.midX > boundingRect.midX {
            // Put to the left
            let x = max(boundingRect.minX, referenceRect.minX - size.width)
            if referenceRect.midY > boundingRect.midY {
                // And below
                origin = CGPoint(x: x, y: max(boundingRect.minY, referenceRect.minY - size.height))
            } else {
                // And above
                let bleed = (referenceRect.maxY + size.height) > boundingRect.maxY
                let y = bleed ? boundingRect.maxY - size.height : referenceRect.maxY
                origin = CGPoint(x: x, y: y)
            }
        } else {
            // Put to the right
            let bleed = (referenceRect.maxX + size.width) > boundingRect.maxX
            let x = bleed ? boundingRect.maxX - size.width : referenceRect.maxX
            if referenceRect.midY > boundingRect.midY {
                // And below
                origin = CGPoint(x: x, y: max(boundingRect.minY, referenceRect.minY - size.height))
            } else {
                // And above
                let bleed = (referenceRect.maxY + size.height) > boundingRect.maxY
                let y = bleed ? boundingRect.maxY - size.height : referenceRect.maxY
                origin = CGPoint(x: x, y: y)
            }
        }
        let rect = CGRect(origin: origin, size: size)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(tooltipElement)
        let tree = UITree(rect: rect, root: container)
        if let treeNode = tree.generate() {
            treeNode.zPosition = 1
            node.addChild(treeNode)
        }
    }
    
    func update(deltaTime seconds: TimeInterval) {
        
    }
    
    /// Creates a tooltip overlay describing an `Item`.
    ///
    /// - Parameters:
    ///   - boundingRect: The bounding rect. The tooltip will be positioned inside this rect.
    ///   - referenceRect: The reference rect, which must be contained in the `boundingRect`.
    ///     The tooltip will be positioned close to this rect.
    ///   - item: The item to describe.
    ///   - item: The entity that the item pertains.
    ///   - price: An optional price to display in the tooltip. The default value is `nil`.
    /// - Returns: A new `TooltipOverlay` instance describing the item.
    ///
    class func itemTooltip(boundingRect: CGRect, referenceRect: CGRect, item: Item, entity: Entity,
                           price: Int? = nil) -> TooltipOverlay {
        
        var entries = [UITooltipElement.Entry]()
        
        // Name
        entries.append(.label(style: .subtitle, text: item.name))
        
        // Description
        if let item = item as? DescribableItem {
            entries.append(.label(style: .text, text: item.descriptionFor(entity: Game.protagonist!)))
        }
        
        // Level
        if let item = item as? LevelItem {
            entries.append(.label(style: .emphasis, text: "Requires Level \(item.requiredLevel)"))
        }
        
        // Category
        entries.append(.label(style: .emphasis, text: "Category: \(item.category.rawValue)"))
        
        // Damage
        if let item = item as? DamageItem {
            let baseDamage: String
            if item.damage.baseDamage.lowerBound != item.damage.baseDamage.upperBound {
                baseDamage = "\(item.damage.baseDamage.lowerBound)-\(item.damage.baseDamage.upperBound) Damage"
            } else {
                baseDamage = "\(item.damage.baseDamage.lowerBound) Damage"
            }
            entries.append(.label(style: .value, text: baseDamage))
            
            for (key, value) in item.damage.modifiers.sorted(by: { $0.key < $1.key }) {
                let bonusDamage = "\(Int((value * 100.0).rounded()))% bonus from \(key.rawValue)"
                entries.append(.label(style: .modifier, text: bonusDamage))
            }
        }
        
        // Healing
        if let item = item as? HealingItem {
            let baseHealing: String
            switch item.healing.baseHealing {
            case .absolute(let range):
                if range.lowerBound != range.upperBound {
                    baseHealing = "\(range.lowerBound)-\(range.upperBound) Healing"
                } else {
                    baseHealing = "\(range.lowerBound) Healing"
                }
            case .percentage(let range):
                let lowerBound = Int((range.lowerBound * 100.0).rounded())
                let upperBound = Int((range.upperBound * 100.0).rounded())
                if lowerBound != upperBound {
                    baseHealing = "\(lowerBound)%-\(upperBound)% Healing"
                } else {
                    baseHealing = "\(lowerBound)% Healing"
                }
            }
            entries.append(.label(style: .value, text: baseHealing))
            
            if let modifiers = item.healing.modifiers {
                for (key, value) in modifiers.sorted(by: { $0.key < $1.key }) {
                    let bonusHealing = "\(Int((value * 100.0).rounded()))% bonus from \(key.rawValue)"
                    entries.append(.label(style: .modifier, text: bonusHealing))
                }
            }
        }
        
        // DamageOverTime
        if let item = item as? DamageOverTimeItem {
            let baseDamage: String
            let itemDamage = item.damageOverTime.tickDamage
            if let duration = item.damageOverTime.duration {
                let ticks = Int(max(1.0, duration / item.damageOverTime.tickTime))
                let lowerBound = itemDamage.baseDamage.lowerBound * ticks
                let upperBound = itemDamage.baseDamage.upperBound * ticks
                if lowerBound != upperBound {
                    baseDamage = "\(lowerBound)-\(upperBound) Damage over \(Int(duration)) sec."
                } else {
                    baseDamage = "\(lowerBound) Damage over \(Int(duration)) sec."
                }
            } else {
                let tick = item.damageOverTime.tickTime
                let lowerBound = itemDamage.baseDamage.lowerBound
                let upperBound = itemDamage.baseDamage.upperBound
                if lowerBound != upperBound {
                    baseDamage = "\(lowerBound)-\(upperBound) Damage every \(tick) sec."
                } else {
                    baseDamage = "\(lowerBound) Damage every \(tick) sec."
                }
            }
            entries.append(.label(style: .value, text: baseDamage))
            for (key, value) in itemDamage.modifiers.sorted(by: { $0.key < $1.key }) {
                let bonusDamage = "\(Int((value * 100.0).rounded()))% bonus from \(key.rawValue)"
                entries.append(.label(style: .modifier, text: bonusDamage))
            }
        }
        
        // HealingOverTime
        if let item = item as? HealingOverTimeItem {
            let baseHealing: String
            let itemHealing = item.healingOverTime.tickHealing
            if let duration = item.healingOverTime.duration {
                let ticks = Int(max(1.0, duration / item.healingOverTime.tickTime))
                switch itemHealing.baseHealing {
                case .absolute(let range):
                    let lowerBound = range.lowerBound * ticks
                    let upperBound = range.upperBound * ticks
                    if lowerBound != upperBound {
                        baseHealing = "\(lowerBound)-\(upperBound) Healing over \(Int(duration)) sec."
                    } else {
                        baseHealing = "\(lowerBound) Healing over \(Int(duration)) sec."
                    }
                case .percentage(let range):
                    let lowerBound = Int((range.lowerBound * 100.0).rounded()) * ticks
                    let upperBound = Int((range.upperBound * 100.0).rounded()) * ticks
                    if lowerBound != upperBound {
                        baseHealing = "\(lowerBound)%-\(upperBound)% Healing over \(Int(duration)) sec."
                    } else {
                        baseHealing = "\(lowerBound)% Healing over \(Int(duration)) sec."
                    }
                }
            } else {
                let tick = item.healingOverTime.tickTime
                switch itemHealing.baseHealing {
                case .absolute(let range):
                    if range.lowerBound != range.upperBound {
                        baseHealing = "\(range.lowerBound)-\(range.upperBound) Healing every \(tick) sec."
                    } else {
                        baseHealing = "\(range.lowerBound) Healing every \(tick) sec."
                    }
                case .percentage(let range):
                    let lowerBound = Int((range.lowerBound * 100.0).rounded())
                    let upperBound = Int((range.upperBound * 100.0).rounded())
                    if lowerBound != upperBound {
                        baseHealing = "\(lowerBound)%-\(upperBound)% Healing every \(tick) sec."
                    } else {
                        baseHealing = "\(lowerBound)% Healing every \(tick) sec."
                    }
                }
            }
            entries.append(.label(style: .value, text: baseHealing))
            if let modifiers = itemHealing.modifiers {
                for (key, value) in modifiers.sorted(by: { $0.key < $1.key }) {
                    let bonusHealing = "\(Int((value * 100.0).rounded()))% bonus from \(key.rawValue)"
                    entries.append(.label(style: .modifier, text: bonusHealing))
                }
            }
        }
        
        // Alteration
        if let item = item as? AlterationItem {
            for (key, value) in item.alteration.stats.sorted(by: { $0.key < $1.key }) {
                entries.append(.label(style: .value, text: key.asString(with: value)))
            }
        }
        
        // Resource
        if let item = item as? ResourceItem {
            let resourceCost: Int
            if let resourceUsageComponent = entity.component(ofType: ResourceUsageComponent.self) {
                resourceCost = resourceUsageComponent.alterCost(of: item, cost: nil)
            } else {
                resourceCost = item.resourceCost
            }
            var text = "Uses \(item.resourceName)"
            if item.resourceCost > 0 { text += " (\(resourceCost))" }
            entries.append(.label(style: .resource, text: text))
        }
        
        // Price
        if let price = price {
            entries.append(.label(style: .price, text: "\(price) GP"))
        }
        
        return TooltipOverlay(boundingRect: boundingRect, referenceRect: referenceRect, entries: entries)
    }
    
    /// Creates a tooltip overlay describing a `Skill`.
    ///
    /// - Parameters:
    ///   - boundingRect: The bounding rect. The tooltip will be positioned inside this rect.
    ///   - referenceRect: The reference rect, which must be contained in the `boundingRect`.
    ///     The tooltip will be positioned close to this rect.
    ///   - skill: The skill to describe.
    ///   - entity: The entity that the skill pertains.
    /// - Returns: A new `TooltipOverlay` instance describing the skill.
    ///
    class func skillTooltip(boundingRect: CGRect, referenceRect: CGRect, skill: Skill,
                            entity: Entity) -> TooltipOverlay {
        
        var entries = [UITooltipElement.Entry]()
        
        // Name
        entries.append(.label(style: .subtitle, text: skill.name))
        
        // Description
        entries.append(.label(style: .text, text: skill.descriptionFor(entity: Game.protagonist!)))
        
        // Damage
        if let skill = skill as? DamageSkill {
            let baseDamage: String
            let skillDamage = skill.damageFor(entity: entity)
            if skillDamage.baseDamage.lowerBound != skillDamage.baseDamage.upperBound {
                baseDamage = "\(skillDamage.baseDamage.lowerBound)-\(skillDamage.baseDamage.upperBound) Damage"
            } else {
                baseDamage = "\(skillDamage.baseDamage.lowerBound) Damage"
            }
            entries.append(.label(style: .value, text: baseDamage))
            
            for (key, value) in skillDamage.modifiers.sorted(by: { $0.key < $1.key }) {
                let bonusDamage = "\(Int((value * 100.0).rounded()))% bonus from \(key.rawValue)"
                entries.append(.label(style: .modifier, text: bonusDamage))
            }
        }
        
        // Healing
        if let skill = skill as? HealingSkill {
            let baseHealing: String
            let skillHealing = skill.healingFor(entity: entity)
            switch skillHealing.baseHealing {
            case .absolute(let range):
                if range.lowerBound != range.upperBound {
                    baseHealing = "\(range.lowerBound)-\(range.upperBound) Healing"
                } else {
                    baseHealing = "\(range.lowerBound) Healing"
                }
            case .percentage(let range):
                let lowerBound = Int((range.lowerBound * 100.0).rounded())
                let upperBound = Int((range.upperBound * 100.0).rounded())
                if lowerBound != upperBound {
                    baseHealing = "\(lowerBound)%-\(upperBound)% Healing"
                } else {
                    baseHealing = "\(lowerBound)% Healing"
                }
            }
            entries.append(.label(style: .value, text: baseHealing))
            
            if let modifiers = skillHealing.modifiers {
                for (key, value) in modifiers.sorted(by: { $0.key < $1.key }) {
                    let bonusHealing = "\(Int((value * 100.0).rounded()))% bonus from \(key.rawValue)"
                    entries.append(.label(style: .modifier, text: bonusHealing))
                }
            }
        }
        
        // DamageOverTime
        if let skill = skill as? DamageOverTimeSkill {
            let baseDamage: String
            let skillDot = skill.damageOverTimeFor(entity: entity)
            let skillDamage = skillDot.tickDamage
            if let duration = skillDot.duration {
                let ticks = Int(max(1.0, duration / skillDot.tickTime))
                let lowerBound = skillDamage.baseDamage.lowerBound * ticks
                let upperBound = skillDamage.baseDamage.upperBound * ticks
                if lowerBound != upperBound {
                    baseDamage = "\(lowerBound)-\(upperBound) Damage over \(Int(duration)) sec."
                } else {
                    baseDamage = "\(lowerBound) Damage over \(Int(duration)) sec."
                }
            } else {
                let tick = skillDot.tickTime
                let lowerBound = skillDamage.baseDamage.lowerBound
                let upperBound = skillDamage.baseDamage.upperBound
                if lowerBound != upperBound {
                    baseDamage = "\(lowerBound)-\(upperBound) Damage every \(tick) sec."
                } else {
                    baseDamage = "\(lowerBound) Damage every \(tick) sec."
                }
            }
            entries.append(.label(style: .value, text: baseDamage))
            for (key, value) in skillDamage.modifiers.sorted(by: { $0.key < $1.key }) {
                let bonusDamage = "\(Int((value * 100.0).rounded()))% bonus from \(key.rawValue)"
                entries.append(.label(style: .modifier, text: bonusDamage))
            }
        }
        
        // HealingOverTime
        if let skill = skill as? HealingOverTimeSkill {
            let baseHealing: String
            let skillHot = skill.healingOverTimeFor(entity: entity)
            let skillHealing = skillHot.tickHealing
            if let duration = skillHot.duration {
                let ticks = Int(max(1.0, duration / skillHot.tickTime))
                switch skillHealing.baseHealing {
                case .absolute(let range):
                    let lowerBound = range.lowerBound * ticks
                    let upperBound = range.upperBound * ticks
                    if lowerBound != upperBound {
                        baseHealing = "\(lowerBound)-\(upperBound) Healing over \(Int(duration)) sec."
                    } else {
                        baseHealing = "\(lowerBound) Healing over \(Int(duration)) sec."
                    }
                case .percentage(let range):
                    let lowerBound = Int((range.lowerBound * 100.0).rounded()) * ticks
                    let upperBound = Int((range.upperBound * 100.0).rounded()) * ticks
                    if lowerBound != upperBound {
                        baseHealing = "\(lowerBound)%-\(upperBound)% Healing over \(Int(duration)) sec."
                    } else {
                        baseHealing = "\(lowerBound)% Healing over \(Int(duration)) sec."
                    }
                }
            } else {
                let tick = skillHot.tickTime
                switch skillHealing.baseHealing {
                case .absolute(let range):
                    if range.lowerBound != range.upperBound {
                        baseHealing = "\(range.lowerBound)-\(range.upperBound) Healing every \(tick) sec."
                    } else {
                        baseHealing = "\(range.lowerBound) Healing every \(tick) sec."
                    }
                case .percentage(let range):
                    let lowerBound = Int((range.lowerBound * 100.0).rounded())
                    let upperBound = Int((range.upperBound * 100.0).rounded())
                    if lowerBound != upperBound {
                        baseHealing = "\(lowerBound)%-\(upperBound)% Healing every \(tick) sec."
                    } else {
                        baseHealing = "\(lowerBound)% Healing every \(tick) sec."
                    }
                }
            }
            entries.append(.label(style: .value, text: baseHealing))
            if let modifiers = skillHealing.modifiers {
                for (key, value) in modifiers.sorted(by: { $0.key < $1.key }) {
                    let bonusHealing = "\(Int((value * 100.0).rounded()))% bonus from \(key.rawValue)"
                    entries.append(.label(style: .modifier, text: bonusHealing))
                }
            }
        }
        
        // WaitTime
        if let skill = skill as? WaitTimeSkill {
            entries.append(.label(style: .emphasis, text: "Wait Time: \(Int(skill.waitTime.rounded())) sec."))
        }
        
        // Cost
        if !skill.unlocked {
            entries.append(.label(style: .lockedValue, text: "Locked"))
            entries.append(.label(style: .points, text: "Cost to unlock: \(skill.cost) Points"))
        }
        
        return TooltipOverlay(boundingRect: boundingRect, referenceRect: referenceRect, entries: entries)
    }
    
    /// Creates a tooltip overlay describing an `Ability`.
    ///
    /// - Parameters:
    ///   - boundingRect: The bounding rect. The tooltip will be positioned inside this rect.
    ///   - referenceRect: The reference rect, which must be contained in the `boundingRect`.
    ///     The tooltip will be positioned close to this rect.
    ///   - ability: The ability to describe.
    ///   - entity: The entity that the ability pertains.
    /// - Returns: A new `TooltipOverlay` instance describing the ability.
    ///
    class func abilityTooltip(boundingRect: CGRect, referenceRect: CGRect, ability: Ability,
                              entity: Entity) -> TooltipOverlay {
    
        var entries = [UITooltipElement.Entry]()
        
        if let component = entity.component(ofType: AbilityComponent.self) {
            
            // Name
            entries.append(.label(style: .subtitle, text: ability.rawValue))
            
            // Description
            entries.append(.label(style: .text, text: ability.description))
            
            entries.append(.space(2.0))
            
            // Base value
            entries.append(.label(style: .text, text: "Base Value:"))
            entries.append(.label(style: .value, text: "\(component.baseValue(of: ability))"))
            
            entries.append(.space(2.0))
            
            // Modifiers
            let temp = component.temporaryValues[ability] ?? 0
            entries.append(.label(style: .text, text: "Additional Modifiers:"))
            if temp < 0 {
                entries.append(.label(style: .badValue, text: "\(temp)"))
            } else {
                entries.append(.label(style: .goodValue, text: "+\(temp)"))
            }
        }
        
        return TooltipOverlay(boundingRect: boundingRect, referenceRect: referenceRect, entries: entries)
    }
    
    /// Creates a tooltip overlay describing an entity's damage caused modifiers.
    ///
    /// - Parameters:
    ///   - boundingRect: The bounding rect. The tooltip will be positioned inside this rect.
    ///   - referenceRect: The reference rect, which must be contained in the `boundingRect`.
    ///     The tooltip will be positioned close to this rect.
    ///   - damageType: The damage type to describe.
    ///   - entity: The entity to describe.
    /// - Returns: A new `TooltipOverlay` instance describing the damage modifiers.
    ///
    class func damageTooltip(boundingRect: CGRect, referenceRect: CGRect, damageType: DamageType,
                             entity: Entity) -> TooltipOverlay {
        
        var entries = [UITooltipElement.Entry]()
        
        if let component = entity.component(ofType: DamageAdjustmentComponent.self) {
            let typeName: String
            let typeDesc: String
            switch damageType {
            case .physical:
                typeName = "Physical"
                typeDesc = "physical attacks"
            case .magical:
                typeName = "Magical"
                typeDesc = "magical attacks"
            case .spiritual:
                typeName = "Spiritual"
                typeDesc = "spiritual attacks"
            case .natural:
                typeName = "Natural"
                typeDesc = "natural attacks"
            }
            
            // Name
            entries.append(.label(style: .subtitle, text: "\(typeName) Damage Bonus"))
            
            // Description
            let desc = "The bonus applied to all damage inflicted with \(String(describing: typeDesc))."
            entries.append(.label(style: .text, text: desc))
            
            entries.append(.space(2.0))
            
            // Base adjustment
            let baseDamage = Int((component.baseDamageCaused() * 100.0).rounded())
            entries.append(.label(style: .emphasis, text: "Base Damage:"))
            entries.append(.label(style: baseDamage < 0 ? .badValue : .goodValue, text: "\(baseDamage)%"))
            
            entries.append(.space(2.0))
            
            // Damage type adjustment
            let typeDamage = Int((component.damageCausedFor(type: damageType,
                                                            ignoreBaseDamage: true) * 100.0).rounded())
            entries.append(.label(style: .emphasis, text: "Additional \(typeName) Bonus:"))
            entries.append(.label(style: typeDamage < 0 ? .badValue : .goodValue, text: "\(typeDamage)%"))
        }
        
        return TooltipOverlay(boundingRect: boundingRect, referenceRect: referenceRect, entries: entries)
    }
    
    /// Creates a tooltip overlay describing an entity's critical chance.
    ///
    /// - Parameters:
    ///   - boundingRect: The bounding rect. The tooltip will be positioned inside this rect.
    ///   - referenceRect: The reference rect, which must be contained in the `boundingRect`.
    ///     The tooltip will be positioned close to this rect.
    ///   - medium: The medium to describe.
    ///   - entity: The entity to describe.
    /// - Returns: A new `TooltipOverlay` instance describing the critical hit modifiers.
    ///
    class func criticalChanceTooltip(boundingRect: CGRect, referenceRect: CGRect, medium: Medium,
                                     entity: Entity) -> TooltipOverlay {
        
        var entries = [UITooltipElement.Entry]()
        
        if let component = entity.component(ofType: CriticalHitComponent.self) {
            let mediumName: String?
            let mediumDesc: String!
            switch medium {
            case .melee:
                mediumName = "Melee"
                mediumDesc = "melee weapon attacks"
            case .ranged:
                mediumName = "Ranged"
                mediumDesc = "ranged weapon attacks"
            case .spell:
                mediumName = "Spell"
                mediumDesc = "spells"
            default:
                mediumName = nil
                mediumDesc = nil
            }
            
            if let mediumName = mediumName {
                // Name
                entries.append(.label(style: .subtitle, text: "\(mediumName) Critical Chance" ))
                
                // Description
                let desc = "The chance to land critical hits with \(mediumDesc!), causing twice as much damage."
                entries.append(.label(style: .text, text: desc))
                
                entries.append(.space(2.0))
                
                // Base chance
                let baseCrit = Int((component.criticalChance * 100.0).rounded())
                entries.append(.label(style: .emphasis, text: "Base Chance:"))
                entries.append(.label(style: baseCrit < 0 ? .badValue : .goodValue, text: "\(baseCrit)%"))
                
                entries.append(.space(2.0))
                
                // Medium chance
                let mediumCrit = Int((component.criticalChanceFor(medium: medium,
                                                                  ignoreBaseChance: true) * 100.0).rounded())
                entries.append(.label(style: .emphasis, text: "Additional \(mediumName) Chance:"))
                entries.append(.label(style: mediumCrit < 0 ? .badValue : .goodValue, text: "\(mediumCrit)%"))
            }
        }
        
        return TooltipOverlay(boundingRect: boundingRect, referenceRect: referenceRect, entries: entries)
    }
    
    /// Creates a tooltip overlay describing an entity's defense.
    ///
    /// - Parameters:
    ///   - boundingRect: The bounding rect. The tooltip will be positioned inside this rect.
    ///   - referenceRect: The reference rect, which must be contained in the `boundingRect`.
    ///     The tooltip will be positioned close to this rect.
    ///   - entity: The entity to describe.
    /// - Returns: A new `TooltipOverlay` instance describing the barrier mitigation.
    ///
    class func defenseTooltip(boundingRect: CGRect, referenceRect: CGRect, entity: Entity) -> TooltipOverlay {
        var entries = [UITooltipElement.Entry]()
        
        // Name
        entries.append(.label(style: .subtitle, text: "Defense"))
        
        // Description
        entries.append(.label(style: .text, text: "The chance to defend oneself against physical attacks."))
        
        return TooltipOverlay(boundingRect: boundingRect, referenceRect: referenceRect, entries: entries)
    }
    
    /// Creates a tooltip overlay describing an entity's resistance.
    ///
    /// - Parameters:
    ///   - boundingRect: The bounding rect. The tooltip will be positioned inside this rect.
    ///   - referenceRect: The reference rect, which must be contained in the `boundingRect`.
    ///     The tooltip will be positioned close to this rect.
    ///   - entity: The entity to describe.
    /// - Returns: A new `TooltipOverlay` instance describing the barrier mitigation.
    ///
    class func resistanceTooltip(boundingRect: CGRect, referenceRect: CGRect, entity: Entity) -> TooltipOverlay {
        var entries = [UITooltipElement.Entry]()
        
        // Name
        entries.append(.label(style: .subtitle, text: "Resistance"))
        
        // Description
        entries.append(.label(style: .text, text: "The chance to resist magical effects."))
        
        return TooltipOverlay(boundingRect: boundingRect, referenceRect: referenceRect, entries: entries)
    }
    
    /// Creates a tooltip overlay describing an entity's mitigation.
    ///
    /// - Parameters:
    ///   - boundingRect: The bounding rect. The tooltip will be positioned inside this rect.
    ///   - referenceRect: The reference rect, which must be contained in the `boundingRect`.
    ///     The tooltip will be positioned close to this rect.
    ///   - entity: The entity to describe.
    /// - Returns: A new `TooltipOverlay` instance describing the mitigation.
    ///
    class func mitigationTooltip(boundingRect: CGRect, referenceRect: CGRect, entity: Entity) -> TooltipOverlay {
        var entries = [UITooltipElement.Entry]()
        
        if let component = entity.component(ofType: MitigationComponent.self) {
            // Name
            entries.append(.label(style: .subtitle, text: "Mitigation"))
            
            // Description
            entries.append(.label(style: .text, text: "The absolute amount reduced from damage taken."))
            
            entries.append(.space(2.0))
            
            // Base Mitigation
            entries.append(.label(style: .emphasis, text: "Base Mitigation:"))
            entries.append(.label(style: .value, text: "\(component.mitigation)"))
            
            // Active Barrier
            if let component = entity.component(ofType: BarrierComponent.self) {
                entries.append(.space(2.0))
                
                let barrierStatus: String
                if let barrier = component.barrier {
                    barrierStatus = "\(component.remainingMitigation) of \(barrier.mitigation)"
                } else {
                    barrierStatus = "N/A"
                }
                entries.append(.label(style: .emphasis, text: "Active Barrier:"))
                entries.append(.label(style: .value, text: barrierStatus))
            }
        }
        
        return TooltipOverlay(boundingRect: boundingRect, referenceRect: referenceRect, entries: entries)
    }
    
    /// Creates a generic tootip overlay that displays a single piece of text.
    ///
    /// - Parameters:
    ///   - boundingRect: The bounding rect. The tooltip will be positioned inside this rect.
    ///   - referenceRect: The reference rect, which must be contained in the `boundingRect`.
    ///     The tooltip will be positioned close to this rect.
    ///   - content: The textual content.
    ///   - style: The `UITextStyle` to use.
    /// - Returns: A new `TooltipOverlay` instance that displays the given `content`.
    ///
    class func genericTooltip(boundingRect: CGRect, referenceRect: CGRect,
                              content: String, style: UITextStyle) -> TooltipOverlay {
        
        return TooltipOverlay(boundingRect: boundingRect, referenceRect: referenceRect,
                              entries: [.label(style: style, text: content)])
    }
}

/// A struct that defines the data associated with the `TooltipOverlay` class.
///
fileprivate struct TooltipOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Tooltip.backgroundImage]
    }
    
    private init() {}
    
    /// The `UITooltipElement` data.
    ///
    struct Tooltip {
        private init() {}
        static let minLabelSize = CGSize(width: 100.0, height: 2.0)
        static let maxLabelSize = CGSize(width: 200.0, height: 700.0)
        static let contentOffset: CGFloat = 4.0
        static let backgroundImage = "UI_Alpha_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat = 4.0
    }
}
