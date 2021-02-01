//
//  CharacterMenu.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 9/14/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// A `Menu` type that defines the character menu, used to display/manage the
/// protagonist's details, items and skills.
///
class CharacterMenu: Menu, TextureUser {
    
    static var textureNames: Set<String> {
        return CharacterMenuData.textureNames
    }
    
    /// An enum that defines the character entries.
    ///
    private enum CharacterEntry {
        
        /// An enum defining the context for an `UIDetailElement`.
        ///
        enum DetailContext {
            case portrait, top, bottom, center(index: Int)
        }
        
        /// The context of an `UIDetailElement`'s entry.
        ///
        case detail(context: DetailContext)
        
        /// The index of an `UIItemElement`'s equipment entry.
        ///
        case equipment(index: Int)
        
        /// The column and row indices of a `UIItemElement`'s backpack entry.
        ///
        case backpack(column: Int, row: Int)
        
        /// The index of a `SkillElement`'s entry.
        ///
        case skill(index: Int)
    }
    
    /// An struct that represents an entry's content being carried with the cursor.
    ///
    private struct Carry {
        
        /// The place where the content was set originally.
        ///
        let from: CharacterEntry
        
        /// Custom data.
        ///
        let data: Any?
    }
    
    /// The tracking data for the character element.
    ///
    private typealias CharacterTrackingData = CharacterEntry
    
    /// An enum that names the contents of the detail element's center area.
    ///
    private enum DetailContent {
        case ability(Ability)
        case physicalDamage, magicalDamage, spiritualDamage, naturalDamage
        case meleeCritical, rangedCritical, spellCritical
        case defense, resistance, mitigation
    }
    
    private var entity: Entity {
        guard let entity = Game.protagonist else {
            fatalError("CharacterMenu requires Game.protagonist to be non-nil")
        }
        return entity
    }
    
    private var portraitComponent: PortraitComponent {
        guard let component = entity.component(ofType: PortraitComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has a PortraitComponent")
        }
        return component
    }
    
    private var inventoryComponent: InventoryComponent {
        guard let component = entity.component(ofType: InventoryComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has an InventoryComponent")
        }
        return component
    }
    
    private var equipmentComponent: EquipmentComponent {
        guard let component = entity.component(ofType: EquipmentComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has an EquipmentComponent")
        }
        return component
    }
    
    private var healthComponent: HealthComponent {
        guard let component = entity.component(ofType: HealthComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has a HealthComponent")
        }
        return component
    }
    
    private var abilityComponent: AbilityComponent {
        guard let component = entity.component(ofType: AbilityComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has an AbilityComponent")
        }
        return component
    }
    
    private var progressionComponent: ProgressionComponent {
        guard let component = entity.component(ofType: ProgressionComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has a ProgressionComponent")
        }
        return component
    }
    
    private var skillComponent: SkillComponent {
        guard let component = entity.component(ofType: SkillComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has a SkillComponent")
        }
        return component
    }
    
    private var damageAdjustmentComponent: DamageAdjustmentComponent {
        guard let component = entity.component(ofType: DamageAdjustmentComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has a DamageAdjustmentComponent")
        }
        return component
    }
    
    private var criticalHitComponent: CriticalHitComponent {
        guard let component = entity.component(ofType: CriticalHitComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has a CriticalHitComponent")
        }
        return component
    }
    
    private var defenseComponent: DefenseComponent {
        guard let component = entity.component(ofType: DefenseComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has a DefenseComponent")
        }
        return component
    }
    
    private var resistanceComponent: ResistanceComponent {
        guard let component = entity.component(ofType: ResistanceComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has a ResistanceComponent")
        }
        return component
    }
    
    private var mitigationComponent: MitigationComponent {
        guard let component = entity.component(ofType: MitigationComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has a MitigationComponent")
        }
        return component
    }
    
    private var personaComponent: PersonaComponent {
        guard let component = entity.component(ofType: PersonaComponent.self) else {
            fatalError("CharacterMenu requires a protagonist that has a PersonaComponent")
        }
        return component
    }
    
    let node: SKNode
    
    /// The carry node.
    ///
    let carryNode: SKNode
    
    /// The `UIDetailElement` instance.
    ///
    private let detailElement: UIDetailElement
    
    /// The `UIItemElement` instance.
    ///
    private let itemElement: UIItemElement
    
    /// The `UISkillElement` instance.
    ///
    private let skillElement: UISkillElement
    
    /// The `UIOptionElement` instance.
    ///
    private let optionElement: UIOptionElement
    
    /// The `UITitleElement` instance.
    ///
    private let titleElement: UITitleElement
    
    /// The currently selected character entry.
    ///
    private var selection: CharacterEntry?
    
    /// The content being carried.
    ///
    private var carry: Carry? {
        didSet {
            carryNode.removeAllChildren()
            if let carry = carry {
                guard let data = carry.data else { return }
                
                switch data {
                case let data as Item:
                    let iconSprite = data.icon.makeIconSprite()
                    carryNode.addChild(iconSprite)
                default:
                    break
                }
            }
        }
    }
    
    /// The contents set at the detail element's center label, with its index as key.
    ///
    private var detailContents: [Int: DetailContent] = [:]

    /// A flag indicating whether or not the menu is open.
    ///
    private var isOpen = false
    
    /// The current callback to call when closing the menu.
    ///
    private var onClose: (() -> Void)?
    
    /// The currently active controllable overlay.
    ///
    var controllableOverlay: ControllableOverlay? {
        didSet {
            if controllableOverlay != nil, let menuScene = menuScene {
                menuScene.tooltipOverlay = nil
            }
        }
    }
    
