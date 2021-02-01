//
//  CharacterOverlay.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 7/1/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit

/// An `Overlay` type that displays protagonist information on a `Level` instance.
///
class CharacterOverlay: Overlay, Observer, TextureUser {
    
    static var textureNames: Set<String> {
        return CharacterOverlayData.textureNames
    }
    
    let node: SKNode
    
    private var entity: Entity? {
        return Game.protagonist
    }
    
    private var portraitComponent: PortraitComponent? {
        return entity?.component(ofType: PortraitComponent.self)
    }
    
    private var abilityComponent: AbilityComponent? {
        return entity?.component(ofType: AbilityComponent.self)
    }
    
    private var healthComponent: HealthComponent? {
        return entity?.component(ofType: HealthComponent.self)
    }
    
    private var conditionComponent: ConditionComponent? {
        return entity?.component(ofType: ConditionComponent.self)
    }
    
    private var equipmentComponent: EquipmentComponent? {
        return entity?.component(ofType: EquipmentComponent.self)
    }
    
    private var inventoryComponent: InventoryComponent? {
        return entity?.component(ofType: InventoryComponent.self)
    }
    
    private var skillComponent: SkillComponent? {
        return entity?.component(ofType: SkillComponent.self)
    }
    
    private var personaComponent: PersonaComponent? {
        return entity?.component(ofType: PersonaComponent.self)
    }
    
    /// The `UICharacterElement` instance.
    ///
    private let characterElement: UICharacterElement
    
    /// The size of the overlay.
    ///
    var size: CGSize {
        return characterElement.size
    }
    
    /// Creates a new instance inside the given rect.
    ///
    /// - Parameter rect: The bounding rect.
    ///
    init(rect: CGRect) {
        node = SKNode()
        node.zPosition = DepthLayer.overlays.lowerBound
        
        assert(Game.protagonist != nil)
        
        // Create the character element
        characterElement = UICharacterElement(itemEmptyIconImage: CharacterOverlayData.Character.itemEmptyIconImage,
                                              skillEmptyIconImage: CharacterOverlayData.Character.skillEmptyIconImage,
                                              emptyPortraitImage: CharacterOverlayData.Character.emptyPortraitImage,
                                              nameBarImage: CharacterOverlayData.Character.nameBarImage,
                                              healthBarImage: CharacterOverlayData.Character.healthBarImage,
                                              healthImage: CharacterOverlayData.Character.healthImage,
                                              itemShortcutImage: CharacterOverlayData.Character.itemShortcutImage,
                                              skillShortcutImage: CharacterOverlayData.Character.skillShortcutImage,
                                              itemCount: CharacterOverlayData.Character.itemCount,
                                              skillCount: CharacterOverlayData.Character.skillCount,
                                              healthWidth: CharacterOverlayData.Character.healthWidth,
                                              nameSize: CharacterOverlayData.Character.nameSize,
                                              shortcutTextSize: CharacterOverlayData.Character.shortcutTextSize)
        
        // Set the contents
        characterElement.portrait.portrait = portraitComponent?.portrait
        characterElement.nameBar.text = personaComponent?.personaName
        setHealthBar()
        setItems()
        setSkills()
        setShortcuts()
        
        // The character overlay will be placed at the top-left corner of the rect
        let offset = CGPoint(x: 8.0, y: 8.0)
        let overlayRect = CGRect(origin: CGPoint(x: rect.minX + offset.x,
                                                 y: rect.maxY - characterElement.size.height - offset.y),
                                 size: characterElement.size)
        
        // Generate the tree
        let container = UIContainer(plane: .horizontal, ratio: 1.0)
        container.addElement(characterElement)
        let tree = UITree(rect: overlayRect, root: container)
        if let treeNode = tree.generate() {
            treeNode.zPosition = 1
            node.addChild(treeNode)
        }
        
        // Register self as observer
        portraitComponent?.register(observer: self)
        abilityComponent?.register(observer: self)
        healthComponent?.register(observer: self)
        conditionComponent?.register(observer: self)
        equipmentComponent?.register(observer: self)
        inventoryComponent?.register(observer: self)
        skillComponent?.register(observer: self)
        KeyboardMapping.KeyboardMappingObservable.instance.register(observer: self)
    }
    
    /// Sets the contents of the health bar.
    ///
    private func setHealthBar() {
        guard let healthComponent = healthComponent else { return }
        
        let currentHp = healthComponent.currentHP
        let totalHp = healthComponent.totalHp
        characterElement.healthBar.text = "\(currentHp)/\(totalHp)"
        characterElement.healthBar.resizeTo(normalizedValue: CGFloat(currentHp) / CGFloat(totalHp))
    }
    
    /// Sets the contents of the item bar.
    ///
    private func setItems() {
        guard let entity = entity,
            let equipmentComponent = equipmentComponent,
            let inventoryComponent = inventoryComponent
            else { return }
        
        for i in 0..<min(characterElement.itemSlots.count, EquipmentComponent.maxItems) {
            characterElement.itemSlots[i].icon = equipmentComponent.itemAt(index: i)?.icon
            characterElement.itemSlots[i].text = nil
            if let item = equipmentComponent.itemAt(index: i) {
                if item is StackableItem {
                    characterElement.itemSlots[i].text = "\(inventoryComponent.quantityOf(itemsNamed: item.name))"
                } else if let item = item as? ResourceItem {
                    let totalUses = item.computeTotalUses(for: entity)
                    characterElement.itemSlots[i].text = "\(totalUses)"
                }
            }
        }
    }
    
