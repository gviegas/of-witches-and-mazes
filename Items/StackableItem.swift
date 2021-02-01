//
//  StackableItem.swift
//  Of Witches and Mazes
//
//  Created by Gustavo C. Viegas on 11/26/18.
//  Copyright © 2018 Gustavo C. Viegas. All rights reserved.
//

import Foundation

/// A struct that defines an item stack, used to manage stackable items.
///
struct ItemStack {
    
    /// The mutable stack count.
    ///
    private var _count: Int
    
    /// The stack capacity.
    ///
    let capacity: Int
    
    /// The stack count.
    ///
    var count: Int {
        return _count
    }
    
    /// Returns `true` if the stack is full, `false` otherwise.
    ///
    var isFull: Bool {
        return _count == capacity
    }
    
    /// Adds a given amount to the stack.
    ///
    /// - Parameter amount: The amount to add. The default value is `1`.
    /// - Returns: The amount added.
    ///
    mutating func push(amount: Int = 1) -> Int {
        guard amount > 0 else { return 0 }
        
        let total = min(_count + amount, capacity)
        let added = total - _count
        _count = total
        return added
    }
    
    /// Removes a given amount from the stack.
    ///
    /// - Parameter amount: The amount to remove. The default value is `1`.
    /// - Returns: The amount removed.
    ///
    mutating func pop(amount: Int = 1) -> Int {
        guard amount > 0 else { return 0 }
        
        let total = max(_count - amount, 0)
        let removed = _count - total
        _count = total
        return removed
    }
    
    /// Creates a new instance from the given capacity and count values.
    ///
    /// - Parameters:
    ///   - capacity: The stack's maximum amount.
    ///   - count: The stack's current amount.
    ///
    init(capacity: Int, count: Int) {
        assert(capacity >= count && count >= 0)
        
        self.capacity = capacity
        self._count = count
    }
}

/// A protocol that defines an `Item` type that can be stacked.
///
/// - Note: Stackable items should be identical - items that have random values must not stack together.
///
protocol StackableItem: Item {
    
    /// The capacity of the stack.
    ///
    /// - Note: This value must never change, even when the `stack` is set to a different value.
    ///
    static var capacity: Int { get }
    
    /// The `ItemStack`.
    ///
    /// - Note: The `stack`'s `capacity` property must never change, even when the `stack` is set
    ///   to a different value.
    ///
    var stack: ItemStack { get set }
    
    /// Creates a new instance holding the given quantity.
    ///
    /// - Parameter quantity: The quantity.
    ///
    init(quantity: Int)
    
    /// Creates a new copy of the item with the given stack count.
    ///
    /// - Parameter stackCount: The stack count for the copy. If higher than the stack's capacity,
    ///   the copy is made with no changes.
    ///
    func copy(stackCount: Int) -> Item
}