    required init(rect: CGRect) {
        node = SKNode()
        carryNode = SKNode()
        carryNode.zPosition = DepthLayer.cursor.lowerBound
        carryNode.setScale(0.75)
        node.addChild(carryNode)
        
        // Create the detail element
        detailElement = UIDetailElement(entryCount: CharacterMenuData.Detail.entryCount,
                                        contentOffset: CharacterMenuData.Detail.contentOffset,
                                        topLabelSize: CharacterMenuData.Detail.topLabelSize,
                                        middleLabelSize: CharacterMenuData.Detail.middleLabelSize,
                                        bottomLabelSize: CharacterMenuData.Detail.bottomLabelSize,
                                        emptyPortraitImage: CharacterMenuData.Detail.emptyPortraitImage,
                                        separatorImage: CharacterMenuData.Detail.separatorImage,
                                        backgroundImage: CharacterMenuData.Detail.backgroundImage,
                                        backgroundBorder: CharacterMenuData.Detail.backgroundBorder,
                                        backgroundOffset: CharacterMenuData.Detail.backgroundOffset)
        
        // Create the item element
        itemElement = UIItemElement(equipmentCount: CharacterMenuData.Item.equipmentCount,
                                    backpackColumns: CharacterMenuData.Item.backpackColumns,
                                    backpackRows: CharacterMenuData.Item.backpackRows,
                                    equipmentSlotOffset: CharacterMenuData.Item.equipmentSlotOffset,
                                    backpackSlotOffset: CharacterMenuData.Item.backpackSlotOffset,
                                    contentOffset: CharacterMenuData.Item.contentOffset,
                                    subtitleLabelSize: CharacterMenuData.Item.subtitleLabelSize,
                                    bottomLabelSize: CharacterMenuData.Item.bottomLabelSize,
                                    separatorImage: CharacterMenuData.Item.separatorImage,
                                    backpackImage: CharacterMenuData.Item.backpackImage,
                                    emptyIconImage: CharacterMenuData.Item.emptyIconImage,
                                    backgroundImage: CharacterMenuData.Item.backgroundImage,
                                    backgroundBorder: CharacterMenuData.Item.backgroundBorder,
                                    backgroundOffset: CharacterMenuData.Item.backgroundOffset)
        
        // Create the skill element
        skillElement = UISkillElement(entryCount: CharacterMenuData.Skill.entryCount,
                                      entryOffset: CharacterMenuData.Skill.entryOffset,
                                      contentOffset: CharacterMenuData.Skill.contentOffset,
                                      subtitleLabelSize: CharacterMenuData.Skill.subtitleLabelSize,
                                      entryLabelSize: CharacterMenuData.Skill.entryLabelSize,
                                      pointsLabelSize: CharacterMenuData.Skill.pointsLabelSize,
                                      separatorImage: CharacterMenuData.Skill.separatorImage,
                                      emptyIconImage: CharacterMenuData.Skill.emptyIconImage,
                                      lockImage: CharacterMenuData.Skill.lockImage,
                                      backgroundImage: CharacterMenuData.Skill.backgroundImage,
                                      backgroundBorder: CharacterMenuData.Skill.backgroundBorder,
                                      backgroundOffset: CharacterMenuData.Skill.backgroundOffset)
        
        // Create the option element
        optionElement = UIOptionElement(size: CharacterMenuData.Option.size,
                                        entryOffset: CharacterMenuData.Option.entryOffset,
                                        contentOffset: CharacterMenuData.Option.contentOffset,
                                        primaryButtonImage: CharacterMenuData.Option.primaryButtonImage,
                                        secondaryButtonImage: CharacterMenuData.Option.secondaryButtonImage,
                                        regularKeyImage: CharacterMenuData.Option.regularKeyImage,
                                        wideKeyImage: CharacterMenuData.Option.wideKeyImage)
        
        // Create the title element
        titleElement = UITitleElement(title: CharacterMenuData.Title.title,
                                      maxSize: CharacterMenuData.Title.maxSize,
                                      backgroundImage: CharacterMenuData.Title.backgroundImage,
                                      backgroundBorder: CharacterMenuData.Title.backgroundBorder)
        
        // Add tracking data to the detail element
        detailElement.addTrackingDataForPortrait(data: CharacterTrackingData.detail(context: .portrait))
        detailElement.addTrackingDataForTopLabel(data: CharacterTrackingData.detail(context: .top))
        detailElement.addTrackingDataForBottomLabel(data: CharacterTrackingData.detail(context: .bottom))
        for i in 0..<detailElement.entryCount {
            let data = CharacterTrackingData.detail(context: .center(index: i))
            detailElement.addTrackingDataForMiddleEntryAt(index: i, data: data)
        }
        
        // Add tracking data to the item element
        for i in 0..<itemElement.equipmentCount {
            let data = CharacterTrackingData.equipment(index: i)
            itemElement.addTrackingDataForEquipmentSlotAt(index: i, data: data)
        }
        for i in 0..<itemElement.backpackRows {
            for j in 0..<itemElement.backpackColumns {
                let data = CharacterTrackingData.backpack(column: j, row: i)
                itemElement.addTrackingDataForBackpackSlotAt(column: j, row: i, data: data)
            }
        }
        
        // Add tracking data to the skill element
        for i in 0..<skillElement.entryCount {
            let data = CharacterTrackingData.skill(index: i)
            skillElement.addTrackingDataForEntryAt(index: i, data: data)
        }
        
        // Generate the menu tree
        generate(rect: rect)
    }
    
    /// Generates the menu tree and appends it to the `node` property.
    ///
    /// - Parameter rect: The boundaries of the menu.
    ///
    private func generate(rect: CGRect) {
        var flag: Bool
        
        // The base offset between elements
        let xOffset: CGFloat = CharacterMenuData.elementXOffset
        let yOffset: CGFloat = CharacterMenuData.elementYOffset
        
        // Calculate the required width
        let topWidth = titleElement.size.width + xOffset
        let middleWidth = detailElement.size.width + itemElement.size.width + skillElement.size.width +
            xOffset * 3.0
        let bottomWidth = optionElement.size.width + xOffset
        let width = max(topWidth, max(middleWidth, bottomWidth))
        
        // Calculate the required height
        let topHeight = max(titleElement.size.height, optionElement.size.height) + yOffset
        let middleHeight = max(max(detailElement.size.height, itemElement.size.height),
                               skillElement.size.height) + yOffset
        let bottomHeight = topHeight
        let height = topHeight + middleHeight + bottomHeight
        
        // Check if the required dimensions for all the elements fits inside the rect
        var rect = rect
        var scale: CGFloat = 1.0
        if width > rect.width || height > rect.height {
            // The elements do not fit - use a scaled up rect to place contents and scale down the final node
            scale = max(width / rect.width, height / rect.height)
            rect.origin.x *= scale
            rect.origin.y *= scale
            rect.size.width *= scale
            rect.size.height *= scale
        }
        
        // Create the root container
        let root = UIContainer(plane: .vertical, ratio: 1.0)
        
        // Divide the root in four sections
        let topRatio = (titleElement.size.height + yOffset) / rect.height
        let middleRatio = middleHeight / rect.height
        let bottomRatio = (optionElement.size.height + yOffset) / rect.height
        let topSection = UIContainer(plane: .vertical, ratio: topRatio)
        let middleSection = UIContainer(plane: .horizontal, ratio: middleRatio)
        let bottomSection = UIContainer(plane: .vertical, ratio: bottomRatio)
        
        // Append the main divisions plus blank sections between top/bottom and middle sections
        let remaining = rect.height - (rect.height * (topRatio + middleRatio + bottomRatio))
        let topBlankRatio = ((1.0 - topRatio / (topRatio + bottomRatio)) * remaining) / rect.height
        let bottomBlankRatio = ((1.0 - bottomRatio / (topRatio + bottomRatio)) * remaining) / rect.height
        flag = root.appendContainer(topSection); assert(flag)
        flag = root.appendContainer(UIContainer(plane: .horizontal, ratio: topBlankRatio)); assert(flag)
        flag = root.appendContainer(middleSection); assert(flag)
        flag = root.appendContainer(UIContainer(plane: .horizontal, ratio: bottomBlankRatio)); assert(flag)
        flag = root.appendContainer(bottomSection); assert(flag)
        
        // Divide the middle in three sections
        let leftRatio = (detailElement.size.width + xOffset) / rect.width
        let centerRatio = (itemElement.size.width + xOffset) / rect.width
        let rightRatio = (skillElement.size.width + xOffset) / rect.width
        let detailSection = UIContainer(plane: .vertical, ratio: leftRatio)
        let itemSection = UIContainer(plane: .vertical, ratio: centerRatio)
        let skillSection = UIContainer(plane: .vertical, ratio: rightRatio)
        
        // Append the element sections plus blank sections to the middle section
        let middleBlankRatio = (1.0 - middleWidth / rect.width) / 2.0
        flag = middleSection.appendContainer(UIContainer(plane: .horizontal, ratio: middleBlankRatio)); assert(flag)
        flag = middleSection.appendContainer(detailSection); assert(flag)
        flag = middleSection.appendContainer(itemSection); assert(flag)
        flag = middleSection.appendContainer(skillSection); assert(flag)
        flag = middleSection.appendContainer(UIContainer(plane: .horizontal, ratio: middleBlankRatio)); assert(flag)
        
        // Add the title element to the top
        topSection.addElement(titleElement)
        
        // Add the detail element to the middle-left
        detailSection.addElement(detailElement)
        
        // Add the item element to the middle-center
        itemSection.addElement(itemElement)
        
        // Add the skill element to the middle-right
        skillSection.addElement(skillElement)
        
        // Add the option element to the bottom
        bottomSection.addElement(optionElement)
        
        // Generate the tree
        let tree = UITree(rect: rect, root: root)
        if let treeNode = tree.generate() {
            // Append the tree node to the menu node
            treeNode.zPosition = 1
            treeNode.setScale(1.0 / scale)
            node.addChild(treeNode)
        }
    }
    
