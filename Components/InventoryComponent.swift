//
//  InventoryComponent.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 12/24/17.
//  Copyright © 2017 Gustavo C. Viegas. All rights reserved.
//

import SpriteKit
import GameplayKit

/// A component that provides an entity with an inventory to store items.
///
/// - Note: If the entity that owns this component has an `EquipmentComponent`,
///   items that are completely removed from the inventory will also be unequipped
///   in the `EquipmentComponent`. Thus, if the item is intended to persist after
///   being removed, a reference to it must be kept somewhere else.
///
class InventoryComponent: Component {
    
    /// The maximum capacity for any inventory.
    ///
    static let maxCapacity = 100
    
    private var equipmentComponent: EquipmentComponent? {
        return entity?.component(ofType: EquipmentComponent.self)
    }
    
    /// The internal inventory array.
    ///
    private var inventory: [Item?]
    
    /// The amount of non-`nil` items in the inventory, ignoring stacks.
    ///
    private var totalItems: Int
    
    /// The maximum amount of items allowed in the inventory, ignoring stacks.
    ///
    let capacity: Int
    
    /// Returns the amount of items stored in the inventory, ignoring stacks.
    ///
    var count: Int {
        return totalItems
    }
    
    /// Returns `true` if the inventory does not hold any items, `false` otherwise.
    ///
    var isEmpty: Bool {
        return totalItems == 0
    }
    
    /// Returns `true` if the inventory cannot accept new items, `false` otherwise.
    ///
    /// Note that even if `isFull` is `true`, items may yet have their own stacks
    /// increased.
    ///
    var isFull: Bool {
        return totalItems == capacity
    }
    
    /// All the items held, with their indices in the inventory as key.
    ///
    var items: [Int: Item] {
        var validItems: [Int: Item] = [:]
        if !isEmpty {
            for (index, item) in inventory.enumerated() {
                if item != nil {
                    validItems[index] = item
                }
            }
        }
        return validItems
    }
    
