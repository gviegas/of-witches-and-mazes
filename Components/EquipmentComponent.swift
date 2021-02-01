//
//  EquipmentComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/24/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that enables an entity to equip items.
///
class EquipmentComponent: Component {
    
    /// The maximum number of items allowed to be equipped at once.
    ///
    static let maxItems = 6
    
    private var inventoryComponent: InventoryComponent {
        guard let component = entity?.component(ofType: InventoryComponent.self) else {
            fatalError("An entity with an EquipmentComponent must also have an InventoryComponent")
        }
        return component
    }
    
    /// The equipped items.
    ///
    private var items: [Item?]
    
    /// Creates a nem instance from the given values.
    ///
    /// - Note: This initializer does not check if the items can be equipped based
    ///   on game rules.
    ///
    /// - Parameter items: A list of items to equip. The default value is an empty array, which
    ///   means that no items will be equipped on creation. The maximum number of items that can be
    ///   equipped is given by `EquipmentComponent.maxItems`.
    ///
    init(items: [Item] = []) {
        assert(items.count <= EquipmentComponent.maxItems && EquipmentComponent.maxItems > 0)
        
        self.items = Array(repeating: nil, count: EquipmentComponent.maxItems)
        self.items.replaceSubrange(0..<items.count, with: items)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Retrieves the first equipped item of the given category.
    ///
    /// - Parameter category: The category of the item to retrieve.
    /// - Returns: The first `Item` found having the given category, or `false` if no item
    ///   of this category is equipped.
    ///
    func itemOf(category: ItemCategory) -> Item? {
        return items.first { $0?.category == category } ?? nil
    }
    
    /// Retrieves the equipped item found at the given index.
    ///
    /// The valid indices range from 0 to `maxItems - 1`.
    ///
    /// - Parameter index: The index of the item to retrieve.
    /// - Returns: The `Item` found at the given index, or `false` if no item
    ///   is equipped at `index` or `index` is out of range.
    ///
    func itemAt(index: Int) -> Item? {
        guard index >= 0 && index < items.count else { return nil }
        return items[index]
    }
    
    /// Retrieves the index of the given equipped item.
    ///
    /// - Parameter item: The item which index is to be retrieved.
    /// - Returns: The index where the item is found, or `nil` if the given item is not equipped.
    ///
    func indexOf(item: Item) -> Int? {
        return items.firstIndex(where: { $0 === item })
    }
    
    /// Sets the given `Item` instance in the given index, replacing any item
    /// found at `index`.
    ///
    /// The valid indices range from 0 to `maxItems - 1`.
    ///
    /// - Parameters:
    ///   - item: The `Item` to set.
    ///   - index: The index where the item must be set.
    /// - Returns: The `Item` being replaced, or `nil` if `index` does not hold
    ///   any items, `index` is out of range or the item is not equippable.
    ///
    func equip(item: Item, at index: Int) -> Item? {
        guard item.isEquippable, (0..<items.count).contains(index) else { return nil }
        let oldItem = items[index]
        items[index] = item
        if let entity = entity as? Entity {
            (oldItem as? PassiveItem)?.didUnequip(onEntity: entity)
            (item as? PassiveItem)?.didEquip(onEntity: entity)
        }
        broadcast()
        return oldItem
    }
    
    /// Removes the given `Item` instance from the equipped items.
    ///
    /// - Parameter item: The `Item` instance to remove.
    /// - Returns: The index from which the given `item` was removed, or `nil` if
    ///   this specific instance was not equipped.
    ///
    func unequip(item: Item) -> Int? {
        if let index = items.firstIndex(where: { $0 === item }) {
            items[index] = nil
            if let entity = entity as? Entity {
                (item as? PassiveItem)?.didUnequip(onEntity: entity)
            }
            broadcast()
            return index
        }
        return nil
    }
    
    /// Removes the item found at the given index.
    ///
    /// The valid indices range from 0 to `maxItems - 1`.
    ///
    /// - Parameter index: The index where the item must be removed.
    /// - Returns: The given `Item` instance that was removed, or `nil` if `index`
    ///   does not hold an item or `index` is out of range.
    ///
    func unequip(at index: Int) -> Item? {
        guard index >= 0 && index < items.count else { return nil }
        if let item = items[index] {
            items[index] = nil
            if let entity = entity as? Entity {
                (item as? PassiveItem)?.didUnequip(onEntity: entity)
            }
            broadcast()
            return item
        }
        return nil
    }
    
    /// Removes an item with the given name.
    ///
    /// - Parameter name: The name of the item to be removed.
    /// - Returns: The given `Item` instance that was removed, or `nil` if no item
    ///   with the given name is equipped.
    ///
    func unequip(itemNamed name: String) -> Item? {
        if let index = items.firstIndex(where: { $0?.name == name }) {
            let item = items[index]
            items[index] = nil
            if let entity = entity as? Entity {
                (item as? PassiveItem)?.didUnequip(onEntity: entity)
            }
            broadcast()
            return item
        }
        return nil
    }
    
    /// Checks if a given `Item` instance is currently equipped.
    ///
    /// - Parameter item: The `Item` instance to check.
    /// - Returns: `true` if the given `Item` instance is equipped, `false` otherwise.
    ///
    func isEquipped(_ item: Item) -> Bool {
        for equippedItem in items where equippedItem != nil {
            if equippedItem === item { return true }
        }
        return false
    }
    
    /// Checks if an item with the given name is currently equipped.
    ///
    /// - Parameter name: The name of the item to check.
    /// - Returns: `true` if an item with the given name is equipped, `false` otherwise.
    ///
    func isEquipped(itemNamed name: String) -> Bool {
        for equippedItem in items where equippedItem != nil {
            if equippedItem?.name == name { return true }
        }
        return false
    }
    
    /// Checks if a given `Item` instance can be equipped, based on game rules.
    ///
    /// - Parameters:
    ///   - item: The `Item` instance to check.
    ///   - index: An optional index of where the item would be placed. This parameter is useful
    ///     when items of the same category are meant to swap places. When set to `nil`, no specific
    ///     index is checked.
    /// - Returns: `true` if the given `Item` instance can be equipped, `false` otherwise.
    ///
    func canEquip(_ item: Item, at index: Int?) -> Bool {
        guard item.isEquippable else { return false }
        
        var flag = true
        
        // Check the category
        if !item.category.canEquipMany {
            for equippedItem in items {
                if equippedItem?.category == item.category {
                    flag = isEquipped(item)
                    break
                }
            }
            if !flag, let index = index {
                assert((0..<items.count).contains(index))
                if let otherItem = items[index], item.category == otherItem.category { flag = true }
            }
        }
        
        // Check the required level
        if flag,
            let requiredLevel = (item as? LevelItem)?.requiredLevel,
            let levelOfExperience = entity?.component(ofType: ProgressionComponent.self)?.levelOfExperience,
            requiredLevel > levelOfExperience {
            
            flag = false
        }
        
        return flag
    }
    
    /// Updates the equipped items to reflect any removals in the entity's `InventoryComponent`.
    ///
    /// - Note: This method should be called by the entity's `InventoryComponent` only.
    ///
    /// - Parameter item: The item removed from the inventory.
    ///
    func didRemoveItemFromInventory(_ item: Item) {
        guard let index = indexOf(item: item) else { return }
        
        if item is StackableItem,  let otherInstance = inventoryComponent.itemNamed(itemNamed: item.name) {
            let _ = equip(item: otherInstance, at: index)
        } else {
            let _ = unequip(at: index)
        }
    }
    
    override func didAddToEntity() {
        guard let entity = entity as? Entity else { return }
        
        for item in items {
            if let passiveItem = item as? PassiveItem {
                passiveItem.didEquip(onEntity: entity)
            }
        }
    }
    
    override func willRemoveFromEntity() {
        guard let entity = entity as? Entity else { return }
        
        for item in items {
            if let passiveItem = item as? PassiveItem {
                passiveItem.didUnequip(onEntity: entity)
            }
        }
    }
}