    /// Converts the given column and row indices of the `UIItemElement` to a single
    /// index that can be used in the `InventoryComponent`.
    ///
    /// - Parameters:
    ///   - column: The column index to convert from.
    ///   - row: The row index to convert from.
    /// - Returns: The single array index if successful, `nil` if out of bounds.
    ///
    private func arrayIndexFor(column: Int, row: Int) -> Int? {
        let index = row * itemElement.backpackColumns + column
        
        if index >= 0 && index < inventoryComponent.capacity {
            return index
        }
        return nil
    }
    
    /// Converts the given index of the `InventoryComponent` to column and row indices
    /// that can be used in the `UIItemElement`.
    ///
    /// - Parameter index: The index to convert from.
    /// - Returns: The grid index as a (column, row) pair if successful, `nil` if out of bounds.
    ///
    private func gridIndexFor(index: Int) -> (column: Int, row: Int)? {
        let column = index % itemElement.backpackColumns
        let row = index / itemElement.backpackColumns
        
        if column >= 0 && row >= 0 && column < itemElement.backpackColumns && row < itemElement.backpackRows {
            return (column, row)
        }
        return nil
    }
    
    /// Computes the reference rect for a given `UIIcon`.
    ///
    /// - Parameter slot: The icon slot.
    /// - Returns: The reference rect.
    ///
    private func referenceRectFor(slot: UIIcon) -> CGRect {
        let origin = node.convert(slot.node.position, from: slot.node.parent!)
        let size = slot.node.size
        return CGRect(x: origin.x - size.width / 2.0, y: origin.y - size.height / 2.0,
                      width: size.width, height: size.height)
    }
    
    /// Computes the reference rect for a given `UIIBackground`.
    ///
    /// - Parameter background: The background.
    /// - Returns: The reference rect.
    ///
    private func referenceRectFor(background: UIBackground) -> CGRect {
        let origin = node.convert(background.node.position, from: background.node.parent!)
        let size = background.node.size
        return CGRect(x: origin.x - size.width / 2.0, y: origin.y - size.height / 2.0,
                      width: size.width, height: size.height)
    }
    