    /// Creates a new instance with the given capacity and holding the given items.
    ///
    /// - Parameters:
    ///   - capacity: The maximum amount of items allowed in the inventory.
    ///   - items: The items to start the inventory with.
    ///
    init(capacity: Int, items: [Item]) {
        assert(capacity > 0)
        
        self.capacity = min(capacity, InventoryComponent.maxCapacity)
        self.inventory = Array(repeating: nil, count: capacity)
        self.totalItems = 0
        
        super.init()
        
        for item in items {
            let _  = addItem(item)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Replaces the whole contents with the given inventory data.
    ///
    /// - Note: The inventory component's capacity is immutable. Thus, any out of bounds elements
    ///   in the `contents` list will be ignored, and if the `contents` list has fewer elements than
    ///   `capacity`, the remaining slots will be set empty.
    ///
    /// - Parameter contents: A list of items to use as replacement. The index of this list will
    ///   match the new inventory index. `nil` values may be used to represent empty inventory slots.
    ///
    func replaceWhole(with contents: [Item?]) {
        totalItems = 0
        let oldInventory = inventory
        inventory = Array(repeating: nil, count: capacity)
        
        for item in oldInventory where item != nil {
            equipmentComponent?.didRemoveItemFromInventory(item!)
        }

        var instances = Set<ObjectIdentifier>()
        for i in 0..<min(contents.count, capacity) {
            guard let item = contents[i], instances.insert(ObjectIdentifier(item)).inserted else { continue }
            inventory[i] = item
            totalItems += 1
        }
        
        broadcast()
    }
    
    /// Searches the inventory for an item with the given name.
    ///
    /// - Parameter name: The name of the item to search for.
    /// - Returns: The first item with the given name contained in the inventory,
    ///   or `nil` if not found.
    ///
    func itemNamed(itemNamed name: String) -> Item? {
        return inventory.first(where: { $0 != nil && $0!.name == name }) ?? nil
    }
    
    /// Searches for the item currently occuping a given index of the inventory.
    ///
    /// - Parameter index: The index to search at.
    /// - Returns: The item at the given index of the array, or nil if there is no item at this index.
    ///
    func itemAt(index: Int) -> Item? {
        guard (!isEmpty) && (index >= 0 && index < inventory.endIndex) else { return nil }
        return inventory[index]
    }
    
    /// Searches the inventory for the index of a given `Item` instance.
    ///
    /// - Parameter item: The `Item` instance to search for.
    /// - Returns: The index of the given item in the inventory, or `nil` if not found.
    ///
    func indexOf(item: Item) -> Int? {
        return inventory.firstIndex(where: { $0 === item })
    }
    
    /// Searches the inventory for the index of an item with the given name.
    ///
    /// - Parameter name: The name of the item to search for.
    /// - Returns: The first index found that contains an item with the given name,
    ///   or `nil` if not found.
    ///
    func indexOf(itemNamed name: String) -> Int? {
        return inventory.firstIndex(where: { $0?.name == name })
    }
    
    /// Checks if the given item instance is contained in the inventory.
    ///
    /// - Parameter item: The item instance to check.
    /// - Returns: `true` if the inventory contains the given item, `false` otherwise.
    ///
    func hasItem(_ item: Item) -> Bool {
        guard !isEmpty else { return false }
        return inventory.contains(where: { $0 === item })
    }
    
    /// Checks if an item with the given name is contained in the inventory.
    ///
    /// - Parameter name: The item name to check.
    /// - Returns: `true` if the inventory contains at last one item with the given name,
    ///   `false` otherwise.
    ///
    func hasItem(named name: String) -> Bool {
        guard !isEmpty else { return false }
        return inventory.contains(where: { $0?.name == name })
    }
    
    /// Moves an item in the inventory.
    ///
    /// - Note: If `indexB` also contains an item, the items will swap places.
    ///
    /// - Parameters:
    ///   - indexA: The index of the item to move.
    ///   - indexB: The index to which the item should be moved.
    /// - Returns: `true` if the item could be moved, `false` if there was no item to move,
    ///   `indexA` and `indexB` are the same or either index was out of range.
    ///
    func moveItem(from indexA: Int, to indexB: Int) -> Bool {
        guard indexA != indexB,
            (0..<inventory.count).contains(indexA),
            (0..<inventory.count).contains(indexB),
            let itemA = inventory[indexA]
            else { return false }
        
        let itemB = inventory[indexB]
        inventory[indexB] = itemA
        inventory[indexA] = itemB
        return true
    }
    
    /// Moves one item stack to another's.
    ///
    /// - Parameters:
    ///   - indexA: The index of the item to pop stack content.
    ///   - indexB: The index of the item to push stack content.
    /// - Returns: A `(Bool, Int)` tuple where the first value states if the items are stackable,
    ///   while the second value holds the amount of stack transfered. Note that `(true, 0)` may be
    ///   returned when the items are stackable but the destination's stack is full.
    ///
    func moveStack(from indexA: Int, to indexB: Int) -> (isStackable: Bool, amountMoved: Int) {
        guard indexA != indexB,
            (0..<inventory.count).contains(indexA),
            (0..<inventory.count).contains(indexB),
            let itemA = inventory[indexA] as? StackableItem,
            let itemB = inventory[indexB] as? StackableItem,
            itemA.name == itemB.name
            else { return (false, 0) }
        
        let amountMoved = itemB.stack.push(amount: itemA.stack.count)
        
        if amountMoved == itemA.stack.count {
            inventory[indexA] = nil
            totalItems -= 1
            equipmentComponent?.didRemoveItemFromInventory(itemA)
        } else {
            let _ = itemA.stack.pop(amount: amountMoved)
        }
        
        broadcast()
        return (true, amountMoved)
    }
    
    /// Reduces an item's stack count.
    ///
    /// - Parameters:
    ///   - index: The index of the item to reduce stack count.
    ///   - quantity: The quantity to reduce.
    /// - Returns: The amount of stack reduced, or `nil` if the item is not stackable or there's no
    ///   item at the given index.
    ///
    func reduceStack(at index: Int, quantity: Int) -> Int? {
        guard
            (0..<inventory.count).contains(index),
            let item = inventory[index] as? StackableItem
            else { return nil }
        
        let amountReduced: Int
        if item.stack.count <= quantity {
            amountReduced = item.stack.count
            inventory[index] = nil
            totalItems -= 1
            equipmentComponent?.didRemoveItemFromInventory(item)
        } else {
            amountReduced = item.stack.pop(amount: quantity)
        }
        
        if amountReduced > 0 { broadcast() }
        return amountReduced
    }
    
    /// Adds a new item to the inventory.
    ///
    /// - Note: Items where `stack.count` > 1 may be only partially added. In such cases, the amount added
    ///   is returned and the specific `item` instance is not inserted in the inventory - instead, one or
    ///   more items of the same type have their stacks increased, while the original `item` has its own
    ///   stack decreased.
    ///
    /// - Parameters:
    ///   - item: The item to add.
    ///   - index: An optional index specifying the exactly place in the inventory to insert the item.
    /// - Returns: `1` if a stack-less item was successfully added, the amount that could be added for items
    ///   that have a stack, or `0` if the inventory was full, the specified index was not available or the
    ///   `item` instance was already in the inventory.
    ///
    func addItem(_ item: Item, at index: Int? = nil) -> Int {
        guard !hasItem(item) else { return 0 }
        
        var totalAdded = 0
        
        if let item = item as? StackableItem {
            if let index = index {
                guard index >= 0 && index < inventory.endIndex else { return 0 }
                if let heldItem = inventory[index] {
                    guard heldItem.name == item.name else { return 0 }
                    let added = (heldItem as! StackableItem).stack.push(amount: item.stack.count)
                    totalAdded = item.stack.pop(amount: added)
                } else {
                    inventory[index] = item
                    totalItems += 1
                    totalAdded = item.stack.count
                }
            } else {
                var count = item.stack.count
                for heldItem in inventory where (heldItem != nil) && (heldItem!.name == item.name) {
                    let added = (heldItem as! StackableItem).stack.push(amount: count)
                    totalAdded += item.stack.pop(amount: added)
                    count -= added
                    if count == 0 { break }
                }
                if count > 0 && !isFull {
                    inventory[inventory.firstIndex(where: { $0 == nil })!] = item
                    totalItems += 1
                    totalAdded += item.stack.count
                }
            }
        } else {
            guard !isFull else { return 0 }
            if let index = index {
                guard (index >= 0 && index < inventory.endIndex) && (inventory[index] == nil) else { return 0 }
                inventory[index] = item
            } else {
                inventory[inventory.firstIndex(where: { $0 == nil })!] = item
            }
            totalItems += 1
            totalAdded = 1
        }
        
        if totalAdded > 0 { broadcast() }
        return totalAdded
    }
    
    /// Removes the given item instance from the inventory.
    ///
    /// - Parameters:
    ///   - item: The item to remove.
    ///   - ignoreStack: A flag indicating that the search should ignore the `item`'s stack count
    ///     and remove the `item` altogether. The default value is `false`.
    /// - Returns: `true` if the item was removed, `false` if the item was not found in the inventory.
    ///
    func removeItem(_ item: Item, ignoreStack: Bool = false) -> Bool {
        guard !isEmpty else { return false }
        guard let index = inventory.firstIndex(where: { $0 === item }) else { return false }
        return removeItem(at: index, ignoreStack: ignoreStack)
    }
    
    /// Removes an item with the given name from the inventory.
    ///
    /// - Parameters:
    ///   - name: The name of the item to remove.
    ///   - ignoreStack: A flag indicating that the search should ignore the `item`'s stack count
    ///     and remove the `item` altogether. The default value is `false`.
    /// - Returns: `true` if the item was removed, `false` if the item was not found in the inventory.
    ///
    func removeItem(named name: String, ignoreStack: Bool = false) -> Bool {
        guard !isEmpty else { return false }
        guard let index = inventory.firstIndex(where: { $0?.name == name }) else { return false }
        return removeItem(at: index, ignoreStack: ignoreStack)
    }
    
    /// Removes the item found at the given index, if any.
    ///
    /// - Parameters:
    ///   - index: The index of the item to remove.
    ///   - ignoreStack: A flag indicating that the search should ignore the `item`'s stack count
    ///     and remove the `item` altogether. The default value is `false`.
    /// - Returns: `true` if the item was removed, `false` if there was no item at the given index.
    ///
    func removeItem(at index: Int, ignoreStack: Bool = false) -> Bool {
        guard (!isEmpty) && (index >= 0 && index < inventory.endIndex) else { return false }
        
        if let _ = inventory[index] {
            if !ignoreStack, let stack = (inventory[index] as? StackableItem)?.stack, stack.count > 1 {
                let _ = (inventory[index] as! StackableItem).stack.pop()
            } else {
                let removedItem = inventory[index]!
                inventory[index] = nil
                totalItems -= 1
                equipmentComponent?.didRemoveItemFromInventory(removedItem)
            }
            broadcast()
            return true
        }
        return false
    }
    
    /// Removes multiple items with the given name from the inventory.
    ///
    /// - Parameters:
    ///   - name: The name of the items to remove.
    ///   - quantity: The maximum amount of items to remove.
    ///   - ignoreStack: A flag indicating that the search should ignore the `item`'s stack count
    ///     and remove the `item`s altogether. The default value is `false`.
    /// - Returns: The amount of items removed.
    ///
    func removeMany(itemsNamed name: String, quantity: Int, ignoreStack: Bool = false) -> Int {
        guard quantity > 0, !isEmpty else { return 0 }
        
        var removed = 0
        if ignoreStack {
            for i in 0..<inventory.count where inventory[i] != nil {
                if inventory[i]!.name == name {
                    let removedItem = inventory[i]!
                    inventory[i] = nil
                    totalItems -= 1
                    equipmentComponent?.didRemoveItemFromInventory(removedItem)
                    removed += 1
                    if removed == quantity { break }
                }
            }
        } else {
            for i in 0..<inventory.count where inventory[i] != nil {
                if inventory[i]!.name == name {
                    if !(inventory[i]! is StackableItem) || (inventory[i]! as! StackableItem).stack.count == 1 {
                        let removedItem = inventory[i]!
                        inventory[i] = nil
                        totalItems -= 1
                        equipmentComponent?.didRemoveItemFromInventory(removedItem)
                        removed += 1
                    } else {
                        let count = (inventory[i]! as! StackableItem).stack.count
                        if count + removed <= quantity {
                            let removedItem = inventory[i]!
                            inventory[i] = nil
                            totalItems -= 1
                            equipmentComponent?.didRemoveItemFromInventory(removedItem)
                            removed += count
                        } else {
                            removed += (inventory[i]! as! StackableItem).stack.pop(amount: quantity - removed)
                        }
                    }
                    if removed == quantity { break }
                }
            }
        }
        
        if removed > 0 { broadcast() }
        return removed
    }
    
    /// Removes all items with the given name from the inventory.
    ///
    /// - Parameter name: The name of the items to remove.
    ///
    func removeAll(itemsNamed name: String) {
        let _ = removeMany(itemsNamed: name, quantity: totalItems, ignoreStack: true)
    }
    
    /// Checks the amount of items, with the given name, contained in the inventory.
    ///
    /// - Parameters:
    ///   - name: The name of the items to check.
    ///   - ignoreStack: A flag indicating if the search should ignore the `item`'s stack count.
    ///     The default value is `false`.
    /// - Returns: The quantity of the given item present in the inventory.
    ///
    func quantityOf(itemsNamed name: String, ignoreStack: Bool = false) -> Int {
        guard !isEmpty else { return 0 }
        
        var quantity = 0
        if ignoreStack {
            for item in inventory where item != nil && item!.name == name {
                quantity += 1
            }
        } else {
            for item in inventory where item != nil && item!.name == name {
                quantity += (item! as? StackableItem)?.stack.count ?? 1
            }
        }
        
        return quantity
    }
    
    /// Merges the stacks of items with the given name, possibly freeing up
    /// inventory space.
    ///
    /// - Parameter name: The name of the items to merge.
    ///
    func mergeStacks(itemsNamed name: String) {
        guard let index = inventory.firstIndex(where: { $0?.name == name }) else { return }
        guard var currentItem = inventory[index] as? StackableItem else { return }
        
        for i in (index + 1)..<inventory.count {
            if let otherItem = inventory[i], otherItem.name == name {
                let otherItem = otherItem as! StackableItem
                let toAdd = otherItem.stack.pop(amount: currentItem.stack.capacity - currentItem.stack.count)
                let _ = currentItem.stack.push(amount: toAdd)
                if otherItem.stack.count == 0 {
                    inventory[i] = nil
                    totalItems -= 1
                }
                if currentItem.stack.isFull {
                    if otherItem.stack.count == 0 {
                        if let next = inventory.firstIndex(where: { $0?.name == name }) {
                            currentItem = inventory[next]! as! StackableItem
                        } else {
                            return
                        }
                    } else {
                        currentItem = otherItem
                    }
                }
            }
        }
    }
    
    /// Checks if it is possible to add a given amount to the inventory by only increasing
    /// the stacks of existing items, without creating new entries.
    ///
    /// - Parameters:
    ///   - name: The name of the items to check.
    ///   - quantity: The increase amount to check.
    /// - Returns: `true` if the stacks of existing items can be increased, `false` otherwise.
    ///
    func canStack(itemNamed name: String, quantity: Int) -> Bool {
        guard quantity > 0 && hasItem(named: name) else { return false}
        
        var count = 0
        for (_, item) in items where item.name == name {
            if let stack = (item as? StackableItem)?.stack {
                count += stack.capacity - stack.count
                if count >= quantity {
                    return true
                }
            }
        }
        return false
    }
    
    /// Checks if it is possible to reduce inventory space by only merging
    /// the stacks of existing items.
    ///
    /// - Parameters:
    ///   - name: The name of the items to check.
    ///   - amount: An amount to subtract from the total before validation.
    /// - Returns: `true` if merging would free up space, `false` otherwise.
    ///
    func canReduceSpace(itemNamed name: String, decreasingBy amount: Int) -> Bool {
        guard amount >= 0, let index = indexOf(itemNamed: name) else { return false }
        guard let capacity = (inventory[index] as? StackableItem)?.stack.capacity else { return false }
        
        var count = (inventory[index] as! StackableItem).stack.count - amount
        guard count > 0 else { return true }
        
        for i in (index + 1)..<inventory.count {
            if let otherItem = inventory[i], otherItem.name == name {
                let stack = (otherItem as! StackableItem).stack
                if stack.count <= (capacity - count) {
                    return true
                } else {
                    count = stack.count - (capacity - count)
                }
            }
        }
        return false
    }
}