    /// Sets the contents of the skill bar.
    ///
    private func setSkills() {
        guard let skillComponent = skillComponent else { return }
        
        let skills = skillComponent.usableSkills
        for (index, skill) in zip(skills.indices, skills) {
            guard index < characterElement.skillSlots.count else { break }
            
            let slot = characterElement.skillSlots[index]
            if skill.unlocked {
                slot.icon = skill.icon
                if let skill = skill as? ActiveSkill, skill.isActive {
                    slot.darken()
                } else {
                    slot.undarken()
                }
            } else {
                slot.icon = IconSet.Skill.locked
                slot.darken()
            }
        }
        if characterElement.skillSlots.count > skills.count {
            for i in skills.count..<characterElement.skillSlots.count {
                characterElement.skillSlots[i].icon = IconSet.Skill.locked
                characterElement.skillSlots[i].darken()
            }
        }
    }
    
    /// Sets the contents of the keyboard shorcuts.
    ///
    ///
    private func setShortcuts() {
        let itemButtons = [InputButton.item1, InputButton.item2, InputButton.item3, InputButton.item4,
                           InputButton.item5, InputButton.item6]
        let skillButtons = [InputButton.skill1, InputButton.skill2, InputButton.skill3, InputButton.skill4,
                            InputButton.skill5]
        for i in 0..<itemButtons.count {
            guard i < characterElement.itemShortcuts.count else { break }
            characterElement.itemShortcuts[i].key = itemButtons[i]
        }
        for i in 0..<skillButtons.count {
            guard i < characterElement.skillShortcuts.count else { break }
            characterElement.skillShortcuts[i].key = skillButtons[i]
        }
    }
    
    func update(deltaTime seconds: TimeInterval) {
        guard let skillComponent = skillComponent else { return }
        
        // ToDo: Consider tracking the skills current on wait time instead
        let skills = skillComponent.usableSkills
        for (index, skill) in zip(skills.indices, skills) {
            guard index < characterElement.skillSlots.count else { break }
            guard skill.unlocked, let skill = skill as? WaitTimeSkill else { continue }
            
            let (isOnWait, remainingTime) = skillComponent.isSkillOnWaitTime(skill)
            if isOnWait {
                characterElement.skillSlots[index].waitTime = remainingTime
                characterElement.skillSlots[index].darken()
            } else {
                characterElement.skillSlots[index].waitTime = nil
                if let skill = skill as? ActiveSkill, skill.isActive {
                    characterElement.skillSlots[index].darken()
                } else {
                    characterElement.skillSlots[index].undarken()
                }
            }
        }
    }
    
    func didChange(observable: Observable) {
        switch observable {
        case is PortraitComponent:
            characterElement.portrait.portrait = portraitComponent?.portrait
        case is AbilityComponent, is HealthComponent, is ConditionComponent:
            setHealthBar()
        case is SkillComponent:
            setSkills()
            // Some skills may affect item functionally, thus the item bar must be set
            fallthrough
        case is EquipmentComponent, is InventoryComponent:
            setItems()
        case is KeyboardMapping.KeyboardMappingObservable:
            setShortcuts()
        default:
            break
        }
    }
    
    func removeFromAllObservables() {
        portraitComponent?.remove(observer: self)
        abilityComponent?.remove(observer: self)
        healthComponent?.remove(observer: self)
        conditionComponent?.remove(observer: self)
        equipmentComponent?.remove(observer: self)
        inventoryComponent?.remove(observer: self)
        skillComponent?.remove(observer: self)
        KeyboardMapping.KeyboardMappingObservable.instance.remove(observer: self)
    }
}

/// A struct that defines the data associated with the `CharacterOverlay` class.
///
fileprivate struct CharacterOverlayData: TextureUser {
    
    static var textureNames: Set<String> {
        return [Character.itemEmptyIconImage,
                Character.skillEmptyIconImage,
                Character.emptyPortraitImage,
                Character.nameBarImage,
                Character.healthBarImage,
                Character.healthImage,
                Character.itemShortcutImage,
                Character.skillShortcutImage]
    }
    
    private init() {}
    
    /// The `UICharacterElement` data.
    ///
    struct Character {
        private init() {}
        static let itemEmptyIconImage = "UI_Character_Item_Empty_Icon"
        static let skillEmptyIconImage = "UI_Character_Skill_Empty_Icon"
        static let emptyPortraitImage = "UI_Character_Empty_Portrait"
        static let nameBarImage = "UI_Character_Name_Bar"
        static let healthBarImage = "UI_Character_Health_Bar"
        static let healthImage = "UI_Character_Health"
        static let itemShortcutImage = "UI_Character_Keyboard_Shortcut"
        static let skillShortcutImage = "UI_Character_Keyboard_Shortcut"
        static let itemCount = 6
        static let skillCount = 5
        static let healthWidth: CGFloat = 150.0
        static let nameSize: CGSize? = nil
        static let shortcutTextSize = CGSize(width: 34.0, height: 16.0)
    }
}