    /// Sets the `UIDetailElement`.
    ///
    private func setDetail() {
        var nextIndex = 0
        
        detailElement.portrait.portrait = portraitComponent.portrait
        
        detailElement.topLabels.upper.text = personaComponent.personaName
        let level = progressionComponent.levelOfExperience
        let className = Game.protagonist!.name
        detailElement.topLabels.middle.text = "Level \(level) \(className)"
        let totalHP = healthComponent.totalHp
        let currentHP = healthComponent.currentHP
        detailElement.topLabels.lower.text = "HP: \(currentHP)/\(totalHP)"
        detailElement.topLabels.lower.style = healthComponent.multiplier < 1.0 ? .badValue : .goodValue
        
        // Abilities
        for (index, ability) in zip(Ability.asArray.indices, Ability.asArray) {
            guard let entry = detailElement.middleEntryAt(index: index) else { break }
            let value = abilityComponent.totalValue(of: ability)
            entry.nameLabel.text = ability.rawValue + ":"
            entry.valueLabel.text = "\(value)"
            entry.valueLabel.style = value < abilityComponent.baseValue(of: ability) ? .badValue : .goodValue
            detailContents[nextIndex] = .ability(ability)
            nextIndex += 1
        }
        
        // Space
        nextIndex += 1
        
        // Damage
        if let entry = detailElement.middleEntryAt(index: nextIndex) {
            let damage = Int((damageAdjustmentComponent.damageCausedFor(type: .physical) * 100.0).rounded())
            entry.nameLabel.text = "Physical Damage Bonus:"
            entry.valueLabel.text = "\(damage)%"
            entry.valueLabel.style = damage < 0 ? .badValue : .goodValue
            detailContents[nextIndex] = .physicalDamage
            nextIndex += 1
        }
        if let entry = detailElement.middleEntryAt(index: nextIndex) {
            let damage = Int((damageAdjustmentComponent.damageCausedFor(type: .magical) * 100.0).rounded())
            entry.nameLabel.text = "Magical Damage Bonus:"
            entry.valueLabel.text = "\(damage)%"
            entry.valueLabel.style = damage < 0 ? .badValue : .goodValue
            detailContents[nextIndex] = .magicalDamage
            nextIndex += 1
        }
        if let entry = detailElement.middleEntryAt(index: nextIndex) {
            let damage = Int((damageAdjustmentComponent.damageCausedFor(type: .spiritual) * 100.0).rounded())
            entry.nameLabel.text = "Spiritual Damage Bonus:"
            entry.valueLabel.text = "\(damage)%"
            entry.valueLabel.style = damage < 0 ? .badValue : .goodValue
            detailContents[nextIndex] = .spiritualDamage
            nextIndex += 1
        }
        if let entry = detailElement.middleEntryAt(index: nextIndex) {
            let damage = Int((damageAdjustmentComponent.damageCausedFor(type: .natural) * 100.0).rounded())
            entry.nameLabel.text = "Natural Damage Bonus:"
            entry.valueLabel.text = "\(damage)%"
            entry.valueLabel.style = damage < 0 ? .badValue : .goodValue
            detailContents[nextIndex] = .naturalDamage
            nextIndex += 1
        }
        
        // Space
        nextIndex += 1
        
        // Critical
        if let entry = detailElement.middleEntryAt(index: nextIndex) {
            let critical = Int((criticalHitComponent.criticalChanceFor(medium: .melee) * 100.0).rounded())
            entry.nameLabel.text = "Melee Critical Chance:"
            entry.valueLabel.text = "\(critical)%"
            entry.valueLabel.style = critical < 0 ? .badValue : .goodValue
            detailContents[nextIndex] = .meleeCritical
            nextIndex += 1
        }
        if let entry = detailElement.middleEntryAt(index: nextIndex) {
            let critical = Int((criticalHitComponent.criticalChanceFor(medium: .ranged) * 100.0).rounded())
            entry.nameLabel.text = "Ranged Critical Chance:"
            entry.valueLabel.text = "\(critical)%"
            entry.valueLabel.style = critical < 0 ? .badValue : .goodValue
            detailContents[nextIndex] = .rangedCritical
            nextIndex += 1
        }
        if let entry = detailElement.middleEntryAt(index: nextIndex) {
            let critical = Int((criticalHitComponent.criticalChanceFor(medium: .spell) * 100.0).rounded())
            entry.nameLabel.text = "Spell Critical Chance:"
            entry.valueLabel.text = "\(critical)%"
            entry.valueLabel.style = critical < 0 ? .badValue : .goodValue
            detailContents[nextIndex] = .spellCritical
            nextIndex += 1
        }
        
        // Space
        nextIndex += 1
        
        // Defenses
        if let entry = detailElement.middleEntryAt(index: nextIndex) {
            let defense = Int((defenseComponent.defense * 100.0).rounded())
            entry.nameLabel.text = "Defense:"
            entry.valueLabel.text = "\(defense)%"
            detailContents[nextIndex] = .defense
            nextIndex += 1
        }
        if let entry = detailElement.middleEntryAt(index: nextIndex) {
            let resistance = Int((resistanceComponent.resistance * 100.0).rounded())
            entry.nameLabel.text = "Resistance:"
            entry.valueLabel.text = "\(resistance)%"
            detailContents[nextIndex] = .resistance
            nextIndex += 1
        }
        if let entry = detailElement.middleEntryAt(index: nextIndex) {
            entry.nameLabel.text = "Mitigation:"
            entry.valueLabel.text = "\(mitigationComponent.mitigationPlusBarrier)"
            detailContents[nextIndex] = .mitigation
            nextIndex += 1
        }
        
        detailElement.bottomLabels.left.text = "XP:"
        if progressionComponent.levelOfExperience == EntityProgression.levelRange.upperBound {
            detailElement.bottomLabels.right.text = "N/A"
        } else {
            let currentXP = progressionComponent.experience
            let nextLevelXP = EntityProgression.requiredXPForLevel(progressionComponent.levelOfExperience + 1)
            detailElement.bottomLabels.right.text = "\(currentXP)/\(nextLevelXP)"
        }
    }
    
    /// Sets the given index of the `UISkillElement`'s entry based on `SkillComponent` data.
    ///
    /// - Parameter index: The index of the skill entry.
    ///
    private func setSkillEntry(at index: Int) {
        guard (0..<skillComponent.count).contains(index) else { return }
        
        let skill = skillComponent.skills[index]
        if let entry = skillElement.entryAt(index: index) {
            if skill.unlocked {
                entry.slot.icon = skill.icon
                entry.image.node.isHidden = true
            } else {
                entry.slot.icon = IconSet.Skill.locked
                entry.image.node.isHidden = false
                entry.image.text = String(skill.cost)
            }
            entry.label.text = skill.name
        }
    }
    
    /// Sets all `UISkillElement`'s entries based on `SkillComponent` data.
    ///
    private func setSkillEntries() {
        for i in 0..<skillComponent.count {
            setSkillEntry(at: i)
        }
    }
    
    /// Sets the `UISkillElement`'s skill points label.
    ///
    private func setSkillPoints() {
        skillElement.pointsLabels.left.text = "Skill Points:"
        skillElement.pointsLabels.right.text = "\(skillComponent.currentPoints)"
    }
    
    /// Sets the given index of the `UIItemElement`'s equipment based on `EquipmentComponent` data.
    ///
    /// - Parameter index: The index of the equipment.
    ///
    private func setItemEquipment(at index: Int) {
        let item = equipmentComponent.itemAt(index: index)
        let slot = itemElement.equipmentSlotAt(index: index)
        slot?.icon = item?.icon
    }
    
    /// Sets the whole `UIItemElement`'s equipment based on `EquipmentComponent` data.
    ///
    private func setItemEquipment() {
        for i in 0..<itemElement.equipmentCount {
            setItemEquipment(at: i)
        }
    }
    
    /// Sets the given index of the `UIItemElement`'s backpack based on `InventoryComponent` data.
    ///
    /// - Parameters:
    ///   - column: The column index of the backpack.
    ///   - row: The row index of the backpack.
    ///   - andSetItemGPLabel: A flag stating if `setItemGPLabel()` must be called. The default value
    ///     is `true`.
    ///
    private func setItemBackpack(column: Int, row: Int, andSetItemGPLabel: Bool = true) {
        guard let index = arrayIndexFor(column: column, row: row) else { return }
        guard let slot = itemElement.backpackSlotAt(column: column, row: row) else { return }
        
        let item = inventoryComponent.itemAt(index: index)
        
        slot.icon = item?.icon
        slot.text = nil
        slot.undarken()
        slot.unhighlight()
        
        if let item = item {
            if (carry?.data as? Item) === item {
                slot.highlight()
            }
            if equipmentComponent.isEquipped(item) {
                slot.darken()
            } else if item is StackableItem, equipmentComponent.isEquipped(itemNamed: item.name) {
                slot.darken()
            }
        }
        if let stack = (item as? StackableItem)?.stack {
            slot.text = String(stack.count)
        }
        
        if andSetItemGPLabel { setItemGPLabel() }
    }
    
    /// Sets the whole `UIItemElement`'s backpack based on `InventoryComponent` data.
    ///
    private func setItemBackpack() {
        for column in 0..<itemElement.backpackColumns {
            for row in 0..<itemElement.backpackRows {
                setItemBackpack(column: column, row: row, andSetItemGPLabel: false)
                setItemGPLabel()
            }
        }
    }
    
    /// Sets the `UIItemElement`'s equipment labels.
    ///
    private func setItemEquipmentLabels() {
        let buttons = [InputButton.item1, InputButton.item2, InputButton.item3, InputButton.item4,
                       InputButton.item5, InputButton.item6]
        for i in 0..<buttons.count {
            guard let label = itemElement.equipmentLabelAt(index: i) else { break }
            label.text = buttons[i].symbolFromMapping
        }
    }
    
    /// Sets the `UIItemElement`'s GP label.
    ///
    private func setItemGPLabel() {
        itemElement.bottomLabels.left.text = "Gold Pieces:"
        let goldQuantity = inventoryComponent.quantityOf(itemsNamed: "Gold Pieces")
        itemElement.bottomLabels.right.text = "\(goldQuantity)"
    }
    
    /// Sets the `UIOptionElement` based on the current `selection`.
    ///
    private func setOption() {
        let pickOption = (UIOptionElement.OptionButton.primaryButton, "Take item")
        let dropOption = (UIOptionElement.OptionButton.primaryButton, "Place item")
        let equipOption = (UIOptionElement.OptionButton.primaryButton, "Equip here")
        let unequipOption = (UIOptionElement.OptionButton.primaryButton, "Unequip item")
        let discardOption = (UIOptionElement.OptionButton.secondaryButton, "Discard item")
        let unlockOption = (UIOptionElement.OptionButton.primaryButton, "Unlock skill")
        let cancelOption = (UIOptionElement.OptionButton.primaryButton, "Cancel")
        let backOption = (UIOptionElement.OptionButton.key(.back), "Back")
        
        switch selection {
        case .some(let value):
            switch value {
            case .detail:
                optionElement.replaceWith(options: [backOption])
            
            case .equipment(let index):
                if carry == nil {
                    if let _ = equipmentComponent.itemAt(index: index) {
                        optionElement.replaceWith(options: [unequipOption, backOption])
                    } else {
                        optionElement.replaceWith(options: [backOption])
                    }
                } else {
                    guard let item = carry?.data as? Item, equipmentComponent.canEquip(item, at: index) else {
                        optionElement.replaceWith(options: [backOption])
                        break
                    }
                    optionElement.replaceWith(options: [equipOption, backOption])
                }
            
            case .backpack(let column, let row):
                if carry == nil {
                    let index = arrayIndexFor(column: column, row: row)
                    guard index != nil, let item = inventoryComponent.itemAt(index: index!) else {
                        optionElement.replaceWith(options: [backOption])
                        break
                    }
                    if item.isDiscardable {
                        optionElement.replaceWith(options: [pickOption, discardOption, backOption])
                    } else {
                        optionElement.replaceWith(options: [pickOption, backOption])
                    }
                } else {
                    optionElement.replaceWith(options: [dropOption, backOption])
                }
            
            case .skill(let index):
                guard (0..<skillComponent.count).contains(index) else {
                    optionElement.replaceWith(options: [backOption])
                    break
                }
                let skill = skillComponent.skills[index]
                if !skill.unlocked && (skillComponent.currentPoints >= skill.cost) {
                    optionElement.replaceWith(options: [unlockOption, backOption])
                } else {
                    optionElement.replaceWith(options: [backOption])
                }
            }
        case .none:
            if let _ = carry?.data as? Item {
                optionElement.replaceWith(options: [cancelOption, backOption])
            } else {
                optionElement.replaceWith(options: [backOption])
            }
        }
    }
    
    /// Sets the `TooltipOverlay` of the `MenuScene` based on the current `selection`.
    ///
    private func setTooltip() {
        guard let selection = selection else {
            menuScene?.tooltipOverlay = nil
            return
        }
        
        var tooltip: TooltipOverlay?
        
        switch selection {
        case .detail(let context):
            switch context {
            case .center(let index):
                guard
                    let content = detailContents[index],
                    let background = detailElement.middleEntryAt(index: index)?.background,
                    let rect = menuScene?.frame
                    else { break }
                let referenceRect = referenceRectFor(background: background)
                switch content {
                case .ability(let ability):
                    tooltip = TooltipOverlay.abilityTooltip(boundingRect: rect,
                                                            referenceRect: referenceRect,
                                                            ability: ability,
                                                            entity: Game.protagonist!)
                case .physicalDamage:
                    tooltip = TooltipOverlay.damageTooltip(boundingRect: rect,
                                                           referenceRect: referenceRect,
                                                           damageType: .physical,
                                                           entity: Game.protagonist!)
                case .magicalDamage:
                    tooltip = TooltipOverlay.damageTooltip(boundingRect: rect,
                                                           referenceRect: referenceRect,
                                                           damageType: .magical,
                                                           entity: Game.protagonist!)
                case .spiritualDamage:
                    tooltip = TooltipOverlay.damageTooltip(boundingRect: rect,
                                                           referenceRect: referenceRect,
                                                           damageType: .spiritual,
                                                           entity: Game.protagonist!)
                case .naturalDamage:
                    tooltip = TooltipOverlay.damageTooltip(boundingRect: rect,
                                                           referenceRect: referenceRect,
                                                           damageType: .natural,
                                                           entity: Game.protagonist!)
                case .meleeCritical:
                    tooltip = TooltipOverlay.criticalChanceTooltip(boundingRect: rect,
                                                                   referenceRect: referenceRect,
                                                                   medium: .melee,
                                                                   entity: Game.protagonist!)
                case .rangedCritical:
                    tooltip = TooltipOverlay.criticalChanceTooltip(boundingRect: rect,
                                                                   referenceRect: referenceRect,
                                                                   medium: .ranged,
                                                                   entity: Game.protagonist!)
                case .spellCritical:
                    tooltip = TooltipOverlay.criticalChanceTooltip(boundingRect: rect,
                                                                   referenceRect: referenceRect,
                                                                   medium: .spell,
                                                                   entity: Game.protagonist!)
                case .defense:
                    tooltip = TooltipOverlay.defenseTooltip(boundingRect: rect,
                                                            referenceRect: referenceRect,
                                                            entity: Game.protagonist!)
                case .resistance:
                    tooltip = TooltipOverlay.resistanceTooltip(boundingRect: rect,
                                                               referenceRect: referenceRect,
                                                               entity: Game.protagonist!)
                case .mitigation:
                    tooltip = TooltipOverlay.mitigationTooltip(boundingRect: rect,
                                                               referenceRect: referenceRect,
                                                               entity: Game.protagonist!)
                }
            default:
                break
            }
            
        case .equipment(let index):
            guard
                let item = equipmentComponent.itemAt(index: index),
                let rect = menuScene?.frame
                else { break }
            let referenceRect = referenceRectFor(slot: itemElement.equipmentSlotAt(index: index)!)
            tooltip = TooltipOverlay.itemTooltip(boundingRect: rect, referenceRect: referenceRect,
                                                 item: item, entity: entity)
            
        case .backpack(let column, let row):
            guard
                let index = arrayIndexFor(column: column, row: row),
                let item = inventoryComponent.itemAt(index: index),
                let rect = menuScene?.frame
                else { break }
            let referenceRect = referenceRectFor(slot: itemElement.backpackSlotAt(column: column, row: row)!)
            tooltip = TooltipOverlay.itemTooltip(boundingRect: rect, referenceRect: referenceRect,
                                                 item: item, entity: entity)
            
        case .skill(let index):
            guard (0..<skillComponent.count).contains(index), let rect = menuScene?.frame else { break }
            let skill = skillComponent.skills[index]
            let referenceRect = referenceRectFor(slot: skillElement.entryAt(index: index)!.slot)
            tooltip = TooltipOverlay.skillTooltip(boundingRect: rect, referenceRect: referenceRect,
                                                  skill: skill, entity: entity)
        }
    
        if let tooltip = tooltip {
            menuScene?.tooltipOverlay = tooltip
        } else {
            menuScene?.tooltipOverlay = nil
        }
    }
    
    /// Unselects an entry.
    ///
    /// - Parameters:
    ///   - entry: The entry to unselect.
    ///   - nullifySelection: A flag stating whether or not the instance's `selection` property should
    ///     be set to `nil` when it is the same as the method's parameter. The default value is `true`.
    ///
    private func unselectEntry(_ entry: CharacterEntry, nullifySelection: Bool = true) {
        if nullifySelection, let selection = selection {
            switch selection {
            case .detail(let context):
                switch context {
                case .portrait:
                    switch entry {
                    case .detail(let otherContext):
                        switch otherContext {
                        case .portrait: self.selection = nil
                        default: break
                        }
                    default: break
                    }
                case .bottom:
                    switch entry {
                    case .detail(let otherContext):
                        switch otherContext {
                        case .bottom: self.selection = nil
                        default: break
                        }
                    default: break
                    }
                case .top:
                    switch entry {
                    case .detail(let otherContext):
                        switch otherContext {
                        case .top: self.selection = nil
                        default: break
                        }
                    default: break
                    }
                case .center(let index):
                    switch entry {
                    case .detail(let otherContext):
                        switch otherContext {
                        case .center(let otherIndex): if index == otherIndex { self.selection = nil }
                        default: break
                        }
                    default: break
                    }
                }
            
            case .equipment(let index):
                switch entry {
                case .equipment(let otherIndex):
                    if index == otherIndex { self.selection = nil }
                default:
                    break
                }
            
            case .backpack(let column, let row):
                switch entry {
                case .backpack(let otherColumn, let otherRow):
                    if column == otherColumn && row == otherRow { self.selection = nil }
                default:
                    break
                }
            
            case .skill(let index):
                switch entry {
                case .skill(let otherIndex):
                    if index == otherIndex { self.selection = nil }
                default:
                    break
                }
            }
        }
        
        switch entry {
        case .detail(let context):
            switch context {
            case .portrait, .top, .bottom:
                break
            case .center(let index):
                if let entry = detailElement.middleEntryAt(index: index) {
                    entry.nameLabel.restore()
                    entry.valueLabel.restore()
                }
            }
        case .equipment(let index):
            itemElement.equipmentSlotAt(index: index)?.unflash()
        case .backpack(let column, let row):
            itemElement.backpackSlotAt(column: column, row: row)?.unflash()
        case .skill(let index):
            if let entry = skillElement.entryAt(index: index) {
                entry.slot.unflash()
                entry.label.restore()
            }
        }
        
        setOption()
        setTooltip()
    }
    
    /// Unselects all entries.
    ///
    private func unselectAll() {
        unselectEntry(.detail(context: .portrait))
        unselectEntry(.detail(context: .top))
        unselectEntry(.detail(context: .bottom))
        for i in 0..<detailElement.entryCount {
            unselectEntry(.detail(context: .center(index: i)))
        }
        
        for i in 0..<itemElement.equipmentCount {
            unselectEntry(CharacterEntry.equipment(index: i))
        }
        
        for i in 0..<itemElement.backpackRows {
            for j in 0..<itemElement.backpackColumns {
                unselectEntry(CharacterEntry.backpack(column: j, row: i))
            }
        }
        
        for i in 0..<skillElement.entryCount {
            unselectEntry(CharacterEntry.skill(index: i))
        }
    }
    
    /// Selects an entry.
    ///
    /// - Parameter entry: The entry to select.
    ///
    private func selectEntry(_ entry: CharacterEntry) {
        selection = entry
        
        switch entry {
        case .detail(let context):
            switch context {
            case .portrait, .top, .bottom:
                break
            case .center(let index):
                if let entry = detailElement.middleEntryAt(index: index) {
                    entry.nameLabel.whiten()
                    entry.valueLabel.whiten()
                }
            }
        case .equipment(let index):
            itemElement.equipmentSlotAt(index: index)?.flash()
        case .backpack(let column, let row):
            itemElement.backpackSlotAt(column: column, row: row)?.flash()
        case .skill(let index):
            if let entry = skillElement.entryAt(index: index) {
                entry.slot.flash(circularShape: true)
                entry.label.whiten()
            }
        }
        
        setOption()
        setTooltip()
    }
    
    /// Carries the currently selected content.
    ///
    private func carrySelection() {
        guard carry == nil, let selection = selection else { return }
        
        switch selection {
        case .equipment(let index):
            guard let item = equipmentComponent.unequip(at: index),
                let inventoryIdx = inventoryComponent.indexOf(item: item),
                let (column, row) = gridIndexFor(index: inventoryIdx) else { return }
            
            carry = Carry(from: .backpack(column: column, row: row), data: item)
            
            setDetail()
            setItemEquipment(at: index)
            setItemBackpack(column: column, row: row)
            setOption()
            setTooltip()
            
        case .backpack(let column, let row):
            guard let index = arrayIndexFor(column: column, row: row),
                let item = inventoryComponent.itemAt(index: index)
                else { return }
            
            carry = Carry(from: selection, data: item)
            
            setItemBackpack(column: column, row: row)
            setOption()
            setTooltip()
            
        default:
            break
        }
    }
    
    /// Drops the currently carried content.
    ///
    private func dropCarriedContent() {
        guard let carry = carry else { return }
        
        switch carry.from {
        case .backpack(let column, let row):
            if let selection = selection {
                // Selection is active, attempt to move/equip item
                switch selection {
                case .equipment(let index):
                    guard let item = carry.data as? Item, item.isEquippable else {
                        if let menuScene = menuScene {
                            let note = NoteOverlay(rect: menuScene.frame, text: "This item cannot be equipped")
                            menuScene.presentNote(note)
                        }
                        return
                    }
                    
                    guard equipmentComponent.canEquip(item, at: index) else {
                        if let menuScene = menuScene {
                            let text: String
                            if let item = item as? LevelItem,
                                item.requiredLevel > progressionComponent.levelOfExperience {
                                text = "Requires level \(item.requiredLevel) to equip"
                            } else {
                                text = "Only one \(item.category.rawValue) can be equipped at once"
                            }
                            menuScene.presentNote(NoteOverlay(rect: menuScene.frame, text: text))
                        }
                        return
                    }
                    
                    if equipmentComponent.isEquipped(item) {
                        let _ = equipmentComponent.unequip(item: item)
                    }
                    let _ = equipmentComponent.equip(item: item, at: index)
                    
                    self.carry = nil
                    
                    setDetail()
                    setItemEquipment()
                    setItemBackpack()
                    
                case .backpack(let otherColumn, let otherRow):
                    guard let indexA = arrayIndexFor(column: column, row: row) else { return }
                    guard let indexB = arrayIndexFor(column: otherColumn, row: otherRow) else { return }
                    
                    if inventoryComponent.moveStack(from: indexA, to: indexB).amountMoved == 0 {
                        let _ = inventoryComponent.moveItem(from: indexA, to: indexB)
                    }
                    
                    self.carry = nil
                    
                    setItemBackpack(column: column, row: row)
                    setItemBackpack(column: otherColumn, row: otherRow)
                    
                default:
                    break
                }
            } else {
                // No selection, cancel carry
                self.carry = nil
                
                setItemBackpack(column: column, row: row)
            }
            
        default:
            break
        }
        
        setOption()
        setTooltip()
    }
    
    /// Discards the currently selected backpack item.
    ///
    private func discardSelection() {
        guard carry == nil, let selection = selection else { return }
        
        switch selection {
        case .backpack(let column, let row):
            guard let index = arrayIndexFor(column: column, row: row) else { return }
            guard let item = inventoryComponent.itemAt(index: index) else { return }
            
            // Discard the item if possible
            if item.isDiscardable {
                if controllableOverlay == nil, let menuScene = menuScene {
                    // Create a confirmation overlay to confirm/cancel
                    unselectEntry(selection, nullifySelection: false)
                    dull()
                    let rect = menuScene.frame
                    if let item = item as? StackableItem, item.stack.count > 1 {
                        controllableOverlay = PromptOverlay.discardingPrompt(rect: rect, item: item) {
                            [unowned self] in
                            if let overlay = self.controllableOverlay as? PromptOverlay {
                                if overlay.confirmed, let text = overlay.promptText, let quantity = Int(text) {
                                    if let _ = self.inventoryComponent.reduceStack(at: index, quantity: quantity) {
                                        self.setItemEquipment()
                                        self.setItemBackpack(column: column, row: row)
                                        self.setOption()
                                        self.setTooltip()
                                    }
                                }
                            }
                            if let selection = self.selection { self.selectEntry(selection) }
                            self.undull()
                            self.menuScene?.removeOverlay(self.controllableOverlay!)
                            self.controllableOverlay = nil
                        }
                    } else {
                        controllableOverlay = ConfirmationOverlay(rect: rect, content: "Discard \(item.name)?") {
                            [unowned self] in
                            if let overlay = self.controllableOverlay as? ConfirmationOverlay {
                                if overlay.confirmed && self.inventoryComponent.removeItem(at: index) {
                                    self.setItemEquipment()
                                    self.setItemBackpack(column: column, row: row)
                                    self.setOption()
                                    self.setTooltip()
                                }
                            }
                            if let selection = self.selection { self.selectEntry(selection) }
                            self.undull()
                            self.menuScene?.removeOverlay(self.controllableOverlay!)
                            self.controllableOverlay = nil
                        }
                    }
                    menuScene.addOverlay(controllableOverlay!)
                }
            } else if let menuScene = menuScene {
                // Inform that the item cannot be discarded
                let note = NoteOverlay(rect: menuScene.frame, text: "This item cannot be discarded")
                menuScene.presentNote(note)
            }
        default:
            break
        }
    }
    
    /// Unlocks the currently selected skill.
    ///
    private func unlockSkill() {
        guard carry == nil, let selection = selection else { return }
        
        switch selection {
        case .skill(let index) where index < skillComponent.skills.count:
            let skill = skillComponent.skills[index]
            if !skill.unlocked {
                if skillComponent.currentPoints >= skill.cost {
                    if controllableOverlay == nil, let menuScene = menuScene {
                        // Create a confirmation overlay to confirm/cancel
                        unselectEntry(selection, nullifySelection: false)
                        dull()
                        let rect = menuScene.frame
                        let content = "Spend \(skill.cost) points to unlock \(skill.name)?"
                        controllableOverlay = ConfirmationOverlay(rect: rect, content: content) {
                            [unowned self] in
                            if let overlay = self.controllableOverlay as? ConfirmationOverlay {
                                if overlay.confirmed {
                                    skill.unlocked = true
                                    (skill as? PassiveSkill)?.didUnlock(onEntity: Game.protagonist!)
                                    self.skillComponent.didChangeSkill(skill)
                                    self.setSkillEntry(at: index)
                                    self.setSkillPoints()
                                    self.setOption()
                                    self.setTooltip()
                                    self.setDetail()
                                }
                            }
                            if let selection = self.selection { self.selectEntry(selection) }
                            self.undull()
                            self.menuScene?.removeOverlay(self.controllableOverlay!)
                            self.controllableOverlay = nil
                        }
                        menuScene.addOverlay(controllableOverlay!)
                    }
                } else if let menuScene = menuScene {
                    // Inform that there are not enough skill points
                    let note = NoteOverlay(rect: menuScene.frame,
                                           text: "Not enough skill points to unlock this skill")
                    menuScene.presentNote(note)
                }
            }
            
        default:
            break
        }
    }
    
    func open(onClose: @escaping () -> Void) -> Bool {
        guard !isOpen else { return false }
        isOpen = true
        
        assert(EquipmentComponent.maxItems == itemElement.equipmentCount)
        assert(inventoryComponent.capacity == itemElement.backpackColumns * itemElement.backpackRows)
        
        setDetail()
        setItemEquipment()
        setItemEquipmentLabels()
        setItemBackpack()
        setSkillEntries()
        setSkillPoints()
        setOption()
        
        self.onClose = onClose
        return true
    }
    
    func update(deltaTime seconds: TimeInterval) {
        if let _ = carry { carryNode.position = InputManager.cursorLocation }
    }
    
    func close() {
        onClose?()
        onClose = nil
        isOpen = false
        carry = nil
        unselectAll()
        undull()
        if let controllableOverlay = controllableOverlay {
            menuScene?.removeOverlay(controllableOverlay)
            self.controllableOverlay = nil
        }
    }
    
    func didReceiveEvent(_ event: Event) {
        if let _ = controllableOverlay {
            // Update the selection property before dispatching the event to the overlay
            switch event.type {
            case .mouseEntered:
                if let event = event as? MouseEvent, let data = event.data as? CharacterTrackingData {
                    selection = data
                }
            case .mouseExited:
                if let event = event as? MouseEvent, let _ = event.data as? CharacterTrackingData {
                    selection = nil
                }
            default:
                break
            }
            controllableOverlay!.didReceiveEvent(event)
        } else {
            switch event.type {
            case .mouseDown:
                if let event = event as? MouseEvent {
                    mouseDownEvent(event)
                }
            case .mouseEntered:
                if let event = event as? MouseEvent {
                    mouseEnteredEvent(event)
                }
            case .mouseExited:
                if let event = event as? MouseEvent {
                    mouseExitedEvent(event)
                }
            case .keyDown:
                if let event = event as? KeyboardEvent {
                    keyDownEvent(event)
                }
            default:
                break
            }
        }
    }
    
    /// Handles mouse down events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseDownEvent(_ event: MouseEvent) {
        switch event.button {
        case .left:
            if let selection = selection {
                // Selection is active
                switch selection {
                case .equipment, .backpack:
                    if carry == nil {
                        carrySelection()
                    } else {
                        dropCarriedContent()
                    }
                case .skill:
                    if carry == nil {
                        unlockSkill()
                    }
                default:
                    break
                }
            } else {
                // No selection
                if let _ = carry {
                    dropCarriedContent()
                }
            }
            
        case .right:
            if let selection = selection {
                // Selection is active
                switch selection {
                case .backpack:
                    if carry == nil {
                        discardSelection()
                    }
                default:
                    break
                }
            } else {
                // No selection
            }
            
        default:
            break
        }
    }
    
    /// Handles mouse entered events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseEnteredEvent(_ event: MouseEvent) {
        if let data = event.data as? CharacterTrackingData {
            if let selection = selection { unselectEntry(selection) }
            selectEntry(data)
        }
    }
    
    /// Handles mouse exited events.
    ///
    /// - Parameter event: The event.
    ///
    private func mouseExitedEvent(_ event: MouseEvent) {
        if let data = event.data as? CharacterTrackingData {
            unselectEntry(data)
        }
    }
    
    /// Handles keyboard key down events.
    ///
    /// - Parameter event: The event.
    ///
    private func keyDownEvent(_ event: KeyboardEvent) {
        guard let mapping = KeyboardMapping.mappingFor(keyCode: event.keyCode, modifiers: event.modifiers)
            else { return }

        if mapping.contains(.back) {
            let _ = SceneManager.switchToScene(ofKind: .level)
        }
    }
}

/// A struct that defines the data associated with the `CharacterMenu` class.
///
fileprivate struct CharacterMenuData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Detail.emptyPortraitImage,
                Detail.separatorImage,
                Detail.backgroundImage,
                Item.separatorImage,
                Item.backpackImage,
                Item.emptyIconImage,
                Item.backgroundImage,
                Skill.separatorImage,
                Skill.emptyIconImage,
                Skill.lockImage,
                Skill.backgroundImage,
                Option.primaryButtonImage,
                Option.secondaryButtonImage,
                Option.regularKeyImage,
                Option.wideKeyImage]
    }
    
    /// The horizontal offset to apply between each element.
    ///
    static let elementXOffset: CGFloat = 30.0
    
    /// The vertical offset to apply between each element.
    ///
    static let elementYOffset: CGFloat = 40.0
    
    private init() {}
    
    /// The data to use for the `UIDetailElement`.
    ///
    struct Detail {
        private init() {}
        static let entryCount = 17
        static let contentOffset: CGFloat = 6.0
        static let topLabelSize = CGSize(width: 214.0, height: 16.0)
        static let middleLabelSize = CGSize(width: 256.0, height: 18.0)
        static let bottomLabelSize = CGSize(width: 208.0, height: 26.0)
        static let emptyPortraitImage = "UI_Default_Empty_Portrait"
        static let separatorImage = "UI_Default_Separator"
        static let backgroundImage = "UI_Default_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat =  10.0
    }
    
    /// The data to use for the `UIItemElement`.
    ///
    struct Item {
        private init() {}
        static let equipmentCount = 6
        static let backpackColumns = 10
        static let backpackRows = 9
        static let equipmentSlotOffset: CGFloat = 4.0
        static let backpackSlotOffset: CGFloat = 4.0
        static let contentOffset: CGFloat = 6.0
        static let subtitleLabelSize: CGSize = CGSize(width: 172.0, height: 34.0)
        static let bottomLabelSize = CGSize(width: 208.0, height: 26.0)
        static let separatorImage = "UI_Default_Separator"
        static let backpackImage = "UI_Backpack"
        static let emptyIconImage = "UI_Default_Item_Empty_Icon"
        static let backgroundImage = "UI_Default_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat = 10.0
    }
    
    /// The data to use for the `UISkillElement`.
    ///
    struct Skill {
        private init() {}
        static let entryCount = 10
        static let entryOffset: CGFloat = 6.0
        static let contentOffset: CGFloat = 6.0
        static let subtitleLabelSize = CGSize(width: 172.0, height: 34.0)
        static let entryLabelSize = CGSize(width: 212.0, height: 39.0)
        static let pointsLabelSize = CGSize(width: 208.0, height: 26.0)
        static let separatorImage = "UI_Default_Separator"
        static let emptyIconImage = "UI_Default_Skill_Empty_Icon"
        static let lockImage = "UI_Lock"
        static let backgroundImage = "UI_Default_Background_8p"
        static let backgroundBorder = UIBorder(width: 8.5)
        static let backgroundOffset: CGFloat = 10.0
    }
    
    /// The data to use for the `UIOptionElement`.
    ///
    struct Option {
        private init() {}
        static let size = CGSize(width: 1280.0, height: 60.0)
        static let entryOffset: CGFloat = 38.0
        static let contentOffset: CGFloat = 6.0
        static let primaryButtonImage = "UI_Primary_Mouse_Button"
        static let secondaryButtonImage = "UI_Secondary_Mouse_Button"
        static let regularKeyImage = "UI_Keyboard_Key"
        static let wideKeyImage = "UI_Wide_Keyboard_Key"
    }
    
    /// The data to use for the `UITitleElement`.
    ///
    struct Title {
        private init() {}
        static let title = "CHARACTER"
        static let maxSize = CGSize(width: 272.0, height: 60.0)
        static let backgroundImage: String? = nil
        static let backgroundBorder: UIBorder? = nil
    }
}
